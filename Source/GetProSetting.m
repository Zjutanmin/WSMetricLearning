setting.Rconfidence = Rconfidence;setting.rescale = 0;setting.MultiFold = 0;setting.WeightUpC = 0;
if iscell(multiview)  %%if is cell, one is for training, another for testing
    setting.testmultiview = multiview{2};
    multiview = multiview{1};
else
    setting.testmultiview = multiview;
end

setting.WeightUpC = 0;
if round(multiview) ~= multiview
    multiview = floor(multiview);
    setting.WeightUpC = 1;
end
setting.multiview =multiview;

setting.Ratio = Ratio;
setting.RRatio = RRatio;
fast = 0;
if strcmp(setting.feattype{1}, 'siftflow') %%for 'siftflow', if using fast computation method
    setting.fast = fast;
else
    setting.fast = 1;
end
setting.svote = svote;setting.Crange = Crange; 

setting.Ninit = 0;
if iscell(selfpaced)
    setting.Ninit = selfpaced{2};
    selfpaced = selfpaced{1};
end

setting.UseRound = 0;
GroupR = 0;

setting.KNNlatent = 1;
setting.isKNNlatent = 0;
if setting.KNNlatent(1) ~= 1
    setting.isKNNlatent = 1;
end

%%the following parameters are for WTA hasing, expired
config_WTA=''; WTAwithraw=0;
setting.config_WTA = config_WTA;

pwd = cd;
fn = [pwd '/setting/',config_WTA,'.m'];
if exist(fn)  %%%modify feature type
    cwd = pwd;cd([pwd '/setting/']);
    eval(config_WTA);cd(cwd);
    setting.WTA = 1;
    setting.WTAwithraw = WTAwithraw;
else
    setting.WTA = 0; setting.WTAwithraw = 0;
end
setting.Fpyramid = Fpyramid;
if setting.WTA  %%%if used WTA hasing
    maxk = 7;
    name = ['BitCount_' num2str(maxk)];
    try
        load(['WTA/' name '.mat'], BitCount);
    catch
        if ~exist('WTA/')
            mkdir('WTA/')
        end
        BitCount = CreateNum1table(maxk);
        save(['WTA/' name '.mat'], 'BitCount');
    end
else
    BitCount = '';
    setting.K = 0;
end
setting.BitCount = BitCount;
bestPara = zeros([1,5]);


%%the following parameters are for reocgnition with latent bounding box, expired
config_latent = '';platent = 0;
setting.bestS = 0;
pwd = cd;
fn = [pwd '/setting/',config_latent,'.m'];
if exist(fn)
    setting.displace = 0; setting.rotate = 0;
    cwd = pwd; cd([pwd '/setting/']);
    eval(config_latent); cd(cwd);
    setting.latent = 1; setting.config_latent = config_latent;  
    setting.platent = platent;
else
    setting.config_latent = '';
    if mod(platent, 10) ~= 5
        setting.latent = 0;
        setting.platent = 0;
    else
        setting.latent = platent;
        setting.platent = platent;
        setting.bestS = 1;
    end
end
setting.KNNlatentTrain = 0;
setting.KNNlatent = 1;
% if length(KNNlatent) > 2 && round(KNNlatent(2)) ~= KNNlatent(2)
%     setting.UseRound = round(10*(KNNlatent(2) - floor(KNNlatent(2))));
%     KNNlatent(2) = floor(KNNlatent(2));
% end
% setting.KNNlatent = KNNlatent;
% if length(KNNlatent) > 1 && KNNlatent(2) == 1
%     setting.KNNlatentTrain = 1;
% end
setting.Tplatent = mod(setting.platent, 10);

%%the following parameters are for image pre-processing, expired
config_DOG = '';setting.config_DOG = config_DOG;
pwd = cd;
fn = [pwd '/setting/',config_DOG,'.m'];
if exist(fn)  %%%modify feature type
    cwd = pwd;cd([pwd '/setting/']);
    eval(config_DOG);cd(cwd);
    setting.DoG = 1;
end


%%the following parameters are for storage limitation, expired
GBlimit = 20;Nmax = 5000;NmaxMLR = 36000;
setting.GBlimit = GBlimit;
UseSplit= 1; %%training/testing split
if iscell(UseSplit)
    setting.SplitRatio = floor((UseSplit{2}));
    UseSplit = floor((UseSplit{1}));
else
    if UseSplit < 0
        setting.SplitRatio = -(UseSplit + floor(abs(UseSplit)));
        UseSplit = -floor(abs(UseSplit));
    else
        setting.SplitRatio = UseSplit - floor(abs(UseSplit));
        UseSplit = floor(abs(UseSplit));
    end
end
if setting.SplitRatio == 0
    setting.SplitRatio = 0.25;
end
Nfold = UseSplit;
setting.RoundSplit = 0;
if Nfold < 0
    setting.RoundSplit = 1;
    Nfold = -Nfold;
end
setting.featPad = featPad;
testSOutput= 0; setting.testSOutput = testSOutput;

if ~setting.WTA && isfield(setting, 'WTAwithraw') && setting.WTAwithraw
    fprintf('Error configuration: no WTA coding, but WTAwithraw is valid\n');
    pause;
end
if changesize  %%%for feature extraction, used varied steps
    setting.swin = ones(size(setting.swin)) * patchsize;
    idx = find(setting.overlap == 1);
    setting.stride = setting.swin;
    setting.stride(idx) = setting.swin(idx) / 2;
end

testdata = suffix;testdata1 = suffix;
setting.VirTest = 0;
setting.sRatio = 1;
if iscell(rawsize)
    if length(rawsize) > 2
        setting.sRatio = rawsize{1};
    end
    if ~isempty(rawsize{end-1})
        testdata = rawsize{end-1};
    end
    if iscell(testdata)
        setting.VirTest = testdata{1};
        testdata = testdata{2};
    end
    rawsize = rawsize{end};
end
setting.testdata = testdata;

setting.rawsize = rawsize;
setting.LDAfeaNORM = 1;
if iscell(dataname)
    setting.LDAfeaNORM = dataname{2};
    dataname = dataname{1};
end
dataname1 = dataname;
addpath('Liblinear/matlab');        % we use Liblinear package, you need 
addpath('Libsvm/matlab');        % we use Liblinear package, you need 
addpath(genpath('mlr/'));
if ~strcmp(dataname, 'Caltech101')
    Tdataname = [dataname testdata];
    dataname = [dataname suffix];   
end
img_dir1 = ['image/' dataname1];       % directory for the image database  
feattype = setting.feattype;
img_dir = ['image/' dataname];       % directory for the image database   
Timg_dir = ['image/' Tdataname];       % directory for the image database   

fea_dir = ['features/' dataname];     % directory for saving final image features
if setting.Ratio
    setting.ratio_dir = ['Ratio/' dataname];
end
% setting.Mplatent = floor(setting.platent / 10);
setting.Tplatent = mod(setting.platent , 10);
if floor(setting.platent / 10)  %%%>10
    setting.Mplatent = 0;
else
    setting.Mplatent = setting.Tplatent;
end

if length(setting.KNNlatent) > 4 %%%the last on is for test
    setting.teststyle = setting.KNNlatent(5);
    setting.KNNlatent =  setting.KNNlatent(1:4);
else
    setting.teststyle = 1;
end

% getImFFold(img_dir);
setting.cmethod = cmethod;
setting.splitPCA = 0;
setting.AidConf = [];
FeaDRSetting;  %%%setings for dimension reduction


[mfea_dir, feastr, codestr, bookstr, Mfeastr, setting, N, mfea_dir_WTA] = ...
    getfeastr(fea_dir, setting);

if UseSplit
    Mfeastr = [Mfeastr, '_S', num2str(UseSplit)];
    if setting.SplitRatio ~= 0.25
        Mfeastr = [Mfeastr, '_', num2str(setting.SplitRatio)];
    end
    if setting.SplitRatio ~= 0.5 || UseSplit ~= -3
        setting.Mfeastr1 = [setting.Mfeastr1, '_S', num2str(UseSplit)];
        setting.Mfeastr1 = [setting.Mfeastr1, '_', num2str(setting.SplitRatio)];
        setting.Modelfeastr = [setting.Modelfeastr, '_S', num2str(UseSplit)];
        setting.Modelfeastr = [setting.Modelfeastr, '_', num2str(setting.SplitRatio)];
    end
end

setting.DRstr = '';
setting.PCAenergy = 0;
if iscell(setting.PCA) || setting.PCA
    if iscell(setting.PCA)
        pcastr = getcparastr(setting.PCAO, setting.PCAdef, setting.PCAMethod);
        setting.DRstr = pcastr;
        setting.PCAenergy = setting.PCA{1};
    else
        pcastr = ['_' setting.PCAMethod num2str(setting.PCA)];
        setting.PCAenergy = setting.PCA;
    end
    if setting.splitPCA
        pcastr = [pcastr, 'M'];
    end
    if ~isempty(setting.AidConf)
        pcastr = [pcastr, 'A', getparastr(setting.AidConf)];
    end
    if setting.LocalPCA
        pcastr = [pcastr, '_L'];
    end
    Mfeastr = [Mfeastr, pcastr];
    setting.Mfeastr1 = [setting.Mfeastr1, pcastr];
    setting.Modelfeastr = [setting.Modelfeastr, pcastr];
end

testSOutput = setting.testSOutput;
setting.testSOutput = mod(testSOutput, 2);
setting.Flatent = floor(testSOutput / 2); %%%fix latent

if setting.testSOutput
    Mfeastr = [Mfeastr, '_SO'];
    setting.Mfeastr1 = [setting.Mfeastr1, '_SO'];
end

if setting.Flatent
    Mfeastr = [Mfeastr, '_FL'];
    setting.Mfeastr1 = [setting.Mfeastr1, '_FL'];
end

imRes_dir = ['imresult/' dataname '/'];
Res_dir = ['result/' dataname '/'];

kpara = ['-' num2str(knnpara(1))];
setting.kparastr = '';setting.kparastrMod = '';
for i = 2:length(knnpara) %%%soft KNN setting
    if i == 3
        ss = ['-' num2str(knnpara(i)) repmat('0', [1, KNNPad1])];
        setting.Randclassstr = [ss];
        kpara = [kpara ss];
    end
    if i == 2
        ss = ['-' num2str(knnpara(i)) repmat('0', [1, KNNPad])];
        setting.kparastr = [setting.kparastr ss];
        if knnpara(i) ~= 0
            setting.kparastrMod = [setting.kparastrMod ss];
        end
        setting.Randclassstr = [ss];
        kpara = [kpara ss];
    end
    kii = i;
end
nameresult = [Res_dir Mfeastr '_' cmethod kpara];
setting.Tplatent = mod(setting.platent, 10);

nameimresult = [imRes_dir Mfeastr '_' cmethod getparastr(knnpara)];
setting.confidenceF = ['Confidence/' dataname '/' setting.Mfeastr2 '_' cmethod getparastr(knnpara)];
setting.latentresult = ['latent/' dataname '/' setting.Mfeastr1 '_' cmethod];
setting.Modelresult = ['SVMModel/' dataname '/' setting.Modelfeastr '_' cmethod]; 



setting.ModelresultO = setting.Modelresult;
nameresulttmp = nameresult; 
suffix = '';
setting.Usetemplate = 1;
setting.MeanT = 0; setting.AllTemp = 0; setting.TestSuf = '';
setting.MetricL2 = 0;



%%%initialization for tempalte learning
setting.WeightUp = 1;setting.TempMLR = 0;setting.TemplateNorm = 0;
setting.TemplateINNC = 0;setting.GammaS = 0;setting.KmeanA = 1;setting.FeatUp = 0; 
setting.mult_dic = 1;setting.iter_dic = 10e3;setting.Newcode = 0;suffx = '';

setting.method_dic = 1;
setting.innerfea = 0;
if ~strcmp(cmethod, 'MLR') && ~strcmp(cmethod, 'RMLR')
    if iscell(cpara) && ~isempty(cpara)
        if length(cpara) > 1
            setting.innerfea = cpara{2};
            suffix = [suffix 'In'];
        end
        cpara = cpara{1};
    end
end
setting.TrainINNC = 1;setting.WUp = 1;setting.MUp = 0;
setting.exitDiC = 0;
setting.TemplateUp = 0;
setting.INNCSP = 0;setting.Enorm = 0;
setting.TestKNN = 0;setting.TestINNC = 0;

setting.isMetricL2 = 1;setting.testMetric = 0;
setting.RC = 0;
suffixMod = suffix;
switch cmethod
    case 'INNC'
        useallT = 0;
        setting.latentresult = [setting.latentresult '-' num2str(mod(setting.platent, 2))];
        setting.Modelresult = [setting.Modelresult '-' num2str(mod(setting.platent, 2))];
        suffix = getparastr(cpara);suffixMod = suffix;
        if length(knnpara) > 1
            suffix = [suffix setting.kparastr];
            suffixMod = [suffixMod setting.kparastrMod];
        end
    case 'ML'
        useallT = 0;
        setting.latentresult = [setting.latentresult '-' num2str(mod(setting.platent, 2))];
        setting.Modelresult = [setting.Modelresult '-' num2str(mod(setting.platent, 2))];
        suffix = getparastr(cpara);suffixMod = suffix;
        if length(knnpara) > 1
            suffix = [suffix setting.kparastr];
            suffixMod = [suffixMod setting.kparastrMod];
        end
    case 'lmnn'
        useallT = 1;
        setting.latentresult = [setting.latentresult '-' num2str(mod(setting.platent, 2))];
        setting.Modelresult = [setting.Modelresult '-' num2str(mod(setting.platent, 2))];
        suffix = getparastr(cpara);suffixMod = suffix;
        if length(knnpara) > 1
            suffix = [suffix setting.kparastr];
            suffixMod = [suffixMod setting.kparastrMod];
        end 
    case 'gblmnn'
        useallT = 1;
        setting.latentresult = [setting.latentresult '-' num2str(mod(setting.platent, 2))];
        setting.Modelresult = [setting.Modelresult '-' num2str(mod(setting.platent, 2))];
        setting.lmnnsuffix2 = getparastr(cpara(1:end-1));
        suffix = getparastr(cpara);setting.lmnnsuffix1 = suffix;suffixMod = suffix;
        if length(knnpara) > 1
            suffix = [suffix setting.kparastr];
            suffixMod = [suffixMod setting.kparastrMod];
        end 
    case 'KNN'
        useallT = 0;
    case 'MultiSVM'
        useallT = 0;
        setting.latentresult = [setting.latentresult '-' num2str(mod(setting.platent, 2))];
        setting.Modelresult = [setting.Modelresult '-' num2str(mod(setting.platent, 2))];
        suffix = getparastr(cpara);
        if length(setting.Crange) > 1
            suffix = [suffix '-' num2str(setting.Crange(1)) '-' num2str(setting.Crange(2))];
            if length(setting.Crange) > 2
                 suffix = [suffix '-' num2str(setting.Crange(3))];
            end
        end
        suffixMod = suffix;
        if length(knnpara) > 1
            suffix = [suffix setting.kparastr];
            suffixMod = [suffixMod setting.kparastrMod];
        end
    case 'MLR'
        useallT = 0;
        [setting, suffix, cpara, suffixMod, nameresult] = getsettingMLR(nameresult, setting, cpara, knnpara);
    case 'RMLR'
        useallT = 0;
        [setting, suffix, cpara, suffixMod, nameresult] = getsettingMLR(nameresult, setting, cpara, knnpara);
    case 'CNN'
        useallT = 1;
end

if setting.WKNN
    nameresult = [nameresult, 'W'];
end
setting.SetNormFea = SetNormFea;suffixstr = '';
if setting.SetNormFea
    suffix = [suffix, 'NF'];suffixstr = 'NF';
    suffixMod = [suffixMod, 'NF'];
end
setting.latentresult = [setting.latentresult suffix];
setting.Modelresult = [setting.Modelresult suffixMod];
if setting.platent
    setting.ModelresultO = [setting.ModelresultO suffix];
end


setting.useallO = setting.useall;
if setting.useall == 2  %%not consider template
    setting.Usetemplate = 0;
    setting.useall = 1;
    suffix = [suffix, 'NT'];
    setting.useallstr = 'NT';
else  
    if setting.useall == -1  %%if defalt, then 
        setting.useall = useallT;
    end
    setting.useallC = useallT;
    setting.useallstr = '';
    if setting.useallC ~= setting.useall
        if setting.useall
            suffix = [suffix, 'UA'];
            setting.useallstr = 'UA';
        else
            suffix = [suffix, 'UT'];
            setting.useallstr = 'UT';
        end
    end
end

nameresult = [nameresult suffix setting.TestSuf];


if strcmp(cmethod, 'MLR') || strcmp(cmethod, 'RMLR')
    nameresult = [nameresult 'T-' num2str(setting.teststyle)];
    setting.latentresult = [setting.latentresult 'T-' num2str(setting.teststyle)];
end
        
nameimresult = [nameimresult suffix];       
if setting.confidence && ~exist(['Confidence/' dataname])
    mkdir(['Confidence/' dataname])
end


setting.featNormstr = '';
setting.normweigh = 1;
if length(feattype) >1
if ~normmerge
    nameresult = [nameresult '_C'];nameresulttmp = [nameresulttmp '_C']; nameimresult = [nameimresult '_C'];
    
else
    if length(normmerge) == 1
        setting.normweigh = ones([length(feattype), 1]);
    else
        setting.normweigh = normmerge;
        suffixx = ['_N', getparastr(normmerge)];
        setting.featNormstr = suffixx;
        setting.latentresult = [setting.latentresult suffixx];
        setting.Modelresult = [setting.Modelresult suffixx];
        setting.Modelfeastr = [setting.Modelfeastr suffixx];
        nameresult = [nameresult suffixx];
        nameresulttmp = [nameresulttmp suffixx]; 
        nameimresult = [nameimresult suffixx];
    end
end
end


[~, name1] = fileparts(img_dir);
if (isdir(img_dir))
    [~, name1, ext] = fileparts(img_dir);
    name1 = [name1, ext];
else
    [~, name1] = fileparts(img_dir);
end


%%%get category number
setting.samesplit = 'Sign_NewT3';
if strcmp(name1, 'Sign_NewT2')
    Nclass = 31;
end
if strcmp(name1, 'Sign_NewT3')
    Nclass = 31;
end
if strcmp(name1, 'Sign_NewT4')
    Nclass = 52;
end
if strcmp(name1, 'Sign_NewT5')
    Nclass = 52;
end
if strcmp(name1, 'Sign_New2')
    Nclass = 7;
end


setting.isweightNorm = 0;
if strcmp(name1, 'TSR_GTSRB')
    Nclass = 43;
    setting.isweightNorm = 1;
end
if strcmp(name1, 'TSR_BTSRB')
    Nclass = 62;
    setting.isweightNorm = 1;
end
if setting.testmultiview ~= multiview
    nameresult = [nameresult 'T' num2str(setting.testmultiview)];nameresulttmp = [nameresulttmp  'T' num2str(setting.testmultiview)];
    nameimresult = [nameimresult 'T' num2str(setting.testmultiview)];
end
setting.NewFormatFold = 0;
if ~isempty(strfind(name1, 'Sign_NewT6')) || ~isempty(strfind(name1, 'Sign_NewT7')) || ~isempty(strfind(name1, 'Sign_NewT8')) || ~isempty(strfind(name1, 'Sign_NewT9')) || ~isempty(strfind(name1, 'Sign_NewT10')) || ~isempty(strfind(name1, 'Sign_NewT11'))
    setting.NewFormatFold = 1;
end
setting.loadDataMAT = 0;
if length(dataname) >= 8 && strcmp(dataname(1:8), 'face_PIE') 
    setting.loadDataMAT = 1;setting.LDAfeaNORM = 0;
    Nclass = 68;
else
try
    if strcmp(dataname, 'face_YaleBE') || strcmp(dataname, 'face_ORL')
        load(fullfile(pwd, 'TrainInfo', ['image_' dataname '_0_database.mat']))
    else
        load(fullfile(pwd, 'TrainInfo', ['image_' dataname '_1_database.mat']))
    end
    Nclass = length(database.cname);
catch
    if setting.NewFormatFold
    ffn = dir(img_dir);
    Nclass = 0;
    for i = 1:length(ffn)
        if strcmp(ffn(i).name, '.') || strcmp(ffn(i).name, '..')
            continue;
        end
        if isdir(fullfile(img_dir, ffn(i).name))
            ffdir = dir(fullfile(img_dir, ffn(i).name, 'test_*.jpg'));
            if length(ffdir) == 0
                rmdir(fullfile(img_dir, ffn(i).name), 's')
                pause;
                continue;
            end
            Nclass = Nclass + 1;
        end
    end
    end
end
end
if ~isempty(strfind(name1, 'Sign_NewT7')) && ~strcmp(name1, 'Sign_NewT7')
    Nclass = 101;
end
NclassO = Nclass;
latentresult1 = setting.latentresult;
if multiview
    nameresult = [nameresult '_MV' num2str(multiview)];nameresulttmp = [nameresulttmp  '_MV' num2str(multiview)];
    nameimresult = [nameimresult '_MV' num2str(multiview)];
    setting.latentresult = [setting.latentresult '_MV' num2str(multiview)];
    if strcmp(name1(1:3), 'TSR')
        setting.Modelresult = [setting.Modelresult '_MV' num2str(multiview)];
    end
    if multiview ~= 1
        if multiview == 5
            suff = [num2str(Rconfidence(1)), '-', num2str(Rconfidence(2))];
        else
            suff = [num2str(Rconfidence)];
        end
        nameresult = [nameresult '_' suff]; 
        nameresulttmp = [nameresulttmp '_' suff];
        nameimresult = [nameimresult '_' suff];
        setting.latentresult = [setting.latentresult '_' suff];
    end
end
if setting.WeightUpC
    nameresult = [nameresult 'C'];nameresulttmp = [nameresulttmp 'C'];nameimresult = [nameimresult 'C'];
    setting.latentresult = [setting.latentresult 'C'];setting.Modelresult = [setting.Modelresult 'C'];
end


setting.Metric = [];
Error = 0;


setting.UsePos = 0;setting.TrainError = 0;setting.recompute = 0;
if issave == -1
    setting.TrainError = 1;
    setting.resultsuffix = '_T';
    setting.latentresult = [setting.latentresult setting.resultsuffix];
    issave = 0;
else if issave == 2
        setting.resultsuffix = '_SRB';
        issave = 0;
        setting.UsePos = 1;
    else
        if issave == 3
            setting.recompute = 1;
            issave = 0;
        else
            setting.resultsuffix = '';
        end
    end
end

if ~isfield(setting, 'MetricTemplate')
    setting.MetricTemplate = 0;
end

setting.QualityResult = setting.Modelresult;
setting.SoftCScore = 0;setting.UseAll = 0;
if ismember(setting.confidence, [4 5])
    setting.SoftCScore = 1;
    if setting.confidence == 5
        setting.UseAll = 1;
        setting.SnippetRatio{1} = 0.3;
    end
end

setting.MaxMin = 0;
if length(setting.SnippetRatio) > 2 & floor(setting.SnippetRatio{3}) ~= setting.SnippetRatio{3}
    setting.MaxMin = 1;
end    

if setting.SnippetRatio{1} ~= 1   %%%get reliability feature parameters
    if length(setting.SnippetRatio) < 2
        if setting.SnippetRatio{1} == -1
            setting.SnippetRatio{2} = 0.9;
        else
            setting.SnippetRatio{2} = 0;
        end
    end
    if length(setting.SnippetRatio) < 3
        setting.SnippetRatio{3} = 1;
    end
    if length(setting.SnippetRatio) < 4
        setting.SnippetRatio{4} = 0;
    end
    ssufix = [num2str(setting.SnippetRatio{1}) '_' ...
        num2str(setting.SnippetRatio{2}) '_'];
    if length(setting.SnippetRatio) < 11
        setting.FRatio = 1;
    else
        setting.FRatio = setting.SnippetRatio{11};
    end
    if setting.FRatio ~= 1
        ssufix  = [ssufix  'FR' num2str(setting.FRatio)];
    end
    
    slen = length(ssufix);
    strSR = [ssufix num2str(setting.SnippetRatio{3}) '_' num2str(setting.SnippetRatio{4})];
    CmethodSR = mod(setting.SnippetRatio{3}, 100);  %%%%ge wei shu
    if ismember(CmethodSR, ReciprocalInter)
        if length(setting.SnippetRatio) < 5
            setting.SnippetRatio{5} = 'Reciprocal';
            setting.SnippetRatio{6} = 0;
        end
        strSR = [strSR (setting.SnippetRatio{5}) '_'...
                num2str(setting.SnippetRatio{6})];
    end
    if length(setting.SnippetRatio) < 7
        setting.SnippetRatio{7} = 0; %%%not first round all
    end
    if setting.SnippetRatio{7}
        strSR = [strSR '_FA'];
    end
    
    if length(setting.SnippetRatio) < 8
        setting.SnippetRatio{8} = 0; %%%not first round all
    end
    THstr = '';
    if setting.SnippetRatio{8}
        THstr = ['_TH'];
        if setting.SnippetRatio{8} ~= 1
            THstr = [THstr num2str(setting.SnippetRatio{8})];
        end
    end
    nameresult = [nameresult '_SR' strSR THstr];
    nameimresult = [nameimresult '_SR' strSR THstr];
    setting.latentresult = [setting.latentresult '_SR' strSR THstr];

    if floor(setting.SnippetRatio{3} / 10000) == 0
        setting.Modelresult = [setting.Modelresult '_SR' strSR];
        setting.QualityResult = [setting.QualityResult '_SR' strSR THstr];
    end
    setting.Ntype = 'NA';
    setting.onetype = 'min';    
    if floor(setting.SnippetRatio{3} / 10000) == 2
        setting.Noiseretrain = 1;
        setting.Modelresult = [setting.Modelresult '_SR' strSR(slen+1:end)];
        setting.QualityResult = [setting.QualityResult '_SR' strSR(slen+1:end) THstr];
        if length(setting.SnippetRatio) > 8
            setting.Ntype = setting.SnippetRatio{9};
            setting.onetype = setting.SnippetRatio{10};
        else
            setting.Ntype = 'NA';
            setting.onetype = 'min';
        end
        if length(setting.SnippetRatio) > 11
            setting.weightNorm = setting.SnippetRatio{12};
        else
            setting.weightNorm = 0;
        end
        if setting.isweightNorm
            setting.weightNorm = 1;
        end
        ss = '';
        if ~strcmp(setting.Ntype, 'NA') || ~strcmp(setting.onetype, 'min')
            ss = [ss '-', setting.Ntype, '-', setting.onetype];
        end
        if setting.weightNorm
            ss = [ss 'N', num2str(setting.weightNorm)];
        end
        nameimresult = [nameimresult ss];nameresult = [nameresult ss];
        setting.QualityResult = [setting.QualityResult ss];
        setting.latentresult = [setting.latentresult ss];
        setting.Modelresult = [setting.Modelresult ss]; 
    end
    
    if floor(setting.SnippetRatio{3} / 10000) == 1
        setting.QualityResult = [setting.QualityResult '_SR' strSR(slen+1:end) THstr];
    end
    if setting.useallO == 2
        setting.Modelresult = [setting.Modelresult, setting.useallstr];
    end
    setting.QualityResult = [setting.QualityResult, setting.useallstr];
else
    if setting.useallO == 2
        setting.Modelresult = [setting.Modelresult, setting.useallstr];
    end
end

if setting.SnippetRatio{1} ~= 1 && strcmp(cmethod, 'MLR') && setting.MultiFold
    setting.Modelresult = [setting.Modelresult, 'MF'];
    setting.QualityResult = [setting.QualityResult, 'MF'];
    nameimresult = [nameimresult, 'MF'];
    nameresult = [nameresult, 'MF'];
end

if ~setting.isKNNlatent && setting.isSnippetRatio
    if length(setting.KNNlatent) > 1 && setting.KNNlatent(2) ~= 5
        ss = ['R',num2str(setting.KNNlatent(2))];
        nameimresult = [nameimresult ss];
        nameresult = [nameresult ss];
        setting.QualityResult = [setting.QualityResult ss];
        setting.latentresult = [setting.latentresult ss];
        setting.Modelresult = [setting.Modelresult ss]; 
    end
else
    if ~setting.isKNNlatent && length(setting.KNNlatent) > 1
        ss = ['R',num2str(setting.KNNlatent(2))];
        nameimresult = [nameimresult ss];nameresult = [nameresult ss];
        setting.QualityResult = [setting.QualityResult ss];
        setting.latentresult = [setting.latentresult ss];
        setting.Modelresult = [setting.Modelresult ss]; 
    end
end


if setting.Comverge  %%acc vs. coverage
    ss =['Cov', num2str(setting.Comverge)];
    nameimresult = [nameimresult ss];
    nameresult = [nameresult ss];
    setting.QualityResult = [setting.QualityResult ss];
    setting.latentresult = [setting.latentresult ss];
    setting.Modelresult = [setting.Modelresult ss]; 
end

%%%for CNN feature
setting.boostInter = [80];
setting.CNNInter = [16];
setting.CNNmInter= [17,18,19];
setting.CNNm_newInter= [20,21];
setting.CNNm_new2Inter= [22,23];
setting.CNNm_new3Inter= [24,25];
setting.CNNm_train1Inter= [30];
setting.CNNm_train2Inter= [31];
setting.CNNm_train3Inter= [32];
setting.CNNm_train4Inter= [33];
setting.CNNm_train5Inter= [34];
setting.CNNm_train6Inter= [35];
isCNN = [setting.CNNInter, setting.CNNmInter, setting.CNNm_new3Inter, setting.CNNm_newInter, setting.CNNm_new2Inter, ...
    30:35];
setting.isCNN = 0;
if setting.isSnippetRatio
    setting.isCNN = ismember(mod(setting.SnippetRatio{3},100), isCNN);
end
setting.isboost = 0;
if setting.isSnippetRatio
    setting.isboost = ismember(mod(setting.SnippetRatio{3},100), setting.boostInter);
end

setting.LatentInter = [40,41,80];
setting.FeatureInter = [50,51,61];
setting.Mthresh = [-1, -2];
setting.EdgeInter = [12,13,14,15];
setting.feaInter = [9];
setting.SaveRes = 1;

setting = getClassNum(setting, knnpara, Nclass, KNNNUM, KNNNUM1);
% setting = getClassNum_T(setting, knnpara, Nclass, KNNNUM1);
setting.Usesubset = 0;
if setting.Nclass ~= Nclass || setting.NclassT ~= Nclass 
    setting.Usesubset = 1;
end
if setting.Usesubset
    Nclass = setting.Nclass;
end

TestRound = [1:Nfold];
if setting.FirstRound(1)
    TestRound = setting.FirstRound(1);
end

setting.TestOneR = 0;setting.TestR=0;
if length(setting.KNNlatent) > 1
    setting.TestR = setting.KNNlatent(2);setting.TestOneR = 0;
    if length(setting.FirstRound) > 1 %% testing round
        setting.TestR = setting.FirstRound(2);setting.TestOneR = 1;
        setting.resultsuffix = [setting.resultsuffix, 'R' num2str(setting.TestR)];
    end
end
setting.FirstRound = setting.FirstRound(1);


setting.extendTest = 0;setting.ReQuality = 0;
if setting.Nclass ~= setting.NclassT
    setting.extendTest = 1;
    if length(knnpara) < 3
        frpintf('Extend need to give the New number of class\n')
        pause;
    end
    ss = ['-' num2str(knnpara(kii)) repmat('0', [1, KNNPad1])];
    setting.Randclassstr = [ss];
    setting.ReQuality = 1;
    setting.QualityResult = [setting.QualityResult 'E' ss];
end

setting.Ngroup = setting.NgroupT;

if GroupR==0
    setting.NgroupR = [1:setting.Ngroup];
else
    setting.NgroupR = round(GroupR*10);
end

setting.NclassPCA = setting.Nclass;
setting.Nclass = setting.NclassT;

if setting.HandClass && (setting.NclassT ~= NclassO || setting.NclassPCA ~= NclassO)
    nameresult = [nameresult, 'CH'];
    if setting.NclassPCA ~= NclassO
        setting.Modelresult = [setting.Modelresult, 'CH'];
        setting.QualityResult = [setting.QualityResult, 'CH'];
        setting.latentresult = [setting.latentresult, 'CH'];   
    end
end
if setting.TSREMPTY
    [~,bb] = fileparts(img_dir1);
    if strcmp(bb, 'Sign')
        setting.TSREMPTY = 0;
    end
    if setting.TSREMPTY 
        nameresult = [nameresult, 'TE'];
    end
end

        
setting.USEINNC = 0; 
if strcmp(cmethod, 'MLR') || strcmp(cmethod, 'RMLR')
    if setting.TestINNC && (~setting.TestKNN)
        if setting.ReCnew
            setting.USEINNC = 1;
            nameresult = [nameresult 'RE'];
            setting.QualityResult = [setting.QualityResult setting.TestSuf 'RE'];
        end
    end
end

if ~setting.LDAfeaNORM
    nameresult = [nameresult, 'FN'];
    setting.Modelresult = [setting.Modelresult, 'FN'];
    setting.QualityResult = [setting.QualityResult, 'FN'];
    setting.latentresult = [setting.latentresult, 'FN'];
end
setting.TDataNew = 0;
if ~strcmp(testdata1, testdata)
    SS = '';
    if setting.VirTest
        SS = num2str(setting.VirTest);
    end
    nameresult = [nameresult, setting.testdata, SS];
    nameimresult = [nameimresult, setting.testdata, SS];
    setting.QualityResult = [setting.QualityResult, setting.testdata, SS];
    setting.TDataNew = 1;
    img_dir = {Timg_dir, img_dir};
end

if setting.sRatio ~= 1
    SS = num2str(setting.sRatio);SS = SS(2:end);
    nameresult = [nameresult, SS];
    nameimresult = [nameimresult, SS];
    setting.QualityResult = [setting.QualityResult, SS];
    setting.Modelresult = [setting.Modelresult, SS];
end
SS = '';
if setting.Ninit
    SS = 'T';
    if setting.Ninit > 10
        SS = 'T1';
    end
    nameresult = [nameresult, SS];
    nameimresult = [nameimresult, SS];
    setting.QualityResult = [setting.QualityResult, SS];
    setting.Modelresult = [setting.Modelresult, SS];
end

if setting.RC
    setting.Modelresult = [setting.Modelresult, 'C', num2str(setting.RC)];
    nameresult = [nameresult, 'C', num2str(setting.RC)];
    setting.QualityResult = [setting.QualityResult, 'C', num2str(setting.RC)];
end

nameresult = [nameresult '/'];nameresulttmp = [nameresulttmp '/'];
nameimresult = [nameimresult '/'];


setting.resultsuffix1 = setting.resultsuffix;
setting.resultsuffix1 = [setting.resultsuffix1, '_I'];
REstr = [];
if setting.TSREMPTY
    REstr = 'TE';
end

if ~exist(nameresult)  
    try   
        mkdir(nameresult)  
    end
end;
if ~exist(nameimresult)  
    mkdir(nameimresult)   
end;



setting.VirUse = VirUse;
setting.VirUsestr = VirUsestr;
setting.VirUseNum = VirUseNum;
setting.Nmax = Nmax;
setting.NmaxMLR = NmaxMLR;
if setting.VirUse
    ss1 = '';
    if NmaxMLR ~= 50000
        ss1 = ['_' num2str(NmaxMLR)];
    end
    setting.Modelresult = [setting.Modelresult, setting.VirUsestr, '_', num2str(setting.VirUseNum) ss1];
    nameresult = [nameresult, setting.VirUsestr, '_', num2str(setting.VirUseNum) ss1];
    setting.QualityResult = [setting.QualityResult, setting.VirUsestr, '_', num2str(setting.VirUseNum) ss1];
end

setting.Modelresult
setting.minLEN = minLEN;
coverage = [-1, coverage];
Cov_str{1} = '';
for i = 2:length(coverage)
    Cov_str{i} = ['_' num2str(coverage(i))];
end

Oresultsuffix1 = setting.resultsuffix1;
Oresultsuffix = setting.resultsuffix;
setting.NSplit = 0;
if isfield(setting, 'C') && setting.C == 0
    seachtype = 'non';
    if strcmp(cmethod, 'KNN') || strcmp(cmethod, 'INNC') 
        seachtype = 'knn';
    end
    if ~strcmp(seachtype, 'knn') && ~strcmp(cmethod, 'CNN')
        for jj = 1:length(Cov_str)
            PCave = zeros([Nclass,1]);ranktime = 0;Ravg = 0;ranktime = 0;  
            PCave = PCave';
            PCave = reshape(PCave,1, []);
            CPCave{jj} = PCave;
            CRavg{jj} = Ravg;
            Cranktime{jj} = ranktime;
        end
        CPCave = cell2mat(CPCave);
        CRavg = cell2mat(CRavg);
        Cranktime = cell2mat(Cranktime);
    end
    return;
end
setting.PreModel1 = PreModel1;
setting.PreModel = PreModel;
setting.PreModelType = PreModelType;
Rstr = '';
if setting.UseRound
    if length(setting.KNNlatent) > 2 &&  setting.KNNlatent(2) ~= setting.UseRound
        Rstr = ['R', num2str(setting.UseRound)];
    end
end
setting.QualityResult = [setting.QualityResult, '_', Rstr];
setting.cresultsuffix1 = {};setting.cresultsuffix = {};setting.ccoverage = {};
    