%% Simulation of f1 vs SD (for both groups)

% Note f1 and pred SD should be in linear relationship: 
% Var_mix = f1 * var1 + (1-f1) * var2
%         = (var1 - var2) * f1 + var2
% also: y = sqrt(x) is monotonically increasing.
% so pred_SD = sqrt( (var1 - var2) * f1 + var2 ) should be a concave (curved)
% if var1 < var2, then the curve of pred SD decreasing from left to right
% To check if pred SD is linear, we can do: diff(diff(simu_mix_SD)), if <
% 0, then concave, if = 0, then linear

clear all
cd('E:\1 Landmark integration project\Data analysis\behavioral')


load CLM_behav_f1_value_all.mat
CLM_f1_value_all = f1_value_all;
CLM_f1_value_all(1, :) = []; % remove nan 

load SLM_behav_f1_value_all.mat
SLM_f1_value_all = f1_value_all;

% Columns: Compound test using ow, Shift using ow, shift using rp


fileName2 = 'observed_predicted_SD_all.xlsx';
sheetName2 = 'CLM';
raw_data_all2 = readtable(fileName2, 'Sheet', sheetName2);

CLM_SD_all = raw_data_all2{:, :};
CLM_SD_all([1],:) = []; % remove nan 
CLM_SD_all(:,[1;6;10]) = []; % remove nan 
% 36 x 10: 1-4: obs SD, 5-7: pred SD in compound test, 8-10: pred SD in shift test

sheetName3 = 'SLM';
raw_data_all3 = readtable(fileName2, 'Sheet', sheetName3);

SLM_SD_all = raw_data_all3{:, :};
SLM_SD_all(:,[1;6;10]) = []; % remove nan 
% 38 x 10



%% plot 2 x 2
% given the achieved weight, also plot the horizontal lines for Competition
% and combination models

Fig = figure;
Fig.WindowState = 'max';
hold on 

for row_idx = 1:3
    if row_idx ~= 2  % skip the "shift using ow" 

        if row_idx == 1 % compound test
            col_idx = 5; 
            col_idx_obs = 3;
            plot_idx = 1; 
        elseif row_idx == 2 || row_idx == 3 % shift
            col_idx = 8; 
            col_idx_obs = 4;
            plot_idx = 2; 
        end

        % CLM group: 
        subplot(2, 2, (plot_idx-1)*2+1)
        hold on
        num_simu = 1000;
        simu_f1 = linspace(0, 1, num_simu);

        % simulation (line)
        Var_Comb = mean(CLM_SD_all(:, col_idx))^2;
        Var_Alt = mean(CLM_SD_all(:, col_idx+1))^2;

        SE_Comb_SD = std(CLM_SD_all(:, col_idx))/sqrt(36);
        SE_Alt_SD = std(CLM_SD_all(:, col_idx+1))/sqrt(36);
        Comb_SD_up_bd = mean(CLM_SD_all(:, col_idx)) + 1.96*SE_Comb_SD;
        Comb_SD_low_bd = mean(CLM_SD_all(:, col_idx)) - 1.96*SE_Comb_SD;
        Alt_SD_up_bd = mean(CLM_SD_all(:, col_idx+1)) + 1.96*SE_Alt_SD;
        Alt_SD_low_bd = mean(CLM_SD_all(:, col_idx+1)) - 1.96*SE_Alt_SD;

        simu_mix_SD = nan(num_simu, 3);
        for simu_idx = 1:num_simu
            simu_mix_SD(simu_idx,1) = sqrt(simu_f1(simu_idx)*Var_Comb + (1-simu_f1(simu_idx))*Var_Alt);
            simu_mix_SD(simu_idx, 2) = sqrt(simu_f1(simu_idx)*(Comb_SD_up_bd^2) + (1-simu_f1(simu_idx))*(Alt_SD_up_bd^2));
            simu_mix_SD(simu_idx, 3) = sqrt(simu_f1(simu_idx)*(Comb_SD_low_bd^2) + (1-simu_f1(simu_idx))*(Alt_SD_low_bd^2));
        end

        % for combination and Competition models (horizontal lines): 
%         CI_area_comb = fill([simu_f1, fliplr(simu_f1)], [Comb_SD_up_bd*ones(1, 1000), fliplr(Comb_SD_low_bd*ones(1, 1000))], ...
%             'g', 'EdgeColor', 'none', 'facealpha', 0.2);
        line_comb = plot(simu_f1, (sqrt(Var_Comb)*ones(1, 1000)), '-', 'color', [0, 0.5, 0]);
        text(0.65, sqrt(Var_Comb)-1, 'Combination', 'color', [0, 0.5, 0])

%         CI_area_alt = fill([simu_f1, fliplr(simu_f1)], [Alt_SD_up_bd*ones(1, 1000), fliplr(Alt_SD_low_bd*ones(1, 1000))], ...
%             [1 0.5 0.8], 'EdgeColor', 'none', 'facealpha', 0.2);
        line_alt = plot(simu_f1, (sqrt(Var_Alt)*ones(1, 1000)), '-', 'color', 'r');
        text(0.1, sqrt(Var_Alt)+1, 'Competition', 'color', 'r')

        % Plot the shaded area: Fill the shaded area between the upper and lower bounds
        SE_area = fill([simu_f1, fliplr(simu_f1)], [simu_mix_SD(:,2)', fliplr(simu_mix_SD(:,3)')], ...
            [0, 0.4470, 0.7410], ...
            'EdgeColor', 'none', 'facealpha', 0.25);

        curve = plot(simu_f1, simu_mix_SD(:,1), '-', 'color', [0, 0.4470, 0.7410], 'linewidth', 1.2);


        % 95% CI
        f1_err = 1.96*(std(CLM_f1_value_all(:, row_idx))/sqrt(36));
        SD_err = 1.96*(std(CLM_SD_all(:, col_idx+2))/sqrt(36));

        pred_marker_bar = plot([0 1], [mean(CLM_SD_all(:, col_idx+2)) mean(CLM_SD_all(:, col_idx+2))], ...
            '--', 'color', [0, 0.4470, 0.7410]);

        
        % Observed:
        obs_SD_err = 1.96*(std(CLM_SD_all(:, col_idx_obs))/sqrt(36));
        obs_marker = errorbar(mean(CLM_f1_value_all(:, row_idx)), mean(CLM_SD_all(:, col_idx_obs)), ...
            obs_SD_err, obs_SD_err, f1_err, f1_err, 'k', 'linestyle', 'none', 'marker', 'v',...
            'markerfacecolor', [1, 1, 0.62], 'markeredgecolor', 'k', 'linewidth', 1, 'markersize', 12);

        ylabel('Observed or Predicted SD (vm)')
        xlabel('Prob of Combination (\itf_1\rm)')
        xlim([0 1])

        if row_idx == 1
            ylim([0 5])
            title({'Compound Learning Group:'; 'Compound test'})

        elseif row_idx == 3
            ylim([0 12])
            title({'Compound Learning Group:'; 'Shift test'})
        end

        legend([line_alt, line_comb, curve, pred_marker_bar, obs_marker], ...
            {'Competition Predicted Mean', 'Combination Predicted Mean', ...
            'Strategy-Selection Simulation', ...
            'Strategy-Selection Predicted Mean', 'Observed Mean \pm 95%CI'}, ...
            'location', 'eastoutside')
        

        % -------------------------------------------------------------- %
        % SLM group: 
        subplot(2, 2, plot_idx*2)
        hold on
        num_simu = 1000;
        simu_f1 = linspace(0, 1, num_simu);

        % simulation (line)
        Var_Comb = mean(SLM_SD_all(:, col_idx))^2;
        Var_Alt = mean(SLM_SD_all(:, col_idx+1))^2;

        SE_Comb_SD = std(SLM_SD_all(:, col_idx))/sqrt(38);
        SE_Alt_SD = std(SLM_SD_all(:, col_idx+1))/sqrt(38);
        Comb_SD_up_bd = mean(SLM_SD_all(:, col_idx)) + 1.96*SE_Comb_SD;
        Comb_SD_low_bd = mean(SLM_SD_all(:, col_idx)) - 1.96*SE_Comb_SD;
        Alt_SD_up_bd = mean(SLM_SD_all(:, col_idx+1)) + 1.96*SE_Alt_SD;
        Alt_SD_low_bd = mean(SLM_SD_all(:, col_idx+1)) - 1.96*SE_Alt_SD;

        simu_mix_SD = nan(num_simu, 3);
        for simu_idx = 1:num_simu
            simu_mix_SD(simu_idx,1) = sqrt(simu_f1(simu_idx)*Var_Comb + (1-simu_f1(simu_idx))*Var_Alt);
            simu_mix_SD(simu_idx, 2) = sqrt(simu_f1(simu_idx)*(Comb_SD_up_bd^2) + (1-simu_f1(simu_idx))*(Alt_SD_up_bd^2));
            simu_mix_SD(simu_idx, 3) = sqrt(simu_f1(simu_idx)*(Comb_SD_low_bd^2) + (1-simu_f1(simu_idx))*(Alt_SD_low_bd^2));
        end

        % for combination and Competition models (horizontal lines): 
%         CI_area_comb = fill([simu_f1, fliplr(simu_f1)], [Comb_SD_up_bd*ones(1, 1000), fliplr(Comb_SD_low_bd*ones(1, 1000))], ...
%             'g', 'EdgeColor', 'none', 'facealpha', 0.2);
        line_comb = plot(simu_f1, (sqrt(Var_Comb)*ones(1, 1000)), '-', 'color', [0, 0.5, 0]);
        text(0.65, sqrt(Var_Comb)-1, 'Combination', 'color', [0, 0.5, 0])

%         CI_area_alt = fill([simu_f1, fliplr(simu_f1)], [Alt_SD_up_bd*ones(1, 1000), fliplr(Alt_SD_low_bd*ones(1, 1000))], ...
%             [1 0.5 0.8], 'EdgeColor', 'none', 'facealpha', 0.2);
        line_alt = plot(simu_f1, (sqrt(Var_Alt)*ones(1, 1000)), '-', 'color', 'r');
        text(0.1, sqrt(Var_Alt)+1, 'Competition', 'color', 'r')


        % Plot the shaded area: Fill the shaded area between the upper and lower bounds
        SE_area = fill([simu_f1, fliplr(simu_f1)], [simu_mix_SD(:,2)', fliplr(simu_mix_SD(:,3)')], ...
            [0, 0.4470, 0.7410], ...
            'EdgeColor', 'none', 'facealpha', 0.25);

        curve = plot(simu_f1, simu_mix_SD(:,1), '-', 'color', [0, 0.4470, 0.7410], 'linewidth', 1.2);

        % 95% CI
        f1_err = 1.96*(std(SLM_f1_value_all(:, row_idx))/sqrt(38));
        SD_err = 1.96*(std(SLM_SD_all(:, col_idx+2))/sqrt(38));

        pred_marker_bar = plot([0 1], [mean(SLM_SD_all(:, col_idx+2)) mean(SLM_SD_all(:, col_idx+2))], ...
            '--', 'color', [0, 0.4470, 0.7410]);

        
        % Observed:
        obs_SD_err = 1.96*(std(SLM_SD_all(:, col_idx_obs))/sqrt(38));
        obs_marker = errorbar(mean(SLM_f1_value_all(:, row_idx)), mean(SLM_SD_all(:, col_idx_obs)), ...
            obs_SD_err, obs_SD_err, f1_err, f1_err, 'k', 'linestyle', 'none', 'marker', 'v',...
            'markerfacecolor', [0.85,0.75,0.9], 'markeredgecolor', 'k', 'linewidth', 1, 'markersize', 12);

        ylabel('Observed or Predicted SD (vm)')
        xlabel('Prob of Combination (\itf_1\rm)')
        xlim([0 1])

        if row_idx == 1
            ylim([0 5])
            title({'Single Learning Group:'; 'Compound test'})

        elseif row_idx == 3
            ylim([0 12])
            title({'Single Learning Group:'; 'Shift test'})
        end

        legend([line_alt, line_comb, curve, pred_marker_bar, obs_marker], ...
            {'Competition Predicted Mean', 'Combination Predicted Mean', ...
            'Strategy-Selection Simulation', ...
            'Strategy-Selection Predicted Mean', 'Observed Mean \pm 95%CI'}, ...
            'location', 'eastoutside')
        
    end
end

set(findall(gcf,'-property','FontSize'),'FontSize',14)

% Place annotations slightly above each subplot
% Letters for panels
letters = 'A':'D'; 

% Loop over all axes (subplots)
ax = findall(gcf, 'Type', 'axes');  % get all axes handles
ax = flipud(ax); % flip order to match subplot order 

for k = 1:length(ax)
    pos = get(ax(k), 'Position'); % get subplot position
    annotation('textbox', [pos(1)-0.04, pos(2)+pos(4)-0.01, 0.05, 0.05], ...
               'String', letters(k), 'FontWeight','bold', 'FontSize',14, ...
               'LineStyle','none');
end



%%
saveas(Fig, ['2grps_f1_SD_mean_all_mdl', '.fig'])
saveas(Fig, ['2grps_f1_SD_mean_all_mdl', '.tiff'])



