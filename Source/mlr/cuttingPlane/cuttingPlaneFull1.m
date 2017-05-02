function [dPsi, M, SO_time, yrank, Yconsnew, YLoss] = cuttingPlaneFull1(nfac,...
    k, X, W, SampleW, Ypos, Yneg, batchSize, SAMPLES, ClassScores, innerfea,...
    ts_fold_idx, cbatchSize, ...
                    cts_fold_idx, c1, ts_Fold_label)
%
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

    global SO PSI PSIALL DISTANCE CPGRADIENT;

%     innerfea = 0;
    
    
    [d,n,m] = size(X);
    D       = DISTANCE(W, X, innerfea);

    yrank   = zeros(batchSize, 1);
    M       = 0;
    S       = zeros(n);
%     S1       = zeros(n);
%     S2       = zeros(n);
    dIndex  = sub2ind([n n], 1:n, 1:n);

    SO_time = 0;
    
    TempID = setdiff([1:n], SAMPLES);
    Yconsnew = int16(zeros(batchSize, length(TempID)));
    YLoss = (zeros(batchSize, 1));
    imax = 0;
%     nTemp = length(TempID);
%     npos = size(cell2mat(Ypos), 2);
%     nfac = npos*(nTemp - npos);
    
%     SS = (zeros(batchSize, 1));
%     Ycons= zeros(batchSize, length(TempID));
    if isempty(ClassScores)
        TS  = zeros(batchSize, n);
%         TS1  = zeros(batchSize, n);
%         TS2  = zeros(batchSize, n);
        for i = 1:batchSize
%         parfor i = 1:batchSize
            if i <= length(SAMPLES)
                j = SAMPLES(i);

                if isempty(Ypos{j})
                    continue;
                end
                if isempty(Yneg)
                    % Construct a negative set 
                    Ynegative = setdiff((1:n)', [j ; Ypos{j}]);
                else
                    Ynegative = setdiff(Yneg{j},Ypos{j}) ;
                end
                SO_start        = tic();
                [yi, li, maxsocre]        = SO(j, D, Ypos{j}, Ynegative, k);
                SO_time         = SO_time + toc(SO_start);

                YLoss(i)        = SampleW(i) * li /batchSize;
                
                M               = M + SampleW(i) * li /batchSize;
                TS(i,:)         = PSI(j, yi', n, Ypos{j}, Ynegative) * SampleW(i);
                
%                 idx = find(yi == Ypos{j});
                idx = find(ismember(yi, Ypos{j})); 
                yrank(i)        = 1 / idx(1);
                
                temp            = PSIALL(j, yi', n, Ypos{j}, Ynegative); 
                Yconsnew(i,:)   = round(temp(TempID)' * nfac(i));
                
                
%                 TS1(i,:)         = PSIALL(j, [Ypos{j}, Ynegative]', n, Ypos{j}, Ynegative); 
%                 TS2(i,:)         = PSIALL(j, yi', n, Ypos{j}, Ynegative); 
%                 SS(i)  = maxsocre - li;
%                 zz2(i,:) = double(Yconsnew(i,1:length(TempID))) / nfac(i);
%                 zz1(i,:) = TS(i,1:length(TempID));
                
%                 Ycons(i,:)   = yi';
                temp1            = PSIALL(j, [Ypos{j}, Ynegative]', n, Ypos{j}, Ynegative); 
                temp1    = round(temp1(TempID)' * nfac(i));
               SS(i) = double(Yconsnew(i,:)) * (-D(j, TempID))' / nfac(i) + li - double(temp1) * (-D(j, TempID))' / nfac(i);
%                imax = max(imax, max(abs(SS(i) - maxsocre)));
                
                
            end
        end
%         save('aa', 'zz1', 'zz2')
%         temp = PSIALL(j, Ycons, n, cell2mat(Ypos(SAMPLES, 1)), Ynegative); 
% imax
%         Reconstruct the S matrix from TS
%         maxsocre1 = maxsocre;
%         save('SS', 'maxsocre1')
        save('SS', 'SS')
        if ~innerfea
            S(SAMPLES,:)    = TS;
            S(:,SAMPLES)    = S(:,SAMPLES) + TS';
            S(dIndex)       = S(dIndex) - sum(TS, 1);
            
%             S1(SAMPLES,:)    = TS1;
%             S1(:,SAMPLES)    = S1(:,SAMPLES) + TS1';
%             S1(dIndex)       = S1(dIndex) - sum(TS1, 1);
%             S2(SAMPLES,:)    = TS2;
%             S2(:,SAMPLES)    = S2(:,SAMPLES) + TS2';
%             S2(dIndex)       = S2(dIndex) - sum(TS2, 1);
        else
            S(SAMPLES,:)    = TS;
%             S1(SAMPLES,:)    = TS1;
%             S2(SAMPLES,:)    = TS2;
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
            Rank    = zeros(length(points), 1);
            parfor x = 1:length(points)
                i           = points(x);
                yl          = yp;
                yl(i)       = 0;
                Ypos        = find(yl);
                SO_start    = tic();
                    [yi, li]    = SO(i, D, Ypos, Yneg, k);
                SO_time     = SO_time + toc(SO_start);

                M           = M + li;
                TS(x,:)     = PSI(i, yi', n, Ypos, Yneg);
                
                
                idx         = find(ismember(yi, Ypos)); 
                Rank(x)     = 1 / idx(1);
            end

            yrank(points,:) = Rank;
            
            if ~innerfea
                S(points,:) = S(points,:) + TS;
                S(:,points) = S(:,points) + TS';
                S(dIndex)   = S(dIndex) - sum(TS, 1);
            else
                S(points,:) = S(points,:) + TS;
            end
        end
        M   = M / batchSize;
    end
    dPsi    = CPGRADIENT(X, S, batchSize);
    
%     dPsi1    = CPGRADIENT(X, S1, batchSize);
%     dPsi2    = CPGRADIENT(X, S2, batchSize); 
%     sum(sum(W.*dPsi2)) - mean(SS)
%     dis = dPsi - (dPsi1 - dPsi2);max(abs(dis(:)))

end
