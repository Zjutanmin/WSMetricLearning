function setting = getdataALL(setting, fdatabase, feattype, idx, range)
if nargin < 5
    range = [1:length(feattype)];
end
TFstr = setting.TFstr;
for jj = range
    [ff1, ff2, ff3] = fileparts([setting.mfea_dir{jj}{1}, '.mat']);
    setting.feaname{jj} = ff2;
    ff2
% % %     if setting.latent
% % %         idd = strfind(ff2, setting.config_latent);
% % %         ff2 = ff2([1:idd(1)-2, idd(1)+1+length(setting.config_latent):end]);
% % %     end
    try
        load([TFstr, '_', ff2, '_data.mat'], 'data_label')
    catch
%         idx1 = idx;
%         idx = idx(randperm(length(idx))); idx = idx(1:1000);
%         tic;
        [data_fea, data_label, tr_imname, tr_size] = ...
            GetFeatureAll(fdatabase, feattype, idx, setting, setting.cindex, jj);
%         toc;
%         tic;
%         [data_fea1, data_label1, tr_imname1, tr_size1] = ...
%             GetFeatureAll_S(fdatabase, feattype, idx, setting, setting.cindex, jj);
%         toc;
        
        tid = [idx];
        vdata_fea = zeros(size(data_fea));vdata_label = zeros(size(data_label));
        vdata_label(tid) = data_label;data_label=vdata_label;
        vdata_fea(tid,:) = data_fea;data_fea=vdata_fea;
        save([TFstr, '_', ff2, '_data.mat'], 'data_fea', 'data_label')
    end
end