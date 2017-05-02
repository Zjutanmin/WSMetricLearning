function [dPsi, M, SO_time, yrank, hLatent, RLatent, X] = cuttingPlaneFull_latent_Large_f(k, KNNlatent, X, hLatent, RLatent, ...
    PsiLatent, numSign, CIndex, W, datastr, SampleW, Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores, PsiLatentS)
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
    if nargin < 19
        PsiLatentS = 0;
        updateS = 0;
    end
    
    L = zeros(size(W));
    for i = 1:size(W,3)
        [vecs,vals] = eig(0.5 * (W(:,:,i) + W(:,:,i)'));
        L(:,:,i) = real(abs(vals)).^0.5 * vecs';
    end
    clear 'W'
    
    [d,n,m] = size(X);
    dPsi = PsiLatent;
    yrank   = zeros(batchSize, 1);
    M       = 0;
    BatchRound = size(CIndex, 1);
    
    dIndex  = sub2ind([n n], 1:n, 1:n);
    nbase = length(Template) / Nrotate;
    SO_time = 0;
    ntrain = length(Template);
    Range = zeros(Nrotate, 2);plus = zeros(Nrotate, 1);
    for jj = 1:Nrotate 
        Range(jj,1) = nbase*(jj-1) + 1;
        Range(jj,2) = nbase*jj;
        plus(jj) = (jj - 1)*nbase;      
    end
    
    
    if iscell(numSign)
        cellbase = numSign{2};
        numSign = numSign{1};
    end
    Tnum = numSign(setdiff((1:n)', Template));

    AH_index = cell(length(Tnum), 1)';
    AC_index = cell(length(Tnum), 1)';
    for i = 1:length(Tnum)
        AH_index{i} = [1:Tnum(i)]';
        AC_index{i} = (i+ntrain)*ones(Tnum(i), 1);
    end
    
    
    if isempty(ClassScores)

        smid = 0;
        for R = 1:BatchRound
            index = [CIndex(R, 1):CIndex(R, 2)];
            
            load([datastr,'_',num2str(R) '.mat'], 'Xcell'); 
            
            
            
% % % % % % % % % % % % % %             %%%%%%%By Tanmin
% % % %             load('index');dataIndex1 = sort(dataIndex1);dataIndex =sort(dataIndex);
% % % %             iid = find(ismember(dataIndex1-ntrain, index));
% % % %             index = iid;
% % % %             Xcell = Xcell(dataIndex1(iid)-ntrain-CIndex(R, 1)+1);
% % % % % % % % % % % % % %             %%%%%%%
% % % %             
            
            Xtest = (cell2mat(Xcell))';
            clear 'Xcell'
            ntest = size(Xtest, 2);
            D1 = setDistanceFullMKL_f([X(:, Template) Xtest], L, ...
                ntrain + (1:ntest), 1:ntrain);
            TSAMPLES = [1:ntest*Nrotate];
            yik = cell(1, length(TSAMPLES));
            
            
            lik = zeros(1, length(TSAMPLES));
            sik = zeros(1, length(TSAMPLES));
            
            xx = cell2mat(AC_index(index));
            C_index = repmat(xx(:),  [Nrotate, 1]);
            R_index = repmat([1:Nrotate], [ntest, 1]);R_index = R_index(:);
            xx = cell2mat(AH_index(index));
            H_index = repmat(xx(:),  [Nrotate, 1]);
%             B_index = [0:Nrotate-1]*ntest;
            SO_start        = tic();
            D1 = permute(reshape(D1, [nbase, Nrotate, ntest]), [1 3 2]);
            D1 = reshape(D1, [nbase, length(TSAMPLES)]);
            Ypos1 = Ypos(C_index);
            Yneg1 = Yneg(C_index);

            MRR  = ((1:(KNNlatent+1)).^-1)';
            R =1 /(nbase-1);
%             
            parfor j = TSAMPLES
                D = -D1(:,j);
                ind1 = Ypos1{j};         
                Dpos = D(ind1);
                [D,ord] = sort(D, 'descend');
                
                Dneg = D(1:KNNlatent+1);%%%the first one is positive
                iindex = find(ord~= ind1);
                ord = ord(iindex);
                Dneg = [Dpos; Dneg(iindex)];
                Td = [Dpos - Dneg];
                
                std = cumsum(Td)*R;
                I = -2*std-MRR(1:KNNlatent+1);
                
                [I1, Index] = max(I);
                ord1 = [0;ord];
                ord1(Index) =ind1;
                ord1(1:Index-1) = ord(1:Index-1);
                
                yik{j} = ord1;
                
                
                lik(j) = (1 - MRR(Index))';
                sik(j) = std(end,:) + I1+1;
                
            end
            
            
%             toc
            clear 'Ypos1'
            clear 'Yneg1'
            SO_time         = SO_time + toc(SO_start);
            
            TSAMPLES = SAMPLES(index);
            S       = zeros(ntrain+length(TSAMPLES));
            n1 = ntrain+length(TSAMPLES);
            TS  = zeros(length(TSAMPLES), n1);
            ntrainS = ntrain+smid;
            Tsum = [0, cumsum(numSign(TSAMPLES'))];
            % tic
            for j = TSAMPLES'
                Ynegative = setdiff(Yneg{j},Ypos{j});
                
                
                index = find(C_index == j);
                [si, ord] = max(sik(index));
                hLatent{j} = H_index(index(ord(1)));
                RLatent{j} = R_index(index(ord(1)));
                

% % % % % % % % % % %                 %%%%%%%By Tanmin
% % % %                 hLatent{j} = 4;RLatent{j} =2;
% % % %                 ord = length(index)/Nrotate*(RLatent{j}-1)+hLatent{j};si(j-ntrain) = (sik(index(ord(1))));
% % % % % % % % % % %                 %%%%%%%
% % % %                 
                
                yi = yik{index(ord(1))};
                Ynegative = setdiff(yi, Ypos{j});
                
                li = lik(index(ord(1)));
                M               = M + SampleW(j-ntrain) *li /batchSize;
                idx = find(ismember(yi, Ypos{j})); 
                yrank(j-ntrain)        = 1 / idx(1);
                X(:, j) = Xtest(:, hLatent{j}+Tsum(j-ntrainS));
                TS(j-ntrainS,:)         = PSIALL(j, yi'+plus(RLatent{j}), n1, Ypos{j}+...
                    plus(RLatent{j}), Ynegative+plus(RLatent{j}))* SampleW(j-ntrain);  
            end
% toc
            
            % Reconstruct the S matrix from TS
            S(TSAMPLES-smid,:)    = TS;
            S(:,TSAMPLES-smid)    = S(:,TSAMPLES-smid) + TS';
            dIndex1  = sub2ind([n1 n1], 1:n1, 1:n1);
            S(dIndex1)       = S(dIndex1) - sum(TS, 1);
            smid = smid + length(TSAMPLES);
            dPsi    = dPsi - CPGRADIENT(X(:, [1:ntrain, TSAMPLES']), S, batchSize);
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
end


