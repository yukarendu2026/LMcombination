# LMcombination
Data and Code for "Strategy-mediated cue combination"

The following datasets are the behavioural raw data in the landmarks integration project. 

CLM_behavioral_raw_data.xlsx  
For the Compound Learning Group (CLM) in the paper. 

SLM_behavioral_raw_data.xlsx  
For the Single Learning Group (SLM) in the paper. 

Scripts: 

CLM_calculate_mean_resp_location.m  
SLM_calculate_mean_resp_location.m  
For calculating the mean response location across trials for each participant. 

CLM_retrieve_distance_error_by_trial.m  
SLM_retrieve_distance_error_by_trial.m  
For retrieving distance error in each trial from raw data. 

CLM_retrieve_trial_type.m  
SLM_retrieve_trial_type.m  
For retrieving trial type in each trial from raw data. 

CLM_calculate_relative_proximity.m  
SLM_calculate_relative_proximity.m  
For calculating the empirical cue weight (relative proximity) from raw data. 

CLM_calc_optimal_weight.m  
SLM_calc_optimal_weight.m  
For calculating the optimal weight. Also returns the observed SD for each participant. 

logmvnpdf.m  
Calculating log likelihood function. 

CLM_calc_DKL_AIC.m  
SLM_calc_DKL_AIC.m  
For calculating DKL and AIC for each model, and f1 values for the SS model. Also returns the observed SD and predicted SD for each participant. 

AIC_analysis.m  
For comparing AIC between models. 

f1_SD_simulation.m  
For simulation between f1 and SD. 
