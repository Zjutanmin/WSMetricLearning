function setting = splitdataALL_1_T(setting, fdatabase, feattype, idx, range, tt, Nmax, Nmax1)
% load('tinfo2')
% splitdataALL_1_T(setting, fdatabase, feattype, idx, [1:length(feattype)], -1, 5000, 50000);
if nargin < 5
    range = [1:length(feattype)];
end
% Nmax = 50000;

if nargin < 7
    Nmax = 50000;
%     5000;
end
if nargin < 8
    Nmax1 = 50000;
end


reverse = 0;
if Nmax < Nmax1
reverse = 1;
tmp = Nmax1;
Nmax1 = Nmax ;
Nmax = tmp; 
end

ss = [''];
if Nmax ~= 50000
    ss = ['_' num2str(Nmax)];
end


ss1 = [''];
if Nmax1 ~= 50000
    ss1 = ['_' num2str(Nmax1)];
end


N = max(idx);
NRound = ceil(N / Nmax);
setting.featNround = NRound;
if NRound == 1
    setting = getdataALL(setting, fdatabase, feattype, idx, range);
    return;
end
if nargin < 6
    tt = [1:NRound];
end
if length(tt) == 1 && tt == -1
    tt = [1:NRound];
end
trange = tt;


NMul =  Nmax / Nmax1;


if round(NMul) ~= NMul
    fprintf('Cannot split data\n')
    pause
end

% % % % % % iid = find(trange <=  ceil(N / Nmax1));
% % % % % % trange = trange(iid);
NRound1 = ceil(N / Nmax1);

TFstr = setting.TFstr;
for jj = range
    [ff1, ff2, ff3] = fileparts([setting.mfea_dir{jj}{1}, '.mat']);
    setting.feaname{jj} = ff2;
    ff2
    if reverse
        for i = trange
        str = ['_' num2str(i) ss];
        xrange = [(i-1)*NMul + 1 : i*NMul];
        try
            load([TFstr, '_', ff2, str, '_data.mat'], 'data_fea', 'data_label')
            
        catch
            vdata_fea = [];vdata_label = [];
            
            kk = 0;
            for tt = xrange
                if tt > NRound1
                    continue
                end
                str1 = ['_' num2str(tt) ss1];
                kk = kk + 1;
                
                
                
                load([TFstr, '_', ff2, str1, '_data.mat'], 'data_fea', 'data_label')
                tidx = [(kk-1)*Nmax1 + 1: (kk-1)*Nmax1 + size(data_fea, 1)];
                [tidx(1), tidx(end)]
                {str, str1}
                vdata_fea(tidx,:) = data_fea;
                vdata_label(tidx,:) = data_label;
            end
            
            data_fea = vdata_fea;
            data_label = vdata_label;
            save([TFstr, '_', ff2, str, '_data.mat'], 'data_fea', 'data_label')
            
        end
        end
        
        
    else
        for i = trange
        str = ['_' num2str(i) ss];
        xrange = [(i-1)*NMul + 1 : i*NMul];
        try
            load([TFstr, '_', ff2, str, '_data.mat'], 'data_fea', 'data_label')
            vdata_fea = data_fea;
            vdata_label = data_label;
            kk = 0;
            len = size(vdata_fea, 1);
            for tt = xrange
                if tt > NRound1
                    continue
                end
                str1 = ['_' num2str(tt) ss1];
                kk = kk + 1;
                tidx = [(kk-1)*Nmax1 + 1: min(kk*Nmax1, len)];
                [tidx(1), tidx(end)]
                {str, str1}
                
                data_fea = vdata_fea(tidx,:);
                data_label = vdata_label(tidx,:);
                save([TFstr, '_', ff2, str1, '_data.mat'], 'data_fea', 'data_label')
            end
        end
        end
    end
end