function [Trainset, Testset] = getsplit1(b, idx, Nfold, cindex, RRatiostr)


Trainset  = [];
Testset = [];
TNfold = (1/RRatiostr)*Nfold;
for tt = 1:Nfold
    ts_idx_conffold = [];
    for jj = 1:length(cindex)
        nnum = ceil(length(idx{jj}) / TNfold);
        tid = [(tt-1)*nnum+1:min(tt*nnum, length(idx{jj}))];

        ts_idx_conffold = [ts_idx_conffold, idx{jj}(tid)];
    end
    ts_idx_conf = find(ismember(b, ts_idx_conffold) == 1);
    Trainset = [Trainset; ts_idx_conf];
end
for tt = Nfold+1:TNfold
    ts_idx_conffold = [];
    for jj = 1:length(cindex)
        nnum = ceil(length(idx{jj}) / TNfold);
        
        tid = [(tt-1)*nnum+1:min(tt*nnum, length(idx{jj}))];
        
        ts_idx_conffold = [ts_idx_conffold, idx{jj}(tid)];
    end
    ts_idx_conf = find(ismember(b, ts_idx_conffold) == 1);
    Testset = [Testset; ts_idx_conf];
end