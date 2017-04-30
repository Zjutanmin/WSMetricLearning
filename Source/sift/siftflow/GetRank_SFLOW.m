function [IDX, confidence] = GetRank_SFLOW(Samplevoted,setting, B, X, knn)
if ~exist('knn', 'var') || isempty(knn),
    knn = 5;
end
nframe=size(X,1);
nbase=size(B,1);
IDX = ones(nframe, knn);
confidence = zeros(nframe, knn);
for i = 1:nframe,
    if Samplevoted(i) == 0
        continue;
    end
    h = tic;
    d = zeros(1, nbase);
    for j = 1:nbase
        d(j) = flowdistance(X{i}, B{j}, setting);
    end
    
    [dummy, idx] = sort(d, 'ascend');
	IDX(i, :) = idx(1:knn);
    confidence(i, :) = d(IDX(i, :));
    ttime = toc(h);
    fprintf('Get siftflow match %d / %d, time consumpution %d \n', i, nframe, ttime)

end