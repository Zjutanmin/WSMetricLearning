function ctr_fea = Computefeat(fdatabase, feattype, tr_idx, setting,...
    labelmap, nstr, nstr1, outall, ir, jr)
ctr_fea = []; 
if nargin < 8
    outall = 0;
end

if nargin < 9
    ir = [1:length(feattype)];
end
load([setting.QulityFeadir, '_' nstr1, 'ResProb_', nstr, '.mat'], 'prob', 'NameList')
number = size(prob,1);
for i = ir
    bookfeattype = length(fdatabase{i}.path);
    if nargin < 10
        jr = [1:length(bookfeattype)];
    end
    for j = jr
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
                tmp1 = zeros(1,number);
                tmp2 = zeros(1,number);
                ctr_fea_t(tr_idx(jj),:) = [tmp1,tmp2];
                continue;
            end 
            tmp1 = prob(:, 1, idx);
            tmp2 = prob(:, 2, idx);
            tmp = [tmp1(:); tmp2(:)];
            ctr_fea_t(tr_idx(jj),:) = tmp';
        end
        ctr_fea = [ctr_fea,ctr_fea_t];
    end
end
clear 'ctr_fea_t'
if ~outall
    ctr_fea = ctr_fea(tr_idx,:);
end