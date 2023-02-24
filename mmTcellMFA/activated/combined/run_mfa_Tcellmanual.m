%% LOAD SETTINGS %%
run('load_settings.m');

%% START RUN %%
%% Find best fit %%
if run_bestfit
    tic
    fprintf('Start building model\n')
    % Load stoichiometric model
    model=xls2MFAmodel(gem_file);

    % Load atom mapping model
    [model,mfamodel]=includemapping(model, amm_file);

    % Create default optimization options
    [mfamodel]=defopt(mfamodel);

    % Load experimental data
    if size(expmt_files, 2) == 1
        fpath = strcat(path_data, expmt_files{1});
        fid = expmt_ids{1};
        [mfamodel]=loadexptdata(mfamodel, fpath, fid, false);
    else
        for i = 1:size(expmt_files, 2)
            fpath = strcat(path_data, expmt_files{i});
            fid = expmt_ids{i};
            [mfamodel]=loadexptdata(mfamodel, fpath, fid, true);
        end
    end

    % Run EMU
    [emod,emus]=emutracer(mfamodel);
    
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
        emod.vardata.vb(i_match,1) = vbs{j}{2} - vbs{j}{3};
        emod.vardata.vb(i_match,2) = vbs{j}{2} + vbs{j}{3};
    end
    
    % Save
    save(strcat(path_expmt, 'models.mat'), 'model', 'mfamodel', 'emus', 'emod');
    toc
    %%% Non-linear minimization of SSR %%%
    %[res, foptCell] = flxestimate_fast(emod, randscale)

    tic
    fprintf('Start non-linear optimization\n')
    [res, foptCell, residualCell] = flxestimate_proper(emod, repeat, randscale, 15);
    
    % Compile SSR
    foptNew = zeros(size(foptCell,1), 1);
    for i = 1:size(foptCell,1)
        res_temp = residualCell{i,1};

        ssr_r = 0;
        for j = 1:size(res_temp.residuals.flxfit, 2)
            ssr_r = ssr_r + res_temp.residuals.flxfit(j).SSRES;
        end

        ssr_m = 0;
        for j = 1:size(res_temp.residuals.mdvfit, 2)
            ssr_m = ssr_m + res_temp.residuals.mdvfit(j).SSRES;
        end

        foptNew(i) = ssr_r + ssr_m;
    end

    for i = 1:size(residualCell,1)
        residualCell{i,1}.fmin = foptNew(i);
    end

    foptCell = foptNew;
    [~,i_min] = min(foptCell);
    res = residualCell{i_min,1};
    
    % Save
    save(strcat(path_expmt, 'res.mat'), 'model', 'mfamodel', 'emus', 'emod',...
        'res', 'foptCell', 'residualCell');
    toc
end

%% Find flux confidence interval %%
if run_fconf
    % Load best-fit result
    load('res.mat');
    
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
end
