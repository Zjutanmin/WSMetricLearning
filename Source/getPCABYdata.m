function setting = getPCABYdata(setting, fdatabase, feattype, idx, suffix)
if nargin < 5
    suffix = '';
end
TFstr = setting.TFstr;
pcastr = suffix;
if isempty(setting.DRstr)
    if setting.PCAenergy ~= -0.9
        pcastr = [pcastr '_E' num2str(setting.PCA)];
    end
else
    if setting.PCAenergy ~= -0.9
        pcastr = [pcastr '_E' setting.DRstr];
    end
end
if setting.LocalPCA
    pcastr = [pcastr, '_L'];
end
if ~isempty(setting.RRatiostr)
    pcastr = [setting.RRatiostr, pcastr];
end 
setting.pcasstr = [setting.strfea, setting.featNormstr, pcastr];
if isempty(setting.mstrfea)
        try
            load([TFstr, '_', setting.strfea, setting.featNormstr, pcastr,'_PCACOEFF.mat'], 'PCACOEFF')
            mPCACOEFF = PCACOEFF;
            
        catch

            cdata_fea = [];
            for jj = 1:length(feattype)
                load([TFstr, '_', setting.feaname{jj}, '_data.mat'], 'data_fea', 'data_label')
                cdata_fea = [cdata_fea, normlized(data_fea, setting.NormFea, ...
                    length(feattype))];clear 'data_fea';
            end
            if setting.Ngroup > 1
                ttid = find(ismember(data_label(idx), setting.labelmap));
                idx = idx(ttid);
                xx1 = sort(unique(data_label(idx))); xx2 = sort(setting.labelmap);
                if length(xx1) ~= length(xx2) || nnz(xx1(:) - xx2(:))
                    fprintf('sort(unique(data_label(idx))) ~= sort(setting.labelmap), data error\n')
                    pause;
                end
            end
            ttmp = data_label(idx);
            fname = [TFstr, '_', setting.strfea, setting.featNormstr, pcastr,'_PCACOEFF'];
            setting1.NormFea = setting.NormFea;setting1.fname = fname;
            setting1.featsize = setting.featsize;setting1.LocalPCA = setting.LocalPCA;
            setting1.NormFea = {setting.NormFea, setting.LDAfeaNORM};
            [PCACOEFF{1}, PCACOEFF{2}] = GetPCAfea(setting1, ...
                [cdata_fea(idx, :), ttmp(:)], (setting.PCA));
            clear 'setting1';
            dos(['del ' fname '*_tmp.mat']); 
            save([fname,'.mat'], 'PCACOEFF')
            mPCACOEFF = PCACOEFF;
        end
    else
        mPCACOEFF = cell(1, length(setting.mstrfea));
        load([TFstr, '_', setting.strfea, '_data.mat'], 'data_fea')
        for jj = 1:length(setting.mstrfea)
            try
                load([TFstr, '_', setting.mstrfea{jj}, setting.featNormstr, pcastr,...
                    '_PCACOEFF.mat'], 'PCACOEFF')
                
                mPCACOEFF{jj} = PCACOEFF;
            catch
                load([TFstr, '_', setting.feaname{jj}, '_data.mat'], 'data_fea')
                
                if setting.Ngroup > 1
                    ttid = find(ismember(data_label(idx), setting.labelmap));
                    idx = idx(ttid);
                    xx1 = sort(unique(data_label(idx))); xx2 = sort(setting.labelmap);
                    if length(xx1) ~= length(xx2) || nnz(xx1(:) - xx2(:))
                        fprintf('sort(unique(data_label(idx))) ~= sort(setting.labelmap), data error\n')
                        pause;
                    end
                end
                ttmp = (data_label(idx));
                [PCACOEFF{1}, PCACOEFF{2}] = GetPCAfea(setting.NormFea, [data_fea(idx, :), ttmp(:)], (setting.PCA));
                save([TFstr, '_', setting.mstrfea{jj}, setting.featNormstr, pcastr,...
                    '_PCACOEFF.mat'], 'PCACOEFF')
                mPCACOEFF{jj} = PCACOEFF;
            end
        end
    end
    setting.PCACOEFF = mPCACOEFF;