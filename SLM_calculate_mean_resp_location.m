clear all

cd('E:\1 Landmark integration project\Data analysis\behavioral')

fileName = 'SLM_behavioral_raw_data.xlsx';
sheetName = 'raw data';
% raw_data_all = xlsread(fileName, sheetName);
raw_data_all = readtable(fileName, 'Sheet', sheetName);

raw_subject_no = raw_data_all{:, 1};
raw_test_condition = raw_data_all{:, 5}; % 0 = Compound, 1 = LM1 only, 2 = LM2 only, 3 = shifted
raw_distance_X_error = raw_data_all{:, 15}; % Error along the x axis
raw_distance_Z_error = raw_data_all{:, 16}; % Error along the z axis

raw_Euclidean_distance = raw_data_all{:, 17}; % Euclidean distance error
% ******************************************************************************************

raw_target_X = raw_data_all{:, 9}; 
raw_target_Z = raw_data_all{:, 10}; 
raw_response_X = raw_data_all{:, 13}; 
raw_response_Z = raw_data_all{:, 14}; 
raw_LM_1_X = raw_data_all{:, 22}; 
raw_LM_2_X = raw_data_all{:, 23}; 
raw_dis_target_LM_1 = raw_data_all{:, 24}; 
raw_dis_target_LM_2 = raw_data_all{:, 25}; 

total_trial_no = 96;
subject_total_no = length(raw_subject_no)/total_trial_no;

% [num, txt] = xlsread(fileName, sheetName);
% raw_reliable_cue = txt(2:length(txt), 23);
raw_reliable_cue = raw_data_all{:, 26};

for i = 1:length(raw_reliable_cue)
    if strcmp(raw_reliable_cue{i}, 'LM1')==1
        reliable_cue_no(i,1) = 1;
    elseif strcmp(raw_reliable_cue{i}, 'LM2')==1
        reliable_cue_no(i,1) = 2;
    end
end

% subject_ID_list = unique(raw_subject_no);
for row_idx = 1:subject_total_no
    subject_ID_list(row_idx, 1) = raw_subject_no(row_idx*total_trial_no);
end

subject_total_no = length(subject_ID_list);

disp(['subject_total_no = ', num2str(subject_total_no)])



%% calculate cue weight according to the combination model: 
% Note in this study, target should always be in range of [-15, -2] and [2, 15].
% No consecutive blocks should show too close target (less than 0.2 away). 

mean_Euc_err_1 = nan(subject_total_no, 3);
mean_Euc_err_2 = nan(subject_total_no, 3);
mean_Euc_err_both = nan(subject_total_no, 3);
mean_Euc_err_shift = nan(subject_total_no, 3);

var_LM1 = nan(subject_total_no, 3); % 2025/08/12: Using Newman (2022, Psych Research)'s method, calculate variance around the mean of those response locations. 
var_LM2 = nan(subject_total_no, 3);
var_both = nan(subject_total_no, 3);
var_shift = nan(subject_total_no, 3);

std_LM1 = nan(subject_total_no, 3);
std_LM2 = nan(subject_total_no, 3);
std_both = nan(subject_total_no, 3);
std_shift = nan(subject_total_no, 3);

M_X = nan(subject_total_no, 3);
M_Z = nan(subject_total_no, 3);

for subject_idx = 1:subject_total_no
% for subject_idx = 2
    current_subID = subject_ID_list(subject_idx);
    disp(' '); disp(['current_subID = ', num2str(current_subID)])
    
    current_raw_test_condition = raw_test_condition(raw_subject_no == current_subID); % length should be 96
%     current_raw_distance_X_error = raw_distance_X_error(raw_subject_no == current_subID);
    current_raw_distance_Z_error = raw_distance_Z_error(raw_subject_no == current_subID);

    current_raw_Euclid_distance_error = raw_Euclidean_distance(raw_subject_no == current_subID);
    
    current_reliable_cue_no = reliable_cue_no(raw_subject_no == current_subID);
    
    current_target_X = raw_target_X(raw_subject_no == current_subID);
    current_response_X = raw_response_X(raw_subject_no == current_subID);
    current_target_Z = raw_target_Z(raw_subject_no == current_subID);
    current_response_Z = raw_response_Z(raw_subject_no == current_subID);
    current_LM_1_X = raw_LM_1_X(raw_subject_no == current_subID);
    current_LM_2_X = raw_LM_2_X(raw_subject_no == current_subID);
    current_dis_target_LM_1 = raw_dis_target_LM_1(raw_subject_no == current_subID);
    current_dis_target_LM_2 = raw_dis_target_LM_2(raw_subject_no == current_subID);
    
    if current_subID == 47 % Subject 47 did not do the last 3 blocks
        current_raw_test_condition(85:96, 1) = nan;
        current_raw_distance_Z_error(85:96, 1) = nan;
        current_raw_Euclid_distance_error(85:96, 1) = nan;
        current_reliable_cue_no(85:96, 1) = nan;
        current_target_X(85:96, 1) = nan;
        current_target_Z(85:96, 1) = nan;
        current_response_X(85:96, 1) = nan;
        current_response_Z(85:96, 1) = nan;
        current_LM_1_X(85:96, 1) = nan;
        current_LM_2_X(85:96, 1) = nan;
        current_dis_target_LM_1(85:96, 1) = nan;
        current_dis_target_LM_2(85:96, 1) = nan;
    elseif current_subID == 56 % Subject 56 did not do the last 2 blocks
        current_raw_test_condition(89:96, 1) = nan;
        current_raw_distance_Z_error(89:96, 1) = nan;
        current_raw_Euclid_distance_error(89:96, 1) = nan;
        current_reliable_cue_no(89:96, 1) = nan;
        current_target_X(89:96, 1) = nan;
        current_target_Z(89:96, 1) = nan;
        current_response_X(89:96, 1) = nan;
        current_response_Z(89:96, 1) = nan;
        current_LM_1_X(89:96, 1) = nan;
        current_LM_2_X(89:96, 1) = nan;
        current_dis_target_LM_1(89:96, 1) = nan;
        current_dis_target_LM_2(89:96, 1) = nan;
    end
    
    current_adj_resp_X = current_response_X - current_target_X;
    current_adj_resp_Z = current_response_Z - current_target_Z;
    
    % pause and check target's location
    disp(['How many blocks were target closer to LM2 = ', num2str(length(find(current_target_X(current_target_X > 0)))/4)])
    
    Fig = figure; plot(current_target_X, 'o--')
    hold on; ylim([-20 20])
    plot([0 100], [0 0], 'k-')
    title(['Subject ', num2str(current_subID)])
    ylabel({'Target''s location during learning'; 'LM1 \rightarrow LM2'})
    xlabel('Trial number')
    close(Fig)
    
    temp_distance_Z_error_SD = std(current_raw_distance_Z_error, 'omitnan');
    upper_bound_z_error = mean(current_raw_distance_Z_error, 'omitnan') + 2.5*temp_distance_Z_error_SD;
    lower_bound_z_error = mean(current_raw_distance_Z_error, 'omitnan') - 2.5*temp_distance_Z_error_SD;

    
    % --------------- Consider different reliable cue trials separately --------------%    
    for current_cue_no = 1:2
        disp(''); disp(['--- current_cue_no = ', num2str(current_cue_no), ' ---'])

        % reliability of single cue:  
        % 1, LM1 only test: Note here LM1 may be nearLM or FarLM       
        temp_idx = find(current_raw_test_condition == 1 & current_reliable_cue_no == current_cue_no); 
        LM1_Euclid_distance = current_raw_Euclid_distance_error(temp_idx);
        LM1_adj_resp_X = current_adj_resp_X(temp_idx);
        LM1_adj_resp_Z = current_adj_resp_Z(temp_idx);
        temp_distance_Z_error = current_raw_distance_Z_error(temp_idx);
        for trial_idx = 1:length(LM1_Euclid_distance) % 12
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                LM1_Euclid_distance(trial_idx, 1) = nan; % exclude trials too far away from LMs
                LM1_adj_resp_X(trial_idx, 1) = nan;
                LM1_adj_resp_Z(trial_idx, 1) = nan;
            end
        end
        LM1_Euclid_distance = LM1_Euclid_distance(~isnan(LM1_Euclid_distance));
        LM1_adj_resp_X = LM1_adj_resp_X(~isnan(LM1_adj_resp_X));
        LM1_adj_resp_Z = LM1_adj_resp_Z(~isnan(LM1_adj_resp_Z));
        size(LM1_Euclid_distance) % should be 12, 1   % Subject 47: 10x1 and 11x1
        
        M_X_temp = mean(LM1_adj_resp_X);
        M_Z_temp = mean(LM1_adj_resp_Z);
        disp(['LM1 test mean of resp = [', num2str(M_X_temp), ', ', num2str(M_Z_temp), ']'])
        LM1_arnd_mean_dist_error = nan(length(LM1_adj_resp_X), 1);
        for trial_idx = 1:length(LM1_adj_resp_X)
            LM1_arnd_mean_dist_error(trial_idx, 1) = sqrt((M_X_temp - LM1_adj_resp_X(trial_idx,1))^2 + (M_Z_temp - LM1_adj_resp_Z(trial_idx,1))^2);
        end        
        
        if length(LM1_Euclid_distance) > 1
            mean_Euc_err_1(subject_idx, current_cue_no) = mean(LM1_Euclid_distance);
            var_LM1(subject_idx, current_cue_no) = var(LM1_arnd_mean_dist_error); % we use (N-1) for variance
            std_LM1(subject_idx, current_cue_no) = sqrt(var_LM1(subject_idx, current_cue_no));
            r1(subject_idx, current_cue_no) = 1/var_LM1(subject_idx, current_cue_no);
        end

        
        % 2, LM2 only test: Note here LM1 may be nearLM or FarLM 
        temp_idx = find(current_raw_test_condition == 2 & current_reliable_cue_no == current_cue_no); 
        LM2_Euclid_distance = current_raw_Euclid_distance_error(temp_idx);
        LM2_adj_resp_X = current_adj_resp_X(temp_idx);
        LM2_adj_resp_Z = current_adj_resp_Z(temp_idx);
        temp_distance_Z_error = current_raw_distance_Z_error(temp_idx);
        for trial_idx = 1:length(LM2_Euclid_distance)
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                LM2_Euclid_distance(trial_idx, 1) = nan; % exclude trials too far away from LMs
                LM2_adj_resp_X(trial_idx, 1) = nan;
                LM2_adj_resp_Z(trial_idx, 1) = nan;
            end
        end
        LM2_Euclid_distance = LM2_Euclid_distance(~isnan(LM2_Euclid_distance)); 
        LM2_adj_resp_X = LM2_adj_resp_X(~isnan(LM2_adj_resp_X));
        LM2_adj_resp_Z = LM2_adj_resp_Z(~isnan(LM2_adj_resp_Z));   
        size(LM2_Euclid_distance) % Subject 47: 10x1 and 11x1
        
        M_X_temp = mean(LM2_adj_resp_X);
        M_Z_temp = mean(LM2_adj_resp_Z);
        disp(['LM2 test mean of resp = [', num2str(M_X_temp), ', ', num2str(M_Z_temp), ']'])
        LM2_arnd_mean_dist_error = nan(length(LM2_adj_resp_X), 1);
        for trial_idx = 1:length(LM2_adj_resp_X)
            LM2_arnd_mean_dist_error(trial_idx, 1) = sqrt((M_X_temp - LM2_adj_resp_X(trial_idx,1))^2 + (M_Z_temp - LM2_adj_resp_Z(trial_idx,1))^2);
        end        
        
        if length(LM2_Euclid_distance) > 1
            mean_Euc_err_2(subject_idx, current_cue_no) = mean(LM2_Euclid_distance);
            var_LM2(subject_idx, current_cue_no) = var(LM2_arnd_mean_dist_error);
            std_LM2(subject_idx, current_cue_no) = sqrt(var_LM2(subject_idx, current_cue_no));
            r2(subject_idx, current_cue_no) = 1/var_LM2(subject_idx, current_cue_no);
        end

        
        
        
        
        % 3, Compound test: observed compound cue
        temp_idx = find(current_raw_test_condition == 0 & current_reliable_cue_no == current_cue_no); 
        both_Euclid_distance = current_raw_Euclid_distance_error(temp_idx);
        both_adj_resp_X = current_adj_resp_X(temp_idx);
        both_adj_resp_Z = current_adj_resp_Z(temp_idx);
        temp_distance_Z_error = current_raw_distance_Z_error(temp_idx);
        for trial_idx = 1:length(both_Euclid_distance)
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                both_Euclid_distance(trial_idx, 1) = nan; % exclude trials too far away from LMs
                both_adj_resp_X(trial_idx, 1) = nan;
                both_adj_resp_Z(trial_idx, 1) = nan;
            end
        end
        both_Euclid_distance = both_Euclid_distance(~isnan(both_Euclid_distance));
        both_adj_resp_X = both_adj_resp_X(~isnan(both_adj_resp_X));
        both_adj_resp_Z = both_adj_resp_Z(~isnan(both_adj_resp_Z));
        M_X_temp = mean(both_adj_resp_X);
        M_Z_temp = mean(both_adj_resp_Z);
        both_arnd_mean_dist_error = nan(length(both_adj_resp_X), 1);
        disp(['Compound test mean of resp = [', num2str(M_X_temp), ', ', num2str(M_Z_temp), ']'])
        for trial_idx = 1:length(both_adj_resp_X)
            both_arnd_mean_dist_error(trial_idx, 1) = sqrt((M_X_temp - both_adj_resp_X(trial_idx,1))^2 + (M_Z_temp - both_adj_resp_Z(trial_idx,1))^2);
        end

        if length(both_Euclid_distance) > 1
            mean_Euc_err_both(subject_idx, current_cue_no) = mean(both_Euclid_distance);
            var_both(subject_idx, current_cue_no) = var(both_arnd_mean_dist_error);
            std_both(subject_idx, current_cue_no) = sqrt(var_both(subject_idx, current_cue_no));
        end
        
        
        
        
        % 4, Shift test
        temp_idx = find(current_raw_test_condition == 3 & current_reliable_cue_no == current_cue_no); 
        shift_Euclid_distance = current_raw_Euclid_distance_error(temp_idx); % should we use this for shift trials???
        shift_adj_resp_X = current_adj_resp_X(temp_idx);
        shift_adj_resp_Z = current_adj_resp_Z(temp_idx);
        temp_distance_Z_error = current_raw_distance_Z_error(temp_idx);
        for trial_idx = 1:length(shift_Euclid_distance)
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                shift_Euclid_distance(trial_idx, 1) = nan; % exclude trials too far away from LMs
                shift_adj_resp_X(trial_idx, 1) = nan;
                shift_adj_resp_Z(trial_idx, 1) = nan;
            end
        end
        shift_Euclid_distance = shift_Euclid_distance(~isnan(shift_Euclid_distance));
        shift_adj_resp_X = shift_adj_resp_X(~isnan(shift_adj_resp_X));
        shift_adj_resp_Z = shift_adj_resp_Z(~isnan(shift_adj_resp_Z));
        M_X_temp = mean(shift_adj_resp_X);
        M_Z_temp = mean(shift_adj_resp_Z);
        shift_arnd_mean_dist_error = nan(length(shift_adj_resp_X), 1);
        disp(['Shift test mean of resp = [', num2str(M_X_temp), ', ', num2str(M_Z_temp), ']'])
        for trial_idx = 1:length(shift_adj_resp_X)
            shift_arnd_mean_dist_error(trial_idx, 1) = sqrt((M_X_temp - shift_adj_resp_X(trial_idx,1))^2 + (M_Z_temp - shift_adj_resp_Z(trial_idx,1))^2);
        end
        
        if length(shift_Euclid_distance) > 1
            mean_Euc_err_shift(subject_idx, current_cue_no) = mean(shift_Euclid_distance);
            var_shift(subject_idx, current_cue_no) = var(shift_arnd_mean_dist_error);
            std_shift(subject_idx, current_cue_no) = sqrt(var_shift(subject_idx, current_cue_no));
        end
        
    end
    
    
    % -------------------- Consider all trials -------------------%
    for current_cue_no = 3
        disp(''); disp('--- Consider all trials: ---')
        
        for trial_idx = 1:total_trial_no
            if current_reliable_cue_no(trial_idx, 1) == 2 
            % If LM2 is the closer LM, then flip the distance error so that
            % LM1 will be reliable cue across trials for later averaging steps. 
            % we only do this for current_cue_no = 3!!
                current_adj_resp_X(trial_idx, 1) = current_adj_resp_X(trial_idx, 1) * (-1);
            end
        end
        
        % reliability of single cue:
        % LM1 trials with reliable cue = LM1 should equal LM2 trials with reliable cue = LM2. 
        % LM1 trials with reliable cue = LM2 should equal LM2 trials with reliable cue = LM1. 
        
        % 1, NearLM test: we need to consider two situations: LM1 = NearLM and LM2 = NearLM separately        
        temp_idx = find(current_raw_test_condition == 1 & current_reliable_cue_no == 1); 
        LM1_Euclid_distance = current_raw_Euclid_distance_error(temp_idx);
        LM1_adj_resp_X = current_adj_resp_X(temp_idx);
        LM1_adj_resp_Z = current_adj_resp_Z(temp_idx);
        temp_distance_Z_error = current_raw_distance_Z_error(temp_idx);
        for trial_idx = 1:length(LM1_Euclid_distance) % 12
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                LM1_Euclid_distance(trial_idx, 1) = nan; % exclude trials too far away from LMs
                LM1_adj_resp_X(trial_idx, 1) = nan;
                LM1_adj_resp_Z(trial_idx, 1) = nan;
            end
        end
        LM1_Euclid_distance = LM1_Euclid_distance(~isnan(LM1_Euclid_distance));
        LM1_adj_resp_X = LM1_adj_resp_X(~isnan(LM1_adj_resp_X));
        LM1_adj_resp_Z = LM1_adj_resp_Z(~isnan(LM1_adj_resp_Z));
        
        temp_idx = find(current_raw_test_condition == 2 & current_reliable_cue_no == 2); 
        LM2_Euclid_distance = current_raw_Euclid_distance_error(temp_idx);
        LM2_adj_resp_X = current_adj_resp_X(temp_idx);
        LM2_adj_resp_Z = current_adj_resp_Z(temp_idx);
        temp_distance_Z_error = current_raw_distance_Z_error(temp_idx);
        for trial_idx = 1:length(LM2_Euclid_distance) % 12
            % we do not need to flip trials
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                LM2_Euclid_distance(trial_idx, 1) = nan; % exclude trials too far away from LMs
                LM2_adj_resp_X(trial_idx, 1) = nan;
                LM2_adj_resp_Z(trial_idx, 1) = nan;
            end
        end
        LM2_Euclid_distance = LM2_Euclid_distance(~isnan(LM2_Euclid_distance));
        LM2_adj_resp_X = LM2_adj_resp_X(~isnan(LM2_adj_resp_X));
        LM2_adj_resp_Z = LM2_adj_resp_Z(~isnan(LM2_adj_resp_Z));
        
        % now combine the two situations: 
        adj_resp_X = [LM1_adj_resp_X; LM2_adj_resp_X];
        adj_resp_Z = [LM1_adj_resp_Z; LM2_adj_resp_Z];
        M_X(subject_idx, 1) = mean(adj_resp_X);
        M_Z(subject_idx, 1) = mean(adj_resp_Z);
        disp(['NearLM test mean of resp = [', num2str(M_X(subject_idx, 1)), ', ', num2str(M_Z(subject_idx, 1)), ']'])
        RC_arnd_mean_dist_error = nan(length(adj_resp_X), 1);
        for trial_idx = 1:length(adj_resp_X)
            RC_arnd_mean_dist_error(trial_idx, 1) = sqrt((M_X(subject_idx, 1) - adj_resp_X(trial_idx,1))^2 + (M_Z(subject_idx, 1) - adj_resp_Z(trial_idx,1))^2);
        end
        
        RC_Euclid_distance_error = [LM1_Euclid_distance; LM2_Euclid_distance]; % single reliable cue; i.e., closer LM
        if length(RC_Euclid_distance_error) > 1
            mean_Euc_err_1(subject_idx, current_cue_no) = mean(RC_Euclid_distance_error);
            var_LM1(subject_idx, current_cue_no) = var(RC_arnd_mean_dist_error ); % we use (N-1) for variance
            std_LM1(subject_idx, current_cue_no) = sqrt(var_LM1(subject_idx, current_cue_no));
            r1(subject_idx, current_cue_no) = 1/var_LM1(subject_idx, current_cue_no);
        end
        size(RC_Euclid_distance_error)
        
        
        % 2, FarLM test: we need to consider two situations: LM1 = NearLM and LM2 = NearLM separately 
        temp_idx = find(current_raw_test_condition == 1 & current_reliable_cue_no == 2); 
        LM1_Euclid_distance = current_raw_Euclid_distance_error(temp_idx);
        LM1_adj_resp_X = current_adj_resp_X(temp_idx);
        LM1_adj_resp_Z = current_adj_resp_Z(temp_idx);
        temp_distance_Z_error = current_raw_distance_Z_error(temp_idx);
        for trial_idx = 1:length(LM1_Euclid_distance) % 12
            % we do not need to flip trials
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                LM1_Euclid_distance(trial_idx, 1) = nan; % exclude trials too far away from LMs
                LM1_adj_resp_X(trial_idx, 1) = nan;
                LM1_adj_resp_Z(trial_idx, 1) = nan;
            end
        end
        LM1_Euclid_distance = LM1_Euclid_distance(~isnan(LM1_Euclid_distance));
        LM1_adj_resp_X = LM1_adj_resp_X(~isnan(LM1_adj_resp_X));
        LM1_adj_resp_Z = LM1_adj_resp_Z(~isnan(LM1_adj_resp_Z));
        
        temp_idx = find(current_raw_test_condition == 2 & current_reliable_cue_no == 1); 
        LM2_Euclid_distance = current_raw_Euclid_distance_error(temp_idx);
        LM2_adj_resp_X = current_adj_resp_X(temp_idx);
        LM2_adj_resp_Z = current_adj_resp_Z(temp_idx);
        temp_distance_Z_error = current_raw_distance_Z_error(temp_idx);
        for trial_idx = 1:length(LM2_Euclid_distance)
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                LM2_Euclid_distance(trial_idx, 1) = nan; % exclude trials too far away from LMs
                LM2_adj_resp_X(trial_idx, 1) = nan;
                LM2_adj_resp_Z(trial_idx, 1) = nan;
            end
        end
        LM2_Euclid_distance = LM2_Euclid_distance(~isnan(LM2_Euclid_distance));
        LM2_adj_resp_X = LM2_adj_resp_X(~isnan(LM2_adj_resp_X));
        LM2_adj_resp_Z = LM2_adj_resp_Z(~isnan(LM2_adj_resp_Z));
        
        % now combine the two situations: 
        adj_resp_X = [LM1_adj_resp_X; LM2_adj_resp_X];
        adj_resp_Z = [LM1_adj_resp_Z; LM2_adj_resp_Z];
        M_X(subject_idx, 2) = mean(adj_resp_X);
        M_Z(subject_idx, 2) = mean(adj_resp_Z);
        disp(['FarLM test mean of resp = [', num2str(M_X(subject_idx, 2)), ', ', num2str(M_Z(subject_idx, 2)), ']'])
        UC_arnd_mean_dist_error = nan(length(adj_resp_X), 1);
        for trial_idx = 1:length(adj_resp_X)
            UC_arnd_mean_dist_error(trial_idx, 1) = sqrt((M_X(subject_idx, 2) - adj_resp_X(trial_idx,1))^2 + (M_Z(subject_idx, 2) - adj_resp_Z(trial_idx,1))^2);
        end
        
        UC_Euclid_distance_error = [LM1_Euclid_distance; LM2_Euclid_distance]; % single unreliable cue; i.e., farther LM
        if length(UC_Euclid_distance_error) > 1
            mean_Euc_err_2(subject_idx, current_cue_no) = mean(UC_Euclid_distance_error);
            var_LM2(subject_idx, current_cue_no) = var(UC_arnd_mean_dist_error);
            std_LM2(subject_idx, current_cue_no) = sqrt(var_LM2(subject_idx, current_cue_no));
            r2(subject_idx, current_cue_no) = 1/var_LM2(subject_idx, current_cue_no);
        end
        size(UC_Euclid_distance_error)

        % Note: matrices with 1 means single reliable cue; matrices with 2 means
        % single unreliable cue.
        
        
        
        % 3, Compound test: observed compound cue
        temp_idx = find(current_raw_test_condition == 0); 
        both_Euclid_distance = current_raw_Euclid_distance_error(temp_idx);
        both_adj_resp_X = current_adj_resp_X(temp_idx);
        both_adj_resp_Z = current_adj_resp_Z(temp_idx);
        temp_distance_Z_error = current_raw_distance_Z_error(temp_idx);
        for trial_idx = 1:length(both_Euclid_distance)
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                both_Euclid_distance(trial_idx, 1) = nan; % exclude trials too far away from LMs
                both_adj_resp_X(trial_idx, 1) = nan;
                both_adj_resp_Z(trial_idx, 1) = nan;
            end
        end
        both_Euclid_distance = both_Euclid_distance(~isnan(both_Euclid_distance));
        both_adj_resp_X = both_adj_resp_X(~isnan(both_adj_resp_X));
        both_adj_resp_Z = both_adj_resp_Z(~isnan(both_adj_resp_Z));
        M_X(subject_idx, 3) = mean(both_adj_resp_X);
        M_Z(subject_idx, 3) = mean(both_adj_resp_Z);
        both_arnd_mean_dist_error = nan(length(both_adj_resp_X), 1);
        disp(['Compound test mean of resp = [', num2str(M_X(subject_idx, 3)), ', ', num2str(M_Z(subject_idx, 3)), ']'])
        for trial_idx = 1:length(both_adj_resp_X)
            both_arnd_mean_dist_error(trial_idx, 1) = sqrt((M_X(subject_idx, 3) - both_adj_resp_X(trial_idx,1))^2 + (M_Z(subject_idx, 3) - both_adj_resp_Z(trial_idx,1))^2);
        end

        if length(both_Euclid_distance) > 1
            mean_Euc_err_both(subject_idx, current_cue_no) = mean(both_Euclid_distance);
            var_both(subject_idx, current_cue_no) = var(both_arnd_mean_dist_error);
            std_both(subject_idx, current_cue_no) = sqrt(var_both(subject_idx, current_cue_no));
        end
        
        

        % 4, Shift test
        temp_idx = find(current_raw_test_condition == 3);
        shift_Euclid_distance = current_raw_Euclid_distance_error(temp_idx); % should we use this for shift trials???
        shift_adj_resp_X = current_adj_resp_X(temp_idx);
        shift_adj_resp_Z = current_adj_resp_Z(temp_idx);
        temp_distance_Z_error = current_raw_distance_Z_error(temp_idx);
        for trial_idx = 1:length(shift_Euclid_distance)
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                shift_Euclid_distance(trial_idx, 1) = nan; % exclude trials too far away from LMs
                shift_adj_resp_X(trial_idx, 1) = nan;
                shift_adj_resp_Z(trial_idx, 1) = nan;
            end
        end
        shift_Euclid_distance = shift_Euclid_distance(~isnan(shift_Euclid_distance));
        shift_adj_resp_X = shift_adj_resp_X(~isnan(shift_adj_resp_X));
        shift_adj_resp_Z = shift_adj_resp_Z(~isnan(shift_adj_resp_Z));
        M_X(subject_idx, 4) = mean(shift_adj_resp_X);
        M_Z(subject_idx, 4) = mean(shift_adj_resp_Z);
        shift_arnd_mean_dist_error = nan(length(shift_adj_resp_X), 1);
        disp(['Shift test mean of resp = [', num2str(M_X(subject_idx, 4)), ', ', num2str(M_Z(subject_idx, 4)), ']'])
        for trial_idx = 1:length(shift_adj_resp_X)
            shift_arnd_mean_dist_error(trial_idx, 1) = sqrt((M_X(subject_idx, 4) - shift_adj_resp_X(trial_idx,1))^2 + (M_Z(subject_idx, 4) - shift_adj_resp_Z(trial_idx,1))^2);
        end
        
        if length(shift_Euclid_distance) > 1
            mean_Euc_err_shift(subject_idx, current_cue_no) = mean(shift_Euclid_distance);
            var_shift(subject_idx, current_cue_no) = var(shift_arnd_mean_dist_error);
            std_shift(subject_idx, current_cue_no) = sqrt(var_shift(subject_idx, current_cue_no));
        end
        
        
        % pause and plot to check:
        Fig2 = figure;
        subplot(2,2,1)
        h = histogram(RC_arnd_mean_dist_error);
        hold on
        plot([mean(RC_arnd_mean_dist_error) mean(RC_arnd_mean_dist_error)], [0 max(h.Values)+2])
        title('NearLM')
        
        subplot(2,2,2)
        h = histogram(UC_arnd_mean_dist_error);
        hold on
        plot([mean(UC_arnd_mean_dist_error) mean(UC_arnd_mean_dist_error)], [0 max(h.Values)+2])
        title('FarLM')
        
        subplot(2,2,3)
        h = histogram(both_arnd_mean_dist_error);
        hold on
        plot([mean(both_arnd_mean_dist_error) mean(both_arnd_mean_dist_error)], [0 max(h.Values)+2])
        title('Compound')
        
        subplot(2,2,4)
        h = histogram(shift_arnd_mean_dist_error);
        hold on
        plot([mean(shift_arnd_mean_dist_error) mean(shift_arnd_mean_dist_error)], [0 max(h.Values)+2])
        title('Shift')
        
        sgtitle(['Around mean distance error, S', num2str(current_subID)])
        close(Fig2)
        
        % Note: matrices with 1 means single reliable cue (nearLM); matrices with 2 means
        % single unreliable cue (farLM).

    end
    
end
disp('----- Calculation DONE -----')

open M_X


%% save mean response location of each test (for later analysis)
note = 'Mean response location of each test across trials; regardless of which reliable cue.';
note2 = 'Columns 1-4: Condition Near, Far, Both, Shift.'
save('SLM_mean_resp_location_all.mat', ... % this is the name of the workspace
    'M_X', 'M_Z', 'note', 'note2' ) % these are the variables to be saved
disp(' '); disp('----- mean_resp_location_all *saving* DONE -----'); disp(' ')



%%




