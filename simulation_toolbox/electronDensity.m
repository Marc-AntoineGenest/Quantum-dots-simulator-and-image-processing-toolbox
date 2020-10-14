function [n, n_island, idx_island, nb_e, eps_0_mod, Int] =...
    electronDensity(integrand_x, eps_0, x, dx, V,...
    int_min, int_max, int_length, integral_tab)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS: 
% g0 : Densit� d'�tat dans un 2DEG, consid�r�e constante = (m*)/(pi*h_bar^2)
% beta : 1/(kT)
% Ef : �nergie de Fermi
% k0 : �chelle d'�nergie pour l'interaction Coulombienne
% sigma : Param�tre qui emp�che la divergence en x' = x dans (x'-x)
% eps_0 : Minimum de bande de conduction � l'�quilibre
% x : Espace 1d en x
% dx : Intervalle entre chaque point x
% V : Espace 1d en tension
%
% OUTPUTS:
% n : Densit� �lectronique en fonction de x sur le dispositif simul�
%
% Example:
% g0 = 1.0;                       %[(eV nm)^-1]
% k = 1.380648E-23 * 6.242E18;    %[eV/K]
% T = 1;                          % beta = 1000 si T = 11.6 K
% beta = 1/k/T;                   %[(eV)^-1]
% Ef = 0.1;                       %[eV]
% k0 = 5E-3;                      %[eV]
% sigma = 5e-9;                   %[nm]
% eps_0 = 0.01;                   %[eV]
% x = X;                          %[nm]
% dx = unique(diff(x));           %[nm]
% V = V;                          %[eV]
% n = electronDensity(g0, beta, Ef, K0, sigma, eps_0, x, dx, V);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialisation des param�tres
% �quation du potentiel d'interaction et initialisation du vecteur
% d'int�gral
Int = zeros(1, length(x));
int_fact = (int_length-1)/(int_max-int_min);

% Initialiser une premi�re densit�
n = 5*(V+abs(min(V)))./abs(sum(V+abs(min(V))));
n(isnan(n) | n<0.01) = 0;

% Compter les iles et les �lectrons qu'il y a avec cette configuration
[n_island, idx_island] = findIslands(n);
nb_e = findNb_e(n, n_island, idx_island, dx);
if isempty(idx_island)
    idx_island = 0;
end

%% Algorithme de convergence
% *On prend max(max(idx)) et max(nb_e) pour conv. [logical] vers logical
bool_idx = 1; nb_e_old = -30; it = 0;
while (bool_idx && ~isequal(nb_e, nb_e_old)) && it < 10
    % Assigner la derni�re densit� calcul�e
    n_old = n;
    idx_island_old = idx_island;
    nb_e_old = nb_e;
    
    % Calcul du potentiel des charges sur elles-m�mes
    Int = transpose(sum(integrand_x .* n_old, 2) * dx);
    
    % Calcul du minimum de bande de conduction modifi�
    eps_0_mod = eps_0 - V + Int;
    
    % Calcul de la nouvelle densit�
    eps_0_mod = round((int_fact*(eps_0_mod-int_min)) + 1, 0);
    eps_0_mod(eps_0_mod < 1 | eps_0_mod > int_length) = int_length;
    n = integral_tab(eps_0_mod);
    
    % Mettre a 0 les zones o� la densit� est plus faible que 0.01 e-/nm
    n(n<0.01) = 0;
    n = transpose(smooth(n));
    
    % Compter les iles et les �lectrons qu'il y a avec cette configuration
    [n_island, idx_island] = findIslands(n);
    nb_e = findNb_e(n, n_island, idx_island, dx);
    if isempty(idx_island)
        idx_island = 0;
    end
    
    % Bool�en des indices des ilots
    try
        bool_idx = ~min(min(abs((idx_island-idx_island_old))<1));
    catch
        bool_idx = 1;
    end
    
    % Additionner 1 � l'it�ration
    it = it + 1;
end
