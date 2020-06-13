function [n_island, idx_island] = findIslands(n, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS:
% n : Profil de densité électronique
% varargin : [x1, x2, ..., xn] = Vecteur d'indices autour desquels une île
%                                sera recherchée.
%
% OUTPUTS:
% n_island : Nombre d'île complète sur le dispositf
% idx_island : tableau de (n_island x 2), où :
%               - idx_island(n, 1) est l'extrémité gauche de l'île
%               - idx_island(n, 2) est l'extrémité droite de l'île
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Lecture du varargin
if nargin > 1
    x_search = varargin{:};
else
    x_search = [];
end


%% Initialisation des indices pour la recherche d'îles
% Trouver tous les indices où la densité est non nulle
n_bool = n>0;

% Trouver tous les indices de "début" de densité -> extrémité gauche
idx1 = find(diff(n_bool)==1)+1;

% Trouver tous les indices de "fin" de densité -> extrémité droite
idx2 = find(diff(n_bool)==-1);


%% Trouver le nombre d'îles et de leurs indices
if isempty(idx1) && isempty(idx2)
    idx1 = 1;
    idx2 = length(n);
elseif isempty(idx1) && ~isempty(idx2)
    idx1 = 1;
elseif isempty(idx2) && ~isempty(idx1)
    idx2 = length(n);
else
    % Ajouter aux indices les extrémités du dispo si une ile s'y rend
    if idx1(1)>idx2(1)
        idx1 = [1, idx1];
    end
    if idx1(end)>idx2(end)
        idx2 = [idx2, length(n)];
    end
end
n_island = length(idx1);
idx_island = [idx1',idx2'];


%% Renvoyer les îles recherchées uniquement s'il y avait un varargin en input
if ~isempty(x_search)
    len_idx = n_island;
    n_island = length(x_search);
    idx_island_old = idx_island;
    idx_island = ones(length(x_search), 2)*-1;
    for i = 1:length(x_search)
        % Assigner idx_island(i) si le x_search(i) est dans [idx1:idx2]
        for j = 1:len_idx
            if idx_island_old(j,1) < x_search(i) && x_search(i) < idx_island_old(j,2)
                idx_island(i,:) = idx_island_old(j,:);
            end
        end
        % Si aucun indice n'a été trouvé, réduire le nombre d'île et indice
        if idx_island(i,1) == -1
            n_island = n_island - 1;
            idx_island(i,:) = [];
        end
    end
end