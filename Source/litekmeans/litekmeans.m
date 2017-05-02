function [label, m] = litekmeans(X, k, W)
% Perform k-means clustering.
%   X: d x n data matrix
%   k: number of seeds
% Written by Michael Chen (sth4nth@gmail.com).
if nargin < 3
    W = [];
end

n = size(X,2);
last = 0;
label = ceil(k*rand(1,n));  % random initialization
while any(label(:) ~= last(:))
    [u,~,label] = unique(label);   % remove empty clusters
    k = length(u);
    E = sparse(1:n,label,1,n,k,n);  % transform label into indicator matrix
    m = X*(E*spdiags(1./sum(E,1)',0,k,k));    % compute m of each cluster
    last = label;
    if ~isempty(W)
        D  = Wdistance(X', m', k, n, W);D = -D';
    else
        XX = sum(X'.*X', 2);BB = sum(m'.*m', 2);
        D  = repmat(XX, 1, k)-2*X'*m+repmat(BB', n, 1);D = -D';
    end
    [~,label] = max(D,[],1); % assign samples to the nearest centers
%     D1 = bsxfun(@minus, bsxfun(@minus,m'*X,dot(m,m,1)'/2), (dot(X,X,1)'/2)');
%     [~,label1] = max(D1,[],1);
%     dis = D - 2*D1; max(abs(dis(:)))
%     nnz(label - label1)


% %     xx1 = m'*X;
% %     xx2 = dot(m,m,1)'/2;
% %     xx4 = xx1 - repmat(xx2, [1, size(xx1, 2)]);
% %     xx3 = bsxfun(@minus,m'*X,dot(m,m,1)'/2);
% %     dis = xx3 - xx4;
%     [~,label] = max(bsxfun(@minus,m'*X,dot(m,m,1)'/2),[],1); % assign samples to the nearest centers
end
[~,~,label] = unique(label);