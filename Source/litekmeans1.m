function [label, m] = litekmeans1(X, k, SWW, INNERMean)
% Perform k-means clustering.
%   X: d x n data matrix
%   k: number of seeds
% Written by Michael Chen (sth4nth@gmail.com).
n = size(X,2);
if nargin < 3
    SWW = ones(1, n);
end
SWW = SWW(:);SWW = SWW';
last = 0;
label = ceil(k*rand(1,n));  % random initialization

if nargin < 4
    INNERMean = 0;
    
end
if ~INNERMean
    [label, m] = litekmeans1_Dis(X, k, SWW, label, n);
    return;
end
% xx = 0;

while any(label ~= last)
%     [u,~,label] = unique(label);   % remove empty clusters
%     k = length(u);

%     E = sparse(1:n,label,1,n,k,n);  % transform label into indicator matrix
%     m = X*(E*spdiags(1./sum(E,1)',0,k,k));    % compute m of each cluster

    E = sparse(1:n,label,SWW,n,k,n);  % transform label into indicator matrix
    m = X*(E*spdiags(1./sum(E,1)',0,k,k));    % compute m of each cluster    
%     for tt = 1:k
%         idx = find(label == tt);
%         mm(:, tt) = sum(bsxfun(@times, X(:, idx), SWW(idx)), 2) / sum(SWW(idx));
%     end
    
%     dis = m - mm; 
%     xx = max(xx, max(abs(dis(:))));
    tidx = find(sum(m.^2, 1));
    m(:, tidx) = bsxfun(@times, m(:, tidx), sqrt(1./sum(m(:, tidx).^2, 1)));

    
    last = label;
    
    
    [~,label] = max(bsxfun(@minus,m'*X,dot(m,m,1)'/2),[],1); % assign samples to the nearest centers
end




function [label, m] = litekmeans1_Dis(X, k, SWW, label, n)
last = 0;
while any(label ~= last)
%     [u,~,label] = unique(label);   % remove empty clusters
%     k = length(u);

%     E = sparse(1:n,label,1,n,k,n);  % transform label into indicator matrix
%     m = X*(E*spdiags(1./sum(E,1)',0,k,k));    % compute m of each cluster

    E = sparse(1:n,label,SWW,n,k,n);  % transform label into indicator matrix
    m = X*(E*spdiags(1./sum(E,1)',0,k,k));    % compute m of each cluster    
%     for tt = 1:k
%         idx = find(label == tt);
%         mm(:, tt) = sum(bsxfun(@times, X(:, idx), SWW(idx)), 2) / sum(SWW(idx));
%     end
    
%     dis = m - mm; 
%     xx = max(xx, max(abs(dis(:))));
   
    
    last = label;
    
    
    [~,label] = max(bsxfun(@minus,m'*X,dot(m,m,1)'/2),[],1); % assign samples to the nearest centers
end
% xx
% t = 1;
% [~,~,label] = unique(label);