% An example code for the algorithm proposed in
%
%   Min Tan, Baoyuan Wang, Zhaohui Wu, Jingdong Wang, Gang Pan.
%   "Weakly Supervised Metric Learning for Traffic Sign Recognition in a
%   LIDAR Equipped Vehicle", T-ITS, 2015

%
% Written by Min Tan @ 
% =========================================================================
function [CPCave, CRavg, Cranktime, PerThresh, modelresult, CAresult] = GetRecogRate_3(dataname, suffix, config_file, ...
    bookfeat, cmethod, knnpara, cpara, copyremove, issave, rawsize,sampling, ...
    pyramid, ncluster, normmerge, multiview, Rconfidence, config_DOG, ...
    config_WTA, WTAwithraw, Fpyramid, Ratio, RRatio, fast, config_latent, ...
    platent, confidence, svote, Crange, UseSplit, PCA, testSOutput, featPad, ...
    GBlimit, selfpaced, KNNlatent, SnippetRatio, FirstRound, Comverge, useall, APcompute, Fcompute, SetNormFea, ReCnew, coverage, patchsize)
global PATH_F;
addpath('Tool')
addpath('LDA');
addpath('sift');
addpath('libsvm-weights');
% addpath(genpath('DeepLearnToolbox-master'));
% addpath(genpath('cvx'));
addpath(genpath('litekmeans'))  
addpath(genpath('ksvdbox'));addpath(genpath('ompbox'));
addpath(genpath('vlfeat'));
cd vlfeat/toolbox
addpath(genpath('l1_ls_matlab'))
vl_setup
cd ..;
cd ..;
addpath(genpath('mnist-sphog'))
main
ReciprocalInter = [2, 4, 7, 8, 9, 10, 11,12,13,14,15,20,21];
if nargin < 1 dataname = 'Caltech101'; end
if nargin < 2 suffix = ''; end
if nargin < 3 config_file = 'llc_1'; end
if nargin < 4 bookfeat = {'sift'};  end
if nargin < 5
    cmethod = 'KNN'; 
    knnpara = 10;
end
minLEN = -1;
VirUse = 0;VirUsestr = '';VirUseNum = 0;Nmax = 5000;NmaxMLR = 36000;
PreModel = '';PreModelType = '';PreModel1 = '';
if iscell(suffix)
    if length(suffix) > 2 && ~isempty(suffix{3})
        VirUse = suffix{3}{1};
        VirUsestr = suffix{3}{2};
        try
            VirUseNum = suffix{3}{3};
            Nmax = suffix{3}{4};
            NmaxMLR = suffix{3}{5};
        end
    end
    if length(suffix) > 3
        if iscell(suffix{4})
            PreModel1 = suffix{4}{2};
            PreModel = suffix{4}{1};
            PreModelType = 0;
        else
            PreModel = suffix{4};
            PreModelType = 0;
        end
    end
    if length(suffix) > 4
        PreModelType = suffix{5};
    end
    
    minLEN = suffix{2};
    suffix = suffix{1};
end
KNNNUM = 0;KNNPad = 0;
KNNNUM1 = 0;KNNPad1 = 0;HandClass = 0;
if iscell(knnpara)
    cknnpara = knnpara;clear 'knnpara'
    t = 0;
    try
        knnpara(1) = str2num(cknnpara{1});
    catch
        HandStr = cknnpara{1}(end);
        if strcmp(HandStr, 'H')
            HandClass = 1;
            knnpara(1) = str2num(cknnpara{1}(1:end-1));
        else
            t = 1;
        end
    end
    if t == 1
        fprintf('Input Error\n');
        pause;
    end
    if length(cknnpara) > 1
        tt = str2num(cknnpara{2});
        if round(tt) ~= tt
            idx = strfind(cknnpara{2}, '.');
            KNNNUM = length(cknnpara{2}) - idx;
        end
        knnpara(2) = str2num(cknnpara{2});
        if round(tt) ~= tt
            KNNPad = idx+KNNNUM-length(num2str(knnpara(2)));
        end
    end
    if length(cknnpara) > 1
        tt = str2num(cknnpara{2});
        if round(tt) ~= tt
            idx = strfind(cknnpara{2}, '.');
            KNNNUM = length(cknnpara{2}) - idx;
        end
        knnpara(2) = str2num(cknnpara{2});
        if round(tt) ~= tt
            KNNPad = idx+KNNNUM-length(num2str(knnpara(2)));
        end
    end
    if length(cknnpara) > 2
        tt = str2num(cknnpara{3});
        if round(tt) ~= tt
            idx = strfind(cknnpara{3}, '.');
            KNNNUM1 = length(cknnpara{3}) - idx;
        end
        knnpara(3) = str2num(cknnpara{3});
        if round(tt) ~= tt
            KNNPad1 = idx+KNNNUM1-length(num2str(knnpara(3)));
        end
        
    end
end
if length(knnpara) >1 && ~nnz(knnpara(2:end))
    knnpara = knnpara(1);
end

if nargin < 7  cpara = []; end
if nargin < 8 copyremove = 1;   end
if nargin < 9 issave = 0;     end
if nargin < 10  rawsize = [90, 75];   end
if nargin < 42  SetNormFea = 0;  end
if nargin < 43  ReCnew = 0;  end
if nargin < 44  coverage = [];  end

if nargin < 45
    changesize = 0;
    patchsize = 16;     
else
    changesize = 1;
end

precom = 0;ffdir = '';ffdir2 = '';lname = 0;
if iscell(config_file)
    precom = 1;
    ffdir = config_file{3};lname = config_file{4};
    if length(config_file) > 4
        ffdir2 = config_file{5};
    else
        ffdir2 = ffdir;
    end
    config_file = config_file{1};
end
setting = getconfig(config_file, bookfeat);
setting.WKNN = 0;
if knnpara < 0
    setting.WKNN = 1;  
end
knnpara = abs(knnpara);
setting.ReCnew = ReCnew;
setting.precom = precom;setting.lname = lname;
setting.ffdir = ffdir;setting.ffdir2 = ffdir2;

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

setting.rescale = 0;

setting.config_DOG = config_DOG;
setting.MultiFold = 0;
setting.WeightUpC = 0;
if iscell(multiview)
    setting.testmultiview = multiview{2};
    multiview = multiview{1};
else
    setting.testmultiview = multiview;
end
setting.WeightUpC = 0;
if round(multiview) ~= multiview
%     setting.MultiFold = 1;
    multiview = floor(multiview);
    setting.WeightUpC = 1;
end
setting.multiview =multiview;
pwd = cd;
fn = [pwd '/setting/',config_DOG,'.m'];
if exist(fn)  %%%modify feature type
    cwd = pwd;cd([pwd '/setting/']);
    eval(config_DOG);cd(cwd);
    setting.DoG = 1;
end
setting.config_WTA = config_WTA;

pwd = cd;
fn = [pwd '/setting/',config_WTA,'.m'];
if exist(fn)  %%%modify feature type
    cwd = pwd;cd([pwd '/setting/']);
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

setting.bestS = 0;
pwd = cd;
fn = [pwd '/setting/',config_latent,'.m'];
if exist(fn)  %%%modify feature type
    setting.displace = 0; setting.rotate = 0;
    cwd = pwd; cd([pwd '/setting/']);
    eval(config_latent); cd(cwd);
    setting.latent = 1; setting.config_latent = config_latent;  
    

    if nargin < 25    %%%for WTA
        setting.platent = 0;
    else
        setting.platent = platent;
    end
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

if nargin < 26    %%%for WTA
    setting.confidence = 0;
else
    setting.confidence = mod(confidence, 10);  
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
setting.HandClass = HandClass;

if nargin < 29  %%%for WTA
    UseSplit = 0;
    Nfold = 5;
else
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

if nargin < 32  %%%for WTA
    setting.featPad = 0;
else
    setting.featPad = featPad;
end

if nargin < 33  %%%for WTA
    setting.GBlimit = 4;
else
    setting.GBlimit = GBlimit;
end
setting.Ninit = 0;
if iscell(selfpaced)
%     PreModel = '';PreModelType = '';
    setting.Ninit = selfpaced{2};
    selfpaced = selfpaced{1};
end
if nargin < 34  %%%for WTA
    setting.selfpaced = 0;
else
    setting.selfpaced = selfpaced;
%     setting.selfpaced = [0, 1, 1.3];
end

setting.UseRound = 0;
setting.KNNlatentTrain = 0;
if nargin < 35  %%%for WTA
    setting.KNNlatent = 1;
else
    if length(KNNlatent) > 2 && round(KNNlatent(2)) ~= KNNlatent(2)
        setting.UseRound = round(10*(KNNlatent(2) - floor(KNNlatent(2))));
        KNNlatent(2) = floor(KNNlatent(2));
    end
    

    setting.KNNlatent = KNNlatent;
    if length(KNNlatent) > 1 && KNNlatent(2) == 1
        setting.KNNlatentTrain = 1;
    end
end


setting.isSnippetRatio = 0;
if nargin < 36
    setting.SnippetRatio = {1};
    
else
    setting.SnippetRatio = SnippetRatio;
    if setting.SnippetRatio{1}~= 1
        setting.isSnippetRatio = 1;
    end
end
GroupR = 0;
if nargin < 37
    setting.FirstRound = 0;
else
    if round(FirstRound) ~= FirstRound
        GroupR = FirstRound - floor(FirstRound);
        FirstRound = floor(FirstRound);
    end
    
    setting.FirstRound = FirstRound;
end
if nargin < 38
    setting.Comverge = 0;
else
    setting.Comverge = Comverge;
end
if nargin < 39
    setting.useall = -1;
    setting.TSREMPTY = 0;
else
    setting.TSREMPTY = floor(useall/ 10);
    setting.useall = mod(useall, 10);
end

setting.isKNNlatent = 0;
if setting.KNNlatent(1) ~= 1
    setting.isKNNlatent = 1;
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
    % directory for the image database     
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
    getfeastr(fea_dir, setting);  %%%get filenames

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
    if setting.splitPCA   pcastr = [pcastr, 'M'];   end
    if ~isempty(setting.AidConf)  pcastr = [pcastr, 'A', getparastr(setting.AidConf)];  end
    if setting.LocalPCA   pcastr = [pcastr, '_L'];  end
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
for i = 2:length(knnpara)  %%expired
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


nameimresult = [imRes_dir Mfeastr '_' cmethod getparastr(knnpara)];
setting.confidenceF = ['Confidence/' dataname '/' setting.Mfeastr2 '_' cmethod getparastr(knnpara)];
setting.latentresult = ['latent/' dataname '/' setting.Mfeastr1 '_' cmethod];
setting.Modelresult = ['SVMModel/' dataname '/' setting.Modelfeastr '_' cmethod]; 



setting.ModelresultO = setting.Modelresult;
nameresulttmp = nameresult; 
suffix = '';setting.Usetemplate = 1;
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
%         setting.ModelresultO = [setting.ModelresultO suffixx];
        setting.Modelfeastr = [setting.Modelfeastr suffixx];
        nameresult = [nameresult suffixx];
        
        
        nameresulttmp = [nameresulttmp suffixx]; 
        nameimresult = [nameimresult suffixx];
    end
end
end


if (isdir(img_dir))
    [pathstr1, name1, ext] = fileparts(img_dir);
    name1 = [name1, ext];
else
    [pathstr1, name1] = fileparts(img_dir);
end
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

if setting.WTA
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

setting.Metric = [];
Error = 0;
hassaved = 0;
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

if setting.SnippetRatio{1} ~= 1
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


if setting.Comverge
    ss =['Cov', num2str(setting.Comverge)];
    nameimresult = [nameimresult ss];
    nameresult = [nameresult ss];
    setting.QualityResult = [setting.QualityResult ss];
    setting.latentresult = [setting.latentresult ss];
    setting.Modelresult = [setting.Modelresult ss]; 
    
    
end


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
%         setting.Modelresult = [setting.Modelresult, 'TE'];
%         setting.QualityResult = [setting.QualityResult, 'TE'];
%         setting.latentresult = [setting.latentresult, 'TE']; 
    end
end
% % if exist(nameresult)
% %     mkdir([nameresult, '_New'])
% %     movefile(nameresult, [nameresult, '_New'])
% %     mkdir([nameresult])
% % end
        
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


if nargin < 40
    APcompute = 0;
end

if nargin < 41
    setting.Fcompute = 1;
else
    setting.Fcompute = Fcompute;
end


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
% [setting.multiview, setting.WeightUpC, setting.confidence]
% pause
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

nameresult
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
    

for jj = 1:length(Cov_str)
    if jj == 1
        setting.ccoverage{1} = coverage(1);
    else
        
        for tt = 2:length(Cov_str)
        setting.cresultsuffix1{tt -1} = [Oresultsuffix1, Cov_str{tt}, Rstr];
        setting.cresultsuffix{tt -1} = [Oresultsuffix, Cov_str{tt}, Rstr];
        setting.ccoverage{tt -1} = coverage(tt);
        end
    end
    setting.resultsuffix1 = [Oresultsuffix1, Cov_str{jj}, Rstr];
    setting.resultsuffix = [Oresultsuffix, Cov_str{jj}, Rstr];
    setting.coverage = coverage(jj);
% %     if setting.UseRound
% %         setting.resultsuffix1 = [setting.resultsuffix1, 'R', num2str(setting.UseRound)];
% %         setting.resultsuffix = [setting.resultsuffix, 'R', num2str(setting.UseRound)];
% %     end
% % % % % if setting.useall
% % % % %     try
% % % % %         rmdir(nameresult, 's')  
% % % % %     end
% % % % %     try
% % % % %     rmdir(setting.Modelresult, 's')  
% % % % %     end;
% % % % % end
% % %     try
% % %         newN = nameresult;
% % %         index = findstr(newN, 'Cov1FN');
% % %         orgN = [newN(1:index(1)-3), newN(index(1):end)];
% % %         if ~exist(newN)
% % %             mkdir(newN)
% % %         end
% % %         copyfile(orgN, newN);
% % %         rmdir(orgN, 's')  
% % %     end
% % %     try
% % %         newN = setting.Modelresult;
% % %         index = findstr(newN, 'Cov1FN');
% % %         orgN = [newN(1:index(1)-3), newN(index(1):end)];
% % %         if ~exist(newN)
% % %             mkdir(newN)
% % %         end
% % %         copyfile(orgN, newN);
% % %         rmdir(orgN, 's') 
% % %     end;
% % % 
% % % CPCave = 0;
% % % CRavg = 0;Cranktime = 0;PerThresh = 0; modelresult = 0; CAresult = 0;
% % % return;

% COPYNEW(nameresult, PATH_F);
% COPYNEW(setting.Modelresult, PATH_F);
% COPYNEW(setting.QualityResult, PATH_F);

try
%     if ~isempty(setting.PreModel) && setting.PreModelType == 0
%         1/rand([1, 4])
%     end  
    if setting.recompute
        load([nameresult 'TTM.mat'], 'PCave', 'Ravg', 'ranktime');
    else
        
    if setting.FirstRound
        if setting.Usesubset
            accFF = zeros(length(setting.NgroupR), setting.Nclass);
            ranktimeFF = zeros(length(setting.NgroupR), 1);
            tt = 0;
            for ii = setting.NgroupR
                tt = tt + 1;
                Mstr = ['Round' num2str(Nfold) '_' num2str(setting.FirstRound(1)) REstr 'G' num2str(setting.Ngroup) '_' num2str(ii) suffixstr '.mat'];
                if APcompute
                    load(fullfile(nameresult,['Result' setting.resultsuffix1 '-', Mstr]), 'accF', 'ranktimeF'); 
                else
                    load(fullfile(nameresult,['Result' setting.resultsuffix '-', Mstr]), 'accF', 'ranktimeF');
                end
                accFF(tt, :) = accF;   ranktimeFF(tt) = ranktimeF;
            end
            accF = tmean(accFF, 1);ranktimeF = mean(ranktimeFF);
            raccF = (mean(accFF, 2))';
        else
            if setting.TestOneR
                try
                    load(fullfile(setting.Modelresult, ['Metric_',num2str(setting.TestR),'Round' num2str(Nfold) '_' num2str(setting.FirstRound(1))...
                        suffixstr '.mat']) ,'Metric');
                    Mexist = 1;
                catch
                    Mexist = 0;
                end
                if Mexist
                    if APcompute
                        load(fullfile(nameresult,['Result' setting.resultsuffix1 '-' 'Round' num2str(Nfold) '_' num2str(setting.FirstRound(1))...
                            suffixstr REstr '.mat']), 'accF', 'ranktimeF'); 
                    else
                        load(fullfile(nameresult,['Result' setting.resultsuffix '-' 'Round' num2str(Nfold) '_' num2str(setting.FirstRound(1))...
                            suffixstr REstr '.mat']), 'accF', 'ranktimeF'); 
                    end
                    
                else
                    accF = -1*ones([Nclass,1]);ranktimeF = 0;
                end
            else
                if APcompute
                    load(fullfile(nameresult,['Result' setting.resultsuffix1 '-' 'Round' num2str(Nfold) '_' num2str(setting.FirstRound(1))...
                        REstr '.mat']), 'accF', 'ranktimeF'); 
                else
                    load(fullfile(nameresult,['Result' setting.resultsuffix '-' 'Round' num2str(Nfold) '_' num2str(setting.FirstRound(1))...
                        REstr '.mat']), 'accF', 'ranktimeF'); 
                end
            end
            raccF = tmean(accF)*ones(1, length(setting.NgroupR));
        end
        
        Ravg = mean(accF);
        PCave = accF;ranktime = ranktimeF;
    else
        accA = -10;   
        if setting.Ngroup == 1
            accFF = zeros(Nfold, setting.Nclass);
            ranktimeFF = zeros(Nfold, 1);
            for ii = 1:Nfold
                Mstr = ['Round' num2str(Nfold) '_' num2str(ii) suffixstr REstr '.mat'];
                if APcompute
                    load(fullfile(nameresult,['Result' setting.resultsuffix1 '-', Mstr]), 'accF', 'ranktimeF'); 
                else
                    load(fullfile(nameresult,['Result' setting.resultsuffix '-', Mstr]), 'accF', 'ranktimeF');
                end
                accFF(ii, :) = accF;
                ranktimeFF(ii) = ranktimeF;
            end
            raccF = (mean(accFF, 2))';
            accF = tmean(accFF, 1);accA = mean(accF);
            ranktimeF = tmean(ranktimeFF, 1);ranktime = mean(ranktimeF);
        end
        if APcompute
            load([nameresult 'acc' setting.resultsuffix1], 'PCaveI', 'RavgI', 'ranktime');
            PCave = PCaveI;Ravg = RavgI;ranktime = ranktime;
        else
            load([nameresult 'acc' setting.resultsuffix], 'PCave', 'Ravg', 'ranktime');
        end
        if  accA ~= -10
            if abs(accA -   Ravg) / abs(Ravg) > 0.001
                1/rand(1, 4)
            end
        end
    end
    if issave
        load([nameimresult 'issave'], 'issave');
    end
    
    end
    if Ravg <= 0 || ranktime == 0
        1/rand(1,4)
    end
%     if strcmp(cmethod, 'MultiSVM')
%         Mstr = [num2str(mod(setting.platent, 2)), '_', num2str(1), '_', num2str(1), '.mat'];
%         if cpara(1) == -1
%             load(fullfile(setting.Modelresult,['Validate', Mstr]),'cbest', 'dbest', 'gbest', 'rbest', 'Vpara');  
%             bestPara = [cbest, dbest, gbest, rbest, max(Vpara(:,end))];
%         end
%         load(fullfile(setting.Modelresult,['TrainError', Mstr]), 'a', 'C');
%         ranktime = a(1);
%     end
catch
% %     PCave = zeros([Nclass,1]);ranktime = 0;Ravg = 0;ranktime = 0;  raccF  = zeros(setting.Ngroup, 1);
        if ~exist(nameresult) 
            try
                mkdir(nameresult); 
            end
        end
        % if ~exist(nameresulttmp)  mkdir(nameresulttmp);  end
        if ~exist(nameimresult) && issave mkdir(nameimresult);  end
        if issave
        if ~exist([nameimresult 'True/'])
            mkdir([nameimresult 'True/']);
        end
        if ~exist([nameimresult 'False/'])
            mkdir([nameimresult 'False/']);
        end
    end
    setting.cmethod = cmethod;
    
    
    setting_Vir = setting;
    [fdatabase, database, dfea, WTAfea,setting] = computeFeature(img_dir1, img_dir, dataname, ...
        mfea_dir, mfea_dir_WTA, setting, copyremove, feattype, suffix, knnpara);
    if setting.VirUse
        smfea_dir = mfea_dir;smfea_dir_WTA = mfea_dir_WTA;
        for kk = 1:length(setting.feattype)
            [a,b,c] = fileparts(mfea_dir{kk}{1});
            smfea_dir{kk}{1} = fullfile([a, setting.VirUsestr], [b,c]);
            [a,b,c] = fileparts(mfea_dir_WTA{kk}{1});
            smfea_dir_WTA{kk}{1} = fullfile([a, setting.VirUsestr], [b,c]);
        end
        setting.featNround = computeFeature_D(img_dir1, {[img_dir, setting.VirUsestr], [img_dir, '_N1', setting.VirUsestr],...
            database.cname, setting.cindex, setting.tr_idx, setting.ts_idx, database.path(setting.tr_idx), ...
            database.path(setting.ts_idx)}, [dataname, setting.VirUsestr], ...
            smfea_dir, smfea_dir_WTA, setting_Vir, copyremove, feattype, suffix, knnpara);
        clear 'smfea_dir_WTA'
        clear 'smfea_dir'
        clear 'setting_Vir'
        [a, b] = fileparts(img_dir);
        setting.TFstrVir = fullfile('TrainInfo', [a, '_', b, setting.VirUsestr, '_0']);
    end 
    clear 'setting_Vir'
    
    confidencestr = setting.confidence;
    [setting.Idx_fold, c, b] = unique(setting.ts_fold_idx);
    setting.Label_fold = setting.ts_Fold_label(setting.Idx_fold);
    cindex = unique(setting.Label_fold);
    if multiview
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
    end
    TNfold = Nfold;
    if setting.FirstRound
        if TNfold > 1
            setting.SaveRes = 0;
        end
        TNfold = 1;
    end
    racc = zeros(TNfold, setting.Nclass);
    raccI = zeros(TNfold, 1);
    rranktime = zeros(TNfold, 1); 
    imAP = 0;
    for Kround = 1:TNfold
        
        curround = TestRound(Kround);
        rracc = zeros(length(setting.NgroupR), setting.Nclass);
        raccII = zeros(length(setting.NgroupR), 1);
        rrranktime = zeros(length(setting.NgroupR), 1);   
        tt = 0;
        for jjj = (setting.NgroupR)
            tt = tt + 1;
            fprintf('curround: %d, %d, Group: %d, %d\n', curround, Nfold, jjj, setting.Ngroup)
            if setting.Usesubset && setting.Nclass ~= length(cindex)
                setting.labelmap = setting.RClass(jjj, :);
            end
            setting.curgroup = jjj;
            setting.Cov_strindex = jj;
            [tmp, C, rrranktime(tt,:)] = GetRoundAccuracy(issave, curround, Nfold, setting,img_dir1, dfea, ...
                WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, nameresult, ...
                nameimresult,normmerge, multiview, latentresult1);
            
            if tmp(end) == -inf
                imAP = 1;
                raccII(tt) = tmp(end-1);
                rracc(tt,:) = tmp(1:end-2);
            else
                rracc(tt,:) = tmp;
            end
            
        end
        raccF(Kround,:) = (mean(rracc, 2))';
        rranktime(Kround) = mean(rrranktime);
        racc(Kround,:) = tmean(rracc, 1);
        raccI(Kround) = tmean(raccII);
    end
    acc = tmean(racc, 1);ranktime = tmean(rranktime);
    
    raccF = tmean(raccF, 1);
    PCave = acc;Ravg = mean(acc);
    fprintf('===============================================');
    fprintf('Average classification accuracy: %f\n', Ravg);
    fprintf('===============================================');
    if unique(acc) == -1
        Error = 1;
    end
    if issave && ~Error && setting.SaveRes
        save([nameimresult 'issave.mat'], 'issave');
    end
    PCaveI = 0;RavgI = tmean(raccI);
    if imAP && ~APcompute
        imAP = 0;
    end
    if ~Error && setting.SaveRes
        if imAP
            save([nameresult 'acc' setting.resultsuffix '_I.mat'], 'PCaveI', 'RavgI', 'ranktime');
        end
        save([nameresult 'acc' setting.resultsuffix '.mat'], 'PCave', 'Ravg', 'ranktime');
    end
    if imAP
        PCave = PCaveI;Ravg = RavgI;
    end
%     if strcmp(cmethod, 'MultiSVM')
%         Mstr = [num2str(mod(setting.platent, 2)), '_', num2str(1), '_', num2str(1), '.mat'];
%         if cpara(1) == -1
%             load(fullfile(setting.Modelresult,['Validate', Mstr]),'cbest', 'dbest', 'gbest', 'rbest', 'Vpara');  
%             bestPara = [cbest, dbest, gbest, rbest, max(Vpara(:,end))];
%         end
%         load(fullfile(setting.Modelresult,['TrainError', Mstr]), 'a', 'C');
%         ranktime = a(1);
%     end
end
PCave = PCave';
PCave = reshape(PCave,1, []);
CPCave{jj} = PCave*100;
CRavg{jj} = Ravg*100;
Cranktime{jj} = mean(ranktime);
CAresult{jj} = raccF*100;
end
CPCave = cell2mat(CPCave);
CRavg = cell2mat(CRavg);
Cranktime = cell2mat(Cranktime);
CAresult = cell2mat(CAresult);
modelresult = setting.Modelresult;PerThresh =  0;



function COPYNEW(M1, PATH_F)
M1_N = fullfile(PATH_F, [M1]);
% M1_N = fullfile(PATH_F, ['N_', M1]);
if ~ISEMPTYPATH(M1)
    mkdir(M1_N);
    try copyfile(fullfile(PATH_F, M1), M1_N); end
else
    idx = union(findstr(M1, '/'),findstr(M1, '/'));
    idx = idx(1);M1 = [M1(1:idx-1), '_ALL', M1(idx:end)];
    if ~ISEMPTYPATH(M1)
    mkdir(M1_N);
    copyfile(fullfile(PATH_F, M1), M1_N);
    end
end