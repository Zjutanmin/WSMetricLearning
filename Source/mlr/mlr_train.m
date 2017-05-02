function [W, Xi, Diagnostics, yrank, X, XDic] = mlr_train(W, SampleW, X, Y, Cslack, varargin)
                        


%
%   [W, Xi, D] = mlr_train(X, Y, C,...)
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
%

    TIME_START = tic();
    XDic = [];
    global C;
    C = Cslack;

    [d,n,m] = size(X);

    if m > 1
        MKL = 1;
    else
        MKL = 0;
    end

    if nargin < 5
        C = 1;
    end

    %%%
    % Default options:

    global CP SO PSI PSIALL REG FEASIBLE LOSS DISTANCE SETDISTANCE CPGRADIENT STRUCTKERNEL DUALW INIT;

    global FEASIBLE_COUNT;
    FEASIBLE_COUNT = 0;

    CP          = @cuttingPlaneFull;
    SO          = @separationOracleAUC;
    PSI         = @metricPsiPO;
    PSIALL      = @metricPsiPOALL;

    if ~MKL
        INIT        = @initializeFull;
        REG         = @regularizeTraceFull;
        STRUCTKERNEL= @structKernelLinear;
        DUALW       = @dualWLinear;
        FEASIBLE    = @feasibleFull;
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


    if nargin > 5
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
            case {'mrr2'}
                SO          = @separationOracleMRR2;
                PSI         = @metricPsiPO;
                Loss        = 'MRR2';
                Feature     = 'metricPsiPO';
            case {'hinge'}
                SO          = @separationOracleHINGE;
                PSI         = @metricPsiPO;
                Loss        = 'HINGE';
                Feature     = 'metricPsiPO';
            
            case {'mrr3'}
                SO          = @separationOracleMRR3;
                PSI         = @metricPsiPO;
                Loss        = 'MRR3';
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

    if nargin > 6
        k = varargin{2};
    end

    Diagonal = 0;
    if nargin > 8 & varargin{4} > 0
        Diagonal = varargin{4};

        if ~MKL
            INIT        = @initializeDiag;
            REG         = @regularizeTraceDiag;
            STRUCTKERNEL= @structKernelDiag;
            DUALW       = @dualWDiag;
            FEASIBLE    = @feasibleDiag;
            CPGRADIENT  = @cpGradientDiag;
            DISTANCE    = @distanceDiag;
            SETDISTANCE = @setDistanceDiag;
            Regularizer = 'Trace';
        else
            INIT        = @initializeDiagMKL;
            REG         = @regularizeMKLDiag;
            STRUCTKERNEL= @structKernelDiagMKL;
            DUALW       = @dualWDiagMKL;
            FEASIBLE    = @feasibleDiagMKL;
            CPGRADIENT  = @cpGradientDiagMKL;
            DISTANCE    = @distanceDiagMKL;
            SETDISTANCE = @setDistanceDiagMKL;
            LOSS        = @lossHingeDiagMKL;
            Regularizer = 'Trace';
        end
    end

    if nargin >7
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
    if nargin > 9 && varargin{5} > 0
        if varargin{5} < n
            STOCHASTIC  = 1;
            CP          = @cuttingPlaneRandom;
            batchSize   = varargin{5};
        end
    end
    TemplateUp = 0;
    XX = [];
    cparaINNC = [];
    MeanK = 1;
    FeatUp = 0;TemplateNorm = 0;innc = 0;
    cpara = [];
        if nargin > 10
        TemplateUp   = varargin{6};
        KmeanA = 1;
        if nargin > 11
            MeanK   = varargin{7};
        end
        if nargin > 12
            KmeanA   = varargin{8};
            ITERkmean = [0, 0, 0, 0];
            if iscell(KmeanA)
                ITERkmean = [KmeanA{3}, KmeanA{4}, KmeanA{5}, KmeanA{6}];
                FIXW_T = KmeanA{2};
                KmeanA = KmeanA{1};
            end
        end
        if nargin > 13
            FeatUp   = varargin{9};
        end
        if nargin > 14
            TemplateNorm   = varargin{10};
        end
        if nargin > 15
            UpSolver   = varargin{11};
        end
        
        
        if nargin > 16
            innc   = varargin{12};
            if nargin > 17
                cpara   = varargin{13};
                XX   = varargin{14};
                XDic = varargin{15};   
                switch innc
                    case 0
                        cparaINNC = varargin{17};
                    case 1
                        cparaINNC = varargin{17};
                    case 2
                        
                        
                end
            end
% %             [lambda, K, blocksize, verbose, beta] = GetINNCpara(cpara);
% %             cpara = [lambda, K, blocksize, verbose, -1, beta];
% %             if blocksize == -1
% %                 cpara(3) = length(SampleW); 
% %             end
        end
    end
    innerfea = 0;
    
    if nargin > 20
        innerfea   = varargin{16};         
    end  
   
%     innerfea = 0;cpara{4} = 'Grad';
    
    if TemplateUp
        global Ycons Yloss;
    end
    %     lamda = varargin{6};

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
    if isempty(W)
         W           = INIT(X);
%          W           = eye(size(X, 1));
    end


    global ADMM_Z ADMM_U RHO;
    ADMM_Z      = W;
    ADMM_U      = 0 * ADMM_Z;

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
    batchSize = min([batchSize, length(SAMPLES)]);


    [NN, Nneg, Npos] = GetFactor(Ypos, Yneg);
    try
        NN = NN(SAMPLES);
        Nneg = Nneg(SAMPLES);Npos = Npos(SAMPLES);   
    end
    
    if TemplateUp
        if  innc == 2
            KmeanLAMDA = C  / KmeanA;
%             KmeanA = 2 * C ./ (batchSize*KmeanLAMDA*NN);KmeanA = KmeanA(:);
        else
            KmeanLAMDA = 2*C*mean(1./NN) / (batchSize *KmeanA);
            KmeanA = 2 * C ./ (batchSize*KmeanLAMDA*NN);KmeanA = KmeanA(:);
        end
    else
        KmeanA = 1;
        KmeanLAMDA = 1;Ymatched = [];
    end
    
    Diagnostics = struct(   'loss',                 Loss, ...           % Which loss are we optimizing?
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

    Ycons       = {};
    Yloss       = {};
    
    Xi          = -Inf;
    Margins     = [];
    H           = [];
    Q           = [];

    if STOCHASTIC
        dbprint(1, 'STOCHASTIC OPTIMIZATION: Batch size is %d/%d', batchSize, n);
    end

%     MAXITER = 0;
    try
        MAXITER = cpara{12};
    catch
        MAXITER = 1000;
    end
    
    
    
%     
% % %     MAXITER = 1;
    
    
    
    
    
    
    
    
    
    
    try
        FIXW = cpara{13};
    catch
        FIXW = 0;
    end
    try
        KmeanE = cpara{14};
    catch
        KmeanE = 0;
    end
    try
        Tnorm = cpara{15};
    catch
        Tnorm = 1;
    end
    cparaINNC = [cparaINNC, KmeanE, Tnorm];
    W_update = 1;
% % %     if MAXITER == 1
% % %         W_update = 0;
% % %         W = eye(d);
% % %     else
        if FIXW
            W_update = 0;
        end
% % %     end
    
    
    ShowITER = 1;
    
%     MAXITER = 2;
    
    
    OBJF = [];
%     while 1

%     Template = setdiff([1:length(X)], SAMPLES);
if ~isempty(Ypos)
    Template  = reshape(find(cellfun(@isempty, Ypos,  'UniformOutput', true)),...
        1, []);
end

    th1 = tic;
    yrank   = zeros(batchSize, 1);
   if TemplateUp
        Ymatched = cell2mat((Ypos(SAMPLES))');
        tnum = cell2mat(cellfun(@size, Ypos(SAMPLES), 'UniformOutput', false));
        tnum = tnum(:, 2);
        cnum = mat2cell([1:length(tnum)]', ones(1, length(tnum)), 1);
        ctnum = mat2cell(tnum, ones(1, length(tnum)), 1);
        TT = cell2mat((cellfun(@(x,y) y*ones(1, x), ctnum, cnum, 'UniformOutput', false))');
        Ymatched = sub2ind([length(SAMPLES), length(Template)], TT(:), Ymatched(:));
        Ymatched = sort(Ymatched); 
    end
    
    if mean(KmeanA) == Inf
        KmeanA(:) = 1;
        KmeanLAMDA = 0;
    end
    UpSolver = 1;
    NMaxpos = 20000;
    if STOCHASTIC
        NMaxpos  = batchSize;
    end
%     NMaxpos = 100;
    if exist('FIXW_T', 'var') && FIXW_T
        MAXITER = 1;
        W_update = 0;
    end
    
%     if round(MAXITER) ~= MAXITER && FIXW_T == 2
%         Round1 = fix(MAXITER);
%         Round2 = num2str(MAXITER - Round1); Round2 = str2num();
%     else
%     end
    cpara1 =cpara;
    if length(cpara) > 10 && cpara{11} > 0
        Round1 = 1;Round2 = 1;
        if cpara{11} ~= 1
            Round2 = cpara{11}+1;
        end
        UPMODEL = 1;
        cpara1{11} = Round2;
    else
        if length(cpara) > 10
        cpara{11} = -cpara{11};
        if round(cpara{11}) == cpara{11}
            Round1 = cpara{11};
            Round2 = cpara{11};
        else
            Round1 = fix(cpara{11});
            Round2 = num2str(cpara{11} - Round1);Round2 = str2num(Round2(3:end-1));
        end
        UPMODEL = 2;
        cpara1{11} = Round1;
        end
    end
    
%     Round1+Round2




%%%%refine
MAXITER = 1000;
%%%ferein



    while Diagnostics.num_calls_solver < MAXITER
       
        if ~mod(Diagnostics.num_calls_solver, ShowITER)
            th1 = toc(th1);
            fprintf('Cutting Plane in iteration: %d /%d ,%d\n', Diagnostics.num_calls_solver, MAXITER, th1)
            th1 = tic;
        end
            
            
        dbprint(1, 'Round %03d', Diagnostics.num_calls_solver);
        % Generate a constraint set
        Termination = 0;


        dbprint(2, 'Calling separation oracle...');
% 
%         [PsiNew1, Mnew1, SO_time1, yrank1, Yconsnew1, Ylossnew1]     = ...
%             cuttingPlaneFull(NN, k, X, W, SampleW, Ypos, Yneg, ...
%             batchSize, SAMPLES, ClassScores, innerfea);
        tic
        if batchSize > NMaxpos
            istart = 0;
            PsiNew = zeros(size(X, 1), size(X, 1));Mnew = 0;
            while istart < length(SampleW)
                nn = min(length(SampleW) - istart, NMaxpos);
                Windex = [istart+1:istart+nn];
                dindex = [[1:length(Template)], length(Template)+Windex];
                [PsiNewT, MnewT, SO_time, yrank(istart+1:istart+nn), ...
                    Yconsnew(istart+1:istart+nn,:), Ylossnew(istart+1:istart+nn)]   = ...
                    CP(NN, k, X(:, dindex), W, SampleW(Windex), Ypos(dindex), Yneg(dindex), ...
                    nn, SAMPLES(1:nn), ClassScores, innerfea);
                istart = istart+nn;
                PsiNew = PsiNew + PsiNewT*nn;Mnew = Mnew + MnewT*nn;
            end
            PsiNew = PsiNew / batchSize;Mnew = Mnew / batchSize;
        else
            [PsiNew, Mnew, SO_time, yrank, Yconsnew, Ylossnew]     = ...
                CP(NN, k, X, W, SampleW, Ypos, Yneg, ...
                batchSize, SAMPLES, ClassScores, innerfea);
            
% % % % % %             PsiNew1 = PsiNew;
% % % % % %             Mnew1 = Mnew;
% % % % % %             yrank1 = yrank;
% % % % % %             Yconsnew1 = Yconsnew;
% % % % % %             Ylossnew1 = Ylossnew;
% % % % % %             
% % % % % %             save('tt1', 'PsiNew1', 'Mnew1', 'yrank1', 'Yconsnew1', 'Ylossnew1')
% % % % % %             
% % % % % % % % %             [PsiNew1, Mnew1, SO_time1, yrank1, Yconsnew1, Ylossnew1] = ...
% % % % % % % % %                 cuttingPlaneRandom(NN, k, X, W, SampleW, Ypos, Yneg, ...
% % % % % % % % %                 batchSize, SAMPLES, ClassScores, innerfea);
% % % % % % % % %             
% % % % % % % % %             
% % % % % % % % %             [PsiNew2, Mnew2, SO_time2, yrank2, Yconsnew2, Ylossnew2] = ...
% % % % % % % % %                 cuttingPlaneRandom1(NN, k, X, W, SampleW, Ypos, Yneg, ...
% % % % % % % % %                 batchSize, SAMPLES, ClassScores, innerfea);
% % % % % % % % %             
% % % % % % % % %             
% % % % % % % % %             [nnz(PsiNew1 - PsiNew), nnz(Mnew1 - Mnew), nnz(yrank1 - yrank), ...
% % % % % % % % %                 nnz(Yconsnew1 - Yconsnew), nnz(Ylossnew1 - Ylossnew)]
% % % % % % % % % 
% % % % % % % % %             [nnz(PsiNew2 - PsiNew), nnz(Mnew2 - Mnew), nnz(yrank2 - yrank), ...
% % % % % % % % %                 nnz(Yconsnew2 - Yconsnew), nnz(Ylossnew2 - Ylossnew)]
        end
        toc 
%         dis = Mnew - Mnew1;
%         if abs(max(abs(dis(:)))) > 1e-6
%             max(abs(dis(:)))
%             t =1
%             pause
%         end
%        
%         dis = PsiNew - PsiNew1;
%         if abs(max(abs(dis(:)))) > 1e-6
%             max(abs(dis(:)))
%             t =1
%             pause
%         end
        Termination                 = LOSS(W, PsiNew, Mnew, 0);

        Diagnostics.num_calls_SO    = Diagnostics.num_calls_SO + 1;
        Diagnostics.time_SO         = Diagnostics.time_SO + SO_time;

        Margins     = cat(1, Margins,   Mnew);
        PsiR        = cat(1, PsiR,      PsiNew);
        PsiClock    = cat(1, PsiClock,  0);
        if TemplateUp
            Ycons   = cat(1, Ycons,     Yconsnew);
            Yloss   = cat(1, Yloss,     Ylossnew);
        end
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
        tic
        [X, obj, XDic]                  = mlr_Temp(Diagnostics.num_calls_solver+1, NN, Nneg, Npos, Margins, KmeanA, KmeanLAMDA, MeanK, X, ...
            XX, XDic, Ypos, SampleW, TemplateUp, Ymatched, W, SAMPLES, ...
            FeatUp, TemplateNorm, UpSolver, innc, cpara1, innerfea, cparaINNC, ITERkmean, UPMODEL, (Round1+ Round2));
        toc
        if W_update
            NNt = Diagnostics.num_calls_solver+1;
            if UPMODEL == 1
                if ~mod(NNt, Round1)
                    [W, Xi, Dsolver]            = mlr_admm(C, X, Margins, H, Q);
                    [NNt, 1]
                end
            else if UPMODEL == 2
                    tmp = NNt - (Round1+ Round2)*fix(NNt / (Round1+ Round2));
                    tmp(find(tmp==0)) = (Round1+ Round2);
                    if tmp <= Round1
                        [W, Xi, Dsolver]            = mlr_admm(C, X, Margins, H, Q);
                        [NNt, 1]
                    end
                end
            end
        else
            Xi = 0;
            Dsolver = struct(   'f',                0, ...
                'num_steps',        1, ...
                'stop_criteria',    []);
        end
        
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
        if TemplateUp
            Ycons   = Ycons(GC);
            Yloss   = Yloss(GC);
        end
        H           = H(GC, GC);
        Q           = Q(GC);

        Diagnostics.num_constraints = cat(1, Diagnostics.num_constraints, length(PsiR));
        
    end
    if strcmp(Loss, 'MRR2')
         yrank =  yrank .^2;
    end
    
    if strcmp(Loss, 'HINGE')
        idx = find(yrank == 1);
        yrank(:) =  0;
        yrank(idx) =  1;
    end
    
%     Diagnostics.f
    ObjFun{1} = OBJF;
    Diagnostics.ObjFun = ObjFun;
    % Finish diagnostics

    Diagnostics.time_total = toc(TIME_START);
    Diagnostics.feasible_count = FEASIBLE_COUNT;
    X = X';
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
