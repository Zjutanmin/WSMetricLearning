function B = getcodebook(database, dataname, setting, codebook)
Bpath = ['dictionary/' dataname '_' codebook];
Bpath = [Bpath '.mat'];
try
    load(Bpath);
catch
    [B, tr_fea] = Getbook(database, dataname, setting.ncluster, ...
        setting.codesampleR, setting.sampling);
    save(Bpath, 'B');
end

function [B, tr_fea] = Getbook(fdatabase, dataname, ncluster, codesampleR, sampling)
tr_idx = [];
ts_idx = [];
clabel = unique(fdatabase.label);
nclass = length(clabel);
for jj = 1:nclass,
    idx_label = find(fdatabase.label == clabel(jj));
    num = length(idx_label);
    if strcmp(dataname, 'Caltech101')
        idx_rand = randperm(num);
        tr_idx = [tr_idx; idx_label(idx_rand(1:tr_num))];
        ts_idx = [ts_idx; idx_label(idx_rand(tr_num+1:end))];
    else
        tindex = find(fdatabase.istrain(idx_label) == 1);
        tindex1 = setdiff([1:length(idx_label)], tindex);
        tr_idx = [tr_idx; idx_label(tindex)];
        ts_idx = [ts_idx; idx_label(tindex1)]; 
    end
end
fprintf('Training number: %d\n', length(tr_idx));
fprintf('Testing number:%d\n', length(ts_idx));

% load the training features 

tr_fea = [];
for jj = 1:length(tr_idx),
    fpath = fdatabase.path{tr_idx(jj)};
    if sampling == -1 && ~fdatabase.isForBook(tr_idx(jj))
        continue;
    end
    load(fpath, 'feaSet');

    fea = feaSet.feaArr;
    tr_fea = [tr_fea, fea];
end



if codesampleR ~= 0
    ts_idx = [];
    for jj = 1:nclass,
        idx_label = find(fdatabase.label == clabel(jj));
        if ~strcmp(dataname, 'Caltech101')
            tindex1 = find(fdatabase.istrain(idx_label) ~= 1);
            idx_label = idx_label(tindex1);
        end
        if length(idx_label) == 0
            continue;
        end
        
        num = length(idx_label);
        idx_rand = randperm(num);
        ts_idx = [ts_idx; idx_label(idx_rand(1:num))];
        
    end
    for tt = 1:length(ts_idx),
        fpath = fdatabase.path{ts_idx(tt)};
        load(fpath, 'feaSet');
        fea = feaSet.feaArr;
        tr_fea = [tr_fea, fea];
    end
end
if ~ismember(sampling, [-1, 0])
    sampling = min(sampling, size(tr_fea, 2));
    ids = randperm(size(tr_fea, 2));
    tr_fea = tr_fea(:, ids(1:sampling));
end
[idx,B] = kmeans(tr_fea', ncluster, 'emptyaction','drop');
B = B';