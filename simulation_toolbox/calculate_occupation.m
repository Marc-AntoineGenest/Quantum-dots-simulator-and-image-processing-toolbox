function occupation = calculate_occupation(algo, waitbar_bool,...
    gates, CC, n1, V_sweep1, n2, V_sweep2,...
    V_oxe, integrand_x, eps_0, x, dx,...
    int_min, int_max, int_length, integral_tab)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS: 
%
% OUTPUTS:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if waitbar_bool
    f = waitbar(0,'Calcul de l''occupation...');
end
occupation = NaN(length(V_sweep1), length(V_sweep2));

if strcmp(algo, 'fast')
    % 1. Calculer le côté gauche ([length(V_sweep1):-1:1, ones(1, length(V_sweep1))])
    %    et haut ([ones(1, length(V_sweep2)-1), 1:length(V_sweep2)-1])
    i_contour = [1:length(V_sweep1), length(V_sweep1)*ones(1, length(V_sweep2)-1)];
    j_contour = [ones(1, length(V_sweep1)), 2:length(V_sweep2)];
    
    % itérations de la wait_bar
    wait_step = 0:0.05:0.5;
    
    for i = 1:length(i_contour)
        % Nouveau potentiel de la grilles
%         V_gate1 = gatePotential(V_sweep1(i_contour(i)), sweep_gate(1).x0, sweep_gate(1).l,...
%             sweep_gate(1).r0, sweep_gate(1).h, x, sweep_gate(1).cond_inf);
%         V_gate2 = gatePotential(V_sweep2(j_contour(i)), sweep_gate(2).x0, sweep_gate(2).l,...
%             sweep_gate(2).r0, sweep_gate(2).h, x, sweep_gate(2).cond_inf);
%         V = V_constant + V_gate1 + V_gate2;
        V = V_oxe + calculate_potential(gates, n1, V_sweep1(i_contour(i)), n2, V_sweep2(j_contour(i)), CC);
        
        % Calcul auto-consitent de la densité électronique
        [~, ~, ~, nb_e, ~, ~] = electronDensity(integrand_x, eps_0, x, dx, V,...
            int_min, int_max, int_length, integral_tab);
        
        % Assignation du nombre d'électron au diagramme d'occupation
        occupation(i_contour(i), j_contour(i)) = sum(nb_e);
        
        % Update de la waitbar (25% contour, 75% transition)
        if waitbar_bool
            value = i/length(i_contour) * 0.25;
            if wait_step(1) >= value
                waitbar(value, f, ['Calcul des côtés gauche et supérieur... ',...
                    num2str(round(value*100), '%1.1f'), '%']);
                wait_step(1) = [];
            end
        end
    end
    
    % 2. Tableau des transitions
    idx_trans_c_i = find(diff(occupation(:, 1))==1);
    idx_trans_l_j = find(diff(occupation(length(V_sweep1), :))==1);
    idx_trans = [[idx_trans_c_i, ones(length(idx_trans_c_i), 1)];...
        [length(V_sweep1)*ones(length(idx_trans_l_j), 1), idx_trans_l_j']];
    
    % 3. Trouver toutes les transitions
    while ~isempty(idx_trans)
        % Update de la waitbar (25% contour, 75% transition)
        if waitbar_bool
            value = 0.25 + (1 - size(idx_trans, 1)/...
                (length(idx_trans_c_i) + length(idx_trans_l_j))) * 0.75;
            waitbar(value, f, ['Calcul des transitions... ',...
                num2str(size(idx_trans, 1), '%1.0f'), ' restantes']);
        end
        
        % Assigner les indices et nombre d'électron de référence
        i_ref = idx_trans(1,1);
        j_ref = idx_trans(1,2);
        N_ref = occupation(i_ref,j_ref);
        
        % Si sur le côté gauche --> N+1 = ligne au-dessus, test = (i, j+1)
        % Si sur le côté haut   --> N+1 = colonne à droite, test = (i-1, j)
        if  j_ref == 1 && i_ref == length(V_sweep1)
            N_trans = occupation(i_ref, j_ref+1);
            i_test = i_ref;
            j_test = j_ref + 1;
        elseif j_ref == 1
            N_trans = occupation(i_ref+1, j_ref);
            i_test = i_ref;
            j_test = j_ref + 1;
            % Assumer qu'à droite de la case de N+1, nb_e = N+1 aussi
            % (On ne peut pas perdre d'électrons en augmentant le voltage)
            occupation(i_test+1, j_test) = N_trans;
        else
            N_trans = occupation(i_ref,j_ref+1);
            i_test = i_ref - 1;
            j_test = j_ref;
        end
        
        % Tant qu'on a pas fini de calculer la transition (côté bas ou droite)
        while i_test > 0 && j_test <= length(V_sweep2)
            % Nouveau potentiel de la grilles
%             V_gate1 = gatePotential(V_sweep1(i_test), sweep_gate(1).x0, sweep_gate(1).l,...
%                 sweep_gate(1).r0, sweep_gate(1).h, x, sweep_gate(1).cond_inf);
%             V_gate2 = gatePotential(V_sweep2(j_test), sweep_gate(2).x0, sweep_gate(2).l,...
%                 sweep_gate(2).r0, sweep_gate(2).h, x, sweep_gate(2).cond_inf);
%             V = V_constant + V_gate1 + V_gate2;
            V = V_oxe + calculate_potential(gates, n1, V_sweep1(i_test), n2, V_sweep2(j_test), CC);
            
            
            % Calcul auto-consitent de la densité électronique
            [~, ~, ~, nb_e, ~, ~] = electronDensity(integrand_x, eps_0, x, dx, V,...
            int_min, int_max, int_length, integral_tab);
            
            % Assignation du nombre d'électron au diagramme d'occupation
            occupation(i_test, j_test) = sum(nb_e);
            
            % Calcul des nouveaux indices pour suivre la transition
            % La référence devient le point qui vient d'être testé
            i_ref = i_test;
            j_ref = j_test;
            % Tester à droite (augmenter le voltage) si on est à N_ref
            % Tester en bas (diminuer le voltage) si on est à N_trans
            if occupation(i_test, j_test) <= N_ref
                i_test = i_ref;
                j_test = j_ref + 1;
                % Assumer qu'en haut de la case de N_ref, nb_e = N+1 aussi
                % (Preuve: suivre N_trans sans diminuer le voltage)
                if j_test <= length(V_sweep1) && i_test+1 ~= length(V_sweep1) && j_test < length(V_sweep2) 
                    occupation(i_test+1,j_test) = N_trans;
                end
            else
                i_test = i_ref - 1;
                j_test = j_ref;
            end
        end
        idx_trans(1,:) = [];
    end
    
    % 4. Remplir les nan selon les plus proches voisins
    occupation = fillmissing(occupation, 'nearest');
else
    t1 = clock;
    wait_step = 0:0.05:1;
    for i = 1:length(V_sweep1)
        % Sweep de la grille 1, en y (i)
%         V_gate1 = gatePotential(V_sweep1(i), sweep_gate(1).x0, sweep_gate(1).l,...
%             sweep_gate(1).r0, sweep_gate(1).h, x, sweep_gate(1).cond_inf);
        
        for j = 1:length(V_sweep2)
            % Sweep de la grille 2, en x (j)
%             V_gate2 = gatePotential(V_sweep2(j), sweep_gate(2).x0, sweep_gate(2).l,...
%                 sweep_gate(2).r0, sweep_gate(2).h, x, sweep_gate(2).cond_inf);
%             V = V_constant + V_gate1 + V_gate2;
            V = V_oxe + calculate_potential(gates, n1, V_sweep1(i), n2, V_sweep2(j), CC);
            
            % Calcul auto-consitent de la densité électronique
            [~, ~, ~, nb_e, ~, ~] = electronDensity(integrand_x, eps_0, x, dx, V,...
            int_min, int_max, int_length, integral_tab);
            
            % Assignation du nombre d'électron au diagramme d'occupation
            occupation(i,j) = sum(nb_e);
            
            % Update de la waitbar
            if waitbar_bool
                value = ((i-1)*length(V_sweep2) + j)/(length(V_sweep1)*length(V_sweep2));
                if value >= wait_step(1)
                    t2 = clock;
                    temps_total = etime(t2,t1)/value;
                    waitbar(value, f, ['Calcul de l''occupation... ',...
                        num2str(round(value*100), '%1.1f'), '% (',...
                        num2str(round((temps_total-etime(t2,t1))/60, 2), '%1.1f'), 'min restantes)']);
                    wait_step(1) = [];
                end
            end
        end
    end
end

if waitbar_bool
    close(f)
end