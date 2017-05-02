function [dPsi, M, SO_time, yrank, Yconsnew, YLoss] = cuttingPlaneRandom(nfac,...
    k, X, W, SampleW, Ypos, Yneg, batchSize, SAMPLES, ClassScores, innerfea,...
    ts_fold_idx, cbatchSize, ...
                    cts_fold_idx, c1, ts_Fold_label)
%
% [dPsi, M, SO_time] = cuttingPlaneRandom(k, X, W, Yp, Yn, batchSize, SAMPLES, ClassScores)
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

    global SO PSI SETDISTANCE CPGRADIENT PSIALL;

    [d,n]   = size(X);


    TempID  = reshape(find(cellfun(@isempty, Ypos,  'UniformOutput', true)),...
        1, []);
    if length(SAMPLES) == n
        % All samples are fair game (full data)
        Batch   = randperm(n);
        Batch   = Batch(1:batchSize);
        D       = SETDISTANCE(X, W, Batch);

    else
        if isempty(ts_fold_idx)
            Batch   = randperm(length(SAMPLES));
            Batch   = SAMPLES(Batch(1:batchSize));
        else
            Batch = GetFOLDIDX_B(ts_fold_idx, cbatchSize, cts_fold_idx);
            batchSize = length(Batch);   
            Batch   = SAMPLES(Batch(1:batchSize));
            
        end
       
        
        Batch = sort(Batch);
% % % % %         [aa,bb,cc] = unique(ts_Fold_label(unique(ts_fold_idx(Batch))));
% % % % %         c1
% % % % %         for i = 1:length(aa)
% % % % %             len(i) = length(find(cc == i));
% % % % %         end
% % % % %         len ./ sum(len)
% % % % %         try
% % % % %         tt = [c1;  len ./ sum(len)];
% % % % %         catch
% % % % %             1;
% % % % %         end
% % % % %         x1 = unique(ts_fold_idx(Batch));
% % % % %         x2 = unique(ts_fold_idx(setdiff([1:length(ts_fold_idx)], Batch)));
% % % % %         intersect(x1, x2)
        index = [[1:length(TempID)], Batch']';

        yrank   = zeros(length(SAMPLES), 1);
        [dPsi, M, SO_time, yrank(Batch), Yconsnew, YLoss] = cuttingPlaneFull(nfac(Batch- length(TempID)),...
            k, X(:, index), W, (SampleW(Batch - length(TempID)))', Ypos(index), Yneg(index), batchSize, ...
            [length(TempID)+1:length(TempID)+length(Batch)]', ClassScores, innerfea, ts_fold_idx, cbatchSize, cts_fold_idx, c1, ts_Fold_label);
        return

        
        Ito     = sparse(n,1);

        if isempty(ClassScores)
            for i = 1:length(Batch)
                Ito(Ypos{Batch(i)}) = 1;
                Ito(Yneg{Batch(i)}) = 1;
            end
            D       = SETDISTANCE(X, W, Batch, find(Ito));
        else
            D       = SETDISTANCE(X, W, Batch, 1:n);
        end
    end


    M       = 0;
    S       = zeros(n);
    dIndex  = sub2ind([n n], 1:n, 1:n);

    SO_time = 0;
    TempID = setdiff([1:n], SAMPLES);
    yrank   = zeros(batchSize, 1);Yconsnew = int16(zeros(batchSize, length(TempID)));
    YLoss = (zeros(batchSize, 1));
   
    if isempty(ClassScores)
        TS = zeros(batchSize, n);
%         par
        for j = 1:batchSize
            i = Batch(j);
            if isempty(Yneg)
                Ynegative   = setdiff((1:n)', [i ; Ypos{i}]);
            else
                Ynegative   = Yneg{i};
            end
            SO_start        = tic();
                [yi, li]    =   SO(i, D, Ypos{i}, Ynegative, k);
            SO_time         = SO_time + toc(SO_start);
    
            M               = M + SampleW(i- length(TempID)) * li /batchSize;
            TS(j,:)         = PSI(i, yi', n, Ypos{i}, Ynegative) * SampleW(i- length(TempID));
            YLoss(j)        = SampleW(i- length(TempID)) * li /batchSize;
            idx = find(ismember(yi, Ypos{i})); 
            yrank(j)        = 1 / idx(1);
            
            temp            = PSIALL(j, yi', n, Ypos{i}, Ynegative); 
            Yconsnew(j,:)   = round(temp(TempID)' * nfac(i- length(TempID)));  
        
        end
        S(Batch,:)      = TS;
        S(:,Batch)      = S(:,Batch)    + TS';
        S(dIndex)       = S(dIndex)     - sum(TS, 1);
    else
        for j = 1:length(ClassScores.classes)
            c       = ClassScores.classes(j);
            points  = find(ClassScores.Y(Batch) == c);
            if ~any(points)
                continue;
            end

            Yneg    = find(ClassScores.Yneg{j});
            yp      = ClassScores.Ypos{j};

            TS      = zeros(length(points), n);
            parfor x = 1:length(points)
                i               = Batch(points(x));
                yl              = yp;
                yl(i)           = 0;
                Ypos            = find(yl);
                SO_start        = tic();
                    [yi, li]    =   SO(i, D, Ypos, Yneg, k);
                SO_time         = SO_time + toc(SO_start);
    
                M               = M + li /batchSize;
                TS(x,:)         = PSI(i, yi', n, Ypos, Yneg);
            end
            S(Batch(points),:)  = S(Batch(points),:) + TS;
            S(:,Batch(points))  = S(:,Batch(points)) + TS';
            S(dIndex)           = S(dIndex) - sum(TS, 1);
        end
    end

    dPsi    = CPGRADIENT(X, S, batchSize);

    
% % %     dis = dPsi1- dPsi;
% % %     if max(abs(dis(:))) > 1e-6
% % %         max(abs(dis(:)))
% % %         pause
% % %     end
% % %     dis = M1- M1;max(abs(dis(:)))
% % %     if max(abs(dis(:))) > 1e-6
% % %         max(abs(dis(:)))
% % %         pause
% % %     end
% % %     dis = yrank1- yrank;max(abs(dis(:)))
% % %     if max(abs(dis(:))) > 1e-6
% % %         max(abs(dis(:)))
% % %         pause
% % %     end
% % %     dis = Yconsnew1- Yconsnew;max(abs(dis(:)))
% % %     if max(abs(dis(:))) > 1e-6
% % %         max(abs(dis(:)))
% % %         pause
% % %     end
% % %     dis = YLoss1- YLoss;max(abs(dis(:)))
% % %     if max(abs(dis(:))) > 1e-6
% % %         max(abs(dis(:)))
% % %         pause
% % %     end
    
end