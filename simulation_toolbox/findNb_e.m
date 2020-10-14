function nb_e = findNb_e(n, n_island, idx_island, dx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS:
% n : Profil de densit� �lectronique
% n_island : Nombre d'�les d'�lectrons dont on doit compter les �lectrons
% idx_island : Indices de ces �les en tableau de dimension [n_island, 2]
%
% OUTPUTS:
% nb_e : vecteur de dimension [1, n_island] avec le nombre d'e- par �le
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Pr�assigner nb_e, ou le mettre � -1 s'il n'y a pas d'�le
if n_island > 0
    nb_e = zeros(1, n_island);
else
    nb_e = -1;
end


%% Calcul du nombre d'�lectrons par �le ( integrale(densit�(x)) )
for i = 1:n_island
    nb_e(i) = floor(dx*1e9*sum(n(idx_island(i,1):idx_island(i,2))));
end

