% function [W, Xi, Diagnostics, Wtmp] = mlr_train_latent_f(selfpaced, W, X, Y, numSign, ...
%       Tlatentinfo, latentfile, rotate, rawsize, ts_imname, tr_imname, Asubname, Cslack, varargin)
  
function [W, Xi, Diagnostics, yrank, Wtmp, dataX] = mlr_train_latent_f(selfpaced, W, SampleW, X, Y, datastr, numSign, CIndex, ...
      Tlatentinfo, latentfile, rotate, rawsize, KNNlatent, SnippetRatio, ts_imname, tr_imname, Asubname, Cslack, varargin)

%   [W, Xi, D] = mlr_train(X, Y, C,...)
%
%       X = d*n data matrix
%       Y = either n-by-1 label of vectors
%           OR
%           n-by-2 cell array where nt
%               Y{q,1} contains relevant indices for q, andseparatio
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
%   [W, Xi, D] = mlr_train(X, Y, C, LOSS)
%       where LOSS is one of:
%           'AUC':      Area under ROC curve (default)
%           'KNN':      KNN accuracy
%           'Prec@k':   Precision-at-k
%           'MAP':      Mean Average Precision
%           'MRR':      Mean Reciprocal Rank
%           'NDCG':     Normalized Discounted Cumulative Gain
%
%   [W, Xi, D] = mlr_train(X, Y, C, LOSS, k)
%       where k is the number of neighbors for Prec@k or NDCG
%       (default=3)
%
%   [W, Xi, D] = mlr_train(X, Y, C, LOSS, k, REG)
%       where REG defines the regularization on W, and is one of:
%           0:          no regularization
%           1:          1-norm: trace(W)            (default)
%           2:          2-norm: trace(W' * W)
%           3:          Kernel: trace(W * X), assumes X is square and positive-definite
%
%   [W, Xi, D] = mlr_train(X, Y, C, LOSS, k, REG, Diagonal)
%       Diagonal = 0:   learn a full d-by-d W       (default)
%       Diagonal = 1:   learn diagonally-constrained W (d-by-1)
%       
%   [W, Xi, D] = mlr_train(X, Y, C, LOSS, k, REG, Diagonal, B)
%       where B > 0 enables stochastic optimization with batch size B
   
%     rotate = [0, 10, -10];
    if SnippetRatio{1} == -1
        SnippetRatio{1} = 1;
    end
    if SnippetRatio{1} == 1 || SnippetRatio{1} == -1
        numSign1 = ones(size(numSign));
    else
        if SnippetRatio{1} < 1
            numSign1 = ceil(numSign * SnippetRatio);
        else
            numSign1 = min(max(1, SnippetRatio), numSign);
        end
    end
    
    if size(CIndex, 1) == 1
        Train_Large = 0;
        X = changeOrd(X, numSign);
    else
        Train_Large = 1;
        X = changeOrd(X, numSign1);
%         X = (cell2mat(X))';
    end
    latentinfo = cell2mat(Tlatentinfo);
    
    
    if size(CIndex, 1) == 1
        cellbase = getCellBase(numSign, numSign1);
        
    else
        cellbase = getCellBase(numSign1, numSign1);
    end
    hLatent = mat2cell(ones(1, sum(numSign1)), 1, numSign1);
    
% % % % %     %%%%%%BY TANMIN
% % % % %     for jj = 337:length(hLatent)
% % % % %     hLatent{jj} = 4;
% % % % %     end
% % % % %     if Train_Large
% % % % %         for jj = 337:length(hLatent)
% % % % %             hLatent{jj} = 1;
% % % % %         end
% % % % %     end
% % % % %     %%%%%%
    
    global C;
    C = Cslack;

    [d,n,m] = size(getLatent(cellbase, X, hLatent));
    
    

    if m > 1
        MKL = 1;
    else
        MKL = 0;
    end

    if nargin < 18
        C = 1;
    end

    %%%
    % Default options:

    global LATENT CP SO PSI PSIALL REG FEASIBLE LOSS DISTANCE SETDISTANCE CPGRADIENT STRUCTKERNEL DUALW INIT;

    global FEASIBLE_COUNT;
    FEASIBLE_COUNT = 0;

    
    if Train_Large
        CP          = @cuttingPlaneFull_latent_Large_f;
    else
        CP          = @cuttingPlaneFull_Latent_f;
    end
    
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


    
    if Train_Large
        LATENT      = @ComputeLatent_Large_f;
    else
        LATENT      = @ComputeLatent_f;
    end
    
    PSIALL      = @metricPsiPOALL;
    Latent = 1;
    if nargin > 19
%         varargin = varargin{1};
        
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

    if nargin > 19
        k = varargin{2};
    end

    Diagonal = 0;
    if nargin > 21 & varargin{9} > 0
        Diagonal = varargin{4};

        if ~MKL
            INIT        = @initializeDiag;
            REG         = @regularizeTraceDiag;
            STRUCTKERNEL= @structKernelDiag;
            DUALW       = @dualWDiag;
            FEASIBLE    = @feasibleDiag;
            CPGRADIENT  = @cpGradientDiag;
            DISTANCE    = @distanceDiag_Latent;
            SETDISTANCE = @setDistanceDiag;
            Regularizer = 'Trace';
        else
            INIT        = @initializeDiagMKL;
            REG         = @regularizeMKLDiag;
            STRUCTKERNEL= @structKernelDiagMKL;
            DUALW       = @dualWDiagMKL;
            FEASIBLE    = @feasibleDiagMKL;
            CPGRADIENT  = @cpGradientDiagMKL;
            DISTANCE    = @distanceDiagMKL_Latent;
            SETDISTANCE = @setDistanceDiagMKL;
            LOSS        = @lossHingeDiagMKL;
            Regularizer = 'Trace';
        end
    end

    if nargin > 20
        switch(varargin{3})
            case {0}
                REG         = @regularizeNone;
                Regularizer = 'None';

            case {1}
                if MKL
                    if Diagonal == 0
                        REG         = @regularizeMKLFull;
                        STRUCTKERNEL= @structKernelMKL;
                        DUALW       = @dualWMKL;
                    elseif Diagonal == 1
                        REG         = @regularizeMKLDiag;
                        STRUCTKERNEL= @structKernelDiagMKL;
                        DUALW       = @dualWDiagMKL;
                    end
                else
                    if Diagonal 
                        REG         = @regularizeTraceDiag;
                        STRUCTKERNEL= @structKernelDiag;
                        DUALW       = @dualWDiag;
                    else
                        REG         = @regularizeTraceFull;
                        STRUCTKERNEL= @structKernelLinear;
                        DUALW       = @dualWLinear;
                    end
                end
                Regularizer = 'Trace';

            case {2}
                if Diagonal
                    REG         = @regularizeTwoDiag;
                else
                    REG         = @regularizeTwoFull;
                end
                Regularizer = '2-norm';
                error('MLR:REGULARIZER', '2-norm regularization no longer supported');
                

            case {3}
                if MKL
                    if Diagonal == 0
                        REG         = @regularizeMKLFull;
                        STRUCTKERNEL= @structKernelMKL;
                        DUALW       = @dualWMKL;
                    elseif Diagonal == 1
                        REG         = @regularizeMKLDiag;
                        STRUCTKERNEL= @structKernelDiagMKL;
                        DUALW       = @dualWDiagMKL;
                    end
                else
                    if Diagonal
                        REG         = @regularizeMKLDiag;
                        STRUCTKERNEL= @structKernelDiagMKL;
                        DUALW       = @dualWDiagMKL;
                    else
                        REG         = @regularizeKernel;
                        STRUCTKERNEL= @structKernelMKL;
                        DUALW       = @dualWMKL;
                    end
                end
                Regularizer = 'Kernel';

            otherwise
                error('MLR:REGULARIZER', ... 
                    'Unknown regularization: %s', varargin{3});
        end
    end


    % Are we in stochastic optimization mode?
    if nargin > 22 && varargin{10} > 0
        if varargin{5} < n
            STOCHASTIC  = 1;
            CP          = @cuttingPlaneRandom_Latent;
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

    global DEBUG;
    
    if isempty(DEBUG)
        DEBUG = 0;
    end

    %%%
    % Timer to eliminate old constraints
    ConstraintClock = 100;

    %%%
    % Convergence criteria for worst-violated constraint
    E = 1e-3;
    
    %XXX:    2012-01-31 21:29:50 by Brian McFee <bmcfee@cs.ucsd.edu>
    % no longer belongs here
    % Initialize
    
    global ADMM_Z ADMM_U ;
    global PsiR;
    global PsiClock;

    ClassScores = [];

    batchsize = length(hLatent);
    if isa(Y, 'double')
        Ypos        = [];
        Yneg        = [];
        ClassScores = synthesizeRelevance(Y);

    elseif isa(Y, 'cell') && size(Y,1) == batchsize && size(Y,2) == 2
        dbprint(1, 'Using supplied Ypos/Yneg');
        Ypos        = Y(:,1);
        Yneg        = Y(:,2);

        % Compute the valid samples
        SAMPLES     = find( ~(cellfun(@isempty, Y(:,1)) | cellfun(@isempty, Y(:,2))));
%         SAMPLES = SAMPLES;
% % %         if Train_Large
% % %             xx          = cumsum(numSign);
% % %             SAMPLES     = xx(SAMPLES);
% % %             SAMPLES     = cellfun(@(x, y) [x-y+1:x]', ...
% % %                 mat2cell(SAMPLES', ones(length(SAMPLES), 1), 1),...
% % %                 mat2cell((numSign(SAMPLES))', ones(length(SAMPLES), 1), 1),...
% % %                 'ErrorHandler', @errorfun, 'UniformOutput', false);
% % %             SAMPLES     = sort(cell2mat(SAMPLES));
% % %         end
    elseif isa(Y, 'cell') && size(Y,1) == batchsize && size(Y,2) == 1
        dbprint(1, 'Using supplied Ypos/synthesized Yneg');
        Ypos        = Y(:,1);
        Yneg        = [];
        SAMPLES     = find( ~(cellfun(@isempty, Y(:,1))));
    else
        error('MLR:LABELS', 'Incorrect format for Y.');
    end

    if isempty(W)
        xx = (getLatent(cellbase, X, hLatent));
        xx = xx(:, [(min(SAMPLES)-1)/length(rotate)*(1-1)+1:...
            (min(SAMPLES)-1)/length(rotate)*1, SAMPLES']);
        W           = INIT(xx);
    end
    
    %%
    % If we don't have enough data to make the batch, cut the batch
    if STOCHASTIC
        dbprint(1, 'STOCHASTIC OPTIMIZATION: Batch size is %d/%d', batchSize, n);
    end

    Template = setdiff([1:length(X)], SAMPLES);

    MAXITER = 50;
    LatentITER = 10;
    IterINIT = 2;
    
    batchSize = min([batchSize, length(SAMPLES)]);
    
    
    f_new = 0;f_new_relax = 0;
    
    num_calls_latent = 0;
    
    Nrotate = length(rotate);
    Groundtruth = zeros(length(SAMPLES), 1);
    for i = 1:length(SAMPLES)
        Groundtruth(i) = ceil(Y{SAMPLES(i),1}(1) / Nrotate);
    end
    ObjFun = cell(1, LatentITER);
    
    ADMM_Z      = W;
    ADMM_U      = 0 * ADMM_Z;

    Wtmp = cell(1, LatentITER);
    
 
%     W = eye(size(W,1));
    
       
    Yneg = Yneg;
    
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
    
    global Valide;
    Valide = ones(size(numSign));      
    
    

    
    Yneg = ComputeLatent_KNN(KNNlatent, SnippetRatio, X, hLatent, numSign, cellbase, W, Ypos, Yneg, ...
        batchSize, Template, Nrotate, SAMPLES, ClassScores);
    RLatent = (hLatent);
    
    yrank   = zeros(batchSize, 1);
    
% %     %%%%%by Tanmin
% %     LatentITER = 1;MAXITER = 3;
% %     %%%%%
    
% %     SampleW(:) = 1;
    while num_calls_latent < LatentITER
        fprintf('MLR: Compute Latent variables, iter: %d /%d \n', num_calls_latent, LatentITER);
        f_old = f_new;
        

        if UPDATESample && num_calls_latent >= IterINIT   %%%%find latent
            [PsiLatent, hLatent, RLatent, tord, TS, PsiS]        = LATENT(k, numSign1, X, hLatent, RLatent, numSign, W, ...
                cellbase, SampleW, Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores);
        else
            [PsiLatent, XH, hLatent, RLatent]        = LATENT(k, KNNlatent, numSign1, X, hLatent, RLatent, numSign, CIndex, W, ...
                datastr,cellbase, SampleW, Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores);
        end
% % %         if Train_Large
% % %             PsiLatent1 = PsiLatent;hLatent1 = hLatent;RLatent1 = RLatent;
% % %             save('rr1', 'PsiLatent1', 'hLatent1', 'RLatent1')
% % %         else
% % %             save('rr2', 'PsiLatent', 'hLatent', 'RLatent')
% % %         end
% % %         
        TIME_START = tic();
        Wbest = W;
        prev_valid_examples = SAMPLES;
        if Train_Large
            X = XH;
        else
            XH = getLatent(cellbase, X, hLatent);
        end
        
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
                [PsiNew, Mnew, SO_time, yrank, hLatent1, RLatent1, PsiLatentS, TSAMPLES, penalty1]     = CP(k, KNNlatent, X, hLatent, RLatent, PsiLatent, ...
                    {numSign, cellbase}, CIndex, W, datastr, SampleW, Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores, TS, PsiS, penalty);
                
                if penalty1 < inf
                    KINIT = batchSize / (penalty1 * C);
                end
                
                if iter == 0
                    [PsiNew, Mnew, ~, yrank]     = CP(k, KNNlatent, X, hLatent, RLatent, PsiLatentS, ...
                        {numSign, cellbase}, CIndex, W, datastr, SampleW, Ypos, Yneg, batchSize, Template, Nrotate, TSAMPLES, ClassScores);
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
            
            while Diagnostics.num_calls_solver < MAXITER
                dbprint(1, 'Round %03d', Diagnostics.num_calls_solver);
                Termination = 0;
                dbprint(2, 'Calling separation oracle...');
                [PsiNew, Mnew, SO_time, yrank]     = CP(k, KNNlatent, X, hLatent, RLatent, PsiLatentS, ...
                    {numSign, cellbase}, CIndex, W, datastr, SampleW, Ypos, Yneg, batchSize, Template, Nrotate, TSAMPLES, ClassScores);
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
                if Termination <= Xi + E
                    dbprint(1, 'Done.');
                    fprintf('Cutting Plane done in iteration: %d /%d \n', Diagnostics.num_calls_solver, MAXITER);
                    break;
                end
                dbprint(1, 'Calling solver...');
                PsiClock                        = PsiClock + 1;
                Solver_time                     = tic();
                [W, Xi, Dsolver]                = mlr_admm(C, XH(:, [Template,TSAMPLES']), Margins, H, Q);
                Diagnostics.time_solver         = Diagnostics.time_solver + toc(Solver_time);
                Diagnostics.num_calls_solver    = Diagnostics.num_calls_solver + 1;
                if ~mod(Diagnostics.num_calls_solver, MAXITER/4)
                    fprintf('Cutting Plane in iteration: %d /%d \n', Diagnostics.num_calls_solver, MAXITER)
                end
                Diagnostics.Xi                  = cat(1, Diagnostics.Xi, Xi);
                Diagnostics.f                   = cat(1, Diagnostics.f, Dsolver.f);
                Diagnostics.num_steps           = cat(1, Diagnostics.num_steps, Dsolver.num_steps);
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
                
%                 Diagnostics.Xi

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
            [PsiNew, Mnew, ~, yrank]     = CP(k, X, hLatent, RLatent, PsiLatent, ...
                {numSign, cellbase}, CIndex, W, datastr, SampleW, Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores);
            Margins     = cat(1, [],   Mnew);
            PsiR        = cat(1, {},      PsiNew);
            PsiClock    = cat(1, [],   0);
            f_new = mlr_compute(W, C, XH, Margins);
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

    if strcmp(Loss, 'MRR2')
         yrank =  yrank .^2;
    end
    
    if strcmp(Loss, 'HINGE')
        idx = find(yrank == 1);
        yrank(:) =  0;
        yrank(idx) =  1;
    end
    
    if num_calls_latent == LatentITER
        fprintf('Maximum iteration reached!\n');
    end
    W = Wbest;
    Diagnostics.ObjFun = ObjFun;
    Diagnostics.ObjCons = ObjCons;
    
    [~, XH]        = LATENT(k, KNNlatent, numSign1, X, hLatent, RLatent, numSign, CIndex, W, ...
        datastr,cellbase, SampleW, Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores);
    
    if Train_Large
        dataX = XH;
    else
        dataX = getLatent(cellbase, X, hLatent);
    end
    dataX = dataX';
     
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
