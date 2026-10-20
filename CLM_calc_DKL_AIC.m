%% Calculate Kullback-Leibler Divergence (DKL) and AIC for behavioral data (signed
% distance error after flipped)

% Both DKL and AIC showed consistent results. We report AIC in the paper. 

% This script is for the Compound Learning Group. 


%% load data
clear all; clc

cd('E:\1 Landmark integration project\Data analysis\behavioral')
load('CLM_distance_X_error_all.mat')
% note: distance_X_error_all is flipped; do not flip again!!!
flipped_raw_dist_X = distance_X_error_all; % this is the flipped error!! 

load('CLM_trial_type_all_subjects.mat')

subID_list = [... % Subject 2 is pilot subject
2;  3;  5;  4;  6;
7;  8; 10; 12; 14;
152;16; 17; 19; 21;
23; 24; 26; 28; 22;
29; 30; 31; 32; 34;
35; 36; 37; 38; 40;
41; 39; 42; 43; 44;
45; 87];
totalSub = length(subID_list);

excluded_subj_list = [2];

disp('----- loading done -----')


%% observed weight (rp)
load('CLM_relative_proximity_all.mat')
% open rp1_shift_X

mean_p1_X = nan(totalSub, 3);
mean_p2_X = nan(totalSub, 3);
for current_cue_no = 3
    for subID_idx = 2:totalSub
        temp_mtx = rp1_shift_X{current_cue_no}(subID_idx, :);
        temp_mtx = temp_mtx(temp_mtx ~= 0);
        temp_mtx = temp_mtx(~isnan(temp_mtx));
        mean_p1_X(subID_idx,current_cue_no) = mean(temp_mtx);
        
        temp_mtx = rp2_shift_X{current_cue_no}(subID_idx, :);
        temp_mtx = temp_mtx(temp_mtx ~= 0);
        temp_mtx = temp_mtx(~isnan(temp_mtx));
        mean_p2_X(subID_idx,current_cue_no) = mean(temp_mtx);
    end
end

% mean_p1_X(:, 3) is the rp1 for each participant. 


%% Empirical (Monte Carlo) approach

% Choose Xb_idx for compound test (X3), shift test (X4), or predicted combination (X12_common; for debug)
choice = menu('Select Xb_idx:', ...
    'Compound Test (X3)', ...
    'Shift Test (X4)', ...
    'X12_common for debug');

if choice == 1
    Xb_idx = 1;
    disp('--- Observation = Compound test ---')
elseif choice == 2
    Xb_idx = 2;
    disp('--- Observation = shift test ---')
elseif choice == 3
    Xb_idx = 3;
    disp('--- Observation = X12 common (for debug) ---')
else
    % User closed the window
    Xb_idx = [];
    error('--- No selection was made for Xb_idx ---')
end

% Choose weight_idx for optimal weight (w1, w2) or observed weight (rp1, rp2)
choice = menu('Select weight_idx:', ...
    'Optimal weight (w1, w2)', ...
    'Observed weight (rp1, rp2)');

if choice == 1
    weight_idx = 1;
    disp('--- Using optimal weight (ow) ---')
elseif choice == 2
    weight_idx = 2;
    disp('--- Using observed weight (rp) ---')
else
    % User closed the window
    weight_idx = [];
    error('--- No selection was made for weight_idx ---')
end


disp('--- Calculating DKL matrix: Empirical (Monte Carlo) approach ---')
DKL_Alt_all = nan(totalSub, 1); 
DKL_Opt_all = nan(totalSub, 1); 
DKL_Opt_all_dependent = nan(totalSub, 1); 
min_f1_all = nan(totalSub, 1); 
min_DKL_MAC_all = nan(totalSub, 1);  

pred_SD_MAC = nan(totalSub,1);
pred_SD_MC = nan(totalSub,1);
pred_SD_MA = nan(totalSub,1);
observed_SD = nan(totalSub,1);

AIC_MC = nan(totalSub,1);
AIC_MA = nan(totalSub,1);
AIC_MAC = nan(totalSub,1);
min_AIC_MAC_all = nan(totalSub,1);
min_f1_AIC_all = nan(totalSub,1); 

mu_MC_all = nan(totalSub, 1); % for debug


disp('-----')

for subID_idx = 1:totalSub
%     for subID_idx = 31
    current_subID = subID_list(subID_idx);
    disp(' '); disp(['current_subID = ', num2str(current_subID)])

    if ismember(current_subID, excluded_subj_list)==0 
        % ----------- prepare data: -----------
        current_subj_data = (flipped_raw_dist_X(subID_idx, :))';
        k = size(current_subj_data, 2);

        temp_idx = find(trial_type_all2(subID_idx, :) == 4);
        X1_raw = current_subj_data(temp_idx, :);
        temptemp_idx = find(~isnan(X1_raw(:,1)));
        X1 = X1_raw(temptemp_idx, :);

        temp_idx = find(trial_type_all2(subID_idx, :) == 5);
        X2_raw = current_subj_data(temp_idx, :);
        temptemp_idx = find(~isnan(X2_raw(:,1)));
        X2 = X2_raw(temptemp_idx, :);

        % For debug: Find intersection of trial indices (common trials)
        X1_trials = find(~isnan(X1_raw(:,1)));
        X2_trials = find(~isnan(X2_raw(:,1)));
        [common_trials, ia, ib] = intersect(X1_trials, X2_trials);
        X1_common = X1_raw(common_trials, :);   % size m x features, m = number of common trials
        X2_common = X2_raw(common_trials, :);

        if Xb_idx ~= 3
            mu1_hat = mean(X1);
            mu2_hat = mean(X2);
            sd1_hat = std(X1);
            sd2_hat = std(X2);
        elseif Xb_idx == 3
            mu1_hat = mean(X1_common);
            mu2_hat = mean(X2_common);
            sd1_hat = std(X1_common);
            sd2_hat = std(X2_common);
        end

        temp_idx = find(trial_type_all2(subID_idx, :) == 0);
        X3_raw = current_subj_data(temp_idx, :);
        temptemp_idx = find(~isnan(X3_raw(:,1)));
        X3 = X3_raw(temptemp_idx, :);

        temp_idx = find(trial_type_all2(subID_idx, :) == 3); % shift
        X4_raw = current_subj_data(temp_idx, :);
        temptemp_idx = find(~isnan(X4_raw(:,1)));
        X4 = X4_raw(temptemp_idx, :);

        Fig = figure;
        subplot(3, 2, 1)
        h = histogram(current_subj_data, 30);
        title('Signed distance error after flip (all trials, no removal)')
        counts = h.Values;
        binEdges = h.BinEdges;
        binCenters = binEdges(1:end-1) + diff(binEdges)/2;

        subplot(3, 2, 3)
        hold on
        histogram(X1_common)
        title('X1 common')

        subplot(3, 2, 4)
        hold on
        histogram(X2_common)
        title('X2 common')

        subplot(3, 2, 5)
        hold on
        histogram(X3)
        title('X3')

        subplot(3, 2, 6)
        hold on
        histogram(X4)
        title('X4')

        sgtitle(['Sub ', num2str(current_subID)])
        close(Fig)


        % ----------- prepare parameters: -----------
        % if we use signed distance error: 
        if Xb_idx ~= 3
            if weight_idx == 1
                w1 = var(X2)/(var(X1) + var(X2));
                w2 = 1 - w1;
            elseif weight_idx == 2
                w1 = mean_p1_X(subID_idx, 3);
                w2 = mean_p2_X(subID_idx, 3);
            end
        elseif Xb_idx == 3 % For debug:
            w1 = var(X2_common)/(var(X1_common) + var(X2_common));
            w2 = 1 - w1;
            %  Form compound X12 only where both present
            X12_common = w1 * X1_common + w2 * X2_common;
            disp(['mean(X12_common) = ', num2str(mean(X12_common))])
            disp(['std(X12_common) = ', num2str(std(X12_common))])
            disp(['cov(X12_common) = ', num2str(cov(X12_common))])
        end

        % Combination Model: 
        if Xb_idx == 1 
           mu_MC = w1 * 0 + w2 * 0; 
        elseif Xb_idx == 2
           mu_MC = w1*(-10)+ w2*10; % assume mu1 = -10, mu2 = 10
        elseif Xb_idx == 3
           mu_MC = w1 * mu1_hat + w2 * mu2_hat; % = mean(X12_common)
        end
        mu_MC_all(subID_idx, 1) = mu_MC;
        % sd_MC = sqrt((sd1_hat^2*sd2_hat^2)/(sd1_hat^2+sd2_hat^2));
        sd_MC = sqrt(w1^2*sd1_hat^2 + w2^2*sd2_hat^2);

        % For debug only: cross-covariance scalar (univariate). For multivariate keep matrix form.
        X1c = X1_common - mu1_hat;
        X2c = X2_common - mu2_hat;
        C_X1X2 = (X1c' * X2c) / (size(X1_common,1)-1); % scalar covariance between X1 and X2

        var_MC_dependent = w1^2 * sd1_hat^2 + w2^2 * sd2_hat^2 + 2*w1*w2* C_X1X2; % = var(X12_common)
        sd_MC_dependent = sqrt(var_MC_dependent);
        disp(['sd_MC = ', num2str(sd_MC)])
        disp(['sd_MC_dependent = ', num2str(sd_MC_dependent)])
        % sd_MC_dependent is not appropriate for our combination model
        % because cues are independent. 
        % When X1, X2 total trial numbers are not matched (Xb_idx==1 or 2), 
        % the sd_MC_dependent calculation is not correct. 

        % Competition model: 
        mu_alt = mu_MC;
        if Xb_idx == 1
            var_alt = w1*(sd1_hat^2) + w2*(sd2_hat^2);
        elseif Xb_idx == 2
            var_alt = w1*(sd1_hat^2 + (-10 - mu_alt)^2) + w2*(sd2_hat^2 + (+10 - mu_alt)^2);
%                 there are two ways to write the equation for var_alt: 
%                 var_alt = w1*(sd1_hat^2 + (-10)^2) + w2*(sd2_hat^2 + 10^2) - mu_alt^2;
        elseif Xb_idx == 3
            var_alt = w1*(sd1_hat^2 + (mu1_hat - mu_alt)^2) + w2*(sd2_hat^2 + (mu2_hat - mu_alt)^2);
        end
        sd_alt = sqrt(var_alt);            
        disp(['sd_alt = ', num2str(sd_alt)])


        % ----------- DKL calculation -----------
        % Observation (distribution P): 
        if Xb_idx == 1
            Xb = X3;
        elseif Xb_idx == 2
            Xb = X4;
        elseif Xb_idx == 3
            Xb = X12_common;
        end
        [n, k] = size(Xb);
        muP = mean(Xb);
        sdP = std(Xb);
        disp(['sdP = ', num2str( sdP )])
        SigmaP = cov(Xb);
        % when using mvnpdf, the covariance matrix must be symmetric and positive definite.
        tol = eps * norm(SigmaP, 'fro');   % relative to matrix size/scale; sometimes getting isymmetric due to machine precision
        isSym = max(max(abs(SigmaP - SigmaP.'))) < tol; % Returns true if SigmaP is symmetric.
        [~, chol_p] = chol(SigmaP); % Check positive definiteness (Cholesky decomposition)
%             [chol, chol_p] = chol(SigmaP); % Check positive definiteness (Cholesky decomposition)
        % if chol_p == 0, SigmaP is positive definite and we are good to progreed
        if chol_p ~= 0
        % Regularize SigmaP
            disp('%%%%%% Regularize SigmaP')
            lambda = 1e-3 * mean(diag(SigmaP));  % scale-aware
            SigmaP = SigmaP + lambda*eye(k);
        end
        logp_x = logmvnpdf(Xb, muP, SigmaP);

        % Mixture Q: 2 components (Competition Model)
        pQ = [w1, w2];
        musQ = [mu1_hat, mu2_hat];  
        % Covariance matrices (unbiased, divisor n-1)
        if Xb_idx ~= 3
            C_X1 = cov(X1); 
            C_X2 = cov(X2); 
        elseif Xb_idx == 3 % for debug
            C_X1 = cov(X1_common); 
            C_X2 = cov(X2_common); 
        end
        SigmasQ = {C_X1, C_X2};

        tol = eps * norm(C_X1, 'fro');   % relative to matrix size/scale
        isSym = max(max(abs(C_X1 - C_X1.'))) < tol; % Returns true if SigmaP is symmetric.
        [~, chol_p] = chol(C_X1); % if chol_p = 0 then good to proceed
        if chol_p ~= 0
        % Regularize SigmaQ component
            disp('%%%%%% Regularize SigmasQ{1}')
            lambda = 1e-3 * mean(diag(SigmasQ{1} ));  % scale-aware
            Sig_k_1 = SigmasQ{1} + lambda*eye(k);
        else 
            Sig_k_1 = SigmasQ{1};
        end

        tol = eps * norm(C_X2, 'fro');   % relative to matrix size/scale
        isSym = max(max(abs(C_X2 - C_X2.'))) < tol; % Returns true if SigmaP is symmetric.
        [~, chol_p] = chol(C_X2); % if chol_p = 0 then good to proceed
        if chol_p ~= 0
        % Regularize SigmaQ component
            disp('%%%%%% Regularize SigmasQ{2}')
            lambda = 1e-3 * mean(diag(SigmasQ{2} ));  % scale-aware
            Sig_k_2 = SigmasQ{2} + lambda*eye(k);
        else 
            Sig_k_2 = SigmasQ{2};
        end

        if Xb_idx == 1 || Xb_idx == 3
            logf1 = logmvnpdf(Xb, mu1_hat, Sig_k_1);
            logf2 = logmvnpdf(Xb, mu2_hat, Sig_k_2);
        elseif Xb_idx == 2
            logf1 = logmvnpdf(Xb, -10, Sig_k_1);
            logf2 = logmvnpdf(Xb, +10, Sig_k_2);
        end

        logs = [log(pQ(1)) + logf1, log(pQ(2)) + logf2];
        m = max(logs, [], 2); % 1×24, per-sample max across components
        logq_x_alt = m + log(exp(logs(:,1) - m) + exp(logs(:,2) - m)); % log-sum-exp trick
        DKL_MA = mean(logp_x - logq_x_alt);

        % Combination Model: 
        SigmaQ_dependent = pQ(1)^2 * C_X1 + pQ(2)^2 * C_X2 + pQ(1)*pQ(2)*(C_X1X2 + C_X1X2');
        % SigmaQ_dependent equals C_X12_direct when using w1
        % SigmaQ_dependent = sd_MC_dependent^2 when feature = 1

        SigmaQ_independent = pQ(1)^2 * C_X1 + pQ(2)^2 * C_X2 ;

        tol = eps * norm(SigmaQ_dependent, 'fro');   % relative to matrix size/scale
        isSym = max(max(abs(SigmaQ_dependent - SigmaQ_dependent.'))) < tol; % Returns true if SigmaP is symmetric.
        [~, chol_p] = chol(SigmaQ_dependent); % if chol_p = 0 then good to proceed
        if chol_p ~= 0
            % Regularize SigmaQ_dependent
            disp('%%%%%% Regularize SigmaQ dependent')
            lambda = 1e-3 * mean(diag( SigmaQ_dependent ));  % scale-aware
            SigmaQ_dependent = SigmaQ_dependent + lambda*eye(k);
        end

        tol = eps * norm(SigmaQ_independent, 'fro');   % relative to matrix size/scale
        isSym = max(max(abs(SigmaQ_independent - SigmaQ_independent.'))) < tol; % Returns true if SigmaP is symmetric.
        [~, chol_p] = chol(SigmaQ_independent); % if chol_p = 0 then good to proceed
        if chol_p ~= 0
            % Regularize SigmaQ_independent
            disp('%%%%%% Regularize SigmaQ independent')
            lambda = 1e-3 * mean(diag( SigmaQ_independent ));  % scale-aware
            SigmaQ_independent = SigmaQ_independent + lambda*eye(k);
        end            

        logq_x_opt = logmvnpdf(Xb, mu_MC, SigmaQ_independent);
        DKL_MC = mean(logp_x - logq_x_opt);

        logq_x_opt2 = logmvnpdf(Xb, mu_MC, SigmaQ_dependent);
        DKL_MC_dependent = mean(logp_x - logq_x_opt2);

        disp(['[DKL_MA, DKL_MC, DKL_MC_dependent] = ', num2str([DKL_MA, DKL_MC, DKL_MC_dependent])])
        DKL_Alt_all(subID_idx, 1) = DKL_MA;
        DKL_Opt_all(subID_idx, 1) = DKL_MC;
        DKL_Opt_all_dependent(subID_idx, 1) = DKL_MC_dependent; 

        % ------------------------------------------------------- %
        % Now consider mixture of combination and Competition: 
        % calculate DKL_MAC to get mininum: 
        DKL_temp = nan(1001, 1);
        AIC_MAC_temp = nan(1001, 1);
        f1 = nan(1001, 1);
        for f1_idx = 1:1001
            prob_f1 = (f1_idx-1)/1000;
            f1(f1_idx,1) = prob_f1;
            logs2 = [log(prob_f1) + logq_x_opt, log(1-prob_f1) + logq_x_alt];
            mm = max(logs2, [], 2);
            logq_x_mix = mm + log(exp(logs2(:,1) - mm) + exp(logs2(:,2) - mm)); % log-sum-exp trick
            % considering the free parameter f1 in MAC (as MAC has one free parameter, penalty=1): 
            logq_x_mix_corrected = logq_x_mix - 1/n;
            DKL_temp(f1_idx,1) = mean(logp_x - logq_x_mix_corrected);
            AIC_MAC_temp(f1_idx,1) = (-2)*sum(logq_x_mix) + 2*1;
        end
        [min_DKL, min_idx] = min(DKL_temp);
        min_DKL_MAC_all(subID_idx, 1) = min_DKL;
        min_f1_all(subID_idx, 1) = f1(min_idx);
        disp(['min_DKL_MAC = ', num2str(min_DKL)])
        disp(['min_f1 = ', num2str(min_f1_all(subID_idx, 1))])

        Figfig = figure; 
        hold on
        plot(f1, DKL_temp, '-')
        plot(min_f1_all(subID_idx, 1), min_DKL, 'ro', 'markerfacecolor', 'r')
%             ylim([0 3])
        title(['Sub ', num2str(current_subID)])
        xlabel('f1 (weight of combination model)')
        ylabel('DKL MAC')
        text(0.3, 0.5*(max(DKL_temp)-min_DKL)+min_DKL, ['min DKL = ', num2str(min_DKL)])
        close(Figfig)
%             open DKL_temp

        [min_AIC, min_AIC_idx] = min(AIC_MAC_temp);
        min_AIC_MAC_all(subID_idx, 1) = min_AIC;
        min_f1_AIC_all(subID_idx, 1) = f1(min_AIC_idx);
        disp(['min_AIC_MAC = ', num2str(min_AIC)])
        disp(['min_f1 = ', num2str(f1(min_AIC_idx))])

        Figfig = figure; 
        hold on
        plot(f1, AIC_MAC_temp, 'k-')
        plot(f1(min_AIC_idx), min_AIC, 'ro', 'markerfacecolor', 'r')
%             ylim([0 3])
        title(['Sub ', num2str(current_subID)])
        xlabel('f1 (weight of combination model)')
        ylabel('AIC MAC')
        text(0.5, 0.5*(max(AIC_MAC_temp)-min_AIC)+min_AIC, ...
            ['f1 = ', num2str(f1(min_AIC_idx)), ', min AIC = ', num2str(min_AIC)])
%             close(Figfig)
%             open AIC_MAC_temp

        % ------------------------------------------------------- %
        % save the predicted SD into matrices: 
        % mixture model: pred var = f1 * var(combination) + (1-f1) * var(Competition)
        pred_SD_MAC(subID_idx, 1) = sqrt(min_f1_all(subID_idx, 1)*(sd_MC^2)+(1-min_f1_all(subID_idx,1))*(sd_alt^2));
        pred_SD_MC(subID_idx, 1) = sd_MC;
        pred_SD_MA(subID_idx, 1) = sd_alt;
        observed_SD(subID_idx, 1) = std(Xb); % observed SD

        % ------------------------------------------------------- %
        % AIC = -2*(sum of log pdf for each observation) 
        AIC_MA(subID_idx, 1) = (-2)*sum(logq_x_alt);
        AIC_MC(subID_idx, 1) = (-2)*sum(logq_x_opt);
        AIC_MAC(subID_idx, 1) = min_AIC;

        % add AIC to figure: 
        plot([0 1], [AIC_MA(subID_idx, 1) AIC_MA(subID_idx, 1)], 'r--')
        plot([0 1], [AIC_MC(subID_idx, 1) AIC_MC(subID_idx, 1)], '--', 'color', [0, 0.5, 0])
        disdis = abs(AIC_MA(subID_idx, 1)- AIC_MC(subID_idx, 1));
        text(0.7, AIC_MA(subID_idx, 1)-0.1*disdis, ['AIC MA = ', num2str(AIC_MA(subID_idx, 1))])
        text(0.7, AIC_MC(subID_idx, 1)-0.1*disdis, ['AIC MC = ', num2str(AIC_MC(subID_idx, 1))])

%             saveas(Figfig, ['Sub_', num2str(current_subID), '_AIC_curve.fig'])
%             saveas(Figfig, ['Sub_', num2str(current_subID), '_AIC_curve.tiff'])
        close(Figfig)
    end
end

% check: 
min_f1_all - min_f1_AIC_all
min_AIC_MAC_all - AIC_MAC

disp('----- Calculation DONE -----')



%% output
open observed_SD
open pred_SD_MC 
open pred_SD_MA 
open pred_SD_MAC 

open min_f1_AIC_all

open AIC_MC
open AIC_MA
open AIC_MAC 


%% save AIC and f1
if Xb_idx == 1 && weight_idx == 1
    saving_name = 'CLM_AIC_by_model_compd_ow.mat';
elseif Xb_idx == 2 && weight_idx == 2
    saving_name = 'CLM_AIC_by_model_shift_rp.mat';
end

save(saving_name, ... 
    'AIC_MC', 'AIC_MA', 'AIC_MAC' ) % these are the variables to be saved
disp(' '); disp('----- Data *saving* DONE -----'); disp(' ')

f1_value_all = min_f1_AIC_all; 
save('CLM_behav_f1_value_all.mat', ... 
    'f1_value_all' ) % these are the variables to be saved
disp(' '); disp('----- Data *saving* DONE -----'); disp(' ')







