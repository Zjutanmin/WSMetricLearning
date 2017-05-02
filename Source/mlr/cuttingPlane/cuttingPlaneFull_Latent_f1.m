function [dPsi, M, SO_time, hLatent, RLatent, PsiLatentS, TSAMPLES, penalty1] = cuttingPlaneFull_Latent_f1(k, X, hLatent, RLatent, ...
    PsiLatent, numSign, W, Ypos, Yneg, batchSize, Template, Nrotate, SAMPLES, ClassScores, TS1, PsiS, penalty)
    
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

    penalty1 = 0;
    if nargin < 15
        PsiS = 0;
        TS = 0;
        updateS = 0;
    else
        updateS = 1;
    end
    
    [d,n,m] = size(getLatent(numSign, X, hLatent));
    L = zeros(size(W));
    for i = 1:size(W,3)
        [vecs,vals] = eig(0.5 * (W(:,:,i) + W(:,:,i)'));
        L(:,:,i) = real(abs(vals)).^0.5 * vecs';
    end  
    clear 'W'
%     dis = (D1(:,2:end) - Dwgt);max(abs(dis(:)))
    Xtemplate = cell2mat(X(Template));
    XTest = (X(setdiff(1:n, Template)));
    Xtest = (cell2mat(XTest));
    clear 'X';clear 'W';clear 'XTest'
    

    M       = 0;
    S       = zeros(n);
    
%     S1      = zeros(n);
    hLatent1 = hLatent;
    RLatent1 = RLatent;

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
                   
    Tnum = numSign(setdiff((1:n)', Template));
    
    
    AH_index = cell(length(Tnum), 1)';
    AC_index = cell(length(Tnum), 1)';
    for i = 1:length(Tnum)
        AH_index{i} = [1:Tnum(i)]';
        AC_index{i} = (i+ntrain)*ones(Tnum(i), 1);
    end    
    
   
    if isempty(ClassScores)
        TS  = zeros(length(SAMPLES), n);

        ntest = size(Xtest, 2);
        
%         tic
        D1 = setDistanceFullMKL_f([Xtemplate Xtest], L, ...
                ntrain + (1:ntest), 1:ntrain);
%         toc
        
        TSAMPLES = [1:ntest*Nrotate];
            yik = zeros(nbase, length(TSAMPLES));
            lik = zeros(1, length(TSAMPLES));
            sik = zeros(1, length(TSAMPLES));
            
            xx = cell2mat(AC_index);
            C_index = repmat(xx(:),  [Nrotate, 1]);
            
            R_index = repmat([1:Nrotate], [ntest, 1]);
            
            R_index = R_index(:);
            
            xx = cell2mat(AH_index);
            H_index = repmat(xx(:),  [Nrotate, 1]);
            SO_start        = tic();
            
            D1 = permute(reshape(D1, [nbase, Nrotate, ntest]), [1 3 2]);
            D1 = -reshape(D1, [nbase, length(TSAMPLES)]);
            

%             tic
            MRR  = ((1:(nbase)).^-1)';
            Ypos1 = cell2mat(Ypos(C_index));R =1 /(nbase-1);
            parfor j = TSAMPLES
                D = D1(:,j);
                ind1 = Ypos1(j);         
                Dpos = D(ind1);
                D(ind1) = inf;
                [Dneg,ord] = sort(D, 'descend');ord = ord(2:end);
                Dneg(1,:) = Dpos';
                Td = Dpos - Dneg;
                std = cumsum(Td)*R; 
                I = -2*std-MRR;
                [I1, Index] = max(I);
                ord1 = [0;ord];
                ord1(Index) =ind1;
                ord1(1:Index-1) = ord(1:Index-1);
                yik(:,j) = ord1;
                lik(j) = (1 - MRR(Index))';
                sik(j) = std(end,:) + I1+1;
            end
            
            if length(SAMPLES) ~=  length(numSign) - ntrain
                t = 1;
            end
%             MRR  = ((1:(nbase)).^-1)';
%             Ypos1 = cell2mat(Ypos(C_index));R =1 /(nbase-1);
%             Range = SAMPLES(ismember([1:ntest]));
%             
%             D1 = permute(reshape(D1, [nbase, Nrotate, ntest]), [1 3 2]);
%             D1 = -reshape(D1, [nbase, length(TSAMPLES)]);
%             parfor j = TSAMPLES
%                 D = D1(:,j);
%                 ind1 = Ypos1(j);         
%                 Dpos = D(ind1);
%                 D(ind1) = inf;
%                 [Dneg,ord] = sort(D, 'descend');ord = ord(2:end);
%                 Dneg(1,:) = Dpos';
%                 Td = Dpos - Dneg;
%                 std = cumsum(Td)*R; 
%                 I = -2*std-MRR;
%                 [I1, Index] = max(I);
%                 ord1 = [0;ord];
%                 ord1(Index) =ind1;
%                 ord1(1:Index-1) = ord(1:Index-1);
%                 yik(:,j) = ord1;
%                 lik(j) = (1 - MRR(Index))';
%                 sik(j) = std(end,:) + I1+1;
%             end
            
%             toc
            
            
            SO_time         = SO_time + toc(SO_start);
%             tic
             si = zeros(1, length(SAMPLES));
             for i = 1:length(SAMPLES)
                 j = SAMPLES(i);
                 
                Ynegative = Yneg{j};
                index = find(C_index == j);
                [si(j-ntrain), ord] = max(sik(index));
                hLatent(j) = H_index(index(ord(1)));
                RLatent(j) = R_index(index(ord(1)));

                yi = yik(:,index(ord(1)));li = lik(index(ord(1)));
                M               = M + li /batchSize;
                
                TS(i,:)         = PSIALL(j, yi'+plus(RLatent(j)), n, Ypos{j}+...
                    plus(RLatent(j)), Ynegative+plus(RLatent(j))); 
           
             end
             if updateS && penalty
                 Valid = find(si-PsiS < penalty);
             else
                 penalty1 = sort(si-PsiS);
                 tt = ceil(length(penalty1)/ 2);
                 penalty1  = penalty1(tt);
                 Valid = find(si-PsiS < penalty1);
             end
             
                
%              toc
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
    TSAMPLES = SAMPLES;
    PsiLatentS = PsiLatent;
    
    if updateS
        
        S       = zeros(n);
        S(SAMPLES,:)    = TS1;
        S(:,SAMPLES)    = S(:,SAMPLES) + TS1';
        S(dIndex)       = S(dIndex) - sum(TS1, 1);
        
        PsiLatentS = CPGRADIENT(getLatent(numSign, mat2cell([Xtemplate, Xtest], ...
            size(Xtemplate,1), numSign), hLatent1), S, batchSize);
        dis = PsiLatentS - PsiLatent;
        max(abs(dis(:)))
        
        TS1(setdiff([1:size(TS1,1)], Valid), :) = 0;
        S       = zeros(n);
        S(SAMPLES,:)    = TS1;
        S(:,SAMPLES)    = S(:,SAMPLES) + TS1';
        S(dIndex)       = S(dIndex) - sum(TS1, 1);
        PsiLatentS = CPGRADIENT(getLatent(numSign, mat2cell([Xtemplate, Xtest], ...
            size(Xtemplate,1), numSign), hLatent1), S, batchSize);

        dPsi = 0;
        TSAMPLES = Valid' + ntrain;
        return;
    end
    
    dPsi    = PsiLatentS - CPGRADIENT(getLatent(numSign, mat2cell([Xtemplate, Xtest], ...
        size(Xtemplate,1), numSign), hLatent), S, batchSize);
end
