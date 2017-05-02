function [W, Xi, Diagnostics] = rmlr_train_latent_f(selfpaced, W, X, Y, datastr, numSign, CIndex, ...
      Tlatentinfo, latentfile, rotate, rawsize, ts_imname, tr_imname, Asubname, Cslack, varargin)
  
  
  
%   X, Y, Cslack, varargin)
%[W, Xi, D] = rmlr_train(X, Y, C, LOSS, k, REG, Diagonal, stochastic, lam, STRUCTREG)
%
%   [W, Xi, D] = rmlr_train(X, Y, C,...)
%
%       X = d*n data matrix
%       Y = either n-by-1 label of vectors
%           OR
%           n-by-2 cell array where 
%               Y{q,1} contains relevant indices for q, and
%               Y{q,2} contains irrelevant indices for q
%       
%       C >= 0 slack trade-off parameter (default=1)
%
%       W   = the learned metric
%       Xi  = slack value on the learned metric
%       D   = diagnostics
%
%   Optional arguments:
%
%   [W, Xi, D] = rmlr_train(X, Y, C, LOSS)
%       where LOSS is one of:
%           'AUC':      Area under ROC curve (default)
%           'KNN':      KNN accuracy
%           'Prec@k':   Precision-at-k
%           'MAP':      Mean Average Precision
%           'MRR':      Mean Reciprocal Rank
%           'NDCG':     Normalized Discounted Cumulative Gain
%
%   [W, Xi, D] = rmlr_train(X, Y, C, LOSS, k)
%       where k is the number of neighbors for Prec@k or NDCG
%       (default=3)
%
%   [W, Xi, D] = rmlr_train(X, Y, C, LOSS, k, REG)
%       where REG defines the regularization on W, and is one of:
%           0:          no regularization
%           1:          1-norm: trace(W)            (default)
%           2:          2-norm: trace(W' * W)
%           3:          Kernel: trace(W * X), assumes X is square and positive-definite
%
%   [W, Xi, D] = rmlr_train(X, Y, C, LOSS, k, REG, Diagonal)
%   Not implemented as learning a diagonal W metric just reduces to MLR because ||W||_2,1 = trace(W) when W is diagonal. 
%       
%   [W, Xi, D] = rmlr_train(X, Y, C, LOSS, k, REG, Diagonal, B)
%       where B > 0 enables stochastic optimization with batch size B
%
%   [W, Xi, D] = rmlr_train(X, Y, C, LOSS, k, REG, Diagonal, B, lambda)
%	lambda is the desired value of the hyperparameter which is the coefficient of ||W||_2,1. Default is 1 if lambda is not set


   if iscell(X)
        Train_Large = 0;
        X = changeOrd(X, numSign);
    else
        Train_Large = 1;
        X = (cell2mat(X))';
    end
    
    latentinfo = cell2mat(Tlatentinfo);
    
%     TIME_START = tic();

    global C;
    C = Cslack;
    
    [d,n,m] = size(X);

    if m > 1
        MKL = 1;
    else
        MKL = 0;
    end

    if nargin < 16
        C = 1;
    end

    %%%
    % Default options:

    global LATENT CP SO PSI PSIALL REG FEASIBLE LOSS DISTANCE SETDISTANCE CPGRADIENT STRUCTKERNEL DUALW THRESH INIT;
    global RHO;
 

    % </modified>

    global FEASIBLE_COUNT;
    FEASIBLE_COUNT = 0;

    if Train_Large
        CP          = @cuttingPlaneFull_Latent_Large_f;
    else
        CP          = @cuttingPlaneFull_Latent_f;
    end
    
%     CP          = @cuttingPlaneFull;
    SO          = @separationOracleAUC;
    PSI         = @metricPsiPO;
    
    PSIALL      = @metricPsiPOALL;

    if ~MKL
        INIT        = @initializeFull;
        REG         = @regularizeTraceFull;
        STRUCTKERNEL= @structKernelLinear;
        DUALW       = @dualWLinear;
        FEASIBLE    = @feasibleFull;
        THRESH	    = @threshFull_mixed;
        CPGRADIENT  = @cpGradientFull;
        DISTANCE    = @distanceFull;
        SETDISTANCE = @setDistanceFull;
        LOSS        = @lossHinge;
        Regularizer = 'Trace';
    else
        INIT        = @initializeFullMKL;
        REG         = @regularizeMKLFull;
        STRUCTKERNEL= @structKernelMKL;
        DUALW       = @dualWMKL;
        FEASIBLE    = @feasibleFullMKL;
        THRESH	    = @threshFull_mixed;
        CPGRADIENT  = @cpGradientFullMKL;
        DISTANCE    = @distanceFullMKL;
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


    if Train_Large
        LATENT      = @ComputeLatent_large_f;
    else
        LATENT      = @ComputeLatent_f;
    end
    
    PSIALL      = @metricPsiPOALL;
    Latent = 1;
    
    if nargin > 16
        switch lower(varargin{1})
            case {'auc'}
                SO          = @separationOracleAUC;
                PSI         = @metricPsiPO;
                Loss        = 'AUC';
                Feature     = 'metricPsiPO';
            case {'knn'}
                SO          = @separationOracleKNN;
                PSI         = @metricPsiPO;
                Loss        = 'KNN';
                Feature     = 'metricPsiPO';
            case {'prec@k'}
                SO          = @separationOraclePrecAtK;
                PSI         = @metricPsiPO;
                Loss        = 'Prec@k';
                Feature     = 'metricPsiPO';
            case {'map'}
                SO  = @separationOracleMAP;
                PSI = @metricPsiPO;
                Loss        = 'MAP';
                Feature     = 'metricPsiPO';
            case {'mrr'}
                SO          = @separationOracleMRR;
                PSI         = @metricPsiPO;
                Loss        = 'MRR';
                Feature     = 'metricPsiPO';
            case {'ndcg'}
                SO          = @separationOracleNDCG;
                PSI         = @metricPsiPO;
                Loss        = 'NDCG';
                Feature     = 'metricPsiPO';
            otherwise
                error('MLR:LOSS', ...
                    'Unknown loss function: %s', varargin{1});
        end
    end

    if nargin > 17
        k = varargin{2};
    end

    Diagonal = 0;
    %Diagonal case is not implemented. Use mlr_train for that.
    
    if nargin > 18
        switch(varargin{3})
            case {0}
                REG         = @regularizeNone;
                Regularizer = 'None';
                THRESH      = @threshFull_mixed;
            case {1}
                if MKL
                        REG         = @regularizeMKLFull;
                        STRUCTKERNEL= @structKernelMKL;
                        DUALW       = @dualWMKL;
                else
                        REG         = @regularizeTraceFull;
                        STRUCTKERNEL= @structKernelLinear;
                        DUALW       = @dualWLinear;
                end
                Regularizer = 'Trace';

            case {2}
                REG         = @regularizeTwoFull;
                Regularizer = '2-norm';
                error('MLR:REGULARIZER', '2-norm regularization no longer supported');
                

            case {3}
                if MKL
                        REG         = @regularizeMKLFull;
                        STRUCTKERNEL= @structKernelMKL;
                        DUALW       = @dualWMKL;
                else
                        REG         = @regularizeKernel;
                        STRUCTKERNEL= @structKernelMKL;
                        DUALW       = @dualWMKL;
                end
                Regularizer = 'Kernel';

		
            otherwise
                error('MLR:REGULARIZER', ... 
                    'Unknown regularization: %s', varargin{3});
        end
    end


    % Are we in stochastic optimization mode?
    if nargin > 20 && varargin{5} > 0
        if varargin{5} < n
            STOCHASTIC  = 1;
            CP          = @cuttingPlaneRandom;
            batchSize   = varargin{5};
        end
    end
    % Algorithm
    %
    % Working <- []
    %
    % repeat:
    %   (W, Xi) <- solver(X, Y, C, Working)
    %
    %   for i = 1:|X|
    %       y^_i <- argmax_y^ ( Delta(y*_i, y^) + w' Psi(x_i, y^) )
    %
    %   Working <- Working + (y^_1,y^_2,...,y^_n)
    % until mean(Delta(y*_i, y_i)) - mean(w' (Psi(x_i,y_i) - Psi(x_i,y^_i))) 
    %           <= Xi + epsilon

    if nargin > 21
	    lam = varargin{6};
    else
	    lam = 1;
    end

    disp(['lam = ' num2str(lam)])

    global DEBUG;
    
    if isempty(DEBUG)
        DEBUG = 0;
    end

    DEBUG = 1;

    %%%
    % Max calls to seperation oracle
    MAX_CALLS = 200;
    MIN_CALLS = 10;
    %%%
    
    LatentITER = 100;
    IterINIT = 2;
    
    % Timer to eliminate old constraints
    ConstraintClock = 500;

    %%%
    % Convergence criteria for worst-violated constraint
    E = 1e-3;
    
    
    %XXX:    2012-01-31 21:29:50 by Brian McFee <bmcfee@cs.ucsd.edu>
    % no longer belongs here
    % Initialize
    if isempty(W)
        W           = INIT((getLatent(numSign, X)));
    end

    global ADMM_Z ADMM_V ADMM_UW ADMM_UV;
    ADMM_Z      = W;
    ADMM_V      = W;
    ADMM_UW     = 0 * ADMM_Z;
    ADMM_UV     = 0 * ADMM_Z;
 
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

%CCCP
    %%%%
    hLatent = ones(1,n);
    f_new = 0;f_new_relax = 0;
    
    num_calls_latent = 0;
    
    Nrotate = length(rotate);
    Groundtruth = zeros(length(SAMPLES), 1);
    for i = 1:length(SAMPLES)
        Groundtruth(i) = ceil(Y{SAMPLES(i),1}(1) / Nrotate);
    end
    ObjFun = cell(1, LatentITER);
    
    
    PsiLatentM = rand(size(W));
    
    dp = 0;
    Wtmp = cell(1, LatentITER);
    if length(selfpaced)>1 && selfpaced(2) %%%if K > 0
        if selfpaced(2) > 0
            KINIT = 2*batchSize/(C);
        else
            KINIT = inf;
        end
        UPDATESample = 1;
        iter_inner = inf;
    else
        UPDATESample = 0;
        KINIT = 0;
        iter_inner = 1;
    end
    
    Template = setdiff([1:length(X)], SAMPLES);
    %%
    % If we don't have enough data to make the batch, cut the batch
    batchSize = min([batchSize, length(SAMPLES)]);

%     Diagnostics = struct(   'loss',                 Loss, ...           % Which loss are we optimizing?
%                             'feature',              Feature, ...        % Which ranking feature is used?
%                             'k',                    k, ...              % What is the ranking length?
%                             'regularizer',          Regularizer, ...    % What regularization is used?
%                             'diagonal',             Diagonal, ...       % 0 for full metric, 1 for diagonal
%                             'num_calls_SO',         0, ...              % Calls to separation oracle
%                             'num_calls_solver',     0, ...              % Calls to solver
%                             'time_SO',              0, ...              % Time in separation oracle
%                             'time_solver',          0, ...              % Time in solver
%                             'time_total',           0, ...              % Total time
%                             'f',                    [], ...             % Objective value
%                             'num_steps',            [], ...             % Number of steps for each solver run
%                             'num_constraints',      [], ...             % Number of constraints for each run
%                             'Xi',                   [], ...             % Slack achieved for each run
%                             'Delta',                [], ...             % Mean loss for each SO call
%                             'gap',                  [], ...             % Gap between loss and slack
%                             'C',                    C, ...              % Slack trade-off
%                             'epsilon',              E, ...              % Convergence threshold
%                             'feasible_count',       FEASIBLE_COUNT, ... % Counter for # svd's
%                             'constraint_timer',     ConstraintClock);   % Time before evicting old constraints



    global PsiR;
    global PsiClock;

    PsiR        = {};
    PsiClock    = [];

    Xi          = -Inf;
    Margins     = [];
    H           = [];
    Q           = [];

    if STOCHASTIC
        dbprint(1, 'STOCHASTIC OPTIMIZATION: Batch size is %d/%d', batchSize, n);
    end

    OBJF = [];
    
    
    dbprint(1,['Regularizer is "' Regularizer '"']);
    
        while num_calls_latent < LatentITER

%         %%%%1.getLatentSample
        fprintf('MLR: Compute Latent variables, iter: %d /%d \n', num_calls_latent, LatentITER);
        f_old = f_new;
        RLatent = ones(size(hLatent));

        if UPDATESample && num_calls_latent >= IterINIT   %%%%find latent
            [PsiLatent, hLatent, RLatent, tord, TS, PsiS]        = LATENT(k, X, hLatent, RLatent, numSign, W, ...
                Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores);
        else
            [PsiLatent, hLatent, RLatent]        = LATENT(k, X, hLatent, RLatent, numSign, W, ...
                Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores);
        end
            
        
        TIME_START = tic();
        Wbest = W;
        prev_valid_examples = SAMPLES;
        XH = getLatent(numSign, X, hLatent);
        iter = 0;
        
        while iter < iter_inner 
            W = Wbest;
            PsiR        = {};
            PsiClock    = [];
            Xi          = -Inf;
            Margins     = [];
            H           = [];
            Q           = [];
            FEASIBLE_COUNT = 0;
            
            Diagnostics = INITDiag(Loss, Feature, k, Regularizer, Diagonal, C, E, FEASIBLE_COUNT, ConstraintClock);
            
            f_old_relax = f_new_relax;
            
            if UPDATESample && num_calls_latent >= IterINIT   %%%%find latent
                penalty = batchSize / (KINIT * C);
                [PsiNew, Mnew, SO_time, hLatent1, RLatent1, PsiLatentS, TSAMPLES, penalty1]     = CP(k, X, hLatent, RLatent, PsiLatent, ...
                    numSign, W, Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores, TS, PsiS, penalty);
                if penalty1 < inf
                    KINIT = batchSize / (penalty1 * C);
                end
                
                if iter == 0
                    [PsiNew, Mnew]     = CP(k, X, hLatent, RLatent, PsiLatentS, ...
                        numSign, W, Ypos, Yneg, batchSize, Template, Nrotate, TSAMPLES, ClassScores);
                    Margins     = cat(1, Margins,   Mnew);
                    PsiR        = cat(1, PsiR,      PsiNew);
                    PsiClock    = cat(1, PsiClock,  0);
                    f_new_relax = mlr_compute(W, C, XH(:, [Template,TSAMPLES']), Margins) + ...
                        + 1 / KINIT * (length(SAMPLES) - length(TSAMPLES));
                    iter = iter + 1;
                    continue;
                end
                
            else
                TSAMPLES = SAMPLES;
                PsiLatentS = PsiLatent;
            end
            
            nvalid = length(SAMPLES) - length(TSAMPLES);
            
            if UPDATESample && num_calls_latent >= IterINIT
                converged = length(TSAMPLES) == length(prev_valid_examples)...
                    && ~nnz(prev_valid_examples - TSAMPLES);
                if(converged)
                    break;
                end
            end
            
            
            while 1
                if Diagnostics.num_calls_solver > MAX_CALLS
                    dbprint(1,['Calls to SO >= ' num2str(MAX_CALLS)]);
                    break;
                end
                
                dbprint(1, 'Round %03d', Diagnostics.num_calls_solver);
                % Generate a constraint set
                Termination = -Inf;

                dbprint(2, 'Calling separation oracle...');
                [PsiNew, Mnew, SO_time]     = CP(k, X, hLatent, RLatent, PsiLatentS, ...
                    numSign, W, Ypos, Yneg, batchSize, Template, Nrotate, TSAMPLES, ClassScores);
                Termination                 = LOSS(W, PsiNew, Mnew, 0);
                Diagnostics.num_calls_SO    = Diagnostics.num_calls_SO + 1;

                Diagnostics.time_SO         = Diagnostics.time_SO + SO_time;

                Margins     = cat(1, Margins,   Mnew);
                PsiR        = cat(1, PsiR,      PsiNew);
                PsiClock    = cat(1, PsiClock,  0);
                H           = expandKernel(H);
                Q           = expandRegularizer(Q, XH(:, [Template,TSAMPLES']), W);
                
                dbprint(2, '\n\tActive constraints    : %d',            length(PsiClock));
                dbprint(2, '\t           Mean loss  : %0.4f',           Mnew);
                dbprint(2, '\t  Current loss Xi     : %0.4f',           Xi);
                dbprint(2, '\t  Termination -Xi < E : %0.4f <? %.04f\n', Termination - Xi, E);
        
                Diagnostics.gap     = cat(1, Diagnostics.gap,   Termination - Xi);
                Diagnostics.Delta   = cat(1, Diagnostics.Delta, Mnew);

                %if Termination <= Xi + E
                if Termination <= Xi + E && Diagnostics.num_calls_solver > MIN_CALLS	
                    %if Termination - Xi <= E            
                    dbprint(1, 'Done.');
          
                    break;
                end
                dbprint(1, 'Calling solver...');
                PsiClock                        = PsiClock + 1;
                Solver_time                     = tic();
                %         disp('Robust MLR')
                [W, Xi, Dsolver]                = rmlr_admm(C, XH(:, [Template,TSAMPLES']), Margins, H, Q, lam);
                Diagnostics.time_solver         = Diagnostics.time_solver + toc(Solver_time);
                Diagnostics.num_calls_solver    = Diagnostics.num_calls_solver + 1;
                Diagnostics.Xi                  = cat(1, Diagnostics.Xi, Xi);
                Diagnostics.f                   = cat(1, Diagnostics.f, Dsolver.f);
                Diagnostics.num_steps           = cat(1, Diagnostics.num_steps, Dsolver.num_steps);

                OBJF = cat(1, OBJF, Diagnostics.f(end));
                %%%
                % Cull the old constraints
                GC          = PsiClock < ConstraintClock;
                Margins     = Margins(GC);
                PsiR        = PsiR(GC);
                PsiClock    = PsiClock(GC);
                H           = H(GC, GC);
                Q           = Q(GC);

                Diagnostics.num_constraints = cat(1, Diagnostics.num_constraints, length(PsiR));
        
        
                if (UPDATESample && num_calls_latent >= IterINIT)
                    Diagnostics.f = Diagnostics.f + 1 / KINIT * nvalid;
                end
            end
            
            
            prev_valid_examples = TSAMPLES;
            Diagnostics.time_total = toc(TIME_START);
            Diagnostics.feasible_count = FEASIBLE_COUNT;
            fprintf('Time for iteration: %d /%d, time,number,timepernum %d,%d,%f \n', ...
                num_calls_latent, LatentITER, Diagnostics.time_total, ...
                Diagnostics.num_calls_solver, Diagnostics.time_total/Diagnostics.num_calls_solver);

            f_new_relax = Diagnostics.f(end);
            if (UPDATESample && num_calls_latent >= IterINIT)
                if f_old_relax - f_new_relax >= 0
                    Wbest = W;
                    Diagnostics1 = Diagnostics;
                end
                if (f_old_relax - f_new_relax) < C*E
                    break;
                end
                iter = iter + 1;
            else
                Wbest = W;
                f_new = Diagnostics.f(end);
                Diagnostics1 = Diagnostics;
                iter = iter_inner;
            end                         
        end
        
        if (UPDATESample && num_calls_latent >= IterINIT)
            [PsiNew, Mnew]     = CP(k, X, hLatent, RLatent, PsiLatent, ...
                numSign, W, Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores);
            Margins     = cat(1, [],   Mnew);
            PsiR        = cat(1, {},      PsiNew);
            PsiClock    = cat(1, [],   0);
            f_new = mlr_compute(W, C, XH, Margins, lam);
            
            KINIT = KINIT / selfpaced(3);
        end
        
        num_calls_latent = num_calls_latent +1;
        ObjFun{num_calls_latent} = Diagnostics1.f;
        ObjCons{num_calls_latent} = Diagnostics1.num_constraints(end);
       
        Wtmp{num_calls_latent} = Wbest;
        if (abs((f_old - f_new) / f_old) < E && nvalid==0)
            fprintf('Finished after iteration: %d /%d \n', num_calls_latent, LatentITER);
            break;
        end 

    end

    if num_calls_latent == LatentITER
        fprintf('Maximum iteration reached!\n');
    end
    W = Wbest;
    Diagnostics.ObjFun = ObjFun;
    Diagnostics.ObjCons = ObjCons;
    
%     Diagnostics.feasible_count = FEASIBLE_COUNT;
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
