function occ_modif = full_translate(occ, angle, nVgy, nVgx,...
    gates, CC, n1, V_sweep1, n2, V_sweep2,...
    V_oxe, integrand_x, eps_0, x, dx,...
    int_min, int_max, int_length, integral_tab)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Effet d'un piège
% Attention aux angles positifs --> c'est un autre effet, dû au reservoire
% Bruit télégraphique --> aléatoire et dynamique, et diagramme partiel
% seulement, et non reproductible, car varie dans le temps
% Paramètres pour le bruit télégraphique
% - angle : ~ couplage de la charge avec les grilles [0-90]
% - nVgy : ~ threshold relatif au sweep en y [0-1]
% - nVgx : ~ énergie de charge (taille du saut) relative au sweep en x [0-1]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Modification du diagramme
% Calcul des offset de pixel pour la translation
pixel_offx = round(length(V_sweep2)*nVgx);
dv = V_sweep2(abs(pixel_offx)+1) - V_sweep2(1);
pixel_offy1 = floor(length(V_sweep1)*nVgy);
pixel_offy2 = pixel_offy1 + round(abs(tand(angle)*length(V_sweep2)),0)*angle/abs(angle);
if pixel_offy2 < 0
    pixel_offy2 = 1;
    startx = round(tand(90-angle)*pixel_offy1, 0);
else
    startx = length(V_sweep2)-1;
end

% Calcul de l'interval après lequel il faut augmenter d'un pixel en y
dx_y0 = abs((startx+1)/(pixel_offy1-pixel_offy2));
dx_y = dx_y0;

% Translation de tous les points connus
occ_modif = occ;
for i = startx:-1:abs(pixel_offx)+1
    while dx_y < 0
        dx_y = dx_y + dx_y0;
        pixel_offy2 = pixel_offy2 - angle/abs(angle);
    end
    occ_modif(1:pixel_offy2, i) = occ_modif(1:pixel_offy2, i-pixel_offx);
    dx_y = dx_y - 1;
end

% Calcul de la partie qu'il manque
occ_ligne = calculate_occupation('fast', 0,...
    gates, CC, n1, V_sweep1(1:pixel_offy2+1),...
    n2, V_sweep2(1:pixel_offx+1)-dv,...
    V_oxe, integrand_x, eps_0, x, dx,...
    int_min, int_max, int_length, integral_tab);
occ_ligne = derive_occupation(occ_ligne);
occ_modif(1:pixel_offy2, 1:pixel_offx) = occ_ligne;