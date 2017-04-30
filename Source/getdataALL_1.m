function setting = getdataALL_1(setting, fdatabase, feattype, idx, range)
% load('tinfo2')
% getdataALL_1_T(setting, fdatabase, feattype, idx, [1:length(feattype)], 1);
if nargin < 5
    range = [1:length(feattype)];
end
if nargin < 7
    Nmax = 50000;
end

ss = [''];
if Nmax ~= 50000
    ss = ['_' num2str(Nmax)];
end

N = max(idx);
NRound = ceil(N / Nmax);
if ~setting.NSplit
    NRound = 1;
end
setting.featNround = NRound;
if NRound == 1
    setting = getdataALL(setting, fdatabase, feattype, idx, range);
    return;
end
if nargin < 6
    tt = [1:NRound];
end
trange = tt;

index = find(trange <= NRound);
trange = trange(index);

TFstr = setting.TFstr;
for jj = range
    [ff1, ff2, ff3] = fileparts([setting.mfea_dir{jj}{1}, '.mat']);
    setting.feaname{jj} = ff2;
    ff2
    for i = trange
        str = ['_' num2str(i) ss];
        str1 = ['_' num2str(i)];
        try
            load([TFstr, '_', ff2, str1, '_data.mat'], 'data_label')
%             load([TFstr, '_', ff2, str1, '_data.mat'], 'data_fea', 'data_label')
%             save([TFstr, '_', ff2, str, '_data.mat'], 'data_fea', 'data_label')
        catch
            idx = [(i-1)*Nmax+1:min(i*Nmax, N)];
            
            [data_fea, data_label, tr_imname, tr_size] = ...
                GetFeatureAll(fdatabase, feattype, idx, setting, setting.cindex, jj);
            tid = [idx - (idx(1)-1)];
            vdata_fea = zeros(size(data_fea));vdata_label = zeros(size(data_label));
            vdata_label(tid) = data_label;data_label=vdata_label;
            vdata_fea(tid,:) = data_fea;data_fea=vdata_fea;
            save([TFstr, '_', ff2, str, '_data.mat'], 'data_fea', 'data_label')
        end
    end
end