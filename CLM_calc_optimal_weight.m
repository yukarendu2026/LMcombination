clear all
cd('E:\1 Landmark integration project\Data analysis\behavioral')
load('CLM_distance_X_error_all.mat')
% note: distance_X_error_all is flipped; do not flip again!!!

load('CLM_trial_type_all_subjects')
load('CLM_mean_resp_location_all.mat')
note2

subject_ID_list = [2;3;5;4;6;7;8;10;12;14;152;16;17;19;21;23;24;26;28;22;29;30;31;32;34;35;36;37;38;40;41;39;42;43;44;45;87];
subject_total_no = length(subject_ID_list);

total_trial_no = 96;


flipped_raw_dist_X = distance_X_error_all;


ard_mean_distance_X = nan(subject_total_no, total_trial_no);
ard_mean_distance_Z = nan(subject_total_no, total_trial_no);
for subID_idx = 1:subject_total_no
    for trial_idx = 1:total_trial_no
        
        if trial_type_all2(subID_idx, trial_idx) == 4 % NearLM test
            ard_mean_distance_X(subID_idx, trial_idx) = sqrt((flipped_raw_dist_X(subID_idx, trial_idx) - M_X(subID_idx, 1))^2);
            ard_mean_distance_Z(subID_idx, trial_idx) = sqrt((distance_Z_error_all(subID_idx, trial_idx) - M_Z(subID_idx, 1))^2);
                
        elseif trial_type_all2(subID_idx, trial_idx) == 5 % FarLM test
            ard_mean_distance_X(subID_idx, trial_idx) = sqrt((flipped_raw_dist_X(subID_idx, trial_idx) - M_X(subID_idx, 2))^2);
            ard_mean_distance_Z(subID_idx, trial_idx) = sqrt((distance_Z_error_all(subID_idx, trial_idx) - M_Z(subID_idx, 2))^2);
            
        elseif trial_type_all2(subID_idx, trial_idx) == 0 % Compound test
            ard_mean_distance_X(subID_idx, trial_idx) = sqrt((flipped_raw_dist_X(subID_idx, trial_idx) - M_X(subID_idx, 3))^2);
            ard_mean_distance_Z(subID_idx, trial_idx) = sqrt((distance_Z_error_all(subID_idx, trial_idx) - M_Z(subID_idx, 3))^2);

        elseif trial_type_all2(subID_idx, trial_idx) == 3 % Shift test
            ard_mean_distance_X(subID_idx, trial_idx) = sqrt((flipped_raw_dist_X(subID_idx, trial_idx) - M_X(subID_idx, 4))^2);
            ard_mean_distance_Z(subID_idx, trial_idx) = sqrt((distance_Z_error_all(subID_idx, trial_idx) - M_Z(subID_idx, 4))^2);
        end
        
    end
end
disp('--- loading done ---')



%% calculate and plot mean and SD of distance error on X and Z axes separately: 
mean_raw_dist_X = nan(subject_total_no, 4);
mean_abs_dist_X = nan(subject_total_no, 4);
mean_raw_dist_Z = nan(subject_total_no, 4);
for subID_idx = 2:subject_total_no
    for cond_idx = 1:4
        if cond_idx == 1
            temp_idx = find(trial_type_all2(subID_idx, :) == 4);
        elseif cond_idx == 2
            temp_idx = find(trial_type_all2(subID_idx, :) == 5);
        elseif cond_idx == 3
            temp_idx = find(trial_type_all2(subID_idx, :) == 0);
        elseif cond_idx == 4
            temp_idx = find(trial_type_all2(subID_idx, :) == 3);
        end
        mean_raw_dist_X(subID_idx, cond_idx) = mean(flipped_raw_dist_X(subID_idx, temp_idx), 'omitnan');
        mean_abs_dist_X(subID_idx, cond_idx) = mean(abs(flipped_raw_dist_X(subID_idx, temp_idx)), 'omitnan');
        mean_raw_dist_Z(subID_idx, cond_idx) = mean(distance_Z_error_all(subID_idx, temp_idx), 'omitnan');
    end
end


% around mean distance (sanity check): 
mean_arnd_mean_dist_X = nan(subject_total_no, 4);
mean_arnd_mean_dist_Z = nan(subject_total_no, 4);
for subID_idx = 2:subject_total_no
    for cond_idx = 1:4
        if cond_idx == 1
            temp_idx = find(trial_type_all2(subID_idx, :) == 4);
        elseif cond_idx == 2
            temp_idx = find(trial_type_all2(subID_idx, :) == 5);
        elseif cond_idx == 3
            temp_idx = find(trial_type_all2(subID_idx, :) == 0);
        elseif cond_idx == 4
            temp_idx = find(trial_type_all2(subID_idx, :) == 3);
        end
        mean_arnd_mean_dist_X(subID_idx, cond_idx) = mean(ard_mean_distance_X(subID_idx, temp_idx), 'omitnan');
        mean_arnd_mean_dist_Z(subID_idx, cond_idx) = mean(ard_mean_distance_Z(subID_idx, temp_idx), 'omitnan');
    end
end


%---------------------------------------------------------------------%
% observed and predicted SD and weight: 
SD_X_error = nan(subject_total_no, 4);
SD_Z_error = nan(subject_total_no, 4);
SD_opt_w_X = nan(subject_total_no,1);
SD_opt_w_Z = nan(subject_total_no,1);
w1_X = nan(subject_total_no,1);
w2_X = nan(subject_total_no,1);
w1_Z = nan(subject_total_no,1);
w2_Z = nan(subject_total_no,1); 
for subID_idx = 2:subject_total_no
    for cond_idx = 1:4
        if cond_idx == 1
            temp_idx = find(trial_type_all2(subID_idx, :) == 4);
        elseif cond_idx == 2
            temp_idx = find(trial_type_all2(subID_idx, :) == 5);
        elseif cond_idx == 3
            temp_idx = find(trial_type_all2(subID_idx, :) == 0);
        elseif cond_idx == 4
            temp_idx = find(trial_type_all2(subID_idx, :) == 3);
        end
        
        temp_mtx = ard_mean_distance_X(subID_idx, temp_idx);
        temp_mtx = temp_mtx(~isnan(temp_mtx));
        SD_X_error(subID_idx, cond_idx) = sqrt(sum(temp_mtx.^2)/(length(temp_mtx)-1));

        temp_mtx = ard_mean_distance_Z(subID_idx, temp_idx);
        temp_mtx = temp_mtx(~isnan(temp_mtx));
        SD_Z_error(subID_idx, cond_idx) = sqrt(sum(temp_mtx.^2)/(length(temp_mtx)-1));
    end
    
    % optimal prediction: 
    SD_opt_w_X(subID_idx, 1) = sqrt((SD_X_error(subID_idx,1)^2*SD_X_error(subID_idx,2)^2)/(SD_X_error(subID_idx,1)^2+SD_X_error(subID_idx,2)^2));
    SD_opt_w_Z(subID_idx, 1) = sqrt((SD_Z_error(subID_idx,1)^2*SD_Z_error(subID_idx,2)^2)/(SD_Z_error(subID_idx,1)^2+SD_Z_error(subID_idx,2)^2));
    
    w1_X(subID_idx, 1) = (SD_X_error(subID_idx,2)^2)/(SD_X_error(subID_idx,1)^2 + SD_X_error(subID_idx,2)^2);
    w2_X(subID_idx, 1) = (SD_X_error(subID_idx,1)^2)/(SD_X_error(subID_idx,1)^2 + SD_X_error(subID_idx,2)^2);
    w1_Z(subID_idx, 1) = (SD_Z_error(subID_idx,2)^2)/(SD_Z_error(subID_idx,1)^2 + SD_Z_error(subID_idx,2)^2);
    w2_Z(subID_idx, 1) = (SD_Z_error(subID_idx,1)^2)/(SD_Z_error(subID_idx,1)^2 + SD_Z_error(subID_idx,2)^2);
end


% calculate predicted variance for competition model:
load('CLM_relative_proximity_all.mat')
% open rp1_shift_X

mean_p1_X = nan(subject_total_no, 3);
mean_p2_X = nan(subject_total_no, 3);
mean_p1_Z = nan(subject_total_no, 3);
mean_p2_Z = nan(subject_total_no, 3);
for current_cue_no = 3
    for subID_idx = 1:subject_total_no
        temp_mtx = rp1_shift_X{current_cue_no}(subID_idx, :);
        temp_mtx = temp_mtx(temp_mtx ~= 0);
        temp_mtx = temp_mtx(~isnan(temp_mtx));
        mean_p1_X(subID_idx,current_cue_no) = mean(temp_mtx);
        temp_mtx = rp2_shift_X{current_cue_no}(subID_idx, :);
        temp_mtx = temp_mtx(temp_mtx ~= 0);
        temp_mtx = temp_mtx(~isnan(temp_mtx));
        mean_p2_X(subID_idx,current_cue_no) = mean(temp_mtx);
        
        temp_mtx = rp1_shift_Z{current_cue_no}(subID_idx, :);
        temp_mtx = temp_mtx(temp_mtx ~= 0);
        temp_mtx = temp_mtx(~isnan(temp_mtx));
        mean_p1_Z(subID_idx,current_cue_no) = mean(temp_mtx);
        temp_mtx = rp2_shift_Z{current_cue_no}(subID_idx, :);
        temp_mtx = temp_mtx(temp_mtx ~= 0);
        temp_mtx = temp_mtx(~isnan(temp_mtx));
        mean_p2_Z(subID_idx,current_cue_no) = mean(temp_mtx);
    end
end

% mean_p1_X(:, 3) is the rp1 for each participant. 

SD_alt_rp_X = nan(subject_total_no, 1);
SD_alt_w_X = nan(subject_total_no, 1); 
SD_alt_w_Z = nan(subject_total_no, 1); 
SD_alt2_rp_X = nan(subject_total_no, 1); 
SD_alt2_w_X = nan(subject_total_no, 1); 
for subID_idx = 2:subject_total_no
    % for shift condition: 
    % Note: we use (-10) and 10 for mu1 and mu2. Actually using any values
    % will get the same output as long as mu1 - mu2 = 20
    SD_alt_rp_X(subID_idx, 1) = sqrt(mean_p1_X(subID_idx, 3) * ((-10)^2 +SD_X_error(subID_idx,1)^2) + mean_p2_X(subID_idx, 3)* (10^2 + SD_X_error(subID_idx,2)^2) - ((mean_p1_X(subID_idx, 3)*(-10)+ mean_p2_X(subID_idx, 3)*10)^2));
    SD_alt_w_X(subID_idx, 1) = sqrt(w1_X(subID_idx, 1) * ((-10)^2 +SD_X_error(subID_idx,1)^2) + w2_X(subID_idx, 1)* (10^2 + SD_X_error(subID_idx,2)^2) - ((w1_X(subID_idx, 1)*(-10)+ w2_X(subID_idx, 1)*10)^2));
    
    % for debug: 
%     SD_alt_rp_X(subID_idx, 1) = sqrt(mean_p1_X(subID_idx, 3) * (mean_raw_dist_X(subID_idx, 1)^2 + SD_X_error(subID_idx,1)^2) + mean_p2_X(subID_idx, 3)* (mean_raw_dist_X(subID_idx, 2)^2 + SD_X_error(subID_idx,2)^2) - ((mean_p1_X(subID_idx, 3)*mean_raw_dist_X(subID_idx, 1)+ mean_p2_X(subID_idx, 3)*mean_raw_dist_X(subID_idx, 2))^2));
%     SD_alt_rp_X(subID_idx, 1) = sqrt(mean_p1_X(subID_idx, 3) * ((mean_raw_dist_X(subID_idx, 1)-(mean_p1_X(subID_idx, 3)*mean_raw_dist_X(subID_idx, 1)+ mean_p2_X(subID_idx, 3)*mean_raw_dist_X(subID_idx, 2)))^2 + SD_X_error(subID_idx,1)^2) ...
%         + mean_p2_X(subID_idx, 3)* ((mean_raw_dist_X(subID_idx, 2) - (mean_p1_X(subID_idx, 3)*mean_raw_dist_X(subID_idx, 1)+ mean_p2_X(subID_idx, 3)*mean_raw_dist_X(subID_idx, 2)))^2 + SD_X_error(subID_idx,2)^2) );

    % for compound condition: 
    SD_alt2_rp_X(subID_idx, 1) = sqrt(mean_p1_X(subID_idx, 3) * ( 0 +SD_X_error(subID_idx,1)^2) + mean_p2_X(subID_idx, 3)* (0 + SD_X_error(subID_idx,2)^2) );
    SD_alt2_w_X(subID_idx, 1) = sqrt(w1_X(subID_idx, 1) * ( 0 +SD_X_error(subID_idx,1)^2) + w2_X(subID_idx, 1)* ( 0 + SD_X_error(subID_idx,2)^2) );

end

mean(SD_alt2_rp_X(2:end,1))
mean(SD_alt2_w_X(2:end,1))




%% save calculated weight:
notenote = 'calculated optimal weight using SD of single cue conditions';
save('CLM_optimal_weight.mat', ... % this is the name of the workspace
    'w1_X', 'w1_Z', 'w2_X', 'w2_Z', 'notenote') % these are the variables to be saved
disp(' '); disp('----- CLM_optimal_weight *saving* DONE -----'); disp(' ')


%% output: 
open SD_X_error
open SD_opt_w_X
open SD_alt2_w_X
open SD_alt_rp_X









