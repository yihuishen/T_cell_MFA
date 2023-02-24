%% LOAD SETTINGS %%
run('load_settings.m');

%% START RUN %%
%% Find flux confidence interval %%
if run_fconf
    % Load best-fit result
    load('../combined/res.mat');
    
    % Set bounds
    for j = 1:size(vbs,2)
        i_match = 0;
        vbmat = vbs{j};
        for i = 1:size(emod.vardata.flxdata,2)
            if strcmp(cell2mat(emod.vardata.flxdata(i).name), vbs{j}{1})
                i_match = i;
                break
            end
        end
        if vbfrombestfit
            vbs{j}{2} = res.fluxes(i_match).val;
        end
        emod.vardata.vb(i_match,1) = vbs{j}{2} - vbs{j}{3};
        emod.vardata.vb(i_match,2) = vbs{j}{2} + vbs{j}{3};
    end
    
    % Determine flux confidence interval
    custom_ids = {'EX_glc__D_e.f', 'EX_gln__L_e.f', 'EX_lac__L_e.f',...
        'EX_glu__L_e.f', 'FECOOR_m.f', 'EX_ala__L_e.f', 'EX_arg__L_e.f',...
        'EX_asp__L_e.f', 'EX_gly_e.f', 'EX_ile__L_e.f', 'EX_leu__L_e.f',...
        'EX_lys__L_e.f', 'EX_met__L_e.f', 'EX_phe__L_e.f', 'EX_pro__L_e.f',...
        'EX_ser__L_e.f', 'EX_thr__L_e.f', 'EX_val__L_e.f', 'SK_accoa_c.f',...
        'G6PDH2i_c.f', 'ICDHyi_c.f'
        };
    custom_index = zeros(1, size(custom_ids,2));
    for j = 1:size(custom_ids, 2)
        for i = 1:size(emod.vardata.flxdata,2)
            if strcmp(cell2mat(emod.vardata.flxdata(i).name), custom_ids{j})
                custom_index(j) = i;
                break
            end
        end
    end
    
    emod.options.conf_set = 'custom';
    emod.options.custom = custom_index;
    run_fluxconf_func(res,emod);
    
    load('fluxconf.mat');
    fileID = fopen('fluxconfcustom.txt','w');
    bounds_manual = cell(1,size(custom_index,2));
    
    for j = 1:size(custom_index,2)
        fprintf(fileID, custom_ids{j});
        fprintf(fileID, '\t');
        
        fluxindex = custom_index(j);
        vLB = res.fluxes(fluxindex).vLB;
        vUB = res.fluxes(fluxindex).vUB;
        fprintf(fileID, '%.6f\t%.6f', [vLB, vUB]);
        fprintf(fileID, '\n');
        
        bounds_manual{j} = {custom_ids{j}, vLB, vUB};
    end
    fclose(fileID);
    
    load('fluxconf_minset_all.mat');
    for j = 1:size(custom_index,2)
        fluxindex = custom_index(j);
        res.fluxes(fluxindex).vLB = bounds_manual{j}{2};
        res.fluxes(fluxindex).vUB = bounds_manual{j}{3};
    end
    save('fluxconf_rerun_appended.mat', 'res', 'impres');
    
end
