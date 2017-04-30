% =========================================================================
% An example code for the algorithm proposed in
%
%   Jinjun Wang, Jianchao Yang, Kai Yu, Fengjun Lv, Thomas Huang, and
%   Yihong Gong.
%   "Locality-constrained Linear Coding for Image Classification", CVPR
%   2010.
%getImFFold('D:\MinTan\project\Signdetect\SignClassify\image\Sign_NewT')
%
% Written by Jianchao Yang @ IFP UIUC
% May, 2010.
% =========================================================================
function C = Testonly(dataname, suffix, config_file, ...
    bookfeat, cmethod, knnpara, cpara, copyremove, issave, rawsize,sampling, ...
    pyramid, ncluster, normmerge, multiview, Rconfidence, config_DOG, ...
    config_WTA, WTAwithraw, Fpyramid, Ratio, RRatio, fast, config_latent, ...
    platent, confidence, svote, Crange, UseSplit, PCA, testSOutput,patchsize)
%%%prepocess = 0; non
%%%DOG = div(prepocess); WTA = mod(prepocess); .
addpath(genpath('Tool'));

if nargin < 1 dataname = 'Caltech101'; end
if nargin < 2 suffix = ''; end
if nargin < 3 config_file = 'llc_1'; end
if nargin < 4 bookfeat = {'sift'};  end
if nargin < 5
    cmethod = 'KNN'; 
    knnpara = 10;
end
if nargin < 7  cpara = []; end
if nargin < 8 copyremove = 1;   end
if nargin < 9 issave = 0;     end
if nargin < 10  rawsize = [90, 75];   end
if nargin < 32
    changesize = 0;
    patchsize = 16;     
else
    changesize = 1;
end
setting = getconfig(config_file, bookfeat);
if nargin >= 11 setting.sampling = sampling; end
if nargin >= 12 setting.pyramid = pyramid; end
if nargin >= 13 setting.ncluster = ncluster; end
if nargin < 14 normmerge = 0; end
if nargin < 15 multiview = 0;end
if nargin < 16  Rconfidence = 0.5;end
setting.Rconfidence = Rconfidence;
if nargin < 17   %%%for DOG
    setting.DoG = 0;
    config_DOG = '';
end

if nargin < 18    %%%for WTA
    setting.WTA = 0;
    config_WTA = '';
end

setting.config_DOG = config_DOG;
setting.multiview =multiview;
pwd = cd;
fn = [pwd '\setting\',config_DOG,'.m'];
if exist(fn)  %%%modify feature type
    cwd = pwd;cd([pwd '\setting\']);
    eval(config_DOG);cd(cwd);
    setting.DoG = 1;
end
setting.config_WTA = config_WTA;

pwd = cd;
fn = [pwd '\setting\',config_WTA,'.m'];
if exist(fn)  %%%modify feature type
    cwd = pwd;cd([pwd '\setting\']);
    eval(config_WTA);cd(cwd);
    setting.WTA = 1;
    if nargin < 18    %%%for WTA
        setting.WTAwithraw = 0;
    else
        setting.WTAwithraw = WTAwithraw;
    end
else
    setting.WTA = 0; setting.WTAwithraw = 0;
end
if nargin < 20    %%%for WTA
    setting.Fpyramid = 0;
else
    setting.Fpyramid = Fpyramid;
end   
if nargin < 21    %%%for WTA
    setting.Ratio = 0;
else
    setting.Ratio = Ratio;
    if nargin < 22    %%%for WTA
        setting.RRatio = 0.5;
    else
        setting.RRatio = RRatio;
    end
end
if strcmp(setting.feattype{1}, 'siftflow')
    if nargin < 23    %%%for WTA
        setting.fast = 1;
    else
        setting.fast = fast;
    end
else
    setting.fast = 1;
end
  
if nargin < 24   %%%for WTA
    setting.latent = 0;
    config_latent = '';
end


pwd = cd;
fn = [pwd '\setting\',config_latent,'.m'];
if exist(fn)  %%%modify feature type
    cwd = pwd; cd([pwd '\setting\']);
    eval(config_latent); cd(cwd);
    setting.latent = 1; setting.config_latent = config_latent;   
    if nargin < 25    %%%for WTA
        setting.platent = 0;
    else
        setting.platent = platent;
    end
    setting.platent = platent;
else
    setting.latent = 0;
    setting.platent = 0;
end

if nargin < 26    %%%for WTA
    setting.confidence = 0;
else
    setting.confidence = confidence;  
end

if nargin < 27   %%%for WTA
    setting.svote = {};
else
    setting.svote = svote;  
end
if nargin < 28   %%%for WTA
    setting.Crange= [-5,3];
else
    setting.Crange = Crange;  
end

if nargin < 29  %%%for WTA
    UseSplit = 0;
    Nfold = 5;
else
    Nfold = UseSplit;
    setting.RoundSplit = 0;
    if Nfold < 0
        setting.RoundSplit = 1;
        Nfold = -Nfold;
    end
end
if nargin < 30  %%%for WTA
    setting.PCA = 0;
else
    setting.PCA = PCA;
end

if nargin < 31  %%%for WTA
    setting.testSOutput = 0;
else
    setting.testSOutput = testSOutput;
end

if ~setting.WTA && isfield(setting, 'WTAwithraw') && setting.WTAwithraw
    fprintf('Error configuration: no WTA coding, but WTAwithraw is valid\n');
    pause;
end
if changesize
    setting.swin = ones(size(setting.swin)) * patchsize;
    idx = find(setting.overlap == 1);
    setting.stride = setting.swin;
    setting.stride(idx) = setting.swin(idx) / 2;
end

setting.rawsize = rawsize;
dataname1 = dataname;
addpath('Liblinear/matlab');        % we use Liblinear package, you need 
addpath('Libsvm/matlab');        % we use Liblinear package, you need 
addpath(genpath('mlr/'));


if ~strcmp(dataname, 'Caltech101')
    dataname = [dataname suffix];       % directory for the image database     
end

img_dir1 = ['image/' dataname1];       % directory for the image database  
feattype = setting.feattype;
img_dir = ['image/' dataname];       % directory for the image database   
data_dir = ['data/' dataname];  
fea_dir = ['features/' dataname];     % directory for saving final image features

if setting.Ratio
    setting.ratio_dir = ['Ratio/' dataname];
end
setting.testonly = 1;

getImFFold(img_dir);

% setting.Mplatent = floor(setting.platent / 10);
setting.Tplatent = mod(setting.platent , 10);
if floor(setting.platent / 10)  %%%>10
    setting.Mplatent = 0;
else
    setting.Mplatent = setting.Tplatent;
end

setting.cmethod = cmethod;
[mfea_dir, feastr, codestr, bookstr, Mfeastr, setting, N, mfea_dir_WTA] = ...
    getfeastr(fea_dir, setting);

if UseSplit
    Mfeastr = [Mfeastr, '_S', num2str(UseSplit)];
end

if setting.PCA
    Mfeastr = [Mfeastr, '_PCA', num2str(setting.PCA)];
    
    setting.Mfeastr1 = [setting.Mfeastr1, '_PCA', num2str(setting.PCA)];
    setting.Modelfeastr = [setting.Modelfeastr, '_PCA', num2str(setting.PCA)];
end

if setting.testSOutput
    Mfeastr = [Mfeastr, '_SO'];
    setting.Mfeastr1 = [setting.Mfeastr1, '_SO'];
%     setting.Modelfeastr = [setting.Modelfeastr, '_PCA', num2str(setting.PCA)];
end

imRes_dir = ['imresult/' dataname '/'];
Res_dir = ['result/' dataname '/'];
nameresult = [Res_dir Mfeastr '_' cmethod getparastr(knnpara)];

setting.Tplatent = mod(setting.platent, 10);

nameimresult = [imRes_dir Mfeastr '_' cmethod getparastr(knnpara)];
setting.confidenceF = ['Confidence/' dataname '/' setting.Mfeastr2 '_' cmethod getparastr(knnpara)];
setting.latentresult = ['latent/' dataname '/' setting.Mfeastr1 '_' cmethod];
setting.Modelresult = ['SVMModel/' dataname '/' setting.Modelfeastr '_' cmethod];   
nameresulttmp = nameresult; 
suffix = '';
switch cmethod
    case 'MultiSVM'
        setting.latentresult = [setting.latentresult '-' num2str(mod(setting.platent, 2))];
        setting.Modelresult = [setting.Modelresult '-' num2str(mod(setting.platent, 2))];
        suffix = getparastr(cpara);
        if nnz(setting.Crange - [-5,3])
            suffix = [suffix '-' num2str(setting.Crange(1)) '-' num2str(setting.Crange(2))];
        end
        if length(knnpara) > 1
            suffix = [suffix '-' num2str(knnpara(2))];
        end
    case 'MLR'
        setting.latentresult = [setting.latentresult '-' num2str(setting.platent)];
        setting.Modelresult = [setting.Modelresult '-' num2str(setting.Mplatent)];
        suffix = [getparastr(cpara{1}), '-',cpara{2}, getparastr(cell2mat(cpara(3:end)))];
        if length(knnpara) > 1
            suffix = [suffix '-' num2str(knnpara(2))];
        end
        setting.C = cpara{1};setting.LOSS = cpara{2}; setting.k = cpara{3};  
        setting.REG =cpara{4}; setting.Diagonal = cpara{5}; setting.B = cpara{6};
        setting.Latiter = cpara{7};
       
        if length(cpara) > 7
            setting.MetricTemplate = cpara{8};
            if length(cpara) > 8
                setting.Ttrain.config_latent = cpara{9};
                setting.Ttrain.platent = cpara{10};
            else
                setting.Ttrain.config_latent = 'Latent1';
                setting.Ttrain.platent = cpara{10};
            end
            setting.Platent = cpara{8};
            setting.MetricTemplate = cpara{8};
        else
            setting.MetricTemplate = 0;
        end
end
setting.latentresult = [setting.latentresult suffix];
setting.Modelresult = [setting.Modelresult suffix];
nameresult = [nameresult suffix];
nameimresult = [nameimresult suffix];       
if setting.confidence && ~exist(['Confidence/' dataname])
    mkdir(['Confidence/' dataname])
end
if length(feattype) >1
if ~normmerge
    nameresult = [nameresult '_C'];nameresulttmp = [nameresulttmp '_C']; nameimresult = [nameimresult '_C'];
end
end

latentresult1 = setting.latentresult;
if multiview
    nameresult = [nameresult '_MV' num2str(multiview)];nameresulttmp = [nameresulttmp  '_MV' num2str(multiview)];
    nameimresult = [nameimresult '_MV' num2str(multiview)];
    setting.latentresult = [setting.latentresult '_MV' num2str(multiview)];
    if multiview ~= 1
        nameresult = [nameresult '_' num2str(Rconfidence)]; nameresulttmp = [nameresulttmp '_' num2str(Rconfidence)];
        nameimresult = [nameimresult '_' num2str(Rconfidence)];
        setting.latentresult = [setting.latentresult '_' num2str(Rconfidence)];
    end
end

nameresult = [nameresult '\'];nameresulttmp = [nameresulttmp '\'];
nameimresult = [nameimresult '\'];

if ~exist(nameresult) mkdir(nameresult);  end
if ~exist(nameresulttmp)  mkdir(nameresulttmp);  end
if ~exist(nameimresult) && issave mkdir(nameimresult);  end

if setting.WTA
    maxk = 7;
    name = ['BitCount_' num2str(maxk)];
    try
        load(['WTA\' name '.mat'], BitCount);
    catch
        if ~exist('WTA\')
            mkdir('WTA\')
        end
        BitCount = CreateNum1table(maxk);
        save(['WTA\' name '.mat'], 'BitCount');
    end
else
    BitCount = '';
    setting.K = 0;
end
setting.BitCount = BitCount;
bestPara = zeros([1,5]);

setting.Metric = [];
Error = 0;
hassaved = 0;


    if issave
        if ~exist([nameimresult 'True\'])
            mkdir([nameimresult 'True\']);
        end
        if ~exist([nameimresult 'False\'])
            mkdir([nameimresult 'False\']);
        end
    end

    [fdatabase, database, dfea, WTAfea,setting] = computeFeature(img_dir1, img_dir, dataname, ...
        mfea_dir, mfea_dir_WTA, setting, copyremove, feattype, suffix);
    
    confidencestr = setting.confidence;
    if (strcmp(cmethod, 'MLR') && ~setting.MetricTemplate) || setting.confidence == 3 ||...
            (UseSplit)
        [setting.Idx_fold, c, b] = unique(setting.ts_fold_idx);
        setting.Label_fold = setting.ts_Fold_label(setting.Idx_fold);
        cindex = unique(setting.Label_fold);
        try
            load([setting.TFstr, '_Nfold' num2str(Nfold) '.mat'], 'idx');
        catch
            idx = cell(1, length(cindex));
            for c = 1:length(cindex)
                tid = find(setting.Label_fold == cindex(c));
                idx{c} = randperm(length(tid));
                idx{c} = tid(idx{c});
            end
            save([setting.TFstr, '_Nfold' num2str(Nfold) '.mat'], 'idx');
        end
        if ~UseSplit
            
        if confidencestr == 3  setting.confidence = 1;  end
        acc = zeros(1, length(setting.ts_idx));
        C = zeros(length(setting.ts_idx), knnpara(1));
        ranktime = 0;
        for tt = 1:Nfold
            latentresult = setting.latentresult;
            Modelresult = setting.Modelresult;
            setting.Fold = tt;
            ts_idx_conffold = [];
            for jj = 1:length(cindex)
                nnum = ceil(length(idx{jj}) / Nfold);
                tid = [(tt-1)*nnum+1:min(tt*nnum, length(idx{jj}))];
                ts_idx_conffold = [ts_idx_conffold, idx{jj}(tid)];
            end
            
            ts_idx_conf = find(ismember(b, ts_idx_conffold) ~= 1);  
            setting.ts_idx_conf = ts_idx_conf;
            
            if strcmp(cmethod, 'MLR') 
                setting.platent = setting.Mplatent;
                Mstr = ['F' num2str(Nfold) '-' num2str(setting.Fold) '.mat'];
                try
                    load(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
                catch
                    setting.Mclassfy = 1;setting.Tclassfy = 0;setting.latentresult = latentresult1;
                    [accT, CT, ranktime, WConf, Metric] =  Classify_2(setting, img_dir1, setting.tr_idx,...
                        setting.ts_idx(ts_idx_conf), dfea, ...
                        WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, ...
                        setting.cindex, nameresult, nameimresult, 0, normmerge, 0, 0);
                    save(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
                end
                setting.Metric = Metric;
            else
                setting.Metric = [];
            end
            if confidencestr == 3
                setting.platent = setting.Tplatent;
                try
                    load([setting.confidenceF '_W' num2str(tt) '.mat'], 'WConf', 'ts_idx_conf');
                catch
                    setting.Mclassfy = 0;setting.Tclassfy = 1;setting.latentresult = latentresult1;
                    [accT, CT, ranktime, WConf, Metric] =  Classify_2(setting, img_dir1, setting.tr_idx,...
                        setting.ts_idx(ts_idx_conf), dfea, ...
                        WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, setting.cindex, nameresult, nameimresult, 0, normmerge, ...
                        0, 0);
                    save([setting.confidenceF '_W' num2str(tt) '.mat'], 'WConf', 'ts_idx_conf');
                end
                setting.WConf = WConf;
            end
            Mstr = ['F' num2str(setting.Fold) '.mat'];
            setting.ts_idx_conf = setdiff([1:length(setting.ts_idx)], ts_idx_conf);
            try
                load(fullfile(nameresult,['Result-', Mstr]), 'accF', 'ranktimeF'); 
                if issave
                    load(fullfile(nameresult,['CResult-', Mstr]), 'CF'); 
                end
            catch
                setting.platent = setting.Tplatent;
                setting.Mclassfy = 0;setting.Tclassfy = 0;setting.latentresult = latentresult;
                setting.Modelresult = Modelresult;
                setting.Pacc = 1;
                [accF, CF, ranktimeF] =  Classify_2(setting, img_dir1, setting.tr_idx, setting.ts_idx(setting.ts_idx_conf), dfea, ...
                    WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, setting.cindex, nameresult, nameimresult, issave, normmerge, ...
                    multiview, setting.Rconfidence);
                save(fullfile(nameresult,['Result-', Mstr]), 'accF', 'ranktimeF'); 
                if issave
                    save(fullfile(nameresult,['CResult-', Mstr]), 'CF'); 
                    hassaved = 1;                    
                end
            end
            acc(setting.ts_idx_conf) = accF;
            C(setting.ts_idx_conf, :) = CF;
            ranktime = ranktime + ranktimeF;
            zzz1 = intersect(setting.ts_idx_conf, zzz);
            zzz = union(setting.ts_idx_conf, zzz);
        end
        try
            if issave && ~hassaved
                try
                    load([nameimresult 'issave'], 'issave');
                catch
                    Showresult(fdatabase, setting.cindex, acc, C, setting.tr_idx, setting.ts_idx, ...
                        setting.ts_fold_idx,nameimresult, setting.Asubname, knnpara(1));
                    hassaved = 1;
                end
            end
            acc = GetTotalRate(fdatabase, setting.cindex, acc, setting.ts_idx, setting.ts_fold_idx);
        catch
            Error = 1;
            save('tinfo', 'fdatabase', 'setting', 'acc');fprintf('Error with GetTotalRate\n');pause;
        end
        
        else
            if setting.RoundSplit == 0
                try
                load([setting.TFstr, '_NTraininfo' num2str(Nfold) '.mat'], 'Trainset', 'Testset');
                catch
                [Trainset, Testset] = getsplit(b, idx, Nfold, cindex);
                save([setting.TFstr, '_NTraininfo' num2str(Nfold) '.mat'], 'Trainset', 'Testset');
                end
                setting.Pacc = 0;
                if strcmp(cmethod, 'MLR')  %%%for learning metric
                setting.Metric = NfoldTrain(b, cindex, Trainset, idx, Nfold, setting,img_dir1, dfea, ...
                    WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, nameresult, ...
                    nameimresult,normmerge, multiview, latentresult1);
                end
                latentresult = setting.latentresult;Modelresult = setting.Modelresult; setting.ts_idx_conf = Testset;
                try
                load(fullfile(nameresult,['Result']), 'acc', 'C', 'ranktime'); 
                catch
            setting.platent = setting.Tplatent;
            setting.Mclassfy = 0;setting.Tclassfy = 0;setting.latentresult = latentresult;
            setting.Modelresult = Modelresult;
            [acc, C, ranktime] =  Classify_2(setting, img_dir1, setting.tr_idx, setting.ts_idx(setting.ts_idx_conf), dfea, ...
                WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, setting.cindex, nameresult, nameimresult, issave, normmerge, ...
                multiview, setting.Rconfidence);
            save(fullfile(nameresult,['Result']), 'acc', 'C', 'ranktime'); 
                end
            else
                racc = zeros(Nfold, length(setting.cindex));
                rranktime = zeros(Nfold, 1);
                for round = 1:Nfold
                    [racc(round,:), C, rranktime(round)] = GetRoundAccuracy(round, Nfold, setting,img_dir1, dfea, ...
                        WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, nameresult, ...
                        nameimresult,normmerge, multiview, latentresult1);
                end
                acc = mean(racc);ranktime = mean(rranktime);
            end
        end
        
    else
        setting.Pacc = 0;
        latentresult = setting.latentresult;Modelresult = setting.Modelresult;
        if setting.confidence == 1
            try
                load([setting.confidenceF '_W.mat'], 'WConf', 'ts_idx_conf');
            catch
                idrand = randperm(length(setting.ts_idx));
                ts_idx_conf = idrand([1:round(length(setting.ts_idx)*0.5)]);
                setting.ts_idx_conf = ts_idx_conf;
                setting.Tclassfy = 1;setting.latentresult = latentresult1;
                [acc, C, ranktime, WConf, Metric] =  Classify_2(setting, img_dir1, setting.tr_idx,...
                    setting.ts_idx(ts_idx_conf), dfea, ...
                    WTAfea, fdatabase, feattype,cpara, cmethod, setting.cindex, nameresult, nameimresult, 0, normmerge, ...
                    0, 0);
                save([setting.confidenceF '_W.mat'], 'WConf', 'ts_idx_conf');
            end
            setting.WConf = WConf;
        end
        setting.latentresult = latentresult;setting.Modelresult = Modelresult;
        setting.Tclassfy = 0;setting.ts_idx_conf = [];
        [acc, C] =  Classify_2(setting, img_dir1, setting.tr_idx, setting.ts_idx, dfea, ...
            WTAfea, fdatabase, feattype, knnpara, cpara, cmethod, setting.cindex, nameresult, nameimresult, issave, normmerge, ...
            multiview, setting.Rconfidence);  
    end

    T = cell(1, size(C{1}, 1));
    for ii = 1:size(C{1}, 1)
        T{ii} = cell(1, size(C{1}, 2));
        for jj = 1:size(C{1}, 2)
            T{ii}{jj} = str2num(database.cname{C{1}(ii,jj)});
        end
    end
    C{1} = T;
    index = union(strfind(nameresult, '\'), strfind(nameresult, '/'));
    pathstr = nameresult(index(end-1)+1:index(end)-1);
    save(['image\Labeling_knn\KNN_info\' pathstr '.mat'], 'C');