% load('tt1')
% Batch = GetFOLDIDX_B1(ts_fold_idx, batchSize, SampleC, Ypos)
function Batch = GetFOLDIDX_B1(ts_fold_idx, batchSize, SampleC, Ypos)
if nargin < 3
    SampleC = 0;
    Ypos = [];    
end
[a,b,c] = unique(ts_fold_idx);
xx  = unique(c);
c1 = hist(c, xx);
idx = randperm(length(c1));

c1 = c1(idx);
xx = xx(idx);

xx = xx([1:find(cumsum(c1) >= batchSize, 1, 'first')]);
Batch = find(ismember(c, xx));