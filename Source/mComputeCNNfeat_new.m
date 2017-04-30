function CNN_fea_new = mComputeCNNfeat_new(QulityFeadir, fdatabase,...
    feattype, setting, nstr, nstr1)
mCNN_fea_new =  Computefeat(fdatabase, feattype, ...
    [setting.tr_idx; setting.ts_idx], setting, setting.labelmap, nstr, nstr1,1);
save(QulityFeadir, 'mCNN_fea_new')


