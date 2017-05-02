function [W, Xi, Diagnostics] = mlr_test_latent1(X, Y, numSign, ...
      Tlatentinfo, latentfile, rotate, rawsize, ts_imname, tr_imname, Asubname, NotRatio)
    X = changeOrd(X, numSign);
    latentinfo = cell2mat(Tlatentinfo);
    global LATENT CP SO PSI PSIALL REG FEASIBLE LOSS DISTANCE SETDISTANCE CPGRADIENT STRUCTKERNEL DUALW INIT;

    global FEASIBLE_COUNT;
    FEASIBLE_COUNT = 0;

    CP          = @cuttingPlaneFull_Latent;
    SO          = @separationOracleAUC;
    PSI         = @metricPsiPO;

    if ~MKL
        INIT        = @initializeFull;
        REG         = @regularizeTraceFull;
        STRUCTKERNEL= @structKernelLinear;
        DUALW       = @dualWLinear;
        FEASIBLE    = @feasibleFull;
        CPGRADIENT  = @cpGradientFull;
        DISTANCE    = @distanceFull_Latent;
        SETDISTANCE = @setDistanceFull;
        LOSS        = @lossHinge;
        Regularizer = 'Trace';
    else
        INIT        = @initializeFullMKL;
        REG         = @regularizeMKLFull;
        STRUCTKERNEL= @structKernelMKL;
        DUALW       = @dualWMKL;
        FEASIBLE    = @feasibleFullMKL;
        CPGRADIENT  = @cpGradientFullMKL;
        DISTANCE    = @distanceFullMKL_Latent;
        SETDISTANCE = @setDistanceFullMKL;
        LOSS        = @lossHingeFullMKL;
        Regularizer = 'Trace';
    end

    
    Loss        = 'AUC';
    Feature     = 'metricPsiPO';


    %%%
    % Default k for prec@k, ndcg
    k           = 3;

    %%%
    % Stochastic violator selection?
    STOCHASTIC  = 0;
    batchSize   = n;
    SAMPLES     = 1:n;


    LATENT      = @ComputeLatent;
    PSIALL      = @metricPsiPOALL;
    
    ClassScores = [];

    if isa(Y, 'double')
        Ypos        = [];
        Yneg        = [];
        ClassScores = synthesizeRelevance(Y);

    elseif isa(Y, 'cell') && size(Y,1) == n && size(Y,2) == 2
        dbprint(1, 'Using supplied Ypos/Yneg');
        Ypos        = Y(:,1);
        Yneg        = Y(:,2);

        % Compute the valid samples
        SAMPLES     = find( ~(cellfun(@isempty, Y(:,1)) | cellfun(@isempty, Y(:,2))));
    elseif isa(Y, 'cell') && size(Y,1) == n && size(Y,2) == 1
        dbprint(1, 'Using supplied Ypos/synthesized Yneg');
        Ypos        = Y(:,1);
        Yneg        = [];
        SAMPLES     = find( ~(cellfun(@isempty, Y(:,1))));
    else
        error('MLR:LABELS', 'Incorrect format for Y.');
    end

    %%
    % If we don't have enough data to make the batch, cut the batch
    if STOCHASTIC
        dbprint(1, 'STOCHASTIC OPTIMIZATION: Batch size is %d/%d', batchSize, n);
    end

    Template = setdiff([1:length(X)], SAMPLES);
    
    MAXITER = 200;
  
    batchSize = min([batchSize, length(SAMPLES)]);
 
    hLatent = ones(1,n);
    f_new = 0;num_calls_latent = 0;
    Nrotate = length(rotate);
    Groundtruth = zeros(length(SAMPLES), 1);
    for i = 1:length(SAMPLES)
        Groundtruth(i) = ceil(Y{SAMPLES(i),1}(1) / Nrotate);
    end
    
    while num_calls_latent < LatentITER
%         %%%%1.getLatentSample
        fprintf('MLR: Compute Latent variables, iter: %d /%d \n', num_calls_latent, LatentITER);
        
        
        Diagnostics = struct('loss',                 Loss, ...           % Which loss are we optimizing?
                            'feature',              Feature, ...        % Which ranking feature is used?
                            'k',                    k, ...              % What is the ranking length?
                            'regularizer',          Regularizer, ...    % What regularization is used?
                            'diagonal',             Diagonal, ...       % 0 for full metric, 1 for diagonal
                            'num_calls_SO',         0, ...              % Calls to separation oracle
                            'num_calls_solver',     0, ...              % Calls to solver
                            'time_SO',              0, ...              % Time in separation oracle
                            'time_solver',          0, ...              % Time in solver
                            'time_total',           0, ...              % Total time
                            'f',                    [], ...             % Objective value
                            'num_steps',            [], ...             % Number of steps for each solver run
                            'num_constraints',      [], ...             % Number of constraints for each run
                            'Xi',                   [], ...             % Slack achieved for each run
                            'Delta',                [], ...             % Mean loss for each SO call
                            'gap',                  [], ...             % Gap between loss and slack
                            'C',                    C, ...              % Slack trade-off
                            'epsilon',              E, ...              % Convergence threshold
                            'feasible_count',       FEASIBLE_COUNT, ... % Counter for # svd's
                            'constraint_timer',     ConstraintClock);   % Time before evicting old constraints


        global PsiR;
        global PsiClock;
        PsiR        = {};
        PsiClock    = [];
        Xi          = -Inf;
        Margins     = [];
        H           = [];
        Q           = [];
         
        f_old = f_new;
        hLatent1 = hLatent;
        [PsiLatent, hLatent, Rlatent]        = LATENT(k, X, hLatent, numSign, W, ...
            Ypos, Yneg, batchSize, Template, SAMPLES, ClassScores);
        
        ffile =  fullfile(latentfile, num2str(num_calls_latent));

        index = [0,cumsum(numSign(SAMPLES))];
        hLatent1 = hLatent(SAMPLES)+index(1:end-1);
        ShowLatent(ffile, [latentinfo(hLatent1,:), Rlatent(SAMPLES), Groundtruth],ts_imname, tr_imname, Asubname, rotate, rawsize, 1);

%         if num_calls_latent > 0
%             max(abs(hLatent1 - hLatent))
%             max(abs(W_old(:) - W(:)))
%         end
%         W_old = W;

%         tic;
%         [PsiLatent, hLatent, ord]        = LATENT(k, X, hLatent, numSign, W, ...
%             Ypos, Yneg, batchSize, Template, SAMPLES, ClassScores);
%         toc;
%         tic;
%         [PsiLatent1, hLatent1, ord1]        = ComputeLatent1(k, X, hLatent, numSign, W, ...
%             Ypos, Yneg, batchSize, Template, SAMPLES, ClassScores);
%         toc;
%         t = 1;

        TIME_START = tic();
        fprintf('MLR: Cuttting plane, iter: %d /%d \n', num_calls_latent, LatentITER);
        while Diagnostics.num_calls_solver < MAXITER
            dbprint(1, 'Round %03d', Diagnostics.num_calls_solver);
            % Generate a constraint set
            Termination = 0;
            dbprint(2, 'Calling separation oracle...');
            
            [PsiNew, Mnew, SO_time]     = CP(k, X, hLatent, PsiLatent, numSign, W, Ypos, Yneg, batchSize, Template, SAMPLES, ClassScores);
            Termination                 = LOSS(W, PsiNew, Mnew, 0);

            Diagnostics.num_calls_SO    = Diagnostics.num_calls_SO + 1;
            Diagnostics.time_SO         = Diagnostics.time_SO + SO_time;
            
            Margins     = cat(1, Margins,   Mnew);
            PsiR        = cat(1, PsiR,      PsiNew);
            PsiClock    = cat(1, PsiClock,  0);
            H           = expandKernel(H);
            Q           = expandRegularizer(Q, X, W);
            
            dbprint(2, '\n\tActive constraints    : %d',            length(PsiClock));
            dbprint(2, '\t           Mean loss  : %0.4f',           Mnew);
            dbprint(2, '\t  Current loss Xi     : %0.4f',           Xi);
            dbprint(2, '\t  Termination -Xi < E : %0.4f <? %.04f\n', Termination - Xi, E);
        
            Diagnostics.gap     = cat(1, Diagnostics.gap,   Termination - Xi);
            Diagnostics.Delta   = cat(1, Diagnostics.Delta, Mnew);

            if Termination <= Xi + E
                dbprint(1, 'Done.');
                fprintf('Cutting Plane done in iteration: %d /%d \n', Diagnostics.num_calls_solver, MAXITER);
                break;
            end
            
            dbprint(1, 'Calling solver...');
            PsiClock                        = PsiClock + 1;
            Solver_time                     = tic();
            [W, Xi, Dsolver]                = mlr_admm(C, X, Margins, H, Q);
            Diagnostics.time_solver         = Diagnostics.time_solver + toc(Solver_time);
            Diagnostics.num_calls_solver    = Diagnostics.num_calls_solver + 1;
            
            Diagnostics.Xi                  = cat(1, Diagnostics.Xi, Xi);
            Diagnostics.f                   = cat(1, Diagnostics.f, Dsolver.f);
            Diagnostics.num_steps           = cat(1, Diagnostics.num_steps, Dsolver.num_steps);

            
            %%%
            % Cull the old constraints
            GC          = PsiClock < ConstraintClock;
            Margins     = Margins(GC);
            PsiR        = PsiR(GC);
            PsiClock    = PsiClock(GC);
            H           = H(GC, GC);
            Q           = Q(GC);
            
            Diagnostics.num_constraints = cat(1, Diagnostics.num_constraints, length(PsiR));
        end
        % Finish diagnostics
        Diagnostics.time_total = toc(TIME_START);
        Diagnostics.feasible_count = FEASIBLE_COUNT;
        
        
        Diagnostics.f
        f_new = Diagnostics.f(end);
        if num_calls_latent > 0
            fprintf('Objective function after iteration: %d /%d, %f,%f \n', ...
                num_calls_latent, LatentITER, f_old, f_new);
            if (abs(f_old - Diagnostics.f(end)) < E)
                fprintf('Finished after iteration: %d /%d \n', num_calls_latent, LatentITER);
                break;
            end
        end
        num_calls_latent = num_calls_latent +1;
        
    end

    if num_calls_latent == LatentITER
        fprintf('Maximum iteration reached!\n');
    end
    
end

function H = expandKernel(H)

    global STRUCTKERNEL;
    global PsiR;

    m = length(H);
    H = padarray(H, [1 1], 0, 'post');


    for i = 1:m+1
        H(i,m+1)    = STRUCTKERNEL( PsiR{i}, PsiR{m+1} );
        H(m+1, i)   = H(i, m+1);
    end
end

function Q = expandRegularizer(Q, K, W)

    % FIXME:  2012-01-31 21:34:15 by Brian McFee <bmcfee@cs.ucsd.edu>
    %  does not support unregularized learning

    global PsiR;
    global STRUCTKERNEL REG;

    m           = length(Q);
    Q(m+1,1)    = STRUCTKERNEL(REG(W,K,1), PsiR{m+1});

end

function ClassScores = synthesizeRelevance(Y)

    classes     = unique(Y);
    nClasses    = length(classes);

    ClassScores = struct(   'Y',    Y, ...
                            'classes', classes, ...
                            'Ypos', [], ...
                            'Yneg', []);

    Ypos = cell(nClasses, 1);
    Yneg = cell(nClasses, 1);
    for c = 1:nClasses
        Ypos{c} = (Y == classes(c));
        Yneg{c} = ~Ypos{c};
    end

    ClassScores.Ypos = Ypos;
    ClassScores.Yneg = Yneg;

end
