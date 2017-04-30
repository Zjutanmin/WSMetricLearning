function CNN_fea = ComputeCNNfeat(QulityFeadir, fdatabase, feattype, setting)

CNN_fea =  Computefeat(fdatabase, feattype, [setting.tr_idx; setting.ts_idx], setting, setting.labelmap);
save(QulityFeadir, 'CNN_fea')



function ctr_fea = Computefeat(fdatabase, feattype, tr_idx, setting, labelmap, ir, jr)
ctr_fea = []; 
if nargin < 6
    ir = [1:length(feattype)];
end
load([setting.QulityFeadir, '_ResProb.mat'], 'prob', 'NameList')
prob = mean(prob, 1);
prob = reshape(prob, [size(prob, 2), size(prob, 3)]);

for i = ir
    bookfeattype = length(fdatabase{i}.path);
    if nargin < 7
        jr = [1:length(bookfeattype)];
    end
    for j = jr
        %ctr_fea_t = []; 
        for jj = 1:length(tr_idx),
            if ~mod(jj, 5),
                fprintf('.');
            end
            if ~mod(jj, 100),
                fprintf(' %d images processed\n', jj);
            end
            fpath = fdatabase{i}.imgpath{tr_idx(jj)};
            [pathstr, name, ext] = fileparts(fpath);
            imname = [name, '.png'];
            idx = strfind(NameList, imname);
            idx = find(~cellfun('isempty', idx));
            if isempty(idx)
                tmp(1) = 0;
                tmp(2) = 0;
                ctr_fea_t(tr_idx(jj),:) = tmp;
                continue;
            end 
            tmp(1) = prob(1, idx);
            tmp(2) = prob(2, idx);
            
            ctr_fea_t(tr_idx(jj),:) = tmp;
        end
        ctr_fea = [ctr_fea,ctr_fea_t];
    end
end
clear 'ctr_fea_t'