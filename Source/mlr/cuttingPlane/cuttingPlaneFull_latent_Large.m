function [dPsi, M, SO_time, hLatent, RLatent, X] = cuttingPlaneFull_latent_Large(k, X, hLatent, RLatent, ...
    PsiLatent, numSign, CIndex, W, datastr, Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores)
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

    [d,n,m] = size(X);
    
%     D       = DISTANCE(W, cell2mat(X));
%     Tall = getLatent(numSign, X);
% Tall = cell2mat(X(1:4600));
% 
%     tic;
%     D       = DISTANCE(W, Tall);
%     toc;
%     
%     tic;
% %     D1       = D(1:length(Template),end-215:end);
%     Tall = Tall';
%     weuc = @(XI,XJ,W)(sum(bsxfun(@minus,XI,XJ).^2 * W, 2));
%     Dwgt = pdist2(Tall(1:length(Template), :),Tall(length(Template)+1:end, :), @(Xi,Xj) weuc(Xi,Xj,W));
%     toc;
%     
%     dis = (D1(:,2:end) - Dwgt);max(abs(dis(:)))
%     Xtemplate = cell2mat(X(Template));.
    Xtemplate = X(:, Template);

    M       = 0;
    S       = zeros(n);
    
%     S1      = zeros(n);
    BatchRound = size(CIndex, 1);
    
    dIndex  = sub2ind([n n], 1:n, 1:n);
    nbase = length(Template) / Nrotate;
    SO_time = 0;
    
    Range = zeros(Nrotate, 2);plus = zeros(Nrotate, 1);
    for jj = 1:Nrotate 
        Range(jj,1) = nbase*(jj-1) + 1;
        Range(jj,2) = nbase*jj;
        plus(jj) = (jj - 1)*nbase;      
    end
                   
    
    if isempty(ClassScores)
        TS  = zeros(batchSize, n);
        
%         %%%begin debug
%         TS1 = zeros(batchSize, n);
% %         %%%end debug
%         for R = 1:length(BatchRound)
%             
%             load(fullfile(datastr,[num2str(R) '.mat']), 'XCell'); 
%             index = find(cc)
%          for i = 1:batchsize
%              if i <= length(SAMPLES)
%                 j = SAMPLES(i);



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

%                 load(fullfile(datastr,[num2str(j-length(Template)) '.mat']), 'Xtmp'); 


                D = cell(1, Nrotate);
                for tt = 1:Nrotate
                    D{tt} = DISTANCE(W, [Xtemplate(:,[Range(tt,1):Range(tt,2)]), Xtmp']);
                end

                SO_start        = tic();
                
                yik = zeros([nbase, numSign(j), Nrotate]);
                lik = zeros([numSign(j), Nrotate]);sik = zeros([numSign(j), Nrotate]);
                
                for kk = 1:numSign(j)
                    for tt = 1:Nrotate
                        [yik(:,kk,tt), lik(kk,tt), sik(kk,tt)]    =   SO(nbase+kk, D{tt}, Ypos{j}, Ynegative, k);
                    end
                end
                
                [si, ord] = max(sik(:));
                [xx, yy] = ind2sub([numSign(j), Nrotate], ord);
                
                yi = yik(:,xx, yy);li = lik(xx, yy);
                
                hLatent(j) = xx;
                RLatent(j) = yy;
                
                
                X(:, j) = (Xtmp(hLatent(j), :))';
                
                SO_time         = SO_time + toc(SO_start);

                M               = M + li /batchSize;
                TS(index(i),:)         = PSIALL(j, yi'+plus(RLatent(j)), n, Ypos{j}+...
                    plus(RLatent(j)), Ynegative+plus(RLatent(j)));   
                
%                 %%%for debug
%                 TS1(i,:)        = PSI(j, yi'+...
%                     plus(RLatent(j)), n, Ypos{j}+...
%                     plus(RLatent(j)), Ynegative+...
%                     plus(RLatent(j))); 
%                 %%%end debug
            end
        end
        % Reconstruct the S matrix from TS
        S(SAMPLES,:)    = TS;
        S(:,SAMPLES)    = S(:,SAMPLES) + TS';
        S(dIndex)       = S(dIndex) - sum(TS, 1);
        
%         %%%for debug
%         S1(SAMPLES,:)   = TS1;
%         S1(:,SAMPLES)   = S1(:,SAMPLES) + TS1';
%         S1(dIndex)      = S1(dIndex) - sum(TS1, 1);
%         %%%end debug
        
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
                SO_start    = tic();
                    [yi, li]    = SO(i, D, Ypos, Yneg, k);
                SO_time     = SO_time + toc(SO_start);

                M           = M + li;
                TS(x,:)     = PSI(i, yi', n, Ypos, Yneg);
            end

            S(points,:) = S(points,:) + TS;
            S(:,points) = S(:,points) + TS';
            S(dIndex)   = S(dIndex) - sum(TS, 1);
        end
        M   = M / batchSize;
    end
    
%     %%%When hLatent = 1
%     %%%for debug
%     dPsi1   = CPGRADIENT(getLatent(numSign, X, hLatent), S1, batchSize);
%     
%     dPsi    = CPGRADIENT(getLatent(numSign, X, hLatent), S, batchSize);
%     dPsi2   = PsiLatent - dPsi;
%     dis = dPsi1 - dPsi2;
%     max(abs(dis(:)))
%     pause
%     %%%end debug
%     
    dPsi    = PsiLatent - CPGRADIENT(X, S, batchSize);
end


