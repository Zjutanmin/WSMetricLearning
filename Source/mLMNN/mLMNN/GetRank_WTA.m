function [IDX, confidence] = GetRank_WTA(Samplevoted, NotRatio, BitCount, ...
    K, isWTA, WTAwithraw, Metric, WTAindex, B, X, knn, latentKNN)

if ~exist('knn', 'var') || isempty(knn),
    knn = 5;
end
if ~exist('latentKNN', 'var') || isempty(latentKNN),
    latentKNN = 1;
end

if nargin == 12 && latentKNN ~= 1
    if iscell(Metric)
        if length(Metric) ~= 3
            fprintf('length of refined metric should be 2\n')
        else
            Metric1 = Metric{1};
            Metric2 = Metric{2};
            latentKNN = Metric{3};
        end
    else
        Metric1 = [];
        Metric2 = Metric;
    end
    
    if latentKNN~=size(B,1) %%
        IDX = GetRank_WTA(Samplevoted, NotRatio, BitCount, ...
            K, isWTA, WTAwithraw, Metric1, WTAindex, B, X, latentKNN);
        RNotRatio = NotRatio;
        NotRatio(:) = 0;
        if iscell(IDX)
            for jj = 1:length(IDX)
                isub = intersect(IDX{jj}, find(RNotRatio(jj,:)));
                NotRatio(jj, isub) = 1;
            end
        else
            rind = repmat([1:size(IDX, 1)]', [1, latentKNN]);
            isub = intersect(sub2ind(size(NotRatio), rind(:), IDX(:)), find(RNotRatio));
            NotRatio(isub) = 1;
        end
    end
    
    [IDX, confidence] = GetRank_WTA(Samplevoted, NotRatio, BitCount, ...
        K, isWTA, WTAwithraw, Metric2, WTAindex, B, X, knn);
    return;
end


if ~isWTA
    [IDX, confidence] = GetRank(Samplevoted, NotRatio, Metric, B, X, knn);
    return;
end

Kbit = ceil(log(K) / log(2));
if Kbit > BitCount.N
    maxk = Kbit;
    name = ['BitCount_' num2str(maxk)];
    try
        load(['WTA\' name '.mat'], BitCount);
    catch
        if ~exist('WTA\')
            mkdir('WTA\')
        end
        BitCount = CreateNum1table(maxk);
        save(['WTA\' name '.mat'], 'BitCount');
    end
end

if WTAwithraw
    [IDX, confidence] = GetRank_WTA_RAW(Samplevoted, NotRatio,BitCount, WTAindex,Metric, B, X, knn);
    return;
end

table = BitCount.table;
nframe=size(X,1);
nbase=size(B,1);

if knn < 1
    IDX = cell(nframe, 1);
    X = uint8(X); B = uint8(B);

    tid = find(Samplevoted);
    for k = 1:length(tid)
    i = tid(k);
    
    binxor = bitxor(repmat(X(i,:), [nbase, 1]), B);
	d = table(binxor+1);
    d = (sum(d, 2));d = d';
    
    d = d ./ norm(d);
    
    d(find(NotRatio(i,:) == 0)) = inf;
    
    [dummy, idx] = sort(d, 'ascend');
    
    knn1 = length(find(dummy < knn));
    IDX{i} = idx(1:knn1);
    end
else
    IDX = ones(nframe, knn);
    confidence = zeros(nframe, knn);
    X = uint8(X); B = uint8(B);

    tid = find(Samplevoted);
    for k = 1:length(tid)
    i = tid(k);
    
    binxor = bitxor(repmat(X(i,:), [nbase, 1]), B);

	d = table(binxor+1);
    d = (sum(d, 2));d = d';
    d(find(NotRatio(i,:) == 0)) = inf;
    
    [dummy, idx] = sort(d, 'ascend');
	IDX(i, :) = idx(1:knn);
    confidence(i, :) = d(IDX(i, :));
    end
end

