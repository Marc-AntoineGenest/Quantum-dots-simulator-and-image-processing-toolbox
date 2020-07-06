%%%%%%%%%% Définition des paramètres du dispositif %%%%%%%%%%%%
%%%%%%%%%% Definition of the device parameters %%%%%%%%%%%%%%%%
% Maillage
% Mesh
x1 = -1000e-9;
x2 = 1000e-9;
dx = 10e-9;
x = x1:dx:x2;

% Intégrale Fermi-Dirac (densité d'état g0, cte pour 2DEG)
% Fermi-Dirac integral (state density g0, cte for 2DEG)
g0 = 1.0;                        %[(eV nm)^-1]
k = 1.380648E-23 * 6.242E18;     %[eV/K]
T = 1;                           % beta = 1000 si T = 11.6 K
Ef = 0.1;                        %[eV]
[int_min, int_max, int_length, int_precision, integral_tab] =...
    get_integral_tab(g0, k, T, Ef);

% Interaction entre les charges
% Charge interaction
k0 = 5E-3;                       %[eV]
sigma = 5e-9;                    %[m]
integrand_x = k0./sqrt(((repmat(x,[length(x),1])-x')).^2 + (sigma)^2);

% Minimum de bande de conduction
% Conduction band minimum
eps_0 = 0.01;                    %[eV]


%%% Choose random grids %%%
for count = 1:1
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% Définition des paramètres de grilles %%%%%%%%%%%%%
    %%%%%%%%%%%% Grid parameter definition %%%%%%%%%%%%%%%%%%%%%%%%
    % Pour toutes les grilles
    % For all grids
    r0 = 10 * rand * 1E-9;%5E-9;
    l = 10 * rand * 1E-6;%5e-6;
    h = 100 * 1E-9;%45E-9;
    cond_inf = (1000 * rand + 1000) * 1E-9;%1500E-9;
    cond_inf_barriere = cond_inf/2;
    V_barriere = -0.5;%- 0.2 * rand - 0.4;%-0.5;

    pos1 = (- 250 * rand - 750) * 1e-9;
    pos2 = (- 250 * rand - 250) * 1e-9;

    % Simulation à 2 grilles et 1 dot
    % Simulation of 2 grids and 1 dot
    gates = struct(...
        'V0',       {1, V_barriere, 1},...
        'x0',       {pos1, pos2, 0},...%{-1000e-9, -750e-9 , 0e-9, 750e-9, 1000e-9},...
        'l',        {l},...
        'r0',       {r0},...
        'h',        {h},...
    'cond_inf', {cond_inf, cond_inf_barriere, cond_inf});
    gates = get_Vfun(gates, x);

    CC = eye(length(gates)); %virtual gates, leave it like this to not use this effect
    n1 = 1;
    V_sweep1 = linspace(0, 0.15, 150);
    n2 = 3;
    V_sweep2 = linspace(3, 3.15, 150);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% Calclu du potentiel de charge d'oxyde %%%%%%%%%%%%
    %%%%%%%%%%%% Calculation of oxide charge potential %%%%%%%%%%%%
    % Densité de charges d'oxyde
    % Oxide charge density
    charge_density = 1e-18;
    V_oxe = randomChargePotential(x, dx, h, charge_density, sigma, k0);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%% Calcul du diagramme de stabilité %%%%%%%%%%%%%%%
    %%%%%%%%%%%%%% Stability diagram calculation %%%%%%%%%%%%%%%%%%
    % Démarage du chrono
    % Start clock
    t1 = clock;

    % Calcul de l'occupation électronique
    % Electron occupation calculation
    %%% Here choose 'fast' or 'normal' mode, then activate or deactivate waitbar
    %%% (deactivate to create data)
    occupation = calculate_occupation('fast', 0,...
        gates, CC, n1, V_sweep1, n2, V_sweep2,...
        V_oxe, integrand_x, eps_0, x, dx,...
        int_min, int_max, int_length, integral_tab);

    % Calcul du signal de détection de charge (dérivée)
    % Charge detection signal calculation (derivative)
    occupation_signal = derive_occupation(occupation);

    % Calcul de la vérité terrain pour les transitions
    % Ground truth calculation for the transitions
    [row, col] = find(occupation_signal == 1);
    occupation_trans = zeros(size(occupation_signal));
    for i = 1:length(row)
        occupation_trans(row(i),col(i)) = mean(mean(occupation(max([1,row(i)-1]):row(i)+1,max([1,col(i)-1]):col(i)+1)));
    end
    occupation_trans = floor(occupation_trans);

    % Tracer la figure
    % Create the figure
    plot_occupation(occupation, V_sweep1, V_sweep2)
    plot_occupation(occupation_signal, V_sweep1, V_sweep2)

    % Fin du chrono
    % Stop clock
    t2 = clock;
    simu_time = etime(t2, t1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Image Process
    % Création de la structure de la simulation
    % Simulation structure creation
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
    % Creation of the list of modifications on the image
    % Use this nomenclature:
    % parameters = {...
    %   {'anticroisement 1', nVgy, angle, e_n, n_sommet};...%%%%%%anti-crossing1
    %   {'anticroisement 2', d};...%%%%%anti-crossing2
    %   {'perte sensibilité', n, nVgx, nVgy, eraser, noise};...%%%%%sensitized
    %   {'taux tunnel signal', dw_top, dw_bot, coefx, coefy, moy};...
    %   {'taux tunnel mesure', coefx, coefy, nVgx, n_err};...
    %   {'taux tunnel efface', coefx, coefy, degree, threshold,
    %   off_noise};...%delete
    %   {'effet piège', angle, nVgy, nVgx};...%%%%%trap
    %   {'effet capacitif', A, B, C, D};...
    %   {'effet set Major', A, B, threshold};...
    %   }

    %parameters = {...
    %    {'anticroisement 2', 3};...
    %    };

    %parameters = {{'anticroisement 1', 0.6 * rand + 0.3, randi([-45,45]), 0.4 * rand + 0.1, 0.4 * rand + 0.2}};
    %parameters = {{'effet capacitif', rand, rand, rand, rand}};
    %simulation = image_process(simulation, parameters);
    %plot_occupation(simulation.occupation_signal)
    %plot_occupation(simulation.occupation_trans)

    %simulation = image_process(simulation, parameters);
    %plot_occupation(simulation.occupation_signal)
    %occ_modif = simulation.occupation_signal;
    savepath = ['C:\Users\sCzischek\Documents\Postdoc_Waterloo\Quantum Dots\qd-training-data-creation\training_data\simulation_', num2str(count+17), '.mat'];
    save(savepath, 'simulation')

    %% Enregistrement de l'image et du fichier texte
    %% Define image and file 
    % savepath = 'C:\Users\sCzischek\Documents\Postdoc_Waterloo\Quantum Dots\Quantum-dots-simulator-and-image-processing-toolbox\training_data\';
    % title = 'simulation16';
    % plot_occupation(occ_modif)
    % set(gcf,'PaperPositionMode','auto')
    % print(gcf,[savepath, title],'-dpng')
    % close gcf
    % dlmwrite([savepath, title, '.txt'], occ_modif, 'delimiter',' ');
end