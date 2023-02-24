function run_minSSR_func()
    %%% BUILD MODEL %%%
    run('load_settings.m');

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
        fpath = strcat(path_expmt, expmt_files{1});
        fid = expmt_ids{1};
        [mfamodel]=loadexptdata(mfamodel, fpath, fid, false);
    else
        for i = 1:size(expmt_files, 2)
            fpath = strcat(path_expmt, expmt_files{i});
            fid = expmt_ids{i};
            [mfamodel]=loadexptdata(mfamodel, fpath, fid, true);
        end
    end

    % Run EMU
    [emod,emus]=emutracer(mfamodel);

    % Save
    save(strcat(path_expmt, 'models.mat'), 'model', 'mfamodel', 'emus', 'emod');
    toc
    %%% Non-linear minimization of SSR %%%
    %[res, foptCell] = flxestimate_fast(emod, randscale)

    tic
    fprintf('Start non-linear optimization\n')
    [res, foptCell, residualCell] = flxestimate_proper(emod, repeat, randscale);
    
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
