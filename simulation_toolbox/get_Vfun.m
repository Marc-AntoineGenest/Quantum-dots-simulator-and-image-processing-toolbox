function gates = get_Vfun(gates, x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS:
% V0 : Hauteur du potentiel en x = x0
% x0 : Position de la grille (scalaire si 'plunger', vecteur si 'reservoir'
% l : Longueur de la grille
% r0 : Rayon de la grille
% h : Hauteur de la grille (distance des électrons)
% x : Vecteur de la grille x à simulé
% type : Type de la grille ('plunger' ou 'reservoir')
%
% OUTPUTS
% V : Profil de potentiel en fonction de x sur le dispositif simulé
% 
% EXAMPLE:
% V0 = 1;
% x0 = 0;
% r0 = 5E-9;
% l = 5e-4;
% h = 45E-9;
% cond_inf = 1000E-9;
% V = gatePotential(V0, x0, l, r0, h, x, cond_inf, 'plunger');
%
% INFO:
% Potentiel donné par l'article (avec sigma de l'ordre de r0):
% V = V0/log(h/r0) * log(sqrt((x-x0).^2 + h^2)/r0) .* exp(-abs(x-x0)/sigma);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Définition des fonctions log pour le calcul de potentiels
% var_c(1) = r (distance du centre du cylindre)
% var_c(2) = l (longueur du cylindre)
fun_log_centre = @(var_c) log(var_c{1}./...
    (var_c{2} .* (sqrt(4*var_c{1}.^2 + var_c{2}.^2) + var_c{2})));

% var_d(1) = x - x_2 (distance de l'extrémité droite du cylindre)
% var_d(2) = x - x_1 (distance de l'extrémité gauche du cylindre)
% var_d(3) = y (distance de l'axe du cylindre)
fun_log_decentre = @(var_d)...
    log((sqrt((var_d{1}).^2 + var_d{3}.^2) + var_d{1})./...
    (sqrt((var_d{2}).^2 + var_d{3}.^2) + var_d{2}));

%% Calcul des fonctions de potentiel

for i = 1:length(gates)
    % Définition des paramètres
    x0 = gates(i).x0;
    
    % Déterminer le type de barrière
    if length(x0) == 1
        type = 'plunger';
    else
        type = 'reservoir';
    end

    % Calcul du potentiel en fonction du type de grille
    switch type
        case 'plunger'
            % Transformation de x vers r
            r = sqrt((x-gates(i).x0).^2+(gates(i).r0+gates(i).h)^2);

            % Potentiel centré et perpendiculaire à un cylindre chargé en surface
            log0 = fun_log_centre({gates(i).r0,gates(i).l});
            logInf = fun_log_centre({gates(i).cond_inf,gates(i).l});
            a = 1/(logInf - log0);
            k = 1 + a*log0;
            Vfun = -a*fun_log_centre({r,gates(i).l}) + k;

        case 'reservoir'
            % Initialisation du pas et des indices necessaires
            dx = x(2) - x(1);
            x_1 = x0(1);
            x_2 = x0(2);
            idx_centre = find(x>=mean([x_1,x_2]), 1);
            idx_droite = find(x>=x_2, 1);

            % Potentiel sous le centre de la grille
            log0 = fun_log_centre({gates(i).r0,gates(i).l});
            logInf = fun_log_centre({gates(i).cond_inf,gates(i).l});
            a = 1/(logInf - log0);
            k = 1 + a*log0;
            V_cg = -a*fun_log_centre({gates(i).h+gates(i).r0,gates(i).l}) + k;

            % Potentiel à droite de la grille
            x_calc = x(idx_droite:end) - x(idx_droite);
            log0 = fun_log_decentre({0, gates(i).l, gates(i).r0/5});
            logInf = fun_log_decentre({gates(i).cond_inf*0.75, gates(i).l, gates(i).h+gates(i).r0});
            a = 1/(log0 - logInf);
            k = 1 - a*log0;
            V_dg = a*fun_log_decentre({x_calc, x_calc+gates(i).l, gates(i).h+gates(i).r0}) + k;

            % Potentiel sous le centre-droit de la grille
            l_decentre = gates(i).l - 2*dx*(idx_droite-idx_centre:-1:1);
            l_centre = gates(i).l - l_decentre;
            log_centre = fun_log_centre({gates(i).h+gates(i).r0, l_centre(1)}) + fun_log_decentre({0, l_decentre(1), gates(i).h+gates(i).r0});
            log_droite = fun_log_centre({gates(i).h+gates(i).r0, l_centre(end)}) + fun_log_decentre({0, l_decentre(end), gates(i).h+gates(i).r0});
            a = (V_cg-V_dg(1))/(log_centre-log_droite);
            k = V_cg - a*log_centre;
            V_cdg = a .* (fun_log_centre({gates(i).h+gates(i).r0, l_centre}) + fun_log_decentre({0, l_decentre, gates(i).h+gates(i).r0})) + k;

            % Assigner les V calculés aux bons endroits sur x
            Vfun = [V_cg*ones(1,idx_centre-1), V_cdg, V_dg];
    end
    
    % Mettre la fonction dans la structure à retourner
    gates(i).Vfun = Vfun;
end