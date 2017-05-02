% Iterative Nearest Neighbors Classifier
%
% code by 
%      Radu Timofte @ K.U. Leuven, ESAT/PSI-VISICS
%
% reference
%      Iterative Nearest Neighbors for Classification and Dimensionality Reduction
%      Radu Timofte and Luc Van Gool
%      CVPR 2012
%
% version 0.3, 14.09.2012 - cleaned content, added comments
% version 0.2, 11.10.2011 - fixed weights, parameters
% version 0.1, 28.08.2011 - INNC using weights or residuals

function [labels, acc, labelsR, accR, storedW, Resb]    = INNC1(tr_feats, tr_labels, ...
    te_feats, te_labels, lambda, K, blocksize, verbose, beta, innerfea, knn, TestOnly)

%INPUT
% tr_feats :  number_train_samples * number_dimensions_feature
% tr_labels:  number_train_samples * 1
% te_feats :  number_test_samples * number_dimensions_feature
% te_labels:  number_test_samples * 1
% lambda   :  float > 0  , regulatory parameter, default = 0.25
% K        :  integer > 0, number of iterations, default = defined by lambda & beta
% blocksize:  integer > 0, number test samples processed in the same block, default = ALL
%             Usually the larger the blocksize the faster the computation with Matlab
% verbose  :  0/1, verbose mode, whether INN weights are stored, default = 0
% beta     :  the beta-fraction, default = 0.95;
%             1-beta corresponds to the (noise) tolerance for INN

%OUTPUT
% labels   :  number_test_samples * 1, INNC labels output using weights
% acc      :  float, classification accuracy using weights
% labelsR  :  number_test_samples * 1, INNC labels output using residuals
% accR     :  float, classification accuracy using residuals
% storeW   :  number_test_samples * number_train_samples, INN weights

%COMMENTS
% if K is imposed then one can compute
%          lambda = exp(-log(1-beta)/K)-1
% if lambda is imposed then one can compute
%          K = ceil(-log(1-beta)/log(1+lambda))

if ~exist('beta','var')
    beta = 0.95;
end;
if ~exist('verbose','var')
    verbose = 0;
end;
if ~exist('blocksize','var') || (blocksize > size(te_feats,1))
    blocksize = size(te_feats,1);
end;
if ~exist('lambda','var')
    lambda = 0.25;
    %lambda = exp(-log(1-beta)/K)-1;
end;
if ~exist('K','var')
    K = ceil(-log(1-beta)/log(1+lambda));    	
    if verbose == 1
        fprintf('K = %g\n',K);
    end
end;
if ~exist('knn','var')
    knn = 1;
end;
if ~exist('TestOnly','var')
    TestOnly = 0;
end;

start_time = tic;

%% initialize outputs
labels = zeros(length(te_labels), knn);
labelsR = zeros(size(te_labels));
acc = 0;
accR= 0;
TestOnly = 1;
if TestOnly
scores = zeros(length(te_labels), max(tr_labels));
Nmax = max(tr_labels);
else
scores = zeros(length(te_labels), max(te_labels));
Nmax = max(te_labels);
end
if ~exist('innerfea','var')
    innerfea = 0;
end;
%scoresR = zeros(length(te_labels), max(te_labels));
storedW = [];
if verbose
    storedW = zeros(length(te_labels),size(tr_feats,1));
end

%% 
for blockposition = 1:blocksize:size(te_feats,1)
    
    if blockposition+blocksize-1 > size(te_feats,1)
        blocksize = size(te_feats,1)-blockposition+1;
    end
    
    if verbose == 1
        fprintf('Block %g-%g\n',blockposition,blockposition+blocksize-1);
    end
    
    %% INN computation
         W = zeros(blocksize,size(tr_feats,1));
         temp = te_feats(blockposition:blockposition+blocksize-1,:);
         weight = lambda;
         for k = 1:K
            if innerfea
                res = tr_feats * temp';     % for speed
                [HHH, ID] = max(res);
                
            else
                res = (EuDist2(temp, tr_feats))';
                [HHH, ID] = min(res);
            end

%             res = EuDist2(tr_feats,temp,0); squared Euclidean distances
%             res = EuDist2(tr_feats,temp);   %%Euclidean distances
%             
            res = (EuDist2(temp, tr_feats))';
            
            [HHH, ID] = min(res);
%             if k > 1
%                nnz(ID1 - ID)
%             end
            ID1 = ID;

            ID2 = [1:size(ID,2)]+size(temp,1)*(ID-1);  
            weight = weight/(1.0+lambda);
            W(ID2) = W(ID2) + weight;
            %W(ID2) = W(ID2) + gamma/(1.0+gamma)^k;
            temp = temp + lambda*(temp - tr_feats(ID,:));
         end; 
         
    %% INNC scores based on weights or residuals    
    for l=1:Nmax
        scores(blockposition:blockposition+blocksize-1,l) = sum(W(:,tr_labels==l),2);
%       scoresR(iter1:iter1+blocksize-1,l) = sum((te_feats(iter1:iter1+blocksize-1,:) - ...
%           W(:,tr_labels==l)*tr_feats(tr_labels==l,:)).^2,2);
    end; 
    
    if knn > Nmax
        for l=1:knn
        scores1(blockposition:blockposition+blocksize-1,l) = sum(W(:,tr_labels==l),2);
        end;
    else
        scores1 = zeros([blocksize, knn]);
    end
    

    %% INNC label assignment
    for i=1:blocksize
        [resb idd] = sort(scores(blockposition+i-1,:), 'descend');        
%         labels(blockposition+i-1,:) = idd(1:end);
        
        [resb1 idd1] = sort([-inf * ones([1, Nmax]), scores1(blockposition+i-1,Nmax+1:end)], 'descend');  
        idd = [idd, idd1(1:end-Nmax)];
        resb = [resb, resb1(1:end-Nmax)];
        
        labels(blockposition+i-1,1:knn) = idd(1:knn);
        Resb(blockposition+i-1,1:knn) = resb(1:knn);
    end;
    
%     if knn > Nmax
%         for l=1:knn
%             
%             labels = [labels, 
%         scores1(blockposition:blockposition+blocksize-1,l) = sum(W(:,tr_labels==l),2);
%         end;
%     end
    
    if verbose==1
        fp = sum(~bsxfun(@minus, labels(1:blockposition+blocksize-1,:), te_labels(1:blockposition+blocksize-1)), 2);
        acc  = fp / length(fp);
        % store the INN weights
        storedW(blockposition:blockposition+blocksize-1,:) = W;
        fprintf('Total accuracy <weights> = %.4f%% and <residuals> = %.4f%%\n', acc*100, accR*100);
        toc(start_time);
    end
end

%% INNC accuracy
fp = sum(~bsxfun(@minus, labels, te_labels), 2);
acc  = sum(fp) / length(fp);
        
% acc  = mean(labels==te_labels);
%accR  = mean(labelsR==te_labels);




% % Iterative Nearest Neighbors Classifier
% %
% % code by 
% %      Radu Timofte @ K.U. Leuven, ESAT/PSI-VISICS
% %
% % reference
% %      Iterative Nearest Neighbors for Classification and Dimensionality Reduction
% %      Radu Timofte and Luc Van Gool
% %      CVPR 2012
% %
% % version 0.3, 14.09.2012 - cleaned content, added comments
% % version 0.2, 11.10.2011 - fixed weights, parameters
% % version 0.1, 28.08.2011 - INNC using weights or residuals
% 
% function [labels, acc, labelsR, accR, storedW]    = INNC(tr_feats, ...
%     tr_labels, te_feats, te_labels, lambda, K, blocksize, verbose, beta, innerfea)
% %INPUT
% % tr_feats :  number_train_samples * number_dimensions_feature
% % tr_labels:  number_train_samples * 1
% % te_feats :  number_test_samples * number_dimensions_feature
% % te_labels:  number_test_samples * 1
% % lambda   :  float > 0  , regulatory parameter, default = 0.25
% % K        :  integer > 0, number of iterations, default = defined by lambda & beta
% % blocksize:  integer > 0, number test samples processed in the same block, default = ALL
% %             Usually the larger the blocksize the faster the computation with Matlab
% % verbose  :  0/1, verbose mode, whether INN weights are stored, default = 0
% % beta     :  the beta-fraction, default = 0.95;
% %             1-beta corresponds to the (noise) tolerance for INN
% 
% %OUTPUT
% % labels   :  number_test_samples * 1, INNC labels output using weights
% % acc      :  float, classification accuracy using weights
% % labelsR  :  number_test_samples * 1, INNC labels output using residuals
% % accR     :  float, classification accuracy using residuals
% % storeW   :  number_test_samples * number_train_samples, INN weights
% 
% %COMMENTS
% % if K is imposed then one can compute
% %          lambda = exp(-log(1-beta)/K)-1
% % if lambda is imposed then one can compute
% %          K = ceil(-log(1-beta)/log(1+lambda))
% if ~exist('beta','var')
%     beta = 0.95;
% end;
% if ~exist('verbose','var')
%     verbose = 0;
% end;
% if ~exist('blocksize','var') || (blocksize > size(te_feats,1))
%     blocksize = size(te_feats,1);
% end;
% if ~exist('lambda','var')
%     lambda = 0.25;
%     %lambda = exp(-log(1-beta)/K)-1;
% end;
% if ~exist('K','var')
%     K = ceil(-log(1-beta)/log(1+lambda));    	
%     if verbose == 1
%         fprintf('K = %g\n',K);
%     end
% end;
% if ~exist('innerfea','var')
%     innerfea = 0;
% end;
% 
% start_time = tic;
% 
% %% initialize outputs
% labels = zeros(size(te_labels));
% labelsR = zeros(size(te_labels));
% acc = 0;
% accR= 0;
% scores = zeros(length(te_labels), max(te_labels));
% %scoresR = zeros(length(te_labels), max(te_labels));
% storedW = [];
% if verbose
%     storedW = zeros(length(te_labels),size(tr_feats,1));
% end
% 
% %% 
% for blockposition = 1:blocksize:size(te_feats,1)
%     
%     if blockposition+blocksize-1 > size(te_feats,1)
%         blocksize = size(te_feats,1)-blockposition+1;
%     end
%     
%     if verbose == 1
%         fprintf('Block %g-%g\n',blockposition,blockposition+blocksize-1);
%     end
%     
%     %% INN computation
%          W = zeros(blocksize,size(tr_feats,1));
%          temp = te_feats(blockposition:blockposition+blocksize-1,:);
%          weight = lambda;
%          for k = 1:K
%             if innerfea
%                 res = tr_feats * temp';     % for speed
% %                 res(Ymatched) = -Inf;
%                 [HHH, ID] = max(res);
%                 
%             else
%                 res = (EuDist2(temp, tr_feats))';
% %                 res(Ymatched) = Inf;
%                 [HHH, ID] = min(res);
%             end
% 
% %             res = EuDist2(tr_feats,temp,0); squared Euclidean distances
% %             res = EuDist2(tr_feats,temp);   %%Euclidean distances
% %             
%             
% %             ID1 = ID;
% 
%             ID2 = [1:size(ID,2)]+size(temp,1)*(ID-1);  
%             weight = weight/(1.0+lambda);
%             W(ID2) = W(ID2) + weight;
%             %W(ID2) = W(ID2) + gamma/(1.0+gamma)^k;
%             temp = temp + lambda*(temp - tr_feats(ID,:));
%          end; 
%          
%     %% INNC scores based on weights or residuals    
%     for l=1:max(te_labels)
%         scores(blockposition:blockposition+blocksize-1,l) = sum(W(:,tr_labels==l),2);
% %       scoresR(iter1:iter1+blocksize-1,l) = sum((te_feats(iter1:iter1+blocksize-1,:) - ...
% %           W(:,tr_labels==l)*tr_feats(tr_labels==l,:)).^2,2);
%     end;        
% 
%     %% INNC label assignment
%     for i=1:blocksize
%         [mm idd] = max(scores(blockposition+i-1,:));        
%         labels(blockposition+i-1) = idd(1);
% %        [mm idd] = min(scoresR(iter1+i-1,:));        
% %        labelsR(iter1+i-1) = idd(1);
%     end;
%     if verbose==1
%         acc  = mean(labels(1:blockposition+blocksize-1) ==te_labels(1:blockposition+blocksize-1));
%     %   accR = mean(labelsR(1:iter1+blocksize-1)==te_labels(1:iter1+blocksize-1));
%         
%         % store the INN weights
%         storedW(blockposition:blockposition+blocksize-1,:) = W;
%         fprintf('Total accuracy <weights> = %.4f%% and <residuals> = %.4f%%\n', acc*100, accR*100);
%         toc(start_time);
%     end
% end
% 
% %% INNC accuracy
% acc  = mean(labels==te_labels);
% %accR  = mean(labelsR==te_labels);
% 
