function D = setDistanceFullMKL_f(X, L, Ifrom, Ito, innerfea)
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

    [d,n,m]       = size(X);

    D = 0;

    if nargin < 4
        Ito     = 1:n;
    end
    if nargin < 5
        innerfea = 0;
    end

%     par
    for i = 1:m
% %         [vecs,vals] = eig(0.5 * (W(:,:,i) + W(:,:,i)'));
% %         L           = real(abs(vals)).^0.5 * vecs';

        Vfrom   = L(:,:,i) * X(:,Ifrom,i);

        Vto     = L(:,:,i) * X(:,Ito,i);

        D = D + distToFrom(Vto, Vfrom, innerfea);
    end
end

function D = distToFrom(Vto, Vfrom, innerfea)
    if innerfea
        Cross           = -Vto' * Vfrom;
        D    = Cross;
    else
        Cross           = -2 * Vto' * Vfrom;
        Tonorm          = sum(Vto .^2, 1)';
        Fromnorm        = sum(Vfrom .^2, 1);
        D    = bsxfun(@plus, bsxfun(@plus, Cross, Tonorm), Fromnorm);
    end
    
end