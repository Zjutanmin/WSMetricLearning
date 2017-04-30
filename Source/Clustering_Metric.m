function Clustering_Metric(dataname, suffix, method, NFold, Round, Kinit, testset)
% Clustering_Metric('TSR', '_GTSRB', 'MLR','1', '1','43')
% Clustering_Metric('TSR', '_GTSRB', 'MLR-W','1', '1','43')
% Clustering_Metric('Sign', '_NewT5', 'MLR','3', '1','52')
% Clustering_Metric('Sign', '_NewT5', 'MLR-W','3', '1','52')


% Clustering('TSR', '_GTSRB', '43', 'MLR', '2048', '1', '0', '1', '1', '0', '50')
% Clustering('TSR', '_GTSRB', '43', 'MLR-W', '2048', '1', '0', '1', '1', '0', '50')
% Clustering('TSR', '_GTSRB', '43', 'MLR', '2048', '1', '0', '1', '1', '0', '100')
% Clustering('TSR', '_GTSRB', '43', 'MLR-W', '2048', '1', '0', '1', '1', '0', '100')
%INPUT
% dataname    :  dataset name
% suffix      :  version name for dataset
%             :  e.g. "Sign_NewT5" denotes "Sign" dataset with version "_NewT5"
% Nclass      :  number of categories for the dataset
% method      :  classification method. Currently, it support 'INNC'. 'KNN', 'MLR', 'MLR-W', 'MLR(I)', 'MLR-W(I)'. Default = "MLR" (metric learning)
% C           :  Balance parameter C for MLR. Default = 512. 
%             :  For INNC, C = [lambda, K, blocksize,verbose, beta]. If [K, blocksize,verbose,beta) are not defined, then they are depended on lambda (refer to INNC.m)
% multiview   :  0/1, multi-view input mode, default = 1 (For Germany benchmark is 0)
% NFold       :  NFold for training / testing split. Default = 3. 
% Round       :  Evaluating split (For N-folder setting, otherwise is 1). Default = 1
% evaltype    :  Training and evaluation mode. Default = 0
% isappend    :  Append the classification result or re-create a new one if there exits the file for saving the testresult
addpath(('Tool'))
% addpath(('LDA'));
addpath(('mlr'));
% addpath(('setting'));
addpath(('libsvm-weights')); 
addpath(genpath('vlfeat'));
cd vlfeat/toolbox
vl_setup
cd ..;
cd ..;

ReciprocalInter = [2, 4, 7, 8, 9, 10, 11,12,13,14,15,20,21];
if nargin < 1  dataname = 'Sign'; end
if nargin < 2  suffix = '_NewT5';end                     
 
if nargin < 3  method = 'MLR'; end    
if nargin < 4  NFold = '3';end  
if nargin < 5  Round = '1';end      
if nargin < 6 Kinit = 50;end  


C = -1;knnpara = 1;
NFold = str2num(NFold); Round = str2num(Round);evaltype= 0;Kinit= str2num(Kinit);

if NFold > 1
    UseSplit = NFold + 0.5;
else
    UseSplit = NFold;
end
KNNNUM = 0;KNNPad = 0;
KNNNUM1 = 0;KNNPad1 = 0;HandClass = 0;

[cmethod, cpara, KNNround, SnippetRatio] = getMConfig(method, C);


% % % [KMean, Label, filename] =  cluster(setting, ts_idx, feattype)



switch dataname
    case 'Sign'
        config_file = 'cHoG_1_color24_0';
        APcompute = 0;
        rawsize = [90, 75];
        PCA = 0.95;
        multiview = 3;
        Nclass = 52;
    case 'TSR'
        config_file = 'HOG_02';
        APcompute = 1;
        rawsize = [40, 40];
        PCA = {0.95 'LDA'};
        multiview = 0;
        Nclass = 43;
    otherwise
        fprintf('A non existing assignment dataname \n:%s\n', dataname)
        pause;
        return;
end
fprintf('The selected configuration filename is :%s\n', config_file)
fprintf('The normlized image size is :[%d, %d]\n',rawsize(1), rawsize(2));
bookfeat = {'sift'}; 
changesize = 0;patchsize = 16; precom = 0;ffdir = '';ffdir2 = '';lname = 0;
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
setting.precom = precom;setting.lname = lname;
setting.ffdir = ffdir;setting.ffdir2 = ffdir2;
setting.sampling = -1; setting.pyramid = [4,8,16];
setting.ncluster = 100;normmerge = 1;

Rconfidence = 0;
if multiview
    multiview = 3;Rconfidence = 0.5;
end
ShowExist = 0;
setting.Rconfidence = Rconfidence;setting.ShowExist = ShowExist;

config_DOG = 'DOG_2';
setting.WTA = 0;config_WTA = '';
setting.rescale = 0;
setting.config_DOG = config_DOG;
setting.multiview =multiview;

    setting.sigma1 = 2;
    setting.sigma2 = 5;
    setting.hsize = 9;
    setting.DoG = 1;

setting.config_WTA = config_WTA;
setting.WTA = 0; setting.WTAwithraw = 0;

Fpyramid = 8;setting.Fpyramid = Fpyramid;

setting.Ratio = 0;
setting.fast = 1;
setting.latent = 0;
config_latent = '';
setting.bestS = 0;
platent = 0;

    setting.config_latent = '';
    if mod(platent, 10) ~= 5
        setting.latent = 0;
        setting.platent = 0;
    else
        setting.latent = platent;
        setting.platent = platent;
        setting.bestS = 1;
    end

confidence = 2;
try SnippetRatio{2};
    if SnippetRatio{1} ~= 1
        confidence = 4;
    end
end
setting.confidence = confidence;

setting.svote = [];
setting.Crange= [-5,3];

setting.HandClass = HandClass;

    if round(UseSplit) ~= UseSplit
       UseSplit = -UseSplit;
    end
    if UseSplit < 0
        setting.SplitRatio = -(UseSplit + floor(abs(UseSplit)));
        UseSplit = -floor(abs(UseSplit));
    else
        setting.SplitRatio = UseSplit - floor(abs(UseSplit));
        UseSplit = floor(abs(UseSplit));
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

setting.PCA = PCA;              

setting.testSOutput = 0;
setting.featPad = 0;setting.GBlimit = 20;
setting.KNNlatentTrain = 0;

setting.preDef = 1;

    if KNNround~=1
    KNNlatent = [1,KNNround,1,0,1];
    else
        KNNlatent = KNNround;
    end
    setting.KNNlatent = KNNlatent;
    KNNlatent= setting.KNNlatent;
    if length(KNNlatent) > 1 && KNNlatent(2) == 1
        setting.KNNlatentTrain = 1;
    end

setting.isSnippetRatio = 0;
    setting.SnippetRatio = SnippetRatio;
    if setting.SnippetRatio{1}~= 1
        setting.isSnippetRatio = 1;
    end
setting.selfpaced = 0;setting.Comverge = 0;
if setting.SnippetRatio{1} ~= 1
    setting.selfpaced = 1;setting.Comverge = 1;
end

    setting.FirstRound = Round;
useall = 0;setting.useall = useall;

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
setting.isretrain = 0;
setting.rawsize = rawsize;
dataname1 = dataname;
setting.NeedHoG = 0;
% addpath('Liblinear/matlab');        % we use Liblinear package, you need 
% addpath('Libsvm/matlab');        % we use Liblinear package, you need 
addpath(genpath('mlr/'));
if ~strcmp(dataname, 'Caltech101')
    dataname = [dataname suffix];       % directory for the image database     
end
img_dir1 = ['image/' dataname1];       % directory for the image database  
feattype = setting.feattype;
img_dir = ['image/' dataname];       % directory for the image database     
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
setting.cmethod = cmethod;
setting.splitPCA = 0;
setting.AidConf = [];
setting.PCAMethod = 'PCA';
setting.LocalPCA = 0;
if iscell(setting.PCA)
    if iscell(setting.PCA)
        setting.PCAO = setting.PCA;
        setting.PCAMethod = setting.PCA{2};
        switch setting.PCAMethod
            case 'SAE'
                setting.PCAdef = {'Def' 'Def' 'sigm' 1 0.5 1 1000 0.05 0 0.5 1 8000};
                try setting.PCA{3}; catch setting.PCA{3} = setting.PCAdef{3}; end
                try setting.PCA{4}; catch setting.PCA{4} = setting.PCAdef{4}; end
                try setting.PCA{5}; catch setting.PCA{5} = setting.PCAdef{5}; end
                try setting.PCA{6}; catch setting.PCA{6} = setting.PCAdef{6}; end
                try setting.PCA{7}; catch setting.PCA{7} = setting.PCAdef{7}; end
                
                try setting.PCA{8}; catch setting.PCA{8} = setting.PCAdef{8}; end
                try setting.PCA{9}; catch setting.PCA{9} = setting.PCAdef{9}; end
                try setting.PCA{10}; catch setting.PCA{10} = setting.PCAdef{10}; end
                try setting.PCA{11}; catch setting.PCA{11} = setting.PCAdef{11}; end
                try setting.PCA{12}; catch setting.PCA{12} = setting.PCAdef{12}; end
            case 'PCA'
                setting.PCA = setting.PCA{1};
            case 'LDA'
                setting.PCA{1} = 1;setting.PCAO{1}= 1;
                setting.PCA = [setting.PCA, {1, 1}];setting.PCAO = setting.PCA;
                setting.PCAdef = {'Def' 'Def' 1 1};
                try setting.PCA{3}; catch setting.PCA{3} = setting.PCAdef{3}; end
                try setting.PCA{4}; catch setting.PCA{4} = setting.PCAdef{4}; end
        end
    end
end



% % if isfield(setting, 'ts_idx_conf') && ~isempty(setting.ts_idx_conf)
% %     Range = setting.ts_idx_conf;
% % else
% %     Range = [1:length(ts_idx)];
% % end
% % Samplevoted = setting.Samplevoted;
% % Samplevoted = Samplevoted(Range);
% % if setting.Tclassfy && setting.confidence
% %     Samplevoted(:) = 1;
% % end
% % TFstr = setting.TFstr;       
% % data_feaA = [];
% % for jj = 1:length(feattype)
% %     load([TFstr, '_', setting.feaname{jj}, '_data.mat'], 'data_fea', 'data_label')
% %     data_feaA = [data_feaA, myNormlize(data_fea, setting.NormFea, ...
% %         length(feattype))];
% % end  
% % data_fea = data_feaA;clear 'data_feaA'
% % load([TFstr, '_info_data.mat'], 'data_imsize', 'data_imname')
% % data_label = data_label(:);
% % data_imname = data_imname(:);
% % curr_idx = ts_idx; 
% % curr_ts_label = data_label(curr_idx);        
% % curr_ts_fea = data_fea(curr_idx,:);
% % curr_ts_imname = data_imname(curr_idx);
% % setting.NormFea1 = {[], 1};
% % setting.FeatConf = setdiff([1:length(feattype)], setting.AidConf);
% % if setting.PCAenergy   %%%PCA for training data
% %     curr_ts_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, ...
% %         setting.LocalPCA, setting.NormFea, setting.NormFea1, ...
% %         [curr_ts_fea, curr_ts_label], setting.PCACOEFF, setting.FeatConf);    
% % end
% % idx = find(Samplevoted);
% % filename = curr_ts_imname(idx);
% % Metric = setting.Metric{2};
% % if ~isempty(Metric)
% %     [vecs,vals] = eig(0.5 * (Metric + Metric'));
% %     L = real(abs(vals)).^0.5 * vecs';
% %     curr_ts_fea = L*curr_ts_fea';
% % else
% %     curr_ts_fea = curr_ts_fea';
% % end
% % [KMean, Label] = vl_kmeans(curr_ts_fea, setting.K)



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
setting.kparastr = '';
for i = 2:length(knnpara)
    if i == 3
        ss = ['-' num2str(knnpara(i)) repmat('0', [1, KNNPad1])];
        setting.Randclassstr = [ss];
        kpara = [kpara ss];
    end
    if i == 2
        ss = ['-' num2str(knnpara(i)) repmat('0', [1, KNNPad])];
        setting.kparastr = [setting.kparastr ss];
        setting.Randclassstr = [ss];
        kpara = [kpara ss];
    end
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
setting.MetricL2 = 0;setting.TemplateINNC = 0;setting.TemplateUp = 0;setting.MeanNum = 0;
switch cmethod
    case 'INNC'
        useallT = 0;
        setting.latentresult = [setting.latentresult '-' num2str(mod(setting.platent, 2))];
        setting.Modelresult = [setting.Modelresult '-' num2str(mod(setting.platent, 2))];
        suffix = getparastr(cpara);
        if length(knnpara) > 1
            suffix = [suffix setting.kparastr];
        end
    case 'ML'
        useallT = 0;
        setting.latentresult = [setting.latentresult '-' num2str(mod(setting.platent, 2))];
        setting.Modelresult = [setting.Modelresult '-' num2str(mod(setting.platent, 2))];
        suffix = getparastr(cpara);
    case 'lmnn'
        useallT = 1;
        setting.latentresult = [setting.latentresult '-' num2str(mod(setting.platent, 2))];
        setting.Modelresult = [setting.Modelresult '-' num2str(mod(setting.platent, 2))];
        suffix = getparastr(cpara);
        if length(knnpara) > 1
            suffix = [suffix setting.kparastr];
        end 
    case 'gblmnn'
        useallT = 1;
        setting.latentresult = [setting.latentresult '-' num2str(mod(setting.platent, 2))];
        setting.Modelresult = [setting.Modelresult '-' num2str(mod(setting.platent, 2))];
        setting.lmnnsuffix2 = getparastr(cpara(1:end-1));
        suffix = getparastr(cpara);setting.lmnnsuffix1 = suffix;
        if length(knnpara) > 1
            suffix = [suffix setting.kparastr];
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
        if length(knnpara) > 1
            suffix = [suffix setting.kparastr];
        end
    case 'MLR'
        useallT = 0;
        [setting, suffix, cpara] = getsettingMLR(setting, cpara, knnpara);
    case 'RMLR'
        useallT = 0;
        [setting, suffix, cpara] = getsettingMLR(setting, cpara, knnpara);
    case 'CNN'
        useallT = 1;
end
setting.latentresult = [setting.latentresult suffix];
setting.Modelresult = [setting.Modelresult suffix];
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

latentresult1 = setting.latentresult;
if multiview
    nameresult = [nameresult '_MV' num2str(multiview)];nameresulttmp = [nameresulttmp  '_MV' num2str(multiview)];
    nameimresult = [nameimresult '_MV' num2str(multiview)];
    setting.latentresult = [setting.latentresult '_MV' num2str(multiview)];
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
setting.samesplit = 'Sign_NewT3';

[pathstr1, name1] = fileparts(img_dir);
if nargin < 3
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
end
setting.isweightNorm = 0;
if strcmp(name1, 'TSR_GTSRB')
    Nclass = 43;
    setting.isweightNorm = 1;
end
NclassO = Nclass;
setting.UsePos = 0;setting.TrainError = 0;setting.recompute = 0;
setting.testonly = 0;
setting.resultsuffix = '';
suffixidx1 = length(setting.resultsuffix);
switch evaltype
    case -1
        setting.TrainError = 1;
        setting.resultsuffix = '_T';
        setting.latentresult = [setting.latentresult setting.resultsuffix];
        evaltype = 0;
    case 2
        setting.resultsuffix = '_SRB';
        evaltype = 0;
        setting.UsePos = 1;
    case 3
        setting.recompute = 1;
        evaltype = 0;
    case -2
        setting.testonly = 1;
        setting.resultsuffix = '_TO';
        setting.latentresult = [setting.latentresult setting.resultsuffix];
        evaltype = 0;
end
suffixidx2 = length(setting.resultsuffix);
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
% setting.selfpaced = 0;setting.Comverge = 0;
if setting.SnippetRatio{1} ~= 1
%     setting.selfpaced = 1;setting.Comverge = 1;
    setting.SnippetRatio = [setting.SnippetRatio,{22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'}]; 
    if length(setting.SnippetRatio) < 2
        if setting.SnippetRatio{1} == -1
            setting.SnippetRatio{2} = 0.9;
        else
            setting.SnippetRatio{2} = 0;
        end
    end
    if length(setting.SnippetRatio) < 3
        setting.SnippetRatio{3} = 1;
    else
        setting.SnippetRatio{3} = setting.SnippetRatio{3};
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
    ss = ['-' num2str(knnpara(i)) repmat('0', [1, KNNPad1])];
    setting.Randclassstr = [ss];
    setting.ReQuality = 1;
    setting.QualityResult = [setting.QualityResult 'E' ss];
end

setting.Ngroup = setting.NgroupT;
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
       
nameresult = [nameresult '\'];nameresulttmp = [nameresulttmp '\'];
nameimresult = [nameimresult '\'];

if setting.testonly
    APcompute = 1;
end

setting.Fcompute = 1;
setting.resultsuffix1 = setting.resultsuffix;
setting.resultsuffix1 = [setting.resultsuffix1, '_I'];
setting.APcompute = APcompute;



setting.K = Kinit;
try
    load(fullfile(setting.Modelresult, ['Clustering_', num2str(setting.K), '.mat']), ...
    'CMean', 'Cfilename', 'CLabel');
catch
    if setting.testonly
    if ~strcmp(cmethod, 'KNN') && ~strcmp(cmethod, 'INNC') 
        fprintf('Make sure that you have placed your pre-trained model to the folloiwng folder \n:%s\n', setting.Modelresult)
        if setting.isSnippetRatio && setting.SnippetRatio{1} ~= 1
            fprintf('Make sure that you have placed your pre-trained Reliabilty model to the folloiwng folder \n:%s\n', setting.QualityResult)
        end
    end
end
setting.resultsuffixM = setting.resultsuffix([1:suffixidx1, suffixidx2+1:end]);
resname = '';
    
    if ~exist(nameresult) mkdir(nameresult);  end
        if ~exist(nameimresult) && evaltype mkdir(nameimresult);  end
        if evaltype
        if ~exist([nameimresult 'True\'])
            mkdir([nameimresult 'True\']);
        end
        if ~exist([nameimresult 'False\'])
            mkdir([nameimresult 'False\']);
        end
    end
    setting.cmethod = cmethod;
    [fdatabase, database, dfea, WTAfea,setting] = computeFeature(img_dir1, img_dir, dataname, ...
        mfea_dir, mfea_dir_WTA, setting, 1, feattype, suffix, knnpara);
    
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
        rracc = zeros(setting.Ngroup, setting.Nclass);
        raccII = zeros(setting.Ngroup, 1);
        rrranktime = zeros(setting.Ngroup, 1);   
        for jjj = 1:setting.Ngroup
            fprintf('curround: %d, %d, Group: %d, %d\n', curround, Nfold, jjj, setting.Ngroup)
            if setting.Usesubset && setting.Nclass ~= length(cindex)
                setting.labelmap = setting.RClass(jjj, :);
            end
            setting.curgroup = jjj;
            [Mean, Label, filename] = GetClustering(evaltype, curround, Nfold, setting,img_dir1, dfea, ...
                WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, nameresult, ...
                nameimresult,normmerge, multiview, latentresult1);
            CMean{Kround, jjj} = Mean;
            Cfilename{Kround, jjj} = filename;
            CLabel{Kround, jjj} = Label;
        end 
    end
save(fullfile(setting.Modelresult, ['Clustering_', num2str(setting.K), '.mat']), ...
    'CMean', 'Cfilename', 'CLabel');
fn  = fullfile(setting.Modelresult, ['Clustering_', num2str(setting.K), '.txt']);
fid = fopen(fn, 'w');
for i = 1:size(CMean, 1)
    for j = 1:size(CMean, 2)
        fprintf(fid, 'Results for Round %d, %d \r\n', i, j);
        fprintf(fid, 'Label\tfilename\r\n');
        for k = 1:length(CLabel{i, j})
            fprintf(fid, '%d\t%s\r\n', CLabel{i, j}(k), Cfilename{i, j}{k});
        end
    end
end
end
