function X = L2normMatrix(X, tnorm)
if nargin < 2
    tnorm = 1;
end
idx = find(sum(X.^2, 2));
X(idx,:) = getL2normMatrix(X(idx,:), tnorm);

function X = getL2normMatrix(X, tnorm)
X = X ./ repmat(sqrt(sum(X.^2, 2)), [1, size(X, 2)]);
if nargin > 1
    X = X ./ sqrt(tnorm);
end