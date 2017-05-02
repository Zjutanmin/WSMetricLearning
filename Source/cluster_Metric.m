function [KMean, Label, filename] =  cluster_Metric(setting, ts_idx, feattype)
%%Clustering('TSR', '_GTSRB', '43', 'MLR', '2048', '1', '0', '1', '1', '0', '43')

if isfield(setting, 'ts_idx_conf') && ~isempty(setting.ts_idx_conf)
    Range = setting.ts_idx_conf;
else
    Range = [1:length(ts_idx)];
end
Samplevoted = setting.Samplevoted;
Samplevoted = Samplevoted(Range);
if setting.Tclassfy && setting.confidence
    Samplevoted(:) = 1;
end
TFstr = setting.TFstr;       
data_feaA = [];
for jj = 1:length(feattype)
    load([TFstr, '_', setting.feaname{jj}, '_data.mat'], 'data_fea', 'data_label')
    data_feaA = [data_feaA, myNormlize(data_fea, setting.NormFea, ...
        length(feattype))];
end  
data_fea = data_feaA;clear 'data_feaA'
load([TFstr, '_info_data.mat'], 'data_imsize', 'data_imname')
data_label = data_label(:);
data_imname = data_imname(:);
curr_idx = ts_idx; 
curr_ts_label = data_label(curr_idx);        
curr_ts_fea = data_fea(curr_idx,:);
curr_ts_imname = data_imname(curr_idx);
setting.NormFea1 = {[], 1};
setting.FeatConf = setdiff([1:length(feattype)], setting.AidConf);
if setting.PCAenergy   %%%PCA for training data
    curr_ts_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, ...
        setting.LocalPCA, setting.NormFea, setting.NormFea1, ...
        [curr_ts_fea, curr_ts_label], setting.PCACOEFF, setting.FeatConf);    
end
idx = find(Samplevoted);
filename = curr_ts_imname(idx);
Metric = setting.Metric{2};
if ~isempty(Metric)
    [vecs,vals] = eig(0.5 * (Metric + Metric'));
    L = real(abs(vals)).^0.5 * vecs';
    curr_ts_fea = L*curr_ts_fea';
else
    curr_ts_fea = curr_ts_fea';
end
[KMean, Label] = vl_kmeans(curr_ts_fea, setting.K);