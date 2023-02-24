# T_cell_MFA
13C MFA analysis of naive and activated mouse CD8+ T cell

This repository provides Supplementary files regarding 13C-metabolic flux analysis (13C-MFA) that are part of the manuscripts:
'Proteome capacity constraints favor respiratory ATP generation'
Yihui Shen, Hoang V. Dinh, Edward Cruz, et al., submitted

References notice: Please cite the paper corresponding to the dataset that you use. The details are provided in the README.md file within the sub-directories. If you use the common resources and scripts, please cite Shen et al., 2022.

File descriptions

1) mfa_scripts
Source MATLAB scripts to run 13C-MFA. Available at https://github.com/maranasgroup/SteadyState-MFA.

2) run_scripts
Scripts that combine and arrange source MATLAB 13C-MFA scripts.

3) resources
Collected resources regarding carbon mappings and other setups to run 13C-MFA scripts

4) mfa
13C-MFA run files and results, arranged by directory for each organism.

    ./mfa/<dataset>/metabolic_rxns_mappings: Metabolic network and carbon mappings of metabolic reactions only. The input files are generated from this metabolic_rxns_mappings and ./resources/dilutions_network_modules.xlsx
    ./mfa/<dataset>/run_files: list of input files for 13C-MFA software run
    ./mfa/<dataset>/result_files: processed output files containing simulated 13C-labeling patterns and best-fit metabolic fluxes

There are the following <dataset> in this repository:

    1 dataset on naive T cell (Shen et al., 2022)
    1 dataset on activated T cell (Shen et al., 2022)
