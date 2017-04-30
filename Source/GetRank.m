function [IDX, confidence] = GetRank(Samplevoted, NotRatio, Matric, innerfea, B, X, knn)

if ~exist('knn', 'var') || isempty(knn),
    knn = 5;
end

nframe=size(X,1);
nbase=size(B,1);

% find k nearest neighbors


if ~isempty(Matric)
    D  = Wdistance(X, B, nbase, nframe, Matric, innerfea);
else
    if innerfea
        D  = -X*B';
    else
        XX = sum(X.*X, 2);
        BB = sum(B.*B, 2);
        D  = repmat(XX, 1, nbase)-2*X*B'+repmat(BB', nframe, 1);
    end
end


if knn < 1
    IDX = cell(nframe, 1);
    confidence = 0;
    tid = find(Samplevoted);
    for k = 1:length(tid)
        i = tid(k);
    
        d = D(i,:);
    
        d = d ./ norm(d);
    
    
        d(find(NotRatio(i,:) == 0)) = inf;
        [dummy, idx] = sort(d, 'ascend');

        knn1 = length(find(dummy < knn));
        IDX{i} = idx(1:knn1);
    end
else
    IDX = ones(nframe, knn);
    confidence = zeros(nframe, knn);
    tid = find(Samplevoted);

    for k = 1:length(tid)
    if ~mod(k,1000)
        fprintf('Getrank %d/%d\n', k, length(tid))
    end
    i = tid(k);
    d = D(i,:);
    d(find(NotRatio(i,:) == 0)) = inf;
    [dummy, idx] = sort(d, 'ascend');
	IDX(i, :) = idx(1:knn);
    confidence(i, :) = d(IDX(i, :));
    end
end