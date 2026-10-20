%% compare models

clear all; clc
cd('E:\1 Landmark integration project\Data analysis\behavioral')


load CLM_AIC_by_model_compd_ow.mat
CLM_AIC_compd = [AIC_MC, AIC_MA, AIC_MAC]; % combination, competition, SS
CLM_AIC_compd(1, :) = []; % remove nan 

load CLM_AIC_by_model_shift_rp.mat
CLM_AIC_shift = [AIC_MC, AIC_MA, AIC_MAC]; 
CLM_AIC_shift(1, :) = []; % remove nan 

load SLM_AIC_by_model_compd_ow.mat
SLM_AIC_compd = [AIC_MC, AIC_MA, AIC_MAC]; 
load SLM_AIC_by_model_shift_rp.mat
SLM_AIC_shift = [AIC_MC, AIC_MA, AIC_MAC]; 


load CLM_behav_f1_value_all.mat
CLM_f1_value_all = f1_value_all;
CLM_f1_value_all(1, :) = []; % remove nan 

load SLM_behav_f1_value_all.mat
SLM_f1_value_all = f1_value_all;

% Columns: Compound test using ow, Shift using ow, shift using rp



%% ΔAIC analysis across participants
all_categories = nan(38, 4);
all_best_counts = nan(7, 4);
all_akaike_wts = cell(4, 1);
all_delta_AIC_to_SS = cell(4, 1);
clc

for test_idx = 1:4
    disp(['plot_idx = ', num2str(test_idx)])
    
    if test_idx == 1 
        current_AIC_mtx = CLM_AIC_compd;
    elseif test_idx == 2 
        current_AIC_mtx = CLM_AIC_shift;
    elseif test_idx == 3 
        current_AIC_mtx = SLM_AIC_compd;
    elseif test_idx == 4 
        current_AIC_mtx = SLM_AIC_shift;
    end

    totalSub = length(current_AIC_mtx(:,1));

    % Per-participant ΔAIC
    min_AIC = min(current_AIC_mtx, [], 2);  % totalSub x 1: best AIC per participant
    delta_AIC = current_AIC_mtx - min_AIC;  % totalSub x 3: ΔAIC per model per participant
    % any(delta_AIC(:) < 0)
    
    delta_AIC_to_SS = current_AIC_mtx(:,1:2) - current_AIC_mtx(:,3);  % totalSub x 2: ΔAIC per model per participant
%     find(delta_AIC_to_SS ==0)
    all_delta_AIC_to_SS{test_idx, 1} = delta_AIC_to_SS;
    
    % Best model counts (ΔAIC == 0)
    plausible = delta_AIC <= 2;   % logical matrix (36 × 3)

    category = zeros(totalSub,1);

    for subID_idx = 1:totalSub
        p = plausible(subID_idx,:);

        if isequal(p, [1 0 0])
            category(subID_idx) = 1;  % MC only
        elseif isequal(p, [0 1 0])
            category(subID_idx) = 2;  % MA only
        elseif isequal(p, [0 0 1])
            category(subID_idx) = 3;  % MAC only
            
        elseif isequal(p, [1 1 0])
            category(subID_idx) = 4;  % MC or MA
        elseif isequal(p, [1 0 1])
            category(subID_idx) = 5;  % MC or MAC
        elseif isequal(p, [0 1 1])
            category(subID_idx) = 6;  % MA or MAC
            
        elseif isequal(p, [1 1 1])
            category(subID_idx) = 7;  % Not clear
        end
    end
    
    best_counts = accumarray(category, 1, [7 1]);
    
    all_categories(1:totalSub, test_idx) = category;
    all_best_counts(:, test_idx) = best_counts; 

    labels = {
        'MC only'
        'MA only'
        'MAC only'
        'MC or MA'
        'MC or MAC'
        'MA or MAC'
        'Not clear'
    };
    table(labels, best_counts)
    
    sum(best_counts) == size(current_AIC_mtx,1) % sanity check


    model_names = {'Combination', 'Competition', 'SS'};
    median_delta = median(delta_AIC, 1);  % 1 x 3


    %  Akaike weights per participant, then average across participants
    
    % Akaike weight: The probability that model is the best model for prediction 
    % among the set of models considered.
    
    % Akaike weight is a normalized relative likelihood
    % A probability-like weight (they sum to 1 across models)
    % A way to quantify model uncertainty
    % Higher weight = lower expected information loss

    delta_AIC_wts = delta_AIC / 2;  % Divide by 2 for weights
    exp_delta = exp(-delta_AIC_wts);  % totalSub x 3; relative likelihood
    akaike_wts = exp_delta ./ sum(exp_delta, 2);  % Normalize per row (participant)
    mean_akaike_wts = mean(akaike_wts, 1);  % Average across participants: 1 x 3
    median_akaike_wts = median(akaike_wts, 1);  
    all_akaike_wts{test_idx, 1} = akaike_wts; 


    % if we only consider two models: Combination vs Competition: 
    min_AIC_Alt_to_comb = min(current_AIC_mtx(:,1:2), [], 2);  % totalSub x 1: best AIC per participant
    delta_AIC_Alt_to_comb = current_AIC_mtx(:,1:2) - min_AIC_Alt_to_comb;  % totalSub x 2: ΔAIC per model per participant
    delta_AIC_wts_Alt_to_comb = delta_AIC_Alt_to_comb / 2;  % Divide by 2 for weights
    exp_delta_Alt_to_comb = exp(-delta_AIC_wts_Alt_to_comb);  % totalSub x 2; relative likelihood
    akaike_wts_Alt_to_comb = exp_delta_Alt_to_comb ./ sum(exp_delta_Alt_to_comb, 2);  % Normalize per row (participant)


    results_table = table(...
        categorical(model_names'), ...
        best_counts(1:3,1), ...
        median_delta', ...
        median_akaike_wts', ...
        'VariableNames', {'Model', 'N_Best', 'MedianDeltaAIC', 'Median_Akaike_Weight'});

    disp('Summary Table:');
    disp(results_table);

end

open all_categories, open all_best_counts, open all_akaike_wts, open all_delta_AIC_to_SS




%%









