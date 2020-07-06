function [occ_modif, occ_modif_trans] = exp_enlarge(occ, occ_trans, dw_top, dw_bot, coefx, coefy, moy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Taux tunnel dot-reservoire (effet sur l'epaisseur des lignes)
% Paramètres pour l'effet du taux tunnel dot-reservoire
% - dw_top  : épaisseur de la ligne en haut du diagramme (desired width)
% - dw_bot  : épaisseur de la ligne en bas du diagramme
% - coefy   : ~ couplage avec la grille 1
% - coefx   : ~ couplage avec la grille 2
% - moy     : nombre de moyennage (enlève le bruit des lignes)
% 
% dw_top = 6;
% dw_bot = 2;
% coefy = 2;
% coefx = 0.4;
% moy = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Modification d'image
occ_modif = occ;
occ_modif_trans = occ_trans;
occ_modif_trans(occ_trans >= 1) = 1;
for idx = 1:moy
    occ_modif_ = occ;
    occ_modif_trans_ = occ_trans;
    occ_modif_trans_(occ_trans >= 1) = 1;
    % Élargissement des lignes
    for it = 1:dw_top
        % Map de taux tunnel
        ca = linspace(-1, 0, size(occ_modif_,1));
        cb = linspace(-1, 0, size(occ_modif_,2));
        ttmap = exp(coefy*ca' + coefx*cb);
        ttmap = (ttmap./(max(max(ttmap)) - min(min(ttmap))))*(1-dw_bot/dw_top);
        ttmap = ttmap + 1-max(max(ttmap));
        
        ca_trans = linspace(-1, 0, size(occ_modif_trans_,1));
        cb_trans = linspace(-1, 0, size(occ_modif_trans_,2));
        ttmap_trans = exp(coefy*ca_trans' + coefx*cb_trans);
        ttmap_trans = (ttmap_trans./(max(max(ttmap_trans)) - min(min(ttmap_trans))))*(1-dw_bot/dw_top);
        ttmap_trans = ttmap_trans + 1-max(max(ttmap_trans));

        % Map d'énergie aléatoire
        if size(occ_modif_, 1) > size(occ_modif_trans_, 1) || size(occ_modif_, 2) > size(occ_modif_trans_, 2)
            emap = rand(size(occ_modif_));
            emap_trans = emap(1:size(occ_modif_trans_, 1), 1:size(occ_modif_trans_, 2));
        else
            emap_trans = rand(size(occ_modif_trans_));
            emap = emap_trans(1:size(occ_modif_, 1), 1:size(occ_modif_, 2));
        end

        % Map d'avancement des pixels
        bmap = emap < ttmap & occ_modif_==1;
        bmap_trans = emap_trans < ttmap_trans & occ_modif_trans_>=1;

        % Copier le pixel de chaque côté de la ligne si l'energie le permet
        if mod(it,2)
            occ_modif_ = [occ_modif_(:,1), occ_modif_(:,2:end)+bmap(:,1:end-1), bmap(:,end)];
            occ_modif_ = [occ_modif_(1,:); occ_modif_(2:end,:)+[bmap(1:end-1,:), bmap(1:end-1,end)]; [bmap(end,:), bmap(end)]];
            occ_modif_trans_ = [occ_modif_trans_(:,1), occ_modif_trans_(:,2:end)+bmap_trans(:,1:end-1), bmap_trans(:,end)];
            occ_modif_trans_ = [occ_modif_trans_(1,:); occ_modif_trans_(2:end,:)+[bmap_trans(1:end-1,:), bmap_trans(1:end-1,end)]; [bmap_trans(end,:),bmap_trans(end)]];
        else
            occ_modif_ = [bmap(:,1), bmap(:,2:end)+occ_modif_(:,1:end-1), occ_modif_(:,end)];
            occ_modif_ = [occ_modif_(1,:); occ_modif_(2:end,:)+[bmap(2:end,:), bmap(2:end,end)]; [bmap(end,:), bmap(end)]];
            occ_modif_trans_ = [bmap_trans(:,1), bmap_trans(:,2:end)+occ_modif_trans_(:,1:end-1), occ_modif_trans_(:,end)];
            occ_modif_trans_ = [occ_modif_trans_(1,:); occ_modif_trans_(2:end,:)+[bmap_trans(2:end,:), bmap_trans(2:end,end)]; [bmap_trans(end,:), bmap_trans(end)]];
        end
    end

    % Remettre la taille originale et additionner pour le moyennage
    occ_modif_ = occ_modif_(ceil(dw_top/2):end-floor(dw_top/2)-1,ceil(dw_top/2):end-floor(dw_top/2)-1);
    occ_modif = occ_modif + occ_modif_;
    occ_modif_trans_ = occ_modif_trans_(ceil(dw_top/2):end-floor(dw_top/2)-1,ceil(dw_top/2):end-floor(dw_top/2)-1);
    occ_modif_trans = occ_modif_trans + occ_modif_trans_;
end

% Rebinariser les données et débruiter
occ_modif(occ_modif<moy*0.1) = 0;
occ_modif_trans(occ_modif_trans<moy*0.1) = 0;
occ_modif(occ_modif>=moy*0.1) = 1;
occ_modif_trans(occ_modif_trans>=moy*0.1) = 1;
% occ_modif = bwmorph(bwmorph(occ_modif, 'spur'),'close');
