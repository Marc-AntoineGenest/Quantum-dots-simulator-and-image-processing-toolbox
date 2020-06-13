function occ_modif = ddot_avoided_crossing(occupation, d)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Séparation des région d'un diagramme double dot (colonne)
% Création de la map de dérivée
occupation_ligne = derive_occupation(occupation);

% Créer la map de pixel à colorier
occ_tofill = nan(size(occupation));

% Séparer le diagramme en losange indépendant
occ = double(watershed(imgradient(occupation)));
occ_bool = bwmorph(occ, 'clean');
occ(~occ_bool) = 0;
occ(occ==0) = nan;
occ = fillmissing(occ, 'nearest');
regions = regionprops(occ, 'PixelIdxList', 'Centroid');
centroids = cat(1,regions.Centroid);
regions(isnan(centroids(:,1)))=[];
centroids = cat(1,regions.Centroid);

n_line = 1;
while ~isempty(regions)
    % Déterminer la première région à utiliser, et la colorier
    [~, idx_c] = max(sqrt(sum(centroids.^2,2)));
    occ_tofill(regions(idx_c).PixelIdxList) = n_line;
    
    issameline = true;
    while issameline
        % Mettre en ordre des centroids les plus près au plus loin de idx_c1
        % et trouver le nombre d'électrons associés aux centroids
        [~, order] = sort(sqrt((centroids(idx_c,1) - centroids(:,1)).^2 +...
            (centroids(idx_c,2) - centroids(:,2)).^2));
        regions_sorted = regions(order);
        centroids = cat(1, regions_sorted.Centroid);
        nbe = occupation(sub2ind(size(occ), round(centroids(:,2),0),...
            round(centroids(:,1),0)));

        % Trouver les 2 centroids les plus près à N-1 électrons de idx_c1
        idx_m1 = find(sum((centroids(:,:) -...
            centroids(1,:)).^2,2).*(nbe==nbe(1)-1));
        if length(idx_m1)>=2
            idx_m1 = idx_m1(1:2);
            idx_sort = transpose(reshape([regions_sorted(idx_m1).Centroid],2,2));
            [~, idx_sort] = sort(idx_sort(:,1),'descend');
            idx_m1 = idx_m1(idx_sort,:);
            if regions_sorted(1).Centroid(1) > regions_sorted(idx_m1(1)).Centroid(1)
                if regions_sorted(1).Centroid(2) < 0.8*size(occ,1)
                    issameline = false;
                end
            end
        elseif length(idx_m1)==1
            if regions_sorted(1).Centroid(1) > regions_sorted(idx_m1(1)).Centroid(1)
                if regions_sorted(1).Centroid(2) < 0.8*size(occ,1)
                    issameline = false;
                end
            end
        else
            issameline = false;
        end

        if issameline
            % Déterminer lequel est ligne ou colone (ligne -> next_centroids(1,:))
            % et colorier la zone voulue
            next_centroids = centroids(idx_m1,:);
            occ_tofill(regions_sorted(idx_m1(1)).PixelIdxList) = n_line;
        end
        % Enlever la zone colriée des zones à coloriées
        regions(idx_c) = [];
        centroids = cat(1,regions.Centroid);
        if ~isempty(centroids)
            idx_c = find(ismember(centroids,next_centroids(1,:),'rows'));
        end
    end
    n_line = n_line + 1;
end

% plot_occupation(occupation)
occ_dj = abs(occ_tofill-max(max(occ_tofill)));
% plot_occupation(occ_dj)

%% Déplacement des pixels composants les lignes
occ_dligne = occupation_ligne;
for i = size(occupation_ligne,1):-1:4
    for j = size(occupation_ligne,2):-1:4
        if i-(occ_dj(i,j)*d)>1
            occ_dligne(i,j) = occ_dligne(i-(occ_dj(i,j)*d),j);
        end
    end
end

border = 5;
occ_dligne(border:end-border,border:end-border) =...
    bwmorph(occ_dligne(border:end-border,border:end-border),'bridge',inf);
plot_occupation(occ_dligne)

%%
% close all
I = occ_dligne(border:end-border,border:end-border);
% operation_list = {'diag','shrink','diag','shrink'};
operation_list = {'fatten','bridge','fill','thin'};
for i = 1:length(operation_list)
    if i == length(operation_list)
        I = bwmorph(I, operation_list{i});
    else
        I = bwmorph(I, operation_list{i});
    end
end

occ_test = occ_dligne;
occ_test(border:end-border,border:end-border) = I;

operation_list = {'bridge','diag','skel'};
for i = 1:length(operation_list)
    if i == length(operation_list)
        occ_test = bwmorph(occ_test, operation_list{i},inf);
    else
        occ_test = bwmorph(occ_test, operation_list{i});
    end
end

% plot_occupation(occ_test)
occ_dligne = occ_test;

%% Séparation des région d'un diagramme double dot (ligne)
% Créer la map de pixel à colorier
occ_tofill = nan(size(occ_dligne));

% Séparer le diagramme en losange indépendant
% occ = double(watershed(imgradient(occupation)));
occ = double(watershed(occ_dligne,4));
occ(occ==0) = nan;
occ = fillmissing(occ, 'nearest');
regions = regionprops(occ, 'PixelIdxList', 'Centroid');
centroids = cat(1,regions.Centroid);

n_line = 1;
while ~isempty(regions)
    % Déterminer la première région à utiliser, et la colorier
%     [~, idx_c] = max(sqrt(sum(centroids.^2,2)));
    [~, idx_c] = max(sqrt(centroids(:,1).^2 + 10*centroids(:,2).^2));
    occ_tofill(regions(idx_c).PixelIdxList) = n_line;
    
    issameline = true;
    while issameline
        % Mettre en ordre des centroids les plus près au plus loin de idx_c1
        % et trouver le nombre d'électrons associés aux centroids
        [~, order] = sort(sqrt((centroids(idx_c,1) - centroids(:,1)).^2 +...
            (centroids(idx_c,2) - centroids(:,2)).^2));
        regions_sorted = regions(order);
        centroids = cat(1, regions_sorted.Centroid);
        nbe = occupation(sub2ind(size(occupation),...
            round(centroids(:,2)-occ_dj(sub2ind(size(occupation),...
            round(centroids(:,2),0), round(centroids(:,1),0)))*2*d/3, 0),...
            round(centroids(:,1),0)));

        % Trouver les 2 centroids les plus près à N-1 électrons de idx_c1
        idx_m1 = find(sum((centroids(:,:) -...
            centroids(1,:)).^2,2).*(nbe==nbe(1)-1));
        if length(idx_m1)>=2
            idx_m1 = idx_m1(1:2);
            idx_sort = transpose(reshape([regions_sorted(idx_m1).Centroid],2,2));
            [~, idx_sort] = sort(idx_sort(:,2),'descend');
            idx_m1 = idx_m1(idx_sort,:);
            if regions_sorted(1).Centroid(1) < regions_sorted(idx_m1(1)).Centroid(1)
                if regions_sorted(2).Centroid(2) < 0.9*size(occ,1)
                    issameline = false;
                end
            elseif regions_sorted(1).Centroid(1) < 0.2*size(occ,2)
                issameline = false;
            end
        elseif length(idx_m1)==1
            if ~isempty(regions_sorted) && size(centroids,1)>2
                if regions_sorted(1).Centroid(2) > regions_sorted(idx_m1).Centroid(2)
                    if regions_sorted(1).Centroid(1) < 0.8*size(occ,2)
                        issameline = false;
                    end
                end
            end
        else
            issameline = false;
        end
        
        if issameline
            % Déterminer lequel est ligne ou colone (ligne -> next_centroids(1,:))
            % et colorier la zone voulue
            next_centroids = centroids(idx_m1,:);
            occ_tofill(regions_sorted(idx_m1(1)).PixelIdxList) = n_line;
        end
        % Enlever la zone colriée des zones à coloriées
        regions(idx_c) = [];
        centroids = cat(1,regions.Centroid);
        if ~isempty(centroids)
            idx_c = find(ismember(centroids,next_centroids(1,:),'rows'));
        end
    end
    n_line = n_line + 1;
end

% plot_occupation(occupation)
occ_di = abs(occ_tofill-max(max(occ_tofill)));
% plot_occupation(occ_di)

%% Déplacement des pixels composants les lignes
occ_dligne_2 = occ_dligne;
for i = size(occupation_ligne,1):-1:4
    for j = size(occupation_ligne,2):-1:4
        if j-(occ_di(i,j)*d)>1
            occ_dligne_2(i,j) = occ_dligne_2(i,j-(occ_di(i,j)*d));
        end
    end
end

I = occ_dligne_2;
operation_list = {'fatten','diag','thin','diag','thin'};
for i = 1:length(operation_list)
    if i == length(operation_list)
        I = bwmorph(I, operation_list{i}, inf);
    else
        I = bwmorph(I, operation_list{i}, 2);
    end
end

occ_modif = I;
% plot_occupation(I)