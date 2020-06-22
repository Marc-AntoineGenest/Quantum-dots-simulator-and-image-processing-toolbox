function occ_modif = add_avoided_crossing(occ, nVgy, angle, e_n, n_sommet,...
    gates, CC, n1, V_sweep1, n2, V_sweep2,...
    V_oxe, integrand_x, eps_0, x, dx,...
    int_min, int_max, int_length, integral_tab)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Anti-croisement
% Paramètres pour l'anti-croisement
% - nVgy     : hauteur du début du défaut sur l'axe y
% - angle    : angle de la ligne créée par le défaut
% - e_n      : pourcentage de l'énergie d'addition déterminant les limites de
%              l'hyperbole
% - n_sommet : distance entre les sommets des hyperboles face-à-face, en
%              pourcentage de la distance des limites
% 
% nVgy = 0.6;
% angle = -10;
% e_n = 0.3;
% n_sommet = 0.4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Estimation de la taille de la "patch" à coller et calcul du plus grand
% diagramme de stabilité pour assurer toutes les transformations
n_pixel = mean(diff(find(occ(1,:))));
dv1 = mean(diff(V_sweep1));
dv2 = mean(diff(V_sweep2));
V_sweep1_2 = linspace(V_sweep1(1)-n_pixel*dv1, V_sweep1(end)+n_pixel*dv1, length(V_sweep1)+2*n_pixel);
V_sweep2_2 = linspace(V_sweep2(1)-n_pixel*dv2, V_sweep2(end)+n_pixel*dv2, length(V_sweep2)+2*n_pixel);
occupation_2 = calculate_occupation('normal', 1,...
    gates, CC, n1, V_sweep1_2, n2, V_sweep2_2,...
    V_oxe, integrand_x, eps_0, x, dx,...
    int_min, int_max, int_length, integral_tab);
occupation_ligne_2 = derive_occupation(occupation_2);

% Ajouter une ligne de défaut
% - [i0, j0]   : pixel de départ pour la ligne de défaut
% - [i, j]     : à la fin, pixel de fin pour la ligne de défaut
% - dxy, dxy0  : calcul de l'angle de la ligne
% - occ_defect : diagramme de stabilité du défaut
i0 = round(size(occupation_ligne_2, 1)*nVgy, 0);
i = i0;
j0 = 1;
j = j0;
dxy0 = abs(1/tand(angle));
dxy = dxy0 - 1;
occ_defect = zeros(size(occupation_ligne_2));
while i <= size(occupation_ligne_2, 1) && i > 0 && j <= size(occupation_ligne_2, 2)
    occ_defect(i,j) = 1;
    if dxy > 0
        j = round(j + 1, 0);
        dxy = dxy - 1;
    else
        if angle > 0
            i = round(i + 1, 0);
        else
            i = round(i - 1, 0);
        end
        dxy = dxy + dxy0;
    end
%     if i <= size(occupation_ligne_2, 1) && j <= size(occupation_ligne_2, 2)
%         if occupation_ligne_2(i,j) == 1
%             i = i + 5;
%         end
%     end
end

% Trouver les points de rencontre
% - nb_ilots       : nombre de lignes croisées par la ligne de défaut
% - [idx_i, idx_j] : indice des premiers pixels de croisement du défaut
nb_ilots = occupation_2(i,j) - occupation_2(i0,j0);
[idx_i, idx_j] = find((occ_defect + occupation_ligne_2)==2);
m = -1/((idx_i(end) - idx_i(1)) / (idx_j(end) - idx_j(1)));
b = mean([idx_i(1), idx_i(end)]) - m*mean([idx_j(1), idx_j(end)]);
di = -b/m;
if length(idx_i) > nb_ilots
    diff_points = abs(diff(sqrt((idx_i+di).^2+idx_j.^2)));
    [~, idx_points] = sort(diff_points, 'descend');
    idx_points = [1; sort(idx_points(1:nb_ilots-1))+1];
    idx_i = idx_i(idx_points);
    idx_j = idx_j(idx_points);
end
not_to_calc = idx_j < round(n_pixel/2,0) | idx_j > size(occ,2)+round(1.5*n_pixel,0)...
    | idx_i < round(n_pixel/2,0) | idx_i > size(occ,1)+round(1.5*n_pixel,0);
idx_i(not_to_calc) = [];
idx_j(not_to_calc) = [];

occ_modif = occupation_ligne_2 + occ_defect;
for ii = 1:length(idx_i)
    % Trouver les directions des transitions
    % - idx_cercle : indice des croisements du cercle et des lignes
    % - dir_cercle : directions normalisées des 4 segments de droite
    idx_cercle = [];
    for theta = linspace(-pi*2, 3*pi/4, round(pi*n_pixel, 0))
        for r = n_pixel/3:n_pixel/3+1
            i_test = round(idx_i(ii) + r*cos(theta), 0);
            j_test = round(idx_j(ii) + r*sin(theta), 0);
            if occ_modif(i_test, j_test) == 1
                idx_cercle = [idx_cercle; i_test, j_test];
            end
        end
    end
    idx_cercle = unique(idx_cercle, 'rows');
    idx_points = diff(idx_cercle(:,1)).^2 + diff(idx_cercle(:,2)).^2;
    [~, idx_points] = sort(idx_points, 'descend');
    idx_points = [1; sort(idx_points(1:4-1))+1];
    idx_cercle = idx_cercle(idx_points, :);
    dir_cercle = (idx_cercle-[idx_i(ii), idx_j(ii)])./...
        sqrt((idx_cercle(:,1)-idx_i(ii)).^2 + (idx_cercle(:,2)-idx_j(ii)).^2);

    % Trouver la position des limites de l'anticroisement
    % - d_ligne    : longueur du segment à remplacer
    % - idx_approx : estimation des pixels où rattacher l'hyperbole
    % - idx_lim    : indices des pixels où rattacher l'hyperbole
    d_ligne = sqrt((abs(mean(diff(idx_i)))*e_n)^2 + ...
        (abs(mean(diff(idx_j)))*e_n)^2);
    idx_approx = d_ligne*dir_cercle + [idx_i(ii), idx_j(ii)];
    [row, col] = find(occ_modif==1);
    [~, idx_p] = min(abs(sqrt((row' - idx_approx(:,1)).^2 +...
        (col' - idx_approx(:,2)).^2)), [], 2);
    idx_lim = [row(idx_p), col(idx_p)];

    % Séparer les indices en triangles à être modifiés
    % - idx_defect : indices des pixels limites sur la ligne de défaut
    % - idx_trans  : indices des pixels limites sur la ligne de transition
    % - idx_t1     : indices des pixels du premier triangle (supérieur)
    % - idx_t2     : indices des pixels du deuxième triangle (inférieur)
    [row, col] = find(occ_defect==1);
    idx_defect = idx_lim(ismember(idx_lim, [row, col], 'rows'),:);
    if idx_defect(1,1) > idx_defect(2,1)
        idx_defect = flipud(idx_defect);
    end
    [row, col] = find(occupation_ligne_2==1);
    idx_trans = idx_lim(ismember(idx_lim, [row, col], 'rows'),:);
    if idx_trans(1,1) > idx_trans(2,1)
        idx_trans = flipud(idx_trans);
    end
    idx_t1 = [idx_defect(1,:); idx_trans(2,:)];
    idx_t2 = [idx_trans(1,:); idx_defect(2,:)];

    % Tracer l'hyperbole (Steiner generation)
    % - d       : distance entre le croisement et le sommet des hyperboles
    % - angle   : angle de la droite liant les sommets de l'hyperbole
    % - dx_s    : distance en x entre le croisement et le sommet des hyperboles
    % - dy_s    : distanc en y entre le croisement et le somment des hyperboles
    % - A, B, P, V1, V2, Ai, Bi : paramètres pour tracer l'hyperbole
    d = mean(sqrt(sum((idx_t1 - idx_t2).^2, 2)))*n_sommet/2;
    diff_t = abs(diff([idx_t1, idx_t2]));
    angle_norm = mean([atand(diff_t(2)/diff_t(1)), atand(diff_t(4)/diff_t(3))]);
    dx_s = d*abs(sind(angle_norm));
    dy_s = d*abs(cosd(angle_norm));
    n_trace = 75;
    P_triangle = [idx_t1; idx_t2];
    occ_antic = zeros(size(occupation_ligne_2));
    for j = 1:4
        P = P_triangle(j,:);
        if j <= 2
            V1 = round([idx_i(ii)+dx_s, idx_j(ii)+dy_s], 0);
            V2 = round([idx_i(ii)-dx_s, idx_j(ii)-dy_s], 0);
            B = round(mean(idx_t1), 0);
        else
            V1 = round([idx_i(ii)-dx_s, idx_j(ii)-dy_s], 0);
            V2 = round([idx_i(ii)+dx_s, idx_j(ii)+dy_s], 0);
            B = round(mean(idx_t2), 0);
        end
        A = [P(1)-(B(1)-V1(1)), V1(2)-(B(2)-P(2))];
        Ai = [linspace(P(1), A(1), n_trace); linspace(P(2), A(2), n_trace)]';
        Bi = [linspace(P(1), B(1), n_trace); linspace(P(2), B(2), n_trace)]';
        for i = 1:size(Ai,1)
            p1 = (Ai(i,1) - V1(1))/(Ai(i,2) - V1(2));
            p2 = (Bi(i,1) - V2(1))/(Bi(i,2) - V2(2));
            k1 = V1(1) - p1*V1(2);
            k2 = V2(1) - p2*V2(2);
            if isinf(p1) && ~isinf(p2)
                j_intersect = Ai(i,2);
                i_intersect = p2 * j_intersect + k2;
            elseif isinf(p2)
                j_intersect = Bi(i,2);
                i_intersect = p1 * j_intersect + k1;
            else
                j_intersect = (k2-k1)/(p1-p2);
                i_intersect = p1 * j_intersect + k1;
            end
            occ_antic(round(i_intersect, 0), round(j_intersect, 0)) = 1;
        end
    end

    % Remplacer le rectangle (équations paramétriques) de l'anti-croisement
    segments = [[idx_t2(2,:); idx_t1(2,:)],...
        flipud(idx_t1),...
        [idx_t2(1,:); idx_t1(1,:)],...
        flipud(idx_t2)];
    dydx = reshape(segments(2,:)-segments(1,:),2,4);
    pentes = dydx(1,:)./dydx(2,:);
    P = reshape(segments(1,:),2,4);
    ordonnees = P(1,:) - pentes.*P(2,:);
    for i = 1:size(occ_modif,1)
        for j = 1:size(occ_modif,2)
            if i < min(pentes(1:2)*j+ordonnees(1:2)) && i > max(pentes(3:4)*j+ordonnees(3:4))
                occ_modif(i,j) = occ_antic(i,j);
            end
        end
    end
end
occ_modif = occ_modif(1+floor(n_pixel):end-floor(n_pixel),1+floor(n_pixel):end-floor(n_pixel));
