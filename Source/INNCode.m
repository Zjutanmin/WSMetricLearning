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

function [storedW, labels]  = INNCode(tr_feats, tr_labels, te_feats, ...
    te_labels, lambda, K, blocksize, verbose, beta, Ymatched, innerfea)
if ~exist('Ymatched','var')
    Ymatched = [];
end;
if ~exist('innerfea','var')
    innerfea = 0;
end;
if nargin < 9
Ymatched = [];
end
if blocksize == -1
    blocksize = size(te_feats,1); 
end
labels = zeros(size(te_labels));
scores = zeros(length(te_labels), max(te_labels));
blocksize = min(blocksize, size(te_feats,1));  	
fprintf('K = %g\n',K);
storedW = zeros(size(te_feats, 1),size(tr_feats,1));
%% 
if isempty(Ymatched)
    Ymatched = int8(ones(size(storedW)));
    if nnz(size(Ymatched) - [size(tr_feats, 1), size(te_feats, 1)])
        Ymatched = Ymatched';
    end
else
    YmatchT = int8(zeros(size(storedW)));
    YmatchT(Ymatched) = 1;
    Ymatched = YmatchT; clear 'YmatchT';
    if nnz(size(Ymatched) - [size(tr_feats, 1), size(te_feats, 1)])
        Ymatched = Ymatched';
    end
end

for blockposition = 1:blocksize:size(te_feats,1)
    blocksize = min(blocksize, size(te_feats,1)-blockposition+1);
    fprintf('Block %g-%g\n',blockposition,blockposition+blocksize-1);
    W = zeros(blocksize,size(tr_feats,1));
    temp = te_feats(blockposition:blockposition+blocksize-1,:);
    YM = Ymatched(:, blockposition:blockposition+blocksize-1);
    weight = lambda;
    for k = 1:K
        if innerfea
            res = tr_feats * temp';
            res(find(~YM)) = -Inf;
            [~, ID] = max(res);
        else
            res = (EuDist2(temp, tr_feats))';
            res(find(~YM)) = Inf;
            [~, ID] = min(res);
        end
        ID2 = [1:size(ID,2)]+size(temp,1)*(ID-1);  
        weight = weight/(1.0+lambda);
        W(ID2) = W(ID2) + weight;
        temp = temp + lambda*(temp - tr_feats(ID,:));
    end;    
    %% INNC label assignment
    for l=1:max(te_labels)
        scores(blockposition:blockposition+blocksize-1,l) = sum(W(:,tr_labels==l),2);
%       scoresR(iter1:iter1+blocksize-1,l) = sum((te_feats(iter1:iter1+blocksize-1,:) - ...
%           W(:,tr_labels==l)*tr_feats(tr_labels==l,:)).^2,2);
    end;  
    for i=1:blocksize
        [mm idd] = max(scores(blockposition+i-1,:));        
        labels(blockposition+i-1) = idd(1);
    end;
    %% INNC scores based on weights or residuals    
    storedW(blockposition:blockposition+blocksize-1,:) = W;
end
storedW = bsxfun(@times, storedW, 1./sum(storedW, 2));
