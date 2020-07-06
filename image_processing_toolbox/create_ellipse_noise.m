function occ_modif = create_ellipse_noise(occ, n, nVgx, nVgy, eraser, noise)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perte de sensibilit� al�atoire du SET
% Param�tres pour la perte de sensibilit� al�atoire du SET
% - angle  : Angle de l'ellipse de bruit
% - nVgx   : proportion de l'axe x max pour l'ellipse
% - nVgy   : proportion de l'axe y max pour l'ellipse
% - eraser : quantit� de pixel effacer
% - noise  : quantit� de bruit
% - n      : nombre de "tache"

% � voir:
% Ajouter un tracking de la perte de sens. avec un mod�le capacitif.
% (plusieurs grilles et boites quantique necessaire)

% n = 10;
% eraser = 1;
% noise = 0.2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Param�tres al�atoires du bruit en ellipse
idx_off = [randi(size(occ, 1),n,1),...
    randi(size(occ, 2),n,1)];
angles = randi(180,n,1);
etxs = randi(round(nVgx*size(occ,2),0),n,1)+1;
etys = randi(round(nVgy*size(occ,1),0),n,1)+1;

occ_modif = occ;
for i = 1:size(idx_off,1)
    % Initialiser les variables
    angle = angles(i);
    etx = etxs(i);
    ety = etys(i);
    offsetx = idx_off(i,1);
    offsety = idx_off(i,2);

    % Cr�ation de la "patch" de l'ellipse
    pmap_i = normpdf(0:10*ety, 5*ety, ety);
    pmap_j = normpdf(0:10*etx, 5*etx, etx);
    pmap = pmap_i' .* pmap_j;
    pmap = imrotate(pmap, angle, 'bicubic');

    % S'assurer que la patch ne sortira pas en dehors du graphique
    osize = size(pmap);
    if offsety - ceil(size(pmap, 1)/2) < 0
        pmap = pmap(ceil(size(pmap, 1)/2) - offsety:end, :);
    end
    if offsety + ceil(size(pmap, 1)/2) > size(occ, 1)
        pmap = pmap(1:end+size(occ, 1)-(offsety + ceil(size(pmap, 1)/2)), :);
    end
    if offsetx - ceil(size(pmap, 2)/2) < 0
        pmap = pmap(:, ceil(size(pmap, 2)/2) - offsetx:end);
    end
    if offsetx + ceil(size(pmap, 2)/2) > size(occ, 2)
        pmap = pmap(:, 1:end+size(occ, 2)-(offsetx + ceil(size(pmap, 2)/2)));
    end
    pmap = pmap./(max(max(pmap)));

    % Cr�attion de la map de perte de sensibilit�
    occ_sens = zeros(size(occ));
    idx_start_i = offsety-floor(osize(1)/2)+1;
    idx_start_j = offsetx-floor(osize(2)/2)+1;
    if idx_start_i < 0
        idx_start_i = 1;
    end
    if idx_start_i+size(pmap,1)-1 > size(occ_sens,1) && idx_start_i+size(occ_sens,1)-1 <= size(pmap,1)
        pmap = pmap(1:idx_start_i+size(occ_sens,1)-1,:);
    end
    if idx_start_j < 0 || idx_start_j == Inf
        idx_start_j = 1;
    end
    if idx_start_j+size(pmap,2)-1 > size(occ_sens,2) && idx_start_j+size(pmap,2)-1 <= size(pmap,2)
        pmap = pmap(:,1:idx_start_j+size(occ_sens,2)-1);
    end
    
    if idx_start_j == 0
        idx_start_j = 1;
    end
    if idx_start_i == 0
        idx_start_i = 1;
    end
    occ_sens(idx_start_i:idx_start_i+size(pmap,1)-1,...
    idx_start_j:idx_start_j+size(pmap,2)-1) = pmap;

    % Cr�ation d'une carte de point al�atoire
    rmap = rand(size(occ));

    % Effacer le signal et ajouter du bruit
    if size(occ_sens, 1) > size(occ_modif, 1) || size(occ_sens, 2) > size(occ_modif, 2)
        occ_sens = occ_sens(1:size(occ_modif, 1), 1:size(occ_modif,2));
    end
    occ_modif = rmap/eraser>occ_sens & occ_modif;
    occ_modif(rmap/noise<occ_sens & occ_sens>0.01) = 1;
end