function [ctr_fea, tr_label, tr_imname, tr_size] = GetFeatureAll(fdatabase, feattype, tr_idx, setting, labelmap, ir, jr)  
ctr_fea = []; tr_label = [];
if nargin < 6
    ir = [1:length(feattype)];
end
if length(ir) == 1 &&  length(fdatabase{1}.path)== 1 && ~setting.latent
    [ctr_fea, tr_label, tr_imname, tr_size] = GetFeatureAll_S(fdatabase, ...
        feattype, tr_idx, setting, labelmap, ir, 1);
    return;
end

for i = ir
    tr_imname = {};tr_size = [];
    bookfeattype = length(fdatabase{i}.path);
    if nargin < 7
        jr = [1:(bookfeattype)];
    end
    for j = jr
        ctr_fea_t = []; tr_label = [];
        for jj = 1:length(tr_idx),
            if ~mod(jj, 5),
                fprintf('.');
            end
            if ~mod(jj, 100),
                fprintf(' %d images processed\n', jj);
            end
            fpath = fdatabase{i}.path{j}{tr_idx(jj)};
            load(fpath, 'fea', 'label');
%             if ~ismember(labelmap(label), setting.Consider)
%                 continue;
%             end
            if ~setting.latent
                tmp = fea(:);
                ctr_fea_t = [ctr_fea_t; setting.normweigh(i)*tmp'];
                tr_label = [tr_label; labelmap(label)];
                fim = fdatabase{i}.imgpath{tr_idx(jj)};
                tr_imname = [tr_imname; fim];
                tr_size = [tr_size; graysize(imread(fim))];
            else
                
                
            for tt = 1:length(setting.rotate)   %%%if no rotate then for one
                tmp = fea{1}{tt}(:);
                if setting.latent == 2
                    tmp = fea{2}{tt}(:);
                end
% %                 try
                ctr_fea_t = [ctr_fea_t; setting.normweigh(i)*tmp'];
% %                 catch
% %                     t = 1;
% %                 end
                tr_label = [tr_label; setting.labelmap(label)];
                
                fim = fdatabase{i}.imgpath{tr_idx(jj)};
                tr_imname = [tr_imname; fim];
                tr_size = [tr_size; graysize(imread(fim))];
            end
            end
        end
        ctr_fea = [ctr_fea,ctr_fea_t];
    end
end
clear 'ctr_fea_t'