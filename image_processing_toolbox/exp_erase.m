function occ_modif = exp_erase(occ, coefx, coefy, degree, threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - coefy   : ~ couplage avec la grille 1
% - coefx   : ~ couplage avec la grille 2
% - threshold : pixels qui seront effacés après l'application du filtre
% - off_noise : indice de bruitage suite à l'effacement (1 = pas de bruit)
%
% coefx = 1;
% coefy = 2;
% degree = 1;
% threshold = 0.5;
% off_noise = 0.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Modification de l'image
% Gérer les coefs négatifs
bool_flipx = 0;
bool_flipy = 0;
if coefx < 0
    occ = fliplr(occ);
    coefx = abs(coefx);
    bool_flipx = 1;    
end
if coefy < 1
    occ = flipud(occ);
    coefy = abs(coefy);
    bool_flipy = 1; 
end

% Création du filtre exponentiel selon les coeficients de couplages donnés
filtre1 = coefx*ones(size(occ)) .* (logspace(0, 1, size(occ, 1))');
filtre2 = coefy*ones(size(occ)) .* (logspace(0, 1, size(occ, 1))');

% Map de bruit pour ne pas avoir une coupur sharp
rand_map = rand(size(occ));
rand_map(rand_map>1) = 1;

% Filtre total et normalisation
filtre = ((filtre1+filtre2).^degree) .* rand_map;
filtre = flipud(1-fliplr((filtre)./max(max(filtre))));

% Effacement de l'image
occ_modif = filtre .* occ;
if threshold == 1
    threshold = 0.99999;
end
occ_modif(occ_modif>=threshold) = 1;
occ_modif(occ_modif<threshold) = 0;

% Refliper si les coefs étaient négatifs
if bool_flipx
    occ_modif = fliplr(occ_modif); 
end
if bool_flipy
    occ_modif = flipud(occ_modif);
end