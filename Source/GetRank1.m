function [IDX, confidence] = GetRank1(Samplevoted, NotRatio, Matric, B, X, knn)

if ~exist('knn', 'var') || isempty(knn),
    knn = 5;
end

nframe=size(X,1);
nbase=size(B,1);

% find k nearest neighbors
XX = sum(X.*X, 2);
BB = sum(B.*B, 2);

if ~isempty(Matric)
    D  = Wdistance(X, B, nbase, nframe, Matric);
else
    D  = repmat(XX, 1, nbase)-2*X*B'+repmat(BB', nframe, 1);
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
% for i = 1:nframe,
%     if Samplevoted(i) == 0
%         continue;
%     end
   
NotRatio = NotRatio(1:nframe, :);
Samplevoted = Samplevoted(1:nframe);
NotRatio = rand(size(NotRatio)) > 0.5;
Samplevoted = rand(size(Samplevoted)) > 0.5;
confidence2 = confidence;

tid = find(Samplevoted);
tic;
for k = 1:length(tid)
    i = tid(k);
    d = D(i,:);
    d(find(NotRatio(i,:) == 0)) = inf;
	[dummy, idx] = sort(d, 'ascend');
	IDX(i, :) = idx(1:knn);
    confidence(i, :) = d(IDX(i, :));
end
toc;
IDX2 = IDX;confidence1 = confidence;


tic;
D1 = D(tid, :);
D1(find(NotRatio(tid,:) == 0)) = inf;
[dummy, ord] = sort(D1, 2);
IDX(tid, :) = ord;
Bidx = repmat([1:length(tid)],nbase, 1);
ord = ord';
ord = sub2ind(size(D1), Bidx(:), ord(:));
D1 = reshape(D1(ord), nbase, length(tid));
confidence2(tid, :) = D1';
toc;

dis = confidence1 - confidence2; max(abs(dis(:)))
dis = IDX2- IDX; max(abs(dis(:)))

end
