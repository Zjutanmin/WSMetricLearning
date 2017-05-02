function [Samplevoted, thresh] = SelectBeeterSample(ts_fold_idx,  ...
    setting, Samplevoted, Cscore, ylabel, label, ts_label)
thresh = 0;
if SnippetRatio{1} ~= 1
    idx = find(Samplevoted);
    ylabel = label == ts_label(idx);
    [a,b,c] = unique(ts_fold_idx(idx));
    tidx = find(ylabel);
    for tt= 1:length(a)
        idxx = find(c == tt);
        [CS, ordx] = sort(Cscore(idxx), 'descend');
        if SnippetRatio{1}
            idxx = idxx(ordx(1:NNum(tt)));
        end
        SelectIdx = [SelectIdx; idxx];
        if SnippetRatio{2}
            SelectIdx  = intersect(SelectIdx, tidx);
        end
    end
end