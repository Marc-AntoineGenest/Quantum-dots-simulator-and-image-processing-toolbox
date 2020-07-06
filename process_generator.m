% STRUCTURE DES PARAMÈTRES :
% parameters = {...
%   {'perte sensibilité', n, nVgx, nVgy, eraser, noise};...
%   {'taux tunnel signal', dw_top, dw_bot, coefx, coefy, moy};...
%   {'taux tunnel mesure', coefx, coefy, nVgx, n_err};...
%   {'taux tunnel efface', coefx, coefy, threshold, off_noise};...
%   {'effet Major', A, B, threshold, a, b, c, d};...
%   }
%
% VALEURS POSSIBLES :
% Perte Sensibilité:
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

% Define locations to load and store
load_path = 'C:\Users\sCzischek\Documents\Postdoc_Waterloo\Quantum Dots\qd-training-data-creation\test_data';
save_path = 'C:\Users\sCzischek\Documents\Postdoc_Waterloo\Quantum Dots\qd-training-data-creation\test_data';
images_path = 'C:\Users\sCzischek\Documents\Postdoc_Waterloo\Quantum Dots\qd-training-data-creation\test_data';

% Modify the stability diagrams
files = dir([load_path, '\*.mat']);
for f = 1:length(files)
    %Do 5 different transformations for each simulated diagram
    for t = 1:20
        % Read files
        file_name = [load_path, '\', files(f).name];
        simulation = load(file_name);
        simulation = simulation.simulation;
        
        % Determine a random number of transformations (up to 8 out of 8)
        names = {};
        for i = 1:randi(8)
            switch randi(8)
                case 1
                    if not(ismember('effet piège', names))
                        names(end+1) = {'effet piège'};
                    end
                case 2
                    if not(ismember('anticroisement 1', names))
                        names(end+1) = {'anticroisement 1'};
                    end
                case 3
                    if not(ismember('taux tunnel signal', names))
                        names(end+1) = {'taux tunnel signal'};
                    end
                case 4
                    if not(ismember('taux tunnel mesure', names))
                        names(end+1) = {'taux tunnel mesure'};
                    end
                case 5
                    if not(ismember('taux tunnel efface', names))
                        names(end+1) = {'taux tunnel efface'};
                    end
                case 6
                    if not(ismember('perte sensibilité', names))
                        names(end+1) = {'perte sensibilité'};
                    end
                case 7
                    if not(ismember('effet capacitif', names))
                        names(end+1) = {'effet capacitif'};
                    end
                case 8
                    if not(ismember('effet Major', names))
                        names(end+1) = {'effet Major'};
                    end
            end
        end
        
        % Create the random parameters for the defects
        parameters = cell(size(names));
        for n = 1:length(names)
            name = names{n};
            switch name
                case 'effet piège'
                    parameters{n} = {name, randi(89), rand, 0.05 * rand + 0.01};
                case 'anticroisement 1'
                    parameters{n} = {name, 0.5, -10, 0.3, 0.4};
                case 'taux tunnel signal'
                    parameters{n} = {name, randi(4) + 2, randi(2) + 1, rand + 1, 3 * rand + 1, randi(13) + 1};
                case 'taux tunnel mesure'
                    parameters{n} = {name, 6 * rand + 4, 2 * rand + 1, 1.99 * rand + 0.01, 0.9 * rand + 0.1};
                case 'taux tunnel efface'
                    parameters{n} = {name, 2 * rand - 1, 4 * rand - 2, 2 * rand - 1, 0.5 * rand + 0.3, rand};
                case 'perte sensibilité'
                    parameters{n} = {name, randi(4), 0.2 * rand + 0.05, 0.2 * rand + 0.05, 0.25 * rand + 0.75, 0.98 * rand + 0.02};
                case 'effet capacitif'
                    parameters{n} = {name, 0.5 * rand, 0.5 * rand, 0.5 * rand + 0.5, 0.5 * rand + 0.5};
                case 'effet Major'
                    if rand > 0.5 
                        parameters{n} = {name, 0.05 * rand + 0.01, 0.05 * rand + 0.01, 0.3 * rand + 0.65, 0, 0, 0, 0};
                    else
                        parameters{n} = {name, 0.05 * rand + 0.01, 0.05 * rand + 0.01, 0.3 * rand + 0.65, 0.1 * rand + 0.75, 0.5 * rand + 0.2, rand + 1, 4 * rand + 1};
                    end
            end
        end

        simulation = image_process(simulation, parameters);
        
        % Add some unitary random noise
        thresh = 0.1;
        for i = 1:size(simulation.occupation_signal,1)
            for j = 1:size(simulation.occupation_signal,2)
                if rand < thresh
                    simulation.occupation_signal(i,j) = 1;
                end
            end
        end
        
        % Create and store the files
        figure;
        imagesc(flipud(simulation.occupation_signal));
        set(gcf, 'PaperPositionMode', 'auto');
        print(gcf, [images_path, '\processed_', num2str(f), '_', num2str(t), '_signal'], '-dpng')
        imagesc(flipud(simulation.occupation_trans));
        set(gcf, 'PaperPositionMode', 'auto');
        print(gcf, [images_path, '\processed_', num2str(f), '_', num2str(t), '_trans'], '-dpng')
        close gcf;
        dlmwrite([save_path, '\processed_', num2str(f), '_', num2str(t), '_signal', '.txt'],...
            simulation.occupation_signal, 'delimiter', ' ');
        dlmwrite([save_path, '\processed_', num2str(f), '_', num2str(t), '_trans', '.txt'],...
            simulation.occupation_trans, 'delimiter', ' ');
    end
end
        