clear all

cd('E:\1 Landmark integration project\Data analysis\behavioral')

fileName = 'CLM_behavioral_raw_data.xlsx';
sheetName = 'raw data';
% raw_data_all = xlsread(fileName, sheetName);
raw_data_all = readtable(fileName, 'Sheet', sheetName);

raw_subject_no = raw_data_all{:, 1};
raw_test_condition = raw_data_all{:, 5}; % 0 = compound test, 1 = LM1 only, 2 = LM2 only, 3 = shifted
raw_distance_X_error = raw_data_all{:, 14}; % Error along the x axis
raw_distance_Z_error = raw_data_all{:, 15}; % Error along the z axis

raw_Euclidean_distance = raw_data_all{:, 16}; % Euclidean distance error
% ******************************************************************************************

raw_target_X = raw_data_all{:, 8}; 
raw_target_Z = raw_data_all{:, 9}; 
raw_response_X = raw_data_all{:, 12}; 
raw_response_Z = raw_data_all{:, 13}; 
raw_LM_1_X = raw_data_all{:, 19}; 
raw_LM_2_X = raw_data_all{:, 20}; 
raw_dis_target_LM_1 = raw_data_all{:, 21}; 
raw_dis_target_LM_2 = raw_data_all{:, 22}; 

total_trial_no = 96;
subject_total_no = length(raw_subject_no)/total_trial_no;

% [num, txt] = xlsread(fileName, sheetName);
% raw_reliable_cue = txt(2:length(txt), 23);
raw_reliable_cue = raw_data_all{:, 23};

for i = 1:length(raw_reliable_cue)
    if strcmp(raw_reliable_cue{i}, 'LM1')==1
        reliable_cue_no(i,1) = 1;
    elseif strcmp(raw_reliable_cue{i}, 'LM2')==1
        reliable_cue_no(i,1) = 2;
    end
end


for row_idx = 1:subject_total_no
    subject_ID_list(row_idx, 1) = raw_subject_no(row_idx*total_trial_no);
end
subject_ID_list(1,:) = []; % remove subject 1
subject_total_no = length(subject_ID_list);

disp(['subject_total_no = ', num2str(subject_total_no)])




%% we first calculate empirical cue weight using distance (i.e., relative proximity): 

rp1_both = cell(3,1); 
rp2_both = cell(3,1); 
rp1_shift = cell(3,1); 
rp2_shift = cell(3,1); 

rp1_shift_X = cell(3,1); 
rp2_shift_X = cell(3,1); 
rp1_shift_Z = cell(3,1); 
rp2_shift_Z = cell(3,1); 

for subject_idx = 1:subject_total_no
% for subject_idx = 11
    current_subID = subject_ID_list(subject_idx);
    disp(['current_subID = ', num2str(current_subID)])
    
    current_raw_test_condition = raw_test_condition(raw_subject_no == current_subID); % length should be 96
    current_raw_distance_Z_error = raw_distance_Z_error(raw_subject_no == current_subID);
    current_reliable_cue_no = reliable_cue_no(raw_subject_no == current_subID);
    
    current_target_X = raw_target_X(raw_subject_no == current_subID);
    current_target_Z = raw_target_Z(raw_subject_no == current_subID);
    current_response_X = raw_response_X(raw_subject_no == current_subID);
    current_response_Z = raw_response_Z(raw_subject_no == current_subID);
    
    % pause and check target's location
    disp(['How many blocks were target closer to LM2 = ', num2str(length(find(current_target_X(current_target_X > 0)))/4)])
    
    
    temp_distance_Z_error_SD = std(current_raw_distance_Z_error, 'omitnan');
    upper_bound_z_error = mean(current_raw_distance_Z_error, 'omitnan') + 2.5*temp_distance_Z_error_SD;
    lower_bound_z_error = mean(current_raw_distance_Z_error, 'omitnan') - 2.5*temp_distance_Z_error_SD;

    
    % --------------- Consider different reliable cue trials separately --------------%    
    for current_cue_no = 1:2
        % relative proximity on compound trials: (sanity check)
        temp_idx = find(current_raw_test_condition == 0);
        temp_cue_no = current_reliable_cue_no(temp_idx);
        both_target_X = current_target_X(current_raw_test_condition == 0);
        both_target_X = both_target_X(temp_cue_no == current_cue_no);
        both_response_X = current_response_X(current_raw_test_condition == 0);
        both_response_X = both_response_X(temp_cue_no == current_cue_no);
        
        both_target_Z = current_target_Z(current_raw_test_condition == 0);
        both_target_Z = both_target_Z(temp_cue_no == current_cue_no);
        both_response_Z = current_response_Z(current_raw_test_condition == 0);
        both_response_Z = both_response_Z(temp_cue_no == current_cue_no);

        temp_distance_Z_error = current_raw_distance_Z_error(current_raw_test_condition == 0);
        temp_distance_Z_error = temp_distance_Z_error(temp_cue_no == current_cue_no);

        distance_1 = nan(length(both_target_Z), 1);
        distance_2 = nan(length(both_target_Z), 1);
        
        for trial_idx = 1:length(both_target_Z)
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                distance_1(trial_idx,1) = nan; % exclude trials too far away from LMs
                distance_2(trial_idx,1) = nan;
            else
                % distance from response to predicted location by LM1
                distance_1(trial_idx,1) = sqrt((both_response_X(trial_idx,1) - both_target_X(trial_idx,1) )^2 + (both_response_Z(trial_idx,1) - both_target_Z(trial_idx,1))^2); 
                % distance from response to predicted location by LM2
                distance_2(trial_idx,1) = sqrt((both_response_X(trial_idx,1) - both_target_X(trial_idx,1))^2 + (both_response_Z(trial_idx,1) - both_target_Z(trial_idx,1))^2); 
            end
            % rp 1 = distance 2 / (distance 1 + distance 2)
            % rp 2 = distance 1 / (distance 1 + distance 2)
            rp1_both{current_cue_no, 1}(subject_idx, trial_idx) = distance_2(trial_idx,1) / ( distance_1(trial_idx,1) + distance_2(trial_idx,1)); 
            rp2_both{current_cue_no, 1}(subject_idx, trial_idx) = distance_1(trial_idx,1) / ( distance_1(trial_idx,1) + distance_2(trial_idx,1)); 
        end
        
        
        
        % relative proximity on shift trials: 
        temp_idx = find(current_raw_test_condition == 3);
        temp_cue_no = current_reliable_cue_no(temp_idx);
        shift_target_X = current_target_X(current_raw_test_condition == 3);
        shift_target_X = shift_target_X(temp_cue_no == current_cue_no);
        shift_response_X = current_response_X(current_raw_test_condition == 3);
        shift_response_X = shift_response_X(temp_cue_no == current_cue_no);
        
        shift_target_Z = current_target_Z(current_raw_test_condition == 3);
        shift_target_Z = shift_target_Z(temp_cue_no == current_cue_no);
        shift_response_Z = current_response_Z(current_raw_test_condition == 3);
        shift_response_Z = shift_response_Z(temp_cue_no == current_cue_no);
        
        temp_distance_Z_error = current_raw_distance_Z_error(current_raw_test_condition == 3);
        temp_distance_Z_error = temp_distance_Z_error(temp_cue_no == current_cue_no);        
        
        distance_1 = nan(length(shift_target_Z), 1);
        distance_2 = nan(length(shift_target_Z), 1);
        
        for trial_idx = 1:length(shift_target_Z)
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                distance_1(trial_idx,1) = nan; % exclude trials too far away from LMs
                distance_2(trial_idx,1) = nan;
            else
                % distance from response to predicted location by LM1
                distance_1(trial_idx,1) = sqrt((shift_response_X(trial_idx,1) - (shift_target_X(trial_idx,1) - 10))^2 + (shift_response_Z(trial_idx,1) - shift_target_Z(trial_idx,1))^2); 
                % distance from response to predicted location by LM2
                distance_2(trial_idx,1) = sqrt((shift_response_X(trial_idx,1) - (shift_target_X(trial_idx,1) + 10))^2 + (shift_response_Z(trial_idx,1) - shift_target_Z(trial_idx,1))^2); 
            end
            % rp 1 = distance 2 / (distance 1 + distance 2)
            % rp 2 = distance 1 / (distance 1 + distance 2)
            rp1_shift{current_cue_no, 1}(subject_idx, trial_idx) = distance_2(trial_idx,1) / ( distance_1(trial_idx,1) + distance_2(trial_idx,1)); 
            rp2_shift{current_cue_no, 1}(subject_idx, trial_idx) = distance_1(trial_idx,1) / ( distance_1(trial_idx,1) + distance_2(trial_idx,1)); 
        end
        
    end
    
    % -------------------- Consider all trials -------------------%
    for current_cue_no = 3
        disp(''); disp('--- Consider all trials: ---')
        % relative proximity on compound trials: (sanity check)
        temp_idx = find(current_raw_test_condition == 0);
        temp_cue_no = current_reliable_cue_no(temp_idx);
        
        both_target_X = current_target_X(current_raw_test_condition == 0);
        both_response_X = current_response_X(current_raw_test_condition == 0);
        both_target_Z = current_target_Z(current_raw_test_condition == 0);
        both_response_Z = current_response_Z(current_raw_test_condition == 0);
        
        temp_distance_Z_error = current_raw_distance_Z_error(current_raw_test_condition == 0);

        distance_1 = nan(length(both_target_Z), 1);
        distance_2 = nan(length(both_target_Z), 1);
        
        for trial_idx = 1:length(both_target_Z)
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                distance_1(trial_idx,1) = nan; % exclude trials too far away from LMs
                distance_2(trial_idx,1) = nan;
            else
                if temp_cue_no(trial_idx, 1)==1
                    % distance from response to predicted location by LM1
                    distance_1(trial_idx,1) = sqrt((both_response_X(trial_idx,1) - both_target_X(trial_idx,1) )^2 + (both_response_Z(trial_idx,1) - both_target_Z(trial_idx,1))^2); 
                    % distance from response to predicted location by LM2
                    distance_2(trial_idx,1) = sqrt((both_response_X(trial_idx,1) - both_target_X(trial_idx,1))^2 + (both_response_Z(trial_idx,1) - both_target_Z(trial_idx,1))^2); 
                elseif temp_cue_no(trial_idx, 1)==2
                    % distance from response to predicted location by LM2
                    distance_2(trial_idx,1) = sqrt((both_response_X(trial_idx,1) - both_target_X(trial_idx,1) )^2 + (both_response_Z(trial_idx,1) - both_target_Z(trial_idx,1))^2); 
                    % distance from response to predicted location by LM1
                    distance_1(trial_idx,1) = sqrt((both_response_X(trial_idx,1) - both_target_X(trial_idx,1))^2 + (both_response_Z(trial_idx,1) - both_target_Z(trial_idx,1))^2); 
                end
            end
            % rp 1 = distance 2 / (distance 1 + distance 2)
            % rp 2 = distance 1 / (distance 1 + distance 2)
            rp1_both{current_cue_no, 1}(subject_idx, trial_idx) = distance_2(trial_idx,1) / ( distance_1(trial_idx,1) + distance_2(trial_idx,1)); 
            rp2_both{current_cue_no, 1}(subject_idx, trial_idx) = distance_1(trial_idx,1) / ( distance_1(trial_idx,1) + distance_2(trial_idx,1)); 
        end
        
        
        
        
        % relative proximity on shift trials: 
        shift_target_X = current_target_X(current_raw_test_condition == 3);
        shift_response_X = current_response_X(current_raw_test_condition == 3);
        shift_target_Z = current_target_Z(current_raw_test_condition == 3);
        shift_response_Z = current_response_Z(current_raw_test_condition == 3);
        
        temp_distance_Z_error = current_raw_distance_Z_error(current_raw_test_condition == 3);

        distance_1 = nan(length(shift_target_Z), 1); % Note here distance 1 is the distance to the NearLM
        distance_2 = nan(length(shift_target_Z), 1);
        distance_1_X = nan(length(both_target_Z), 1);
        distance_2_X = nan(length(both_target_Z), 1);
        distance_1_Z = nan(length(both_target_Z), 1);
        distance_2_Z = nan(length(both_target_Z), 1); 
        for trial_idx = 1:length(shift_target_Z)
            if temp_distance_Z_error(trial_idx, 1) > upper_bound_z_error || temp_distance_Z_error(trial_idx, 1) < lower_bound_z_error
                distance_1(trial_idx,1) = nan; % exclude trials too far away from LMs
                distance_2(trial_idx,1) = nan;
                distance_1_X(trial_idx,1) = nan; 
                distance_2_X(trial_idx,1) = nan; 
                distance_1_Z(trial_idx,1) = nan; 
                distance_2_Z(trial_idx,1) = nan;
            else
                if temp_cue_no(trial_idx, 1)==1
                    % distance from response to predicted location by LM1
                    distance_1(trial_idx,1) = sqrt((shift_response_X(trial_idx,1) - (shift_target_X(trial_idx,1) - 10))^2 + (shift_response_Z(trial_idx,1) - shift_target_Z(trial_idx,1))^2); 
                    % distance from response to predicted location by LM2
                    distance_2(trial_idx,1) = sqrt((shift_response_X(trial_idx,1) - (shift_target_X(trial_idx,1) + 10))^2 + (shift_response_Z(trial_idx,1) - shift_target_Z(trial_idx,1))^2); 
                    
                    distance_1_X(trial_idx,1) = abs(shift_response_X(trial_idx,1) - (shift_target_X(trial_idx,1) - 10));
                    distance_2_X(trial_idx,1) = abs(shift_response_X(trial_idx,1) - (shift_target_X(trial_idx,1) + 10));
                    distance_1_Z(trial_idx,1) = abs(shift_response_Z(trial_idx,1) - shift_target_Z(trial_idx,1));
                    distance_2_Z(trial_idx,1) = abs(shift_response_Z(trial_idx,1) - shift_target_Z(trial_idx,1));
                    
                elseif temp_cue_no(trial_idx, 1)==2
                    % distance from response to predicted location by LM2
                    distance_2(trial_idx,1) = sqrt((shift_response_X(trial_idx,1) - (shift_target_X(trial_idx,1) - 10))^2 + (shift_response_Z(trial_idx,1) - shift_target_Z(trial_idx,1))^2); 
                    % distance from response to predicted location by LM1
                    distance_1(trial_idx,1) = sqrt((shift_response_X(trial_idx,1) - (shift_target_X(trial_idx,1) + 10))^2 + (shift_response_Z(trial_idx,1) - shift_target_Z(trial_idx,1))^2); 
                    
                    distance_2_X(trial_idx,1) = abs(shift_response_X(trial_idx,1) - (shift_target_X(trial_idx,1) - 10));
                    distance_1_X(trial_idx,1) = abs(shift_response_X(trial_idx,1) - (shift_target_X(trial_idx,1) + 10));
                    distance_2_Z(trial_idx,1) = abs(shift_response_Z(trial_idx,1) - shift_target_Z(trial_idx,1));
                    distance_1_Z(trial_idx,1) = abs(shift_response_Z(trial_idx,1) - shift_target_Z(trial_idx,1)); 
                end
            end
            % rp 1 = distance 2 / (distance 1 + distance 2)
            % rp 2 = distance 1 / (distance 1 + distance 2)
            rp1_shift{current_cue_no, 1}(subject_idx, trial_idx) = distance_2(trial_idx,1) / ( distance_1(trial_idx,1) + distance_2(trial_idx,1)); 
            rp2_shift{current_cue_no, 1}(subject_idx, trial_idx) = distance_1(trial_idx,1) / ( distance_1(trial_idx,1) + distance_2(trial_idx,1)); 
            
            rp1_shift_X{current_cue_no, 1}(subject_idx, trial_idx) = distance_2_X(trial_idx,1) / ( distance_1_X(trial_idx,1) + distance_2_X(trial_idx,1)); 
            rp2_shift_X{current_cue_no, 1}(subject_idx, trial_idx) = distance_1_X(trial_idx,1) / ( distance_1_X(trial_idx,1) + distance_2_X(trial_idx,1)); 
            rp1_shift_Z{current_cue_no, 1}(subject_idx, trial_idx) = distance_2_Z(trial_idx,1) / ( distance_1_Z(trial_idx,1) + distance_2_Z(trial_idx,1)); 
            rp2_shift_Z{current_cue_no, 1}(subject_idx, trial_idx) = distance_1_Z(trial_idx,1) / ( distance_1_Z(trial_idx,1) + distance_2_Z(trial_idx,1)); 
            
        end
    end
end

rp1_shift_X{1, 1} = [];
rp2_shift_X{1, 1} = [];
rp1_shift_Z{1, 1} = [];
rp2_shift_Z{1, 1} = [];
rp1_shift_X{2, 1} = [];
rp2_shift_X{2, 1} = [];
rp1_shift_Z{2, 1} = [];
rp2_shift_Z{2, 1} = [];

disp('----- Calculation DONE -----')



%% save rp
save('CLM_relative_proximity_all.mat', ... % this is the name of the workspace
    'rp1_both', 'rp2_both', 'rp1_shift', 'rp2_shift', ...
    'mean_rp1', 'mean_rp2', 'rp1_shift_X', 'rp2_shift_X', 'rp1_shift_Z', 'rp2_shift_Z' ) % these are the variables to be saved
disp(' '); disp('----- relative_proximity_all *saving* DONE -----'); disp(' ')





%%




