clear all
cd 'D:\1 Landmark integration project\Data analysis\behavioral'

fileName = 'CLM_behavioral_raw_data.xlsx';
sheetName = 'raw data';
raw_data_all = readtable(fileName, 'Sheet', sheetName);

raw_subject_no = raw_data_all{:, 1};
raw_test_condition = raw_data_all{:, 5}; % 0 = compound test, 1 = LM1 only, 2 = LM2 only, 3 = shifted

total_trial_no = 96;
subject_total_no = length(raw_subject_no)/total_trial_no;

for row_idx = 1:subject_total_no
    subject_ID_list(row_idx, 1) = raw_subject_no(row_idx*total_trial_no);
end

subject_ID_list(1,:) = []; % remove subject 1, pilot subject
subject_total_no = length(subject_ID_list);

raw_reliable_cue = raw_data_all{:, 23};

for i = 1:length(raw_reliable_cue)
    if strcmp(raw_reliable_cue{i}, 'LM1')==1
        reliable_cue_no(i,1) = 1;
    elseif strcmp(raw_reliable_cue{i}, 'LM2')==1
        reliable_cue_no(i,1) = 2;
    end
end


%%
trial_type_all = nan(subject_total_no, total_trial_no); % this is based on LM1/LM2, not nearLM/farLM
reliable_cue_no_all = nan(subject_total_no, total_trial_no);

trial_type_all2 = nan(subject_total_no, total_trial_no); % this is based on nearLM/farLM, not LM1/LM2

for subID_idx = 1:(subject_total_no+1) % including sub 1 here
    for trial_idx = 1:total_trial_no
        trial_type_all(subID_idx, trial_idx) = raw_test_condition( trial_idx+total_trial_no*(subID_idx-1), 1);
        reliable_cue_no_all(subID_idx, trial_idx) = reliable_cue_no(trial_idx+total_trial_no*(subID_idx-1), 1);
        
        if trial_type_all(subID_idx, trial_idx)==1 && reliable_cue_no_all(subID_idx, trial_idx)==1 
        % LM1 only condition and LM1 is the near cue
            trial_type_all2(subID_idx, trial_idx) = 4; % NearLM
        elseif trial_type_all(subID_idx, trial_idx)==1 && reliable_cue_no_all(subID_idx, trial_idx)==2 
        % LM1 only condition and LM2 is the near cue
            trial_type_all2(subID_idx, trial_idx) = 5; % FarLM
        elseif trial_type_all(subID_idx, trial_idx)==2 && reliable_cue_no_all(subID_idx, trial_idx)==1 
        % LM2 only condition and LM1 is the near cue
            trial_type_all2(subID_idx, trial_idx) = 5; % FarLM
        elseif trial_type_all(subID_idx, trial_idx)==2 && reliable_cue_no_all(subID_idx, trial_idx)==2 
        % LM2 only condition and LM2 is the near cue
            trial_type_all2(subID_idx, trial_idx) = 4; % NearLM
            
        elseif trial_type_all(subID_idx, trial_idx)==0 % Compound test
            trial_type_all2(subID_idx, trial_idx) = 0; 
        elseif trial_type_all(subID_idx, trial_idx)==3
            trial_type_all2(subID_idx, trial_idx) = 3; % shift test
        end        
    end
end

% remove the pilot subject Sub 1
trial_type_all(1, :) = [];
reliable_cue_no_all(1, :) = [];
trial_type_all2(1, :) = [];

save('CLM_trial_type_all_subjects.mat', ... % this is the name of the workspace
    'trial_type_all', 'reliable_cue_no_all', 'trial_type_all2' ) % these are the variables to be saved
disp(' '); disp('----- trial_type_all_subjects *saving* DONE -----'); disp(' ')



%%
