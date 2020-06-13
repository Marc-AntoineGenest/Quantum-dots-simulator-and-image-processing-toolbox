function write_integral_tab(g0, k, T, Ef, file_path)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXEMPLE INPUT:
% g0 = 1.0;                        %[(eV nm)^-1]
% k = 1.380648E-23 * 6.242E18;     %[eV/K]
% T = 1;                           % beta = 1000 si T = 11.6 K
% Ef = 0.1;                        %[eV]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% D�finition de l'int�grale
n_int = @(epsilon) g0./(1+exp(1/k/T*(epsilon-Ef)));

% D�finition des valeurs pour lesquelles seront calcul�es l'int�grale
precision = 4;
eps0 = (-15:10^-precision:0.5)';
n = zeros(length(eps0), 1);

% Calcul de l'int�grale pour chaque eps0
f = waitbar(0,'Calcul de l''int�grale...');
t1 = clock;
for i = 1:length(eps0)
    n(i) = integral(n_int, eps0(i), Inf);
    value = i/length(eps0);
    t2 = clock;
    temps_total = etime(t2,t1)/value;
    waitbar(value, f, ['Calcul de l''int�grale... ',...
        num2str(round(value*100), '%1.1f'), '% (',...
        num2str(round((temps_total-etime(t2,t1))/60, 2), '%1.1f'), 'min restantes)']);
end
close(f)

% Cr�ation du tableau
Tab = table([...
    min(eps0);...
    max(eps0);...
    length(eps0);...
    10^-precision;...
    n]);

% �criture du fichier
writetable(Tab, file_path);