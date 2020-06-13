function V = calculate_potential(gates, n1, V1, n2, V2, CC)
% Définition de la matrice de sweep virtuel
VV = zeros(length(gates), 1);
VV(n1) = V1;
VV(n2) = V2;

% Trouver les indices des grilles non sweepée
bool_ns = ~ismember(1:length(gates),[n1,n2]);
VV(bool_ns) = cat(1,gates(bool_ns).V0);

% Calcul de la matrice de sweep réelle
V_to_apply = CC\VV;

% Calcul du profil de potentiel
V = V_to_apply.*cat(1,gates.Vfun);

% Annuler les valeurs de potentiel calculée plus loin que cond_inf
V(sign(V)~=sign(V_to_apply))=0;

% Faire la somme pour le profil de potentiel total
V = sum(V);