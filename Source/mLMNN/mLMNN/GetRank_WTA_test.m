function [IDX, confidence] = GetRank_WTA_test(BitCount, K, isWTA, B, X, knn)

if ~exist('knn', 'var') || isempty(knn),
    knn = 5;
end

if ~isWTA
    [IDX, confidence] = GetRank(B, X, knn);
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

table = BitCount.table;

tic;
[IDX1, confidence1] = GetRank(B, X, knn);
toc;

tic;
nframe=size(X,1);
nbase=size(B,1);


% % find k nearest neighbors
% XX = sum(X.*X, 2);
% BB = sum(B.*B, 2);
% D  = repmat(XX, 1, nbase)-2*X*B'+repmat(BB', nframe, 1);
% d = D(1,:);
X = uint8(X); B = uint8(B);


IDX = zeros(nframe, knn);
confidence = zeros(nframe, knn);
for i = 1:nframe,
    if ~mod(i, 5),
       fprintf('.');
    end
    if ~mod(i, 100),
        fprintf(' %d Compute distacne\n', i);
    end

    tic
    fprintf(' %d Compute xor\n', i)
    binxor = bitxor(repmat(X(i,:), [nbase, 1]), B);
    toc
    
    
    tic
    d1 = zeros(nbase, 1);
    fprintf(' %d Get bit\n', i)
    for jj = 1:Kbit
        bit = bitget(binxor, jj);
        d1 = d1 + sum(bit, 2); 
    end
    d1 = d1';d1 = uint8(d1);
    toc
    
    
    tic
    d = table(binxor+1);d = uint8(sum(d, 2));d = d';
    toc
    
    dis = nnz(d1 - d);
    if dis > 0
        fprintf(' %d Error in computing d\n', i)
        pause;
    end
    
    tic
    fprintf(' %d sorting\n', i)
	[dummy, idx] = sort(d, 'ascend');
	IDX(i, :) = idx(1:knn);
    confidence(i, :) = d(IDX(i, :));
    toc
end
toc;
t  = 1;
