function [IDX, confidence] = GetRank_WTA_RAW(Samplevoted, NotRatio, ...
    BitCount, WTAindex, Matric, B, X, knn)

table = BitCount.table;
nframe=size(X,1);
nbase=size(B,1);

dim = size(X,2); index2 = setdiff([1:dim], WTAindex);

X1 = uint8(X(:, WTAindex)); B1 = uint8(B(:, WTAindex));
X2 = (X(:, index2)); B2 = (B(:, index2));

XX = sum(X2.*X2, 2);
BB = sum(B2.*B2, 2);
% D1  = repmat(XX, 1, nbase)-2*X2*B2'+repmat(BB', nframe, 1);
if ~isempty(Matric)
    D1  = Wdistance(X, B, nbase, nframe, Matric);
else
    D1  = repmat(XX, 1, nbase)-2*X*B'+repmat(BB', nframe, 1);
end


D2 = zeros(size(D1));
tid = find(Samplevoted);
for k = 1:length(tid)
    i = tid(k);
    binxor = bitxor(repmat(X1(i,:), [nbase, 1]), B1);
	d = table(binxor+1);
    d = (sum(d, 2));
    d = d';
    D2(i,:) = d;
end

D1 = (D1 - min(D1(:))) / (max(D1(:)) - min(D1(:)));
D2 = (D2 - min(D2(:))) / (max(D2(:)) - min(D2(:)));

D = D1 + D2;

D(find(NotRatio == 0)) = inf;


if knn < 1
    IDX = cell(nframe, 1);
    confidence = 0;
    
    D = D ./ repmat(sqrt(sum(D.^2, 2)), [1, nbase]);
    
    [dummy, idx] = sort(D, 2, 'ascend');
    
    dummy = dummy ./ repmat(sqrt(sum(dummy.^2, 2)), [1, nbase]);
    
    for i = 1:nframe,
        knn1 = length(find(dummy(i,:) < knn));
        IDX{i} = idx(i, 1:knn1);
    end
else
    
    
[dummy, idx] = sort(D, 2, 'ascend');
IDX = idx(:, 1:knn);
index = repmat([1:nframe]', [1, knn]) + (IDX-1) * nframe;
confidence = D(index);

end

% 
% IDX = zeros(nframe, knn);
% confidence = zeros(nframe, knn);
% for i = 1:nframe,
%     d = D(i,:);
% 	[dummy, idx] = sort(d, 'ascend');
% 	IDX(i, :) = idx(1:knn);
%     confidence(i, :) = d(IDX(i, :));
% end
% 
% dis = confidence1 - confidence; max(abs(dis))
% dis = IDX1 - IDX; max(abs(dis))