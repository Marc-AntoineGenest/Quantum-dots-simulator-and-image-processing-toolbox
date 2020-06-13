function [int_min, int_max, int_length, int_precision, integral_tab] = get_integral_tab(g0, k, T, Ef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS: 
%
% OUTPUTS:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Lecture du fichier
name = ['integral_g0_', num2str(g0), '_T_', num2str(T), '_Ef_', num2str(Ef, '%.e')];
[path,~,~] = fileparts(mfilename('fullpath'));
path = [path, '\integral_tabs\'];


file_path = [path, name, '.txt'];
if exist(file_path, 'file') ~= 2
    answer = questdlg({'Le fichier contenant l''intégrale calculée n''existe pas.',...
        'Voulez-vous le créer et poursuivre, ou annuler la simulation?'},...
        'Warning', 'Poursuivre', 'Annuler', 'Poursuivre');
    if strcmp(answer, 'Poursuivre')
        write_integral(g0, k, T, Ef, file_path)
    else
        return
    end
end
tab = dlmread(file_path, ',', 1, 0);

%% Lecture des éléments
int_min = tab(1);
int_max = tab(2);
int_length = tab(3);
int_precision = tab(4);
integral_tab = tab(5:end);
