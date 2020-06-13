%%%%%%%%%% Définition des paramètres du dispositif %%%%%%%%%%%%
% Maillage
x1 = -1000e-9;
x2 = 1000e-9;
dx = 10e-9;
x = x1:dx:x2;

% Intégrale Fermi-Dirac (densité d'état g0, cte pour 2DEG)
g0 = 1.0;                        %[(eV nm)^-1]
k = 1.380648E-23 * 6.242E18;     %[eV/K]
T = 1;                           % beta = 1000 si T = 11.6 K
Ef = 0.1;                        %[eV]
[int_min, int_max, int_length, int_precision, integral_tab] =...
    get_integral_tab(g0, k, T, Ef);

% Interaction entre les charges
k0 = 5E-3;                       %[eV]
sigma = 5e-9;                    %[nm]
integrand_x = k0./sqrt(((repmat(x,[length(x),1])-x')).^2 + (sigma)^2);

% Minimum de bande de conduction
eps_0 = 0.01;                    %[eV]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Définition des paramètres de grilles %%%%%%%%%%%%%
% Pour toutes les grilles
r0 = 5E-9;
l = 5e-6;
h = 45E-9;
cond_inf = 1500E-9;
cond_inf_barriere = cond_inf/2;
V_barriere = -0.5;

% Simulation à 2 grilles et 1 dot
gates = struct(...
    'V0',       {V_barriere, 1, 0, 1, V_barriere},...
    'x0',       {-1000e-9, -750e-9 , 0e-9, 750e-9, 1000e-9},...
    'l',        {l},...
    'r0',       {r0},...
    'h',        {h},...
    'cond_inf', {cond_inf_barriere, cond_inf, cond_inf_barriere, cond_inf, cond_inf_barriere});
gates = get_Vfun(gates, x);

CC = eye(length(gates));
n1 = 2;
V_sweep1 = linspace(0, 0.15, 150);
n2 = 4;
V_sweep2 = linspace(0, 0.15, 150);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Calclu du potentiel de charge d'oxyde %%%%%%%%%%%%
% Densité de charges d'oxyde
charge_density = 0;
V_oxe = randomChargePotential(x, dx, h, charge_density, sigma, k0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Calcul du diagramme de stabilité %%%%%%%%%%%%%%%
% Démarage du chrono
t1 = clock;

% Calcul de l'occupation électronique
occupation = calculate_occupation('normal', 1,...
    gates, CC, n1, V_sweep1, n2, V_sweep2,...
    V_oxe, integrand_x, eps_0, x, dx,...
    int_min, int_max, int_length, integral_tab);

% Calcul du signal de détection de charge (dérivée)
occupation_signal = derive_occupation(occupation);

% Calcul de la vérité terrain pour les transitions
[row, col] = find(occupation_signal == 1);
occupation_trans = zeros(size(occupation_signal));
for i = 1:length(row)
    occupation_trans(row(i),col(i)) = mean(mean(occupation(max([1,row(i)-1]):row(i)+1,max([1,col(i)-1]):col(i)+1)));
end
occupation_trans = floor(occupation_trans);

% Tracer la figure
plot_occupation(occupation_signal, V_sweep1, V_sweep2)

% Fin du chrono
t2 = clock;
simu_time = etime(t2, t1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Image Process
% Création de la structure de la simulation
simulation = struct(...
    'gates', gates,...
    'CC', CC,...
    'n1', n1,...
    'V_sweep1', V_sweep1,...
    'n2', n2,...
    'V_sweep2', V_sweep2,...
    'V_oxe', V_oxe,...
    'integrand_x', integrand_x,...
    'eps_0', eps_0,...
    'x', x,...
    'dx', dx,...
    'int_min', int_min,...
    'int_max', int_max,...
    'int_length', int_length,...
    'integral_tab', integral_tab,...
    'occupation', occupation,...
    'occupation_signal', occupation_signal,...
    'occupation_trans', occupation_trans);

% Création de la liste de modifications à apporter à l'image
% Suivre cette nomenclature :
% parameters = {...
%   {'anticroisement 1', nVgy, angle, e_n, n_sommet};...
%   {'anticroisement 2', d};...
%   {'perte sensibilité', n, nVgx, nVgy, eraser, noise};...
%   {'taux tunnel signal', dw_top, dw_bot, coefx, coefy, moy};...
%   {'taux tunnel mesure', coefx, coefy, nVgx, n_err};...
%   {'taux tunnel efface', coefx, coefy, degree, threshold, off_noise};...
%   {'effet piège', angle, nVgy, nVgx};...
%   {'effet capacitif', A, B, C, D};...
%   {'effet set Major', A, B, threshold};...
%   }
parameters = {...
    {'anticroisement 2', 3};...
    };

simulation = image_process(simulation, parameters);
plot_occupation(simulation.occupation_signal)


%% Enregistrement de l'image et du fichier texte
% savepath = 'C:\Users\Exon\Documents\Maîtrise\GAN\Data\';
% title = 'simulation1';
% plot_occupation(occ_modif)
% set(gcf,'PaperPositionMode','auto')
% print(gcf,[savepath, title],'-dpng')
% close gcf
% dlmwrite([savepath, title, '.txt'], occ_modif, 'delimiter',' ');
