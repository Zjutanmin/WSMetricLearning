function ctr_fea = ComputeAllfeat(QulityFeadir, fdatabase, feattype, setting)

ctr_fea = GetFeatureAll(fdatabase, feattype, [setting.tr_idx; setting.ts_idx], setting, setting.labelmap);
save(QulityFeadir, 'ctr_fea')