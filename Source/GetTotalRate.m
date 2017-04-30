function acc = GetTotalRate(fdatabase, cindex, acctp, ts_idx,...
    ts_fold_idx)
ts_label = zeros(length(ts_idx), 1);
i = 1;j = 1;
for jj = 1:length(ts_idx),
    fpath = fdatabase{i}.path{j}{ts_idx(jj)};
    load(fpath, 'label');
    ts_label(jj) = label;
end

clabel = unique(fdatabase{1}.label);
nclass = length(clabel);
acc = zeros(nclass, 1);
for jj = 1 : nclass,
    if ~ismember(jj, cindex)
        continue;
    end
    c = clabel(jj);
    idx = find(ts_label == c);
    tp = acctp(idx);
    tid = find(tp > 0);
    curr_index = ts_fold_idx(idx);
    uindex =  unique(curr_index);
    tpfold = zeros(1, length(uindex));
    for ii = 1:length(uindex)
        idc = find(curr_index == uindex(ii));    
        tmp = ismember(idc, tid);
        if length(unique(tmp)) > 1
            fprintf('Error, Some Snippets have different prediction label\n')
            pause;
        end
        if tmp(1)
            tpfold(ii) = 1;
        end
    end
    acc(jj) = length(find(tpfold==1))/length(uindex);
end
acc = acc(cindex);