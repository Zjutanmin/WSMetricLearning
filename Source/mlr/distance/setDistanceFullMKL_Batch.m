function D1 = setDistanceFullMKL_Batch(Xtemplate, Xtest, ntrain, W, mem_block)
ntest = size(Xtest, 2);
Round = ceil(ntest / mem_block);
tsize = repmat(mem_block, [1, Round]);
tsize(end) = min(tsize(end), ntest - (Round - 1) * mem_block);
rangebase = [0, cumsum(tsize)];
Drange = rangebase(1:end-1);

D1 = zeros(ntrain+ntest, ntrain+ntest);
for R = 1:Round
    Xtest1 = Xtest(:, Drange(R)+1:Drange(R)+tsize(R));
    Rrange = ntrain+Drange(R)+ [1:tsize(R)];
    D1([1:ntrain,Rrange], [1:ntrain,Rrange]) = setDistanceFullMKL([Xtemplate Xtest1], W, ...
        ntrain + (1:size(Xtest1, 2)), 1:ntrain);
end