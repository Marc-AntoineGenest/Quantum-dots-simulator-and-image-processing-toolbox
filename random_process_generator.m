% STRUCTURE DES PARAM�TRES :
% parameters = {...
%   {'perte sensibilit�', n, nVgx, nVgy, eraser, noise};...
%   {'taux tunnel signal', dw_top, dw_bot, coefx, coefy, moy};...
%   {'taux tunnel mesure', coefx, coefy, nVgx, n_err};...
%   {'taux tunnel efface', coefx, coefy, threshold, off_noise};...
%   {'effet Major', A, B, threshold, a, b, c, d};...
%   }
%
% VALEURS POSSIBLES :
% Perte Sensibilit�:
%   - n = {0,4}
%   - nVgx = {0.05, 0.25}
%   - nVgy = {0.05, 0.25}
%   - eraser = {0.75, 1}
%   - noise = {0.02, 0.1}
%
% Taux tunnel signal:
%   - dw_top = {2, 6}
%   - dw_bot = {1, 3}
%   - coefx = {1, 2}
%   - coefy = {1, 4}
%   - moy = {2, 15}
%
% Taux tunnel mesure
%   - coefx = {4, 10}
%   - coefy = {1, 3}
%   - nVgx = {1e-2, 2}
%   - n_err = {1e-1, 1}
%
% Taux tunnel efface
%   - coefx = {-5, 5}
%   - coefy = {-5, 5}
%   - degree = {0.75, 2}
%   - threshold = {0.75, 1}
%
% Effet Major
%   - A = {0.01, 0.05}
%   - B = {0.85, 0.95}
%   - threshold = {0.75, 2}
%   - a = -0.75, 0.85}
%   - b = {0.2, 0.7}
%   - c = {1, 2}
%   - d = {1, 5}

% D�claration de l'emplacement de fichiers
load_path = 'C:\Users\sCzischek\Documents\Postdoc_Waterloo\Quantum Dots\Quantum-dots-simulator-and-image-processing-toolbox\training_data'; % INSERT SIMULATIONS PATHS (.m file)
save_path = 'C:\Users\sCzischek\Documents\Postdoc_Waterloo\Quantum Dots\Quantum-dots-simulator-and-image-processing-toolbox\training_data\'; % INSERT PATH WHERE .m FILES WILL BE SAVED
images_path = 'C:\Users\sCzischek\Documents\Postdoc_Waterloo\Quantum Dots\Quantum-dots-simulator-and-image-processing-toolbox\training_data\'; % INSERT PATH WHERE IMAGES WILL BE SAVED

% Modification des diagrammes de stabilit�
files = dir([load_path, '\*.mat']);
for f = 1:length(files)
    % Lecture de la simulation
    %file_name = [load_path, '\', files(f).name];
    %simulation = load(file_name);
    %simulation = simulation.simulation;
    
    % Faire six transformations par diagramme simul�
    for t = 1:5
        % Lecture de la simulation � transformer
        file_name = [load_path, '\', files(f).name];
        simulation = load(file_name);
        simulation = simulation.simulation;
        
        % D�termination des modification � apporter
        %switch t
        %    case 1
        %        names = {'taux tunnel signal'; 'perte sensibilit�'; 'effet Major'};
        %    case 2
        %        names = {'taux tunnel signal'; 'perte sensibilit�'; 'taux tunnel efface'};
        %    case 3
        %        names = {'taux tunnel signal'; 'taux tunnel efface'; 'effet Major'};
        %    case 4
        %        names = {'taux tunnel signal'; 'perte sensibilit�'; 'effet Major'; 'taux tunnel efface'};
        %    case 5
        %        names = {'taux tunnel signal'; 'taux tunnel mesure'};
        %    case 6
        %        names = {'taux tunnel signal'; 'taux tunnel mesure'; 'taux tunnel efface'};
        %end
        
        s = randi(4);
        trans_num = randperm(4);
        trafos = {'perte sensibilit�', 'effet Major', 'taux tunnel efface', 'taux tunnel mesure'};%, 'anticroisement 2', 'anticroisement 1', 'effet pi�ge', 'effet capacitif'};
        
        if s == 1
            names = {'taux tunnel signal', trafos{trans_num(1)}};
        elseif s == 2
            names = {'taux tunnel signal', trafos{trans_num(1)}, trafos{trans_num(2)}};
        elseif s == 3
            names = {'taux tunnel signal', trafos{trans_num(1)}, trafos{trans_num(2)}, trafos{trans_num(3)}};
        elseif s == 4
            names = {'taux tunnel signal', trafos{trans_num(1)}, trafos{trans_num(2)}, trafos{trans_num(3)}, trafos{trans_num(4)}};
        elseif s == 5
            names = {'taux tunnel signal', trafos{trans_num(1)}, trafos{trans_num(2)}, trafos{trans_num(3)}, trafos{trans_num(4)}, trafos{trans_num(5)}};
        end      
        
        %for i = 1:randi([2,5])
        %    i
        %    switch randi(5)
        %        case 1
        %            if not(ismember('taux tunnel signal', names))
        %                names(end+1) = {'taux tunnel signal'};
        %            end
        %        case 2
        %            if not(ismember('perte sensibilit�', names))
        %                names(end+1) = {'perte sensibilit�'};
        %            end
        %        case 3
        %            if not(ismember('effet Major', names))
        %                names(end+1) = {'effet Major'};
        %            end
        %        case 4
        %            if not(ismember('taux tunnel efface', names))
        %                names(end+1) = {'taux tunnel efface'};
        %            end
        %        case 5
        %            if not(ismember('taux tunnel mesure', names))
        %                names(end+1) = {'taux tunnel mesure'};
        %            end
        %    end
        %end         
        
        % Cr�ation de la cellule de param�tres
        parameters = cell(size(names));
        for n = 1:length(names)
            name = names{n};
            switch name
                case 'perte sensibilit�'
                    parameters{n} = {name,...
                        randi(5)-1,...
                        (0.25-0.05)*rand+0.05,...
                        (0.25-0.05)*rand+0.05,...
                        (1-0.75)*rand+0.75,...
                        (0.1-0.02)*rand+0.02};
                    
                case 'taux tunnel signal'
                    parameters{n} = {name,...
                        randi(5)+1,...
                        randi(3)+1,...
                        (2-1)*rand+1,...
                        (4-1)*rand+1,...
                        randi(14)+1};
                    
                case 'taux tunnel mesure'
                    parameters{n} = {name,...
                        (10-4)*rand+4,...
                        (3-1)*rand+4,...
                        (2-1e-2)*rand+1e-2,...
                        (1-1e-1)*rand+1e-1};
                    
                case 'taux tunnel efface'
                    parameters{n} = {name,...
                        (5--5)*rand-5,...
                        (5--5)*rand-5,...
                        (2-0.75)*rand+0.75,...
                        (1-0.75)*rand+0.75};
                    
                case 'effet Major'
                    if rand>0.5
                        parameters{n} = {name,...
                            (0.08-0.04)*rand+0.04,...
                            (0.04-0.02)*rand+0.02,...
                            (2-0.75)*rand+0.75,...
                            0,0,0,0};
                    else
                        parameters{n} = {name,...
                            (0.08-0.04)*rand+0.04,...
                            (0.04-0.02)*rand+0.02,...
                            (2-0.75)*rand+0.75,...
                            (0.85--0.75)*rand-0.75,...
                            (0.7-0.2)*rand+0.2,...
                            (2-1)*rand+1,...
                            (5-1)*rand+1};
                    end
            end
        end
        
        % Modification du diagramme
        simulation = image_process(simulation, parameters);
        
        thresh = 0.2;
        for i = 1:size(simulation.occupation_signal,1)
            for j = 1:size(simulation.occupation_signal,2)
                if rand < thresh
                    simulation.occupation_signal(i,j) = 1;
                end
            end
        end
            
        % Enregistrer les images et les fichiers .txt
        figure
        imagesc(flipud(simulation.occupation_signal))
        set(gcf, 'PaperPositionMode', 'auto')
        print(gcf, [images_path, 'processed_', num2str(f), '_', num2str(t), '_signal'], '-dpng')
        imagesc(flipud(simulation.occupation_trans))
        set(gcf, 'PaperPositionMode', 'auto')
        print(gcf, [images_path, 'processed_', num2str(f), '_', num2str(t), '_trans'], '-dpng')
        close gcf
        dlmwrite([save_path, 'processed_', num2str(f), '_', num2str(t), '_signal', '.txt'],...
            simulation.occupation_signal, 'delimiter', ' ');
        dlmwrite([save_path, 'processed_', num2str(f), '_', num2str(t), '_trans', '.txt'],...
            simulation.occupation_trans, 'delimiter', ' ');
    end
end