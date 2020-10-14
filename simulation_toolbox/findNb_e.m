function nb_e = findNb_e(n, n_island, idx_island, dx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS:
% n : Profil de densité électronique
% n_island : Nombre d'îles d'électrons dont on doit compter les électrons
% idx_island : Indices de ces îles en tableau de dimension [n_island, 2]
%
% OUTPUTS:
% nb_e : vecteur de dimension [1, n_island] avec le nombre d'e- par île
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Préassigner nb_e, ou le mettre à -1 s'il n'y a pas d'île
if n_island > 0
    nb_e = zeros(1, n_island);
else
    nb_e = -1;
end


%% Calcul du nombre d'électrons par île ( integrale(densité(x)) )
for i = 1:n_island
    nb_e(i) = floor(dx*1e9*sum(n(idx_island(i,1):idx_island(i,2))));
end

