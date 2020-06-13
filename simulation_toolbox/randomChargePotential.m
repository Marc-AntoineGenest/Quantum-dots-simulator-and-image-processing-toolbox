function V_oxe = randomChargePotential(x, dx, h, densite_charge, sigma, k0)
%% Génération de la distribution de charges aléatoires
% Calcul des paramètre géométriques de l'oxyde
L = x(end)-x(1);
aire_oxyde = L*h;
nb_horizontal = L/dx + 1;
nb_vertical = floor(h/dx) + 1;
dy = h/nb_vertical;

% Calcul du nombre d'électrons dans l'oxyde
nb_electrons = aire_oxyde * densite_charge;

% Calcul de la carte d'électrons aléatoires dans l'oxyde
idx_i = randi(nb_vertical, nb_electrons);
idx_j = randi(nb_horizontal, nb_electrons);
Q_oxe_bool = zeros(nb_vertical, nb_horizontal);
Q_oxe_bool(sub2ind(size(Q_oxe_bool), idx_i, idx_j)) = 1;

%% Calcul du potentiel total des charges d'oxyde
% Intialisation des paramètres pour la lignes de charges
sigma_lines = linspace(sigma + dy*nb_vertical, sigma, nb_vertical);
V_oxe = zeros(1, nb_horizontal);

for i = 1:nb_vertical
    % Équation du potentiel d'interaction
    integrand_x = k0./sqrt(((repmat(x,[length(x),1])-x')).^2 + sigma_lines(i)^2);

    % Calcul du potentiel des charges au niveau du 2DEG
    Int = transpose(sum(integrand_x .* Q_oxe_bool(i,:), 2) * dx);
    
    % Addition du potentiel de la ligne au potentiel total au 2DEG
    V_oxe = V_oxe + Int;
end

V_oxe = -V_oxe;