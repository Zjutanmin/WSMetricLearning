function S = metricPsiPOALL(q, y, n, pos, neg)
%
%   S = metricPsiPO(q, y, n, d, pos, neg)
%
%   q   = index of the query point
%   y   = the ordering to compute
%   n   = number of points in the data set
%   pos = indices of relevant results for q
%   neg = indices of irrelevant results for q
%
%   S is the vector of weights for q

    yp          = ismember(y, pos);
    NumPOS      = sum(yp);
    PosAfter    = NumPOS - cumsum(yp);
    PosBefore   = cumsum(yp) - yp;

    yn          = ~yp;
    NumNEG      = sum(yn);
    NegBefore   = cumsum(yn) - yn;
    NegAfter    = NumNEG - cumsum(yn);

    S = zeros(n,1);

    S1    = -(yp .* NegBefore - yn .* PosAfter) / (NumNEG * NumPOS);
    S2    = (yp .* NegAfter - yn .* PosBefore) / (NumNEG * NumPOS);
    S(y)  = S1 + S2;
end
