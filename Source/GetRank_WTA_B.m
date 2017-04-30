function [IDX, confidence] = GetRank_WTA_B(iscode, isboost, Samplevoted, NotRatio, BitCount, ...
    K, isWTA, WTAwithraw, Metric, WTAindex, innerfea, B, X, knn, latentKNN)
% B = GetSparseCoding(iscode{1}, B, iscode{2});
% X = GetSparseCoding(iscode{1}, X, iscode{2});
B = full(B);
if isempty(B)
    B = X;
    knn = size(B, 1);
end
islatent = 0;numSign = 0;
knn_o = knn;
if length(iscode)>2 && iscode{3}
    knn = size(B, 1);
    nRotate = iscode{4};
    islatent = iscode{3};
    iscode = iscode(1:2);
    
    latentKNN = size(B, 1);
    NotRatio = repmat(NotRatio, [1, nRotate]);
end

if iscell(X)
    numSign = cellfun(@(x) size(x, 1), X,  'UniformOutput', false);
    NotRatio = cell2mat(cellfun(@(x, y) repmat(x, y, 1), mat2cell(NotRatio, ...
        ones(size(NotRatio, 1), 1), size(NotRatio, 2)), numSign, 'UniformOutput', false));
    Samplevoted = cell2mat(cellfun(@(x, y) repmat(x, y, 1), mat2cell(Samplevoted, ...
        ones(size(Samplevoted, 1), 1), size(Samplevoted, 2)), numSign, 'UniformOutput', false));
    X = cell2mat(X);
    numSign = cell2mat(numSign);
else
    X = full(X);
end
if isboost
    Nmetric = length(Metric) / 2;
    fconfidence = 0;
    Tmp = repmat([1:length(Samplevoted)], [1, size(B, 1)]);
    for jjj = 1:Nmetric
        [IDX, confidence] = GetRank_WTA(Samplevoted, NotRatio, BitCount, ...
            K, isWTA, WTAwithraw, Metric{2*(jjj-1)+1}, WTAindex, innerfea, B, X, knn);
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
            K, isWTA, WTAwithraw, Metric, WTAindex, innerfea, B, X, knn);
    else
        [IDX, confidence] = GetRank_WTA(Samplevoted, NotRatio, BitCount, ...
            K, isWTA, WTAwithraw, Metric, WTAindex, innerfea, B, X, knn, latentKNN);
    end
    if islatent
        if knn == 1
            IDX = mod(IDX, latentKNN/nRotate);
            IDX(find(~IDX)) = latentKNN/nRotate;
        else
        RLatent = ceil(IDX(:, 1)/(size(IDX, 2)/nRotate));
% % %         RLatent(:) = 1;
        ttindex = ceil(IDX/(size(IDX, 2)/nRotate)) - repmat(RLatent, 1, size(IDX, 2));
        ttindex = (find(~ttindex'));
        IDX = IDX';confidence = confidence';
        IDX = mod(reshape(IDX(ttindex(:)), size(IDX, 1)/nRotate, size(IDX, 2)), size(IDX, 1)/nRotate);
        IDX(find(~IDX)) = size(IDX, 1);
        confidence = reshape(confidence(ttindex(:)), size(confidence, 1)/nRotate, size(confidence, 2));
        IDX = IDX';confidence = confidence';
% % %         IDX = mod(IDX, size(IDX, 2)/nRotate);
% % %         IDX(find(~IDX)) = size(IDX, 2)/nRotate;
% % %         [IDX1, ord] = cellfun(@(x) unique(x, 'stable'), ...
% % %             mat2cell(IDX, ones(size(IDX, 1), 1), size(IDX, 2)),  'UniformOutput', false);
        
% % % %         confidence = cellfun(@(x, y) x(y), ...
% % % %             mat2cell(confidence, ones(size(IDX, 1), 1), size(IDX, 2)),  ord, 'UniformOutput', false);
% % % %         
% % % %         IDX = cell2mat(IDX1);confidence = cell2mat(confidence);
        end
        if numSign(1)
            [~, ord] = cellfun(@(x) min(x), mat2cell(confidence(:, 1), numSign, 1), 'UniformOutput', true);
            cellnum = [0;cumsum(numSign)];ord = ord+cellnum(1:end-1);
            IDX = IDX(ord,:);confidence = confidence(ord,:);
        end    
        IDX = IDX(:, 1:min(knn_o, size(IDX, 2)));
        confidence = confidence(:, 1:min(knn_o, size(IDX, 2)));
    end
end