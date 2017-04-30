function [Psi, X, hLatent, Rlatent, tord] = ComputeLatent_Large(k, X, hLatent,...
    numSign, CIndex, W, datastr, Ypos, Yneg, ...
    batchSize, Template, Nrotate, SAMPLES, ClassScores)
%%% Psi(x_i,y_i)
% [dPsi, M, SO_time] = cuttingPlaneFull(k, X, W, Yp, Yn, batchSize, SAMPLES, ClassScores)
%
%   k           = k parameter for the SO
%   X           = d*n data matrix
%   W           = d*d PSD metric
%   Yp          = cell-array of relevant results for each point
%   Yn          = cell-array of irrelevant results for each point
%   batchSize   = number of points to use in the constraint batch
%   SAMPLES     = indices of valid points to include in the batch
%   ClassScores = structure for synthetic constraints
%
%   dPsi        = dPsi vector for this batch
%   M           = mean loss on this batch
%   SO_time     = time spent in separation oracle

    global PSIALL CPGRADIENT DISTANCE;

    tord = [];

    [d,n,m] = size(X);
    Rlatent = zeros([length(hLatent), 1]);

    Xtemplate = X(:, Template);

    S       = zeros(n);
    dIndex  = sub2ind([n n], 1:n, 1:n);
    nbase = length(Template) / Nrotate;
    
    BatchRound = size(CIndex, 1);
    
    plus = zeros(Nrotate, 1);
    for jj = 1:Nrotate 
        plus(jj) = (jj - 1)*nbase;
    end
    if isempty(ClassScores)
        TS  = zeros(batchSize, n);
        
        for R = 1:BatchRound
            index = [CIndex(R, 1):CIndex(R, 2)];
            
            load(fullfile(datastr,[num2str(R) '.mat']), 'Xcell'); 
            
            TSAMPLES = SAMPLES(index);
            
            for i = 1:length(TSAMPLES)
                j = TSAMPLES(i);
                Xtmp = Xcell{i};
                
                if isempty(Ypos{j})
                    continue;
                end
                if isempty(Yneg)
                    % Construct a negative set 
                    Ynegative = setdiff((1:n)', [j ; Ypos{j}]);
                else
                    Ynegative = Yneg{j};
                end
                

%                 tic;
                D       = DISTANCE(W, [Xtemplate, Xtmp']);
                
%                 toc;
%                 tic;
                [YposT, YnegativeT] = MultiY(Ypos{j}, Ynegative, nbase, Nrotate);
%                 toc;
%                 tic;
                ScorePos        = - D(YposT,end - numSign(j) + 1:end);
                ScoreNeg        = - D(YnegativeT,end - numSign(j) + 1:end);
                
                ScoreNeg = reshape(ScoreNeg, [size(ScoreNeg,1) / Nrotate, Nrotate, size(ScoreNeg, 2)]);
                C1 = ScorePos - reshape(sum(ScoreNeg, 1) / size(ScoreNeg, 1), size(ScorePos));                
                [C, ord] = sort(C1(:));
                [Rlatent(j), hLatent(j)] = ind2sub(size(C1), ord(end));
                
                X(:, j) = (Xtmp(hLatent(j), :))';
                
                TS(index(i),:)         = PSIALL(j, [Ypos{j}; Ynegative'] + plus(Rlatent(j)),  ...
                    n, Ypos{j} + plus(Rlatent(j)), Ynegative + plus(Rlatent(j)));
            end
        end

        % Reconstruct the S matrix from TS
        S(SAMPLES,:)    = TS;
        S(:,SAMPLES)    = S(:,SAMPLES) + TS';
        S(dIndex)       = S(dIndex) - sum(TS, 1);
    else

        % Do it class-wise for efficiency
        batchSize = 0;
        for j = 1:length(ClassScores.classes)
            c       = ClassScores.classes(j);
            points  = find(ClassScores.Y == c);

            Yneg    = find(ClassScores.Yneg{j});
            yp      = ClassScores.Ypos{j};
            
            if length(points) <= 1
                continue;
            end

            batchSize = batchSize + length(points);
            TS      = zeros(length(points), n);
            parfor x = 1:length(points)
                i           = points(x);
                yl          = yp;
                yl(i)       = 0;
                Ypos        = find(yl);
                TS(x,:)     = PSIALL(i, n, Ypos, Yneg);
            end

            S(points,:) = S(points,:) + TS;
            S(:,points) = S(:,points) + TS';
            S(dIndex)   = S(dIndex) - sum(TS, 1);
        end
    end
    
    Psi    = CPGRADIENT(X, S, batchSize);
end
