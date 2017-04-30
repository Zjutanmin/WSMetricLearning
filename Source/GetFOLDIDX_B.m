function Batch = GetFOLDIDX_B(ts_fold_idx, cbatchSize, cts_fold_idx)
Batch = cellfun(@(x, y) GetFOLDIDX(ts_fold_idx, x, y), cbatchSize, ...
    cts_fold_idx, 'UniformOutput', false);
Batch = sort(cell2mat(Batch));

function Batch = GetFOLDIDX(ts_fold_idx, batchSize, iidx)
ts_fold_idx = ts_fold_idx(iidx);
[a,b,c] = unique(ts_fold_idx);
[xx, b]  = unique(c);

c1 = hist(c, xx);

idx = randperm(length(c1));

c1 = c1(idx);
xx = xx(idx);

xx = xx([1:find(cumsum(c1) >= batchSize, 1, 'first')]);
Batch = iidx(find(ismember(c, xx)));