function [Psi, X, hLatent, Rlatent, tord] = ComputeLatent_Large_f1(k, X, hLatent,...
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
    L = zeros(size(W));
    for i = 1:size(W,3)
        [vecs,vals] = eig(0.5 * (W(:,:,i) + W(:,:,i)'));
        L(:,:,i) = real(abs(vals)).^0.5 * vecs';
        end
%         clear 'W'
        
        [d,n,m] = size(X);
    Rlatent = zeros([length(hLatent), 1]);

    
    dIndex  = sub2ind([n n], 1:n, 1:n);
    nbase = length(Template) / Nrotate;
    ntrain = length(Template);
    BatchRound = size(CIndex, 1);
    
    plus = zeros(Nrotate, 1);
    for jj = 1:Nrotate 
        plus(jj) = (jj - 1)*nbase;
    end
%     rangeS = [0,cumsum(numSign(1:end-1))];
%     rangeE = [cumsum(numSign)];
%     
%     Tnum = numSign(setdiff((1:n)', Template));
%     rangeST = [0,cumsum(Tnum(1:end-1))];
            
    Tnum = cumsum(numSign(setdiff((1:n)', Template)));
    rangeS = [0,Tnum(1:end-1)];
    rangeE = Tnum(1:end);
    Psi = zeros(d);
    if isempty(ClassScores)
        
        bmid = 0;smid = 0;
        for R = 1:BatchRound
            index = [CIndex(R, 1):CIndex(R, 2)];
            
            load(fullfile(datastr,[num2str(R) '.mat']), 'Xcell'); 
            Xtest = (cell2mat(Xcell))';clear 'Xcell'
            
            TSAMPLES = SAMPLES(index);
            D1 = setDistanceFullMKL_f([X(:, Template) Xtest], L, ...
                ntrain + (1:size(Xtest, 2)), 1:ntrain);
            
            S       = zeros(ntrain+length(TSAMPLES));
            n1 = ntrain+length(TSAMPLES);
            TS  = zeros(length(TSAMPLES), n1);
            ntrainS = ntrain+smid;
            
            Cs = 0;
            for j = TSAMPLES'
                    Ynegative = Yneg{j};
                D    = D1(:, rangeS(j-ntrain)+1-bmid:rangeE(j-ntrain)-bmid);
                
                [YposT, YnegativeT] = MultiY(Ypos{j}, Ynegative, nbase, Nrotate);
                ScorePos        = - D(YposT,end - numSign(j) + 1:end);
                ScoreNeg        = - D(YnegativeT,end - numSign(j) + 1:end);
                
                ScoreNeg = reshape(ScoreNeg, [size(ScoreNeg,1) / Nrotate, Nrotate, size(ScoreNeg, 2)]);
                C1 = ScorePos - reshape(sum(ScoreNeg, 1) / size(ScoreNeg, 1), size(ScorePos));                
                [C, ord] = sort(C1(:));
                [Rlatent(j), hLatent(j)] = ind2sub(size(C1), ord(end));
                
                X(:, j) = Xtest(:, hLatent(j)+rangeS(j-ntrain)-bmid);
                
                TS(j-ntrainS,:)         = PSIALL(j, [Ypos{j}; Ynegative'] + plus(Rlatent(j)),  ...
                    n1, Ypos{j} + plus(Rlatent(j)), Ynegative + plus(Rlatent(j)));
                
                Cs = Cs + C(end);
            end
            % Reconstruct the S matrix from TS
            S(TSAMPLES-smid,:)    = TS;
            S(:,TSAMPLES-smid)    = S(:,TSAMPLES-smid) + TS';
            dIndex1  = sub2ind([n1 n1], 1:n1, 1:n1);
            S(dIndex1)       = S(dIndex1) - sum(TS, 1);
            
            bmid = bmid + sum(numSign(SAMPLES(index)));
            smid = smid + length(TSAMPLES);
            Psi    = Psi + CPGRADIENT(X(:, [1:ntrain, TSAMPLES']), S, batchSize);
            
            if abs(sum(sum(W .* CPGRADIENT(X(:, [1:ntrain, TSAMPLES']), S, batchSize))) - Cs / batchSize) > 1e-6
                t = 1;
                pause
            end
        end       
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
            for x = 1:length(points)
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
    

end
