function [res, foptCell, residualCell] = flxestimate_proper(emod, repeat, randscale, pivot_max, randseed)
% Flux estimation function
% Sarat's flxestimate edited by Hoang Dinh

% Setting scale to variation using random function
% If do not set scaling for randomization, set scaling to
% 100 mmolglucose/gDW/h
if nargin < 3
    randscale = 100;
end

% Setting seed of random function for reproducibility (not yet functional)
if nargin < 5
    rng('shuffle')
else
    rng(randseed)
end

if nargin < 2
    repeat = 100;
end

if nargin < 4
    pivot_max = 5;
end

N = emod.vardata.N;
nu = emod.vardata.nu;
nh = sum([emod.data.nh]);
A = [N;-N];
A = blkdiag(A,eye(nh));
b = emod.vardata.vb;
b(:,2) = -1*b(:,2);
b = b(:);
b = [b;1e-7*ones(nh,1)];

foptCell = zeros(repeat,1);
residualCell = cell(repeat,1);

fopt_repeat = Inf;
xopt_repeat = 0;

for i = 1:repeat
    fprintf('Repeat %.d\n', i)
    [x,actcon] = initialize(emod, randscale);
    if isnan(x(1))
        fprintf('Initialized guess is NaN at initialize step, skip run\n')
        continue
    end
    
    % Initial run: step size = emod.options.dfbase (set in defopt)
    [x_inirun,f_inirun,~,actcon_inirun] = lsqsolve(x,emod,A,b,actcon);
    if isnan(x_inirun(1))
        fprintf('Initialized guess is NaN at the very first lsqsolve step, skip run\n')
        continue
    end
    
    xopt = x_inirun;
    res_temp = compileresult(xopt,emod);
    fopt = res_temp.fmin;
 
    % Local perturbation run: wriggle around solution from initial run
    % Replace initial run solution with solution obtained after wriggling
    % Step size: MATLAB's limit
    emod.options.dfbase = eps;
    iter = 1;
    fail = true;
    x = xopt;
    f = fopt;
    ac = actcon_inirun;
    actcon = actcon_inirun;
    while fail || iter <= pivot_max
        [x,f,fail,ac] = lsqsolve(x,emod,A,b,actcon);
        if isnan(x(1))
            fprintf('Solved solution is NaN at lsqsolve loop step, break while loop\n')
            break
        end
        
        res_temp = compileresult(x,emod);
        f = res_temp.fmin;
        
        if f < fopt
            xopt = x;
            fopt = f;
            actcon = ac;
        end
        iter = iter+1;
    end
    
    % Record all "repeat"
    res_temp = compileresult(xopt,emod);
    residualCell(i) = {res_temp};
    fopt = res_temp.fmin;
    foptCell(i) = fopt;
    
    % Compare solutions to current optimal across "repeat"
    if fopt < fopt_repeat
        fopt_repeat = fopt;
        xopt_repeat = xopt;
    end
    
end

res = compileresult(xopt_repeat,emod);

end

