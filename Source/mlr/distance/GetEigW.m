function L = GetEigW(W)
%
% D = setDistanceFullMKL(X, W, Ifrom, Ito)
%
%   X       = d-by-n-by-m data matrix
%   W       = d-by-d-by-m PSD matrix
%   Ifrom   = k-by-1 vector of source points
%   Ito     = j-by-1 vector of destination points
%
%   D = n-by-n matrix of squared euclidean distances from Ifrom to Ito
%       D is sparse, and only the rows corresponding to Ifrom and
%       columns corresponding to Ito are populated.
    m = size(W, 3);
    parfor i = 1:m
        [vecs,vals] = eig(0.5 * (W(:,:,i) + W(:,:,i)'));
        L(:,:,i)    = real(abs(vals)).^0.5 * vecs';
    end
end