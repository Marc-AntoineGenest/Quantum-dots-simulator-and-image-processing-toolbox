% Define locations to load and store
save_path = 'C:\Users\sCzischek\Documents\Postdoc_Waterloo\Quantum Dots\qd-training-data-creation\training_data';
images_path = 'C:\Users\sCzischek\Documents\Postdoc_Waterloo\Quantum Dots\qd-training-data-creation\training_data';

for f = 1:20
    for t = 1:20
        
        
    occupation = zeros(150);
    occupation_trans = zeros(150);
    % Add some unitary random noise
        thresh = 0.1;
        for i = 1:size(occupation,1)
            for j = 1:size(occupation,2)
                if rand < thresh
                    occupation(i,j) = 1;
                end
            end
        end
        
        % Create and store the files
        figure;
        imagesc(flipud(occupation));
        set(gcf, 'PaperPositionMode', 'auto');
        print(gcf, [images_path, '\processed_', num2str(f+20), '_', num2str(t), '_signal'], '-dpng')
        imagesc(flipud(occupation_trans));
        set(gcf, 'PaperPositionMode', 'auto');
        print(gcf, [images_path, '\processed_', num2str(f+20), '_', num2str(t), '_trans'], '-dpng')
        close gcf;
        dlmwrite([save_path, '\processed_', num2str(f+20), '_', num2str(t), '_signal', '.txt'],...
            occupation, 'delimiter', ' ');
        dlmwrite([save_path, '\processed_', num2str(f+20), '_', num2str(t), '_trans', '.txt'],...
            occupation_trans, 'delimiter', ' ');
    end
end
