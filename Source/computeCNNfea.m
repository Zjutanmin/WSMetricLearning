function computeCNNfea(setting, namestr, fdatabase, feattype, nstr, nstr1)
if nargin < 6
    nstr1 = '';
end
try
    load([setting.QulityFeadir namestr], 'mCNN_fea_new');
catch
    mComputeCNNfeat_new([setting.QulityFeadir namestr], fdatabase, ...
        feattype, setting, nstr, nstr1);
end 
