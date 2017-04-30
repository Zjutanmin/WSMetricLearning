function [IDX, confidence] = GetRank_WTA_B1(isboost, Samplevoted, NotRatio, BitCount, ...
    K, isWTA, WTAwithraw, Metric, WTAindex, B, X, knn, latentKNN)
if isempty(B)
    B = X;
    knn = size(B, 1);
end
if isboost
    Nmetric = length(Metric) / 2;
    fconfidence = 0;
    Tmp = repmat([1:length(Samplevoted)], [1, size(B, 1)]);
    for jjj = 1:Nmetric
        [IDX, confidence] = GetRank_WTA(Samplevoted, NotRatio, BitCount, ...
            K, isWTA, WTAwithraw, Metric{2*(jjj-1)+1}, WTAindex, B, X, knn);
        a_t = Metric{2*jjj};
        vindex = sub2ind(size(IDX), Tmp(:), IDX(:));
        ctemp = zeros(size(confidence));
        ctemp(vindex) = confidence;
        fconfidence = fconfidence + ctemp *a_t;
    end
    fconfidence = fconfidence / Nmetric;
    [confidence, IDX] = sort(fconfidence, 2);
else
    if ~exist('latentKNN', 'var') || isempty(latentKNN),
        [IDX, confidence] = GetRank_WTA(Samplevoted, NotRatio, BitCount, ...
            K, isWTA, WTAwithraw, Metric, WTAindex, B, X, knn);
    else
        [IDX, confidence] = GetRank_WTA(Samplevoted, NotRatio, BitCount, ...
            K, isWTA, WTAwithraw, Metric, WTAindex, B, X, knn, latentKNN);
    end
end