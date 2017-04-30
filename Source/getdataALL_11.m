function setting = getdataALL_11(setting, fdatabase, feattype, idx, range)
if nargin < 5
    range = [1:length(feattype)];
end
N = max(idx);

if setting.NSplit
    Nmax = 40;
else
    Nmax = N;
end

setting.NSplit = 0;


NRound = ceil(N / Nmax);
setting.featNround = NRound;
if NRound == 1
    setting = getdataALL(setting, fdatabase, feattype, idx, range);
    return;
end


TFstr = setting.TFstr;
for jj = range
    [ff1, ff2, ff3] = fileparts([setting.mfea_dir{jj}{1}, '.mat']);
    setting.feaname{jj} = ff2;
    ff2
    for i = 1:NRound
        try
        
            str = ['_' num2str(i)];
            load([TFstr, '_', ff2, str, '_data.mat'], 'data_label')
        
        catch

            str = ['_' num2str(i)];
            
            idx = [(i-1)*Nmax+1:min(i*Nmax, N)];
            
            [data_fea, data_label, tr_imname, tr_size] = ...
                GetFeatureAll(fdatabase, feattype, idx, setting, setting.cindex, jj);
            tid = [idx];
            
            vdata_fea = zeros(size(data_fea));vdata_label = zeros(size(data_label));
            vdata_label(tid) = data_label;data_label=vdata_label;
            vdata_fea(tid,:) = data_fea;data_fea=vdata_fea;
            save([TFstr, '_', ff2, str, '_data.mat'], 'data_fea', 'data_label')
        end
    end
end