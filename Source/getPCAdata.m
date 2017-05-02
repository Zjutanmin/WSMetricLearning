function setting = getPCAdata(setting, suffix)
if nargin < 5
    suffix = '';
end
TFstr = setting.TFstr;
pcastr = suffix;
if setting.PCA ~= -0.9
    pcastr = [pcastr '_E' num2str(setting.PCA)];
end
setting.pcastr = pcastr;
try
    load([TFstr, '_', setting.strfea, pcastr, '_data_PCA.mat'],'data_fea',...
        'data_label', 'data_imname', 'data_imsize');
catch
    setting.PCACOEFF = mPCACOEFF;
    load([TFstr, '_', setting.strfea, '_data.mat'], 'data_fea')
    [PCACOEFF{1}, PCACOEFF{2}, data_fea, setting.rdim] =...
        GetPCAfea(data_fea, setting.PCA, [], setting.PCACOEFF);         
    save([TFstr, '_', setting.strfea, pcastr, '_data_PCA.mat'],'data_fea',...
        'data_label', 'data_imname', 'data_imsize');
end