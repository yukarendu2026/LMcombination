%% Retrieve distance error in behavioral data by trial

clear all

cd('E:\1 Landmark integration project\Data analysis\behavioral')

fileName = 'CLM_behavioral_raw_data.xlsx';
sheetName = 'raw data';
raw_data_all = readtable(fileName, 'Sheet', sheetName);

raw_subject_no = raw_data_all{:, 1};
raw_distance_X_error = raw_data_all{:, 14}; % Error along the x axis
raw_distance_Z_error = raw_data_all{:, 15}; % Error along the z axis
raw_reliable_cue = raw_data_all{:, 23};
raw_Euclidean_distance = raw_data_all{:, 16}; % Euclidean distance

raw_target_X = raw_data_all{:, 8}; 
raw_target_Z = raw_data_all{:, 9}; 
raw_response_X = raw_data_all{:, 12}; 
raw_response_Z = raw_data_all{:, 13}; 
raw_condition = raw_data_all{:, 5}; 

for i = 1:length(raw_reliable_cue)
    if strcmp(raw_reliable_cue{i}, 'LM1')==1
        reliable_cue_no(i,1) = 1;
    elseif strcmp(raw_reliable_cue{i}, 'LM2')==1
        reliable_cue_no(i,1) = 2;
    end
end

total_trial_no = 96;
subject_total_no = length(raw_subject_no)/total_trial_no;

for row_idx = 1:subject_total_no
    subject_ID_list(row_idx, 1) = raw_subject_no(row_idx*total_trial_no);
end
subject_ID_list(1,:) = []; % remove subject 1
subject_total_no = length(subject_ID_list);
disp(['subject_total_no = ', num2str(subject_total_no)])

load('CLM_mean_resp_location_all.mat')
note
note2

%%
distance_X_error_all = nan(subject_total_no, total_trial_no);
distance_Z_error_all = nan(subject_total_no, total_trial_no);
Euclid_distance_all = nan(subject_total_no, total_trial_no);
Ard_mean_distance_all = nan(subject_total_no, total_trial_no);

counter_mtx = nan(subject_total_no+1, 1);
for subID_idx = 1:(subject_total_no+1) % including sub 1 here
    if subID_idx > 1
        current_subject_ID = subject_ID_list(subID_idx-1); % including sub 1 here
    elseif subID_idx == 1
        current_subject_ID = 1;
    end
    disp(' '); disp(['current_subject_ID = ', num2str(current_subject_ID)])

    current_raw_distance_Z_error = raw_distance_Z_error( (1+total_trial_no*(subID_idx-1)):(total_trial_no*subID_idx), 1);
    temp_distance_Z_error_SD = std(current_raw_distance_Z_error);
    upper_bound_z_error = mean(current_raw_distance_Z_error) + 2.5*temp_distance_Z_error_SD;
    lower_bound_z_error = mean(current_raw_distance_Z_error) - 2.5*temp_distance_Z_error_SD;
    disp(['upper_bound_z_error = ', num2str(upper_bound_z_error)])
    disp(['lower_bound_z_error = ', num2str(lower_bound_z_error)])
    
    counter = 0;
    counter2 = 0;
    counter3 = 0;
    for trial_idx = 1:total_trial_no
        distance_X_error_all(subID_idx, trial_idx) = raw_distance_X_error( trial_idx+total_trial_no*(subID_idx-1), 1);
        distance_Z_error_all(subID_idx, trial_idx) = raw_distance_Z_error( trial_idx+total_trial_no*(subID_idx-1), 1);
        Euclid_distance_all(subID_idx, trial_idx) = raw_Euclidean_distance( trial_idx+total_trial_no*(subID_idx-1), 1);

        % around mean distance error: 
        adj_resp_X = raw_response_X( trial_idx+total_trial_no*(subID_idx-1), 1) - raw_target_X( trial_idx+total_trial_no*(subID_idx-1), 1);
        adj_resp_Z = raw_response_Z( trial_idx+total_trial_no*(subID_idx-1), 1) - raw_target_Z( trial_idx+total_trial_no*(subID_idx-1), 1);

        if subID_idx > 1
            if raw_condition( trial_idx+total_trial_no*(subID_idx-1), 1) == 1 && reliable_cue_no( trial_idx+total_trial_no*(subID_idx-1), 1)==1
                Ard_mean_distance_all(subID_idx, trial_idx) = sqrt((M_X(subID_idx-1, 1) - adj_resp_X)^2 + (M_Z(subID_idx-1, 1) - adj_resp_Z)^2);
            elseif raw_condition( trial_idx+total_trial_no*(subID_idx-1), 1) == 1 && reliable_cue_no( trial_idx+total_trial_no*(subID_idx-1), 1)==2
                Ard_mean_distance_all(subID_idx, trial_idx) = sqrt((M_X(subID_idx-1, 2) - adj_resp_X)^2 + (M_Z(subID_idx-1, 2) - adj_resp_Z)^2);

            elseif raw_condition( trial_idx+total_trial_no*(subID_idx-1), 1) == 2 && reliable_cue_no( trial_idx+total_trial_no*(subID_idx-1), 1)==2
                Ard_mean_distance_all(subID_idx, trial_idx) = sqrt((M_X(subID_idx-1, 1) - adj_resp_X)^2 + (M_Z(subID_idx-1, 1) - adj_resp_Z)^2);
            elseif raw_condition( trial_idx+total_trial_no*(subID_idx-1), 1) == 2 && reliable_cue_no( trial_idx+total_trial_no*(subID_idx-1), 1)==1
                Ard_mean_distance_all(subID_idx, trial_idx) = sqrt((M_X(subID_idx-1, 2) - adj_resp_X)^2 + (M_Z(subID_idx-1, 2) - adj_resp_Z)^2);

            elseif raw_condition( trial_idx+total_trial_no*(subID_idx-1), 1) == 0 
                Ard_mean_distance_all(subID_idx, trial_idx) = sqrt((M_X(subID_idx-1, 3) - adj_resp_X)^2 + (M_Z(subID_idx-1, 3) - adj_resp_Z)^2);

            elseif raw_condition( trial_idx+total_trial_no*(subID_idx-1), 1) == 3
                Ard_mean_distance_all(subID_idx, trial_idx) = sqrt((M_X(subID_idx-1, 4) - adj_resp_X)^2 + (M_Z(subID_idx-1, 4) - adj_resp_Z)^2);
            end
        end
        
        if reliable_cue_no(trial_idx+total_trial_no*(subID_idx-1), 1)==2
            distance_X_error_all(subID_idx, trial_idx) = distance_X_error_all(subID_idx, trial_idx)*(-1);
            % If LM2 is the closer LM, then flip the distance error so that
            % LM1 will be reliable cue across trials for later averaging
            % steps. 
            counter = counter + 1; % should be 48
        end
        
        % exclude trials too far away from LMs
        if raw_distance_Z_error(trial_idx+total_trial_no*(subID_idx-1), 1) > upper_bound_z_error ...
                || raw_distance_Z_error(trial_idx+total_trial_no*(subID_idx-1), 1) < lower_bound_z_error
            
            distance_X_error_all(subID_idx, trial_idx) = nan;
            distance_Z_error_all(subID_idx, trial_idx) = nan;
            Euclid_distance_all(subID_idx, trial_idx) = nan;
            Ard_mean_distance_all(subID_idx, trial_idx) = nan;
            counter2 = counter2 + 1; 
            disp(['NAN trial_idx = ', num2str(trial_idx)])
        end
        counter_mtx(subID_idx, 1) = counter2;
    end
end

% remove the pilot subject Sub 1
distance_X_error_all(1, :) = [];
distance_Z_error_all(1, :) = [];
counter_mtx(1, :) = [];
Euclid_distance_all(1, :) = [];
Ard_mean_distance_all(1, :) = [];

note = 'Excluded if z error exceeds 2.5*SD';
save('distance_X_error_all.mat', ... % this is the name of the workspace
    'distance_X_error_all', 'distance_Z_error_all', 'Euclid_distance_all', ...
    'Ard_mean_distance_all', 'note', 'counter_mtx' ) % these are the variables to be saved
disp(' '); disp('----- distance_X_error_all *saving* DONE -----'); disp(' ')



%% 





