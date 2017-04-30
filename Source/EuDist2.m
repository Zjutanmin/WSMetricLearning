function res = EuDist2(X, B)
nbase = size(B, 1);
nframe = size(X, 1);
% find k nearest neighbors
XX = sum(X.*X, 2);
BB = sum(B.*B, 2);

res  = repmat(XX, 1, nbase)-2*X*B'+repmat(BB', nframe, 1);