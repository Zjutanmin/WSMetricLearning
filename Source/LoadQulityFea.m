function ctr_fea = LoadQulityFea(QulityFeadir, ts_idx, method)
ctr_fea = [];
if ~isempty(strfind(method, 'feaInter'))
    load([QulityFeadir, '-ALL_fea.mat']);
    ctr_fea = [ctr_fea, ctr_fea(ts_idx,:)];
end
if ~isempty(strfind(method, 'EdgeInter'))
    load([QulityFeadir, '-edge_fea.mat']);
    ctr_fea = [ctr_fea, edge_fea(ts_idx,:)];
end
if ~isempty(strfind(method, 'CNNInter'))
    load([QulityFeadir, '-CNN_fea.mat']);
    ctr_fea = [ctr_fea, CNN_fea(ts_idx,:)];
end
if ~isempty(strfind(method, 'CNNmInter'))
    load([QulityFeadir, '-mCNN_fea.mat']);
    ctr_fea = [ctr_fea, mCNN_fea(ts_idx,:)];
end
if ~isempty(strfind(method, 'CNNm_newInter'))
    load([QulityFeadir, '-mCNN_fea_new.mat']);
    ctr_fea = [ctr_fea, mCNN_fea_new(ts_idx,:)];
end
if ~isempty(strfind(method, 'CNNm_new2Inter'))
    load([QulityFeadir, '-mCNN_fea_new2.mat']);
    ctr_fea = [ctr_fea, mCNN_fea_new(ts_idx,:)];
end
if ~isempty(strfind(method, 'CNNm_new3Inter'))
    load([QulityFeadir, '-mCNN_fea_new3.mat']);
    ctr_fea = [ctr_fea, mCNN_fea_new(ts_idx,:)];
end

if ~isempty(strfind(method, 'CNNm_train1Inter'))
    load([QulityFeadir, '-mCNN_fea_train1.mat']);
    ctr_fea = [ctr_fea, mCNN_fea_new(ts_idx,:)];
end
if ~isempty(strfind(method, 'CNNm_train2Inter'))
    load([QulityFeadir, '-mCNN_fea_train2.mat']);
    ctr_fea = [ctr_fea, mCNN_fea_new(ts_idx,:)];
end
if ~isempty(strfind(method, 'CNNm_train3Inter'))
    load([QulityFeadir, '-mCNN_fea_train3.mat']);
    ctr_fea = [ctr_fea, mCNN_fea_new(ts_idx,:)];
end
if ~isempty(strfind(method, 'CNNm_train4Inter'))
    load([QulityFeadir, '-mCNN_fea_train4.mat']);
    ctr_fea = [ctr_fea, mCNN_fea_new(ts_idx,:)];
end
if ~isempty(strfind(method, 'CNNm_train5Inter'))
    load([QulityFeadir, '-mCNN_fea_train5.mat']);
    ctr_fea = [ctr_fea, mCNN_fea_new(ts_idx,:)];
end
if ~isempty(strfind(method, 'CNNm_train6Inter'))
    load([QulityFeadir, '-mCNN_fea_train6.mat']);
    ctr_fea = [ctr_fea, mCNN_fea_new(ts_idx,:)];
end

