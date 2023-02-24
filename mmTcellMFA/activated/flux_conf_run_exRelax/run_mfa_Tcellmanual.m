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
    run_fluxconf_func(res,emod);
    
    load('./fluxconf.mat');
    save('fluxconf_minset_all.mat', 'res', 'impres');
end
