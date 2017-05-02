function [ctr_fea_t, tr_label, tr_imname, tr_size] = GetFeatureAll_S(fdatabase, feattype, tr_idx, setting, labelmap, ir, jr)  
i = ir;
tr_imname = {};tr_size = [];
bookfeattype = length(fdatabase{i}.path);
if nargin < 7
    jr = [1:(bookfeattype)];
end
j = jr;
ctr_fea_t = []; tr_label = [];
for jj = 1:length(tr_idx),
    if ~mod(jj, 10),
        fprintf('.');
    end
    if ~mod(jj, 500),
        fprintf(' %d images processed\n', jj);
    end
    fpath = fdatabase{i}.path{j}{tr_idx(jj)};
    load(fpath, 'fea', 'label');
    ctr_fea_t = [ctr_fea_t; (fea(:))'];
    try
    tr_label = [tr_label; labelmap(label)];
    catch
        t = 1;
        pause
    end
    fim = fdatabase{i}.imgpath{tr_idx(jj)};
    tr_imname = [tr_imname; fim];
    tr_size = [tr_size; graysize(imread(fim))];
end
ctr_fea_t = setting.normweigh(i)*ctr_fea_t;