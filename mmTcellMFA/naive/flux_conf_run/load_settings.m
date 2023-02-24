%%% ADD DIR TO PATHS %%%
path_scripts = '../../../mfa_scripts/';
path_runscripts = '../../../run_scripts/';
path_case = '../';
path_expmt = './';
path_data = '../data/';

gem_file = '../mmTcell_GEM_completeMFA.xlsx';
amm_file = '../mmTcell_AMM_completeMFA.xlsx';
expmt_files = {'data_expmt1.xlsx', 'data_expmt2.xlsx', 'data_expmt3.xlsx'};
expmt_ids = {'expmt1', 'expmt2', 'expmt3'};

addpath(path_scripts, path_case, path_expmt, path_runscripts)


% Constraining flux bounds for selected reactions
% vbs = {rxn_id, val, error}
% if vbfrombestfit = true, val will be replaced with
% the value of best fit extracted from res.mat
vbset = true;
vbfrombestfit = true;
vbs = {{'EX_glc__D_e.f', 0, 0.01},...
    {'EX_gln__L_e.f', 0, 0.01},...
    {'FECOOR_m.f', 0, 0.01},...
    {'BIOMASS_c.f', 0, 0.0001},...
    {'EX_ala__L_e.f', 0, 0.01},...
    {'EX_arg__L_e.f', 0, 0.01},...
    {'EX_asp__L_e.f', 0, 0.01},...
    {'EX_gly_e.f', 0, 0.01},...
    {'EX_pro__L_e.f', 0, 0.01},...
    {'EX_ser__L_e.f', 0, 0.01}
};

% Safe run on/off: if on, enabling saving with v7.3 setting
% Saved MATLAB objects are heavier but this is required for some
% run with large mapping model and/or labeling dataset
run_safe = false;

% Find best-fit enabling
run_bestfit = false;

% Run flux confidence interval estimation enabling
run_fconf = true;
