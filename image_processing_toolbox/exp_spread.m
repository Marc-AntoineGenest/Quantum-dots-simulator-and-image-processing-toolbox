function [occ_modif, occ_modif_v] = exp_spread(occ, occ_v, coefx, coefy, nVgx, n_err)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Taux tunnel dot-reservoire (effet sur la mesure du signal)
% Taux tunnel proportionnel à 1/V (https://arxiv.org/ftp/quant-ph/papers/0403/0403010.pdf)
% Voir wiki aussi
% Paramètres pour l'effet du taux tunnel dot-reservoire
% - coefx  : ~ couplage à la grille 2 (ex. 5)
% - coefy  : ~ couplage à la grille 1 (ex. 1)
% - nVgx   : ~ proportion du déplacement maximal en nombre de pixels (ex. 0.1)
% - n_err  : Écart type de la gaussienne de l'effet tunnel en proportion de l'axe (ex. 0.1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Modification de l'image
% Paramètres de la fonction normale
dmax = size(occ, 2)*nVgx;
err = size(occ, 2)*n_err;

% Création de la map de taux tunnels
ca = linspace(0, -1, size(occ,1));
cb = linspace(0, -1, size(occ,2));
ttmap = exp(coefy*ca + coefx*cb');
ttmap = (ttmap - min(min(ttmap)))./(max(max(ttmap))-min(min(ttmap)));
t_map = normrnd(ttmap*dmax, err*ttmap)';

% Déplacement des pixels
occ_modif = zeros(size(occ));
occ_modif_v = zeros(size(occ));
for i = 1:size(occ, 1)
    for j = 1:size(occ, 2)
        d = round(t_map(i,j), 0);
        if occ(i,j) > 0 && j+d <= size(occ, 2) && j+d >= j
            occ_modif(i, j+d) = occ(i,j);
        end
    end
end
for i = 1:size(occ_v, 1)
    for j = 1:size(occ_v, 2)
        d = round(t_map(i,j), 0);
        if occ_v(i,j) > 0 && j+d <= size(occ_v, 2) && j+d >= j
            occ_modif_v(i, j+d) = occ_v(i,j);
        end
    end
end