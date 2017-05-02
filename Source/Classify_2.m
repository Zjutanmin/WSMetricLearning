function [acc_RE, C_RE, ranktime_RE, WConf, Metric, PCACOEFF] = Classify_2(setting, img_dir, tr_idx, ts_idx, ...
    dFea, WTAfea, fdatabase, feattype, knnpara, cpara, cmethod,  cindex, ...
    nameresult, nameimresult, issave, normmerge, multiview, Rconfidence)      
try mkdir(setting.Modelresult); end
try mkdir(setting.QualityResult); end
% % % % disp('setting.MetricL2')
% % % % setting.MetricL2
% % % % if setting.MetricL2
% % % %     pause
% % % % end
% % % % ranktime = 0;C = 0;
% % % %  acc = -1 * ones(1, setting.Nclass);
% % % %  WConf = [];
% % % %  Metric = [];PCACOEFF = [];
% % % %  return;
timeforLDA = 0;
% addpath('Liblinear/matlab'); 
pdir  = pwd;
addpath('libsvm-weights/matlab'); 
addpath('itml'); 
addpath('liblinear-weights/matlab'); 
addpath(genpath('mLMNN'));
max_iter = 1000;

% cd('mLMNN\mLMNN');install;cd ..; cd ..
                        
setting.INITINNC = 0;
setting.feattype = feattype;
acc = 0;
C = 0;
tCL = @(y,X) MetricLearningAutotuneKnn(@ItmlAlg, y, X);
ranktime = 0;
acc_RE= 0; C_RE= 0; ranktime_RE= 0;

if length(setting.ccoverage) > 1
    acc_RE= cell(1, length(setting.ccoverage)); 
    C_RE= cell(1, length(setting.ccoverage)); 
    ranktime_RE= cell(1, length(setting.ccoverage)); 
    for kkt = 1:length(setting.ccoverage)
        acc_RE{kkt}=  0; 
    C_RE{kkt}=  0; 
    ranktime_RE{kkt}=  0; 
    end
end

WConf = [];
Metric = [];
PCACOEFF = {};
if nargin < 14
    issave = 0;
end
if nargin < 15
    normmerge = 0;
end
if nargin < 16
    multiview = 0;
    Rconfidence = 0.5;
end
if ~isfield(setting, 'PCACOEFF')
    setting.PCACOEFF = {};
end
if ~isfield(setting, 'weightNorm')
    setting.weightNorm = 0;
end
setting.SRKSVM = 0;
if ~isfield(setting, 'MLRweight')
    setting.MLRweight = 0;
end

SRTest = 0;
setting.WeightedMetric = 0;
if setting.isSnippetRatio
    SRTest = floor(setting.SnippetRatio{3} / 10000);
    
    setting.WeightedMetric = floor(SRTest / 2);
    SRTest = mod(SRTest, 2);
    
    if SRTest && setting.Mclassfy %%train
        setting.isSnippetRatio = 0;
    end
    
    setting.SnippetRatio{3} = mod(setting.SnippetRatio{3}, 10000);
    setting.SRKSVM = floor(setting.SnippetRatio{3} / 1000);
    
    setting.typeSVM = floor(setting.SRKSVM / 2);
    setting.SRKSVM = mod(setting.SRKSVM, 2);
    

    setting.SnippetRatio{3} = mod(setting.SnippetRatio{3},1000); 
    
    setting.WeightSVM = floor(setting.SnippetRatio{3} / 100);
    
    setting.CrossSVM = floor(setting.WeightSVM / 4);
    setting.WeightSVM = mod(setting.WeightSVM, 4);
    setting.MultiSVM = floor(setting.WeightSVM / 2);
    setting.WeightSVM = mod(setting.WeightSVM, 2);
    
    setting.SnippetRatio{3} = mod(setting.SnippetRatio{3},100); 
end
setting.preModel = '';
if strcmp(cmethod, 'gblmnn')
    index = strfind(setting.Modelresult, cmethod);
    setting.preModel = [setting.Modelresult(1:index-1), setting.Modelresult(index+1:end)];
end
SnippetRatio = setting.SnippetRatio;


if length(cpara) > 2  %%%kernel then for libsvm
    Psvmtrain = 1;
    kerneltype = cpara(3);
else
    Psvmtrain = 0;
    kerneltype = 0;
end

if isfield(setting, 'ts_idx_conf') && ~isempty(setting.ts_idx_conf)
    Range = setting.ts_idx_conf;
else
    Range = [1:length(ts_idx)];
end


ComputeQualiy = 0;
if (setting.isSnippetRatio && setting.SnippetRatio{3} == 7)
    ComputeQualiy = 1;
end

Exp = 0.05;
if setting.Comverge
    Exp = 0.01;
end
                                
                                
Snippetmodel = [];
% setting.SQ = {'sizex', 'sizey', 'stdR', 'stdG', 'stdB','stdGm',  'feat'};
setting.SQ = {'sizex', 'sizey', 'stdR', 'stdG', 'stdB','stdGm'};
setting.Nquality = length(setting.SQ);
conf_tr_fea = zeros(length(ts_idx), setting.Nquality);

if strcmp(cmethod, 'Siftflow')
    [acc, ranktime_RE] = SiftFlow_Match(setting, img_dir, tr_idx, ts_idx, ...
        dFea, WTAfea, fdatabase, feattype, cpara, cindex, ...
        nameresult, nameimresult, issave, normmerge, multiview, Rconfidence);
    return;
end

if ~mod(setting.latent, 5)
    setting.latent = 0;
end
    
% % % % % if (setting.latent || setting.bestS) && ~setting.Mclassfy
% % % % %     [acc, ranktime_RE, WConf, Metric, PCACOEFF] = Classify_2_latent(setting, img_dir, tr_idx, ts_idx, ...
% % % % %         dFea, WTAfea, fdatabase, feattype, knnpara, cpara, cmethod,  cindex, ...
% % % % %         nameresult, nameimresult, issave, normmerge, multiview, Rconfidence);
% % % % %     return;
% % % % % end

% ranktime = 0;
isWTA = setting.WTA;
[ADFea, findex, normmerge, WTAindex] = sumcell(dFea, WTAfea, normmerge);
mem_block = 3000;                   % maxmum number of testing feaTrues loaded each time  
% load the training feaTrues 
tr_fea = zeros(length(tr_idx), ADFea );
tr_size = zeros(length(tr_idx), 2);
tr_label = zeros(length(tr_idx), 1);
for jj = 1:length(tr_idx),
    bookfeattype = length(fdatabase{1}.path);
    for j = 1:length(bookfeattype)
    td = [fdatabase{1}.imgpath{tr_idx(jj)}];
    for i = 2:length(feattype)
        td1 = fdatabase{i}.imgpath{tr_idx(jj)};
%         td1(find(td1 == '/')) = '\';
%         td(find(td == '/')) = '\';
%         run in linux
        td1(find(td1 == '\')) = '/';
        td(find(td == '\')) = '/';
        if ~strcmp(td, td1)
            fprintf('name error')
            pause;
        end
    end
    end
end
clabel = unique(fdatabase{1}.label);
nclass = length(clabel);

if isfield(setting, 'svote') && ~isempty(setting.svote)
    setting.softK = setting.svote{3};
    setting.GlobarNorm = setting.svote{2};
    setting.RankK = setting.svote{4};
    setting.svote = setting.svote{1}; 
else
    setting.softK = 1;
    setting.RankK = 1;
end
if length(knnpara) > 1
    if knnpara(2) > 0
    setting.labelmap = (length(cindex)+1) * ones(nclass, 1);
    setting.labelmap(cindex) = [1:length(cindex)];
    
    setting.PClass = 1;
    switch knnpara(2)
        case 1
            setting.Consider = [1:length(cindex)];
            setting.ConsiderID = cindex;
        case 2
            setting.labelmap = tr_label;
            setting.Consider = unique(setting.labelmap);
            setting.ConsiderID = [1:length(tr_label)];
    end
    end
else
    setting.labelmap = [1:nclass];
    setting.Consider = unique(setting.labelmap);
    setting.ConsiderID = [1:length(tr_label)];
end


labelmap = setting.labelmap;
if length(setting.KNNlatent) > 1
    try
        Dfactor = setting.KNNlatent(3);
        if Dfactor < 0
            Dfactor = 1 / abs(Dfactor);
        end
    catch
        Dfactor = 1;
    end
    try
        FirstALL = setting.KNNlatent(4);
    catch
        FirstALL = 0;
    end 
    KNNRound = setting.KNNlatent(2);
    setting.KNNlatent = setting.KNNlatent(1); 
    CasTest = setting.teststyle;
else
    KNNRound = 1;
    CasTest = 0;
    FirstALL = 0;
    Dfactor = 1;
end

setting.KNNadptive = 0;
if setting.KNNlatent < 1
    if setting.KNNlatent > 0
        setting.KNNlatent = ceil(abs(setting.KNNlatent) * length(labelmap));
    else
        if setting.KNNlatent > -1 && setting.KNNlatent < 0
            setting.KNNadptive = abs(setting.KNNlatent(1))*10;
            FirstALL = 0;
            setting.KNNlatent = floor(Dfactor);
            if setting.KNNlatent == 0
                setting.KNNlatent = length(labelmap);
            end
            setting.KNNadptiveRate = Dfactor - floor(Dfactor);
            if setting.KNNadptiveRate == 0
                setting.KNNadptiveRate = 1;
            end
            Dfactor = 1;
        else
            setting.rankKNN = 1;
            setting.KNNlatent = abs(setting.KNNlatent);
        end
    end
end
NotRatio = uint8(ones(length(ts_idx), length(tr_idx)));
if setting.Ratio
    setting.ts_ratio = setting.ts_ratio(:);
    setting.ts_ratio = setting.ts_ratio(Range);
    setting.tr_ratio = setting.tr_ratio(:);
    Map1 = repmat(setting.ts_ratio, [1, length(setting.tr_ratio)]);
    Map2 = repmat(setting.tr_ratio', [length(setting.ts_ratio), 1]);
    dis = abs(Map1 - Map2) ./ Map2;
    NotRatio(find(dis > setting.RRatio)) = 0;
end
svotestr = '';
if ~nnz(NotRatio - 1) && ~nnz(setting.Samplevoted - 1)
    svotestr = 'V';
end
cmethodorg = cmethod; 
if ~setting.latent
TFstr = [setting.TFstr];       
data_feaA = [];
for jj = 1:length(feattype)
    load([TFstr, '_', setting.feaname{jj}, '_data.mat'], 'data_fea', 'data_label')
    ddata_N = myNormlize(data_fea, setting.NormFea, ...
        length(feattype));
    if setting.TDataNew && ~setting.Mclassfy
        load([setting.TTFstr, '_', setting.feaname{jj}, '_data.mat'], 'data_fea', 'data_label')
        if setting.VirTest
            ddata_N1 = ddata_N(ts_idx,:);   %%%new testing
        end
        if setting.VirTest
            dis = ddata_N1 - myNormlize(data_fea(ts_idx,:), setting.NormFea, ...
                length(feattype));
            dis = sum(dis.^2, 2);
            switch setting.VirTest
                case 1
                    ts_idx = ts_idx(find(abs(dis) > 1e-6));Range = ts_idx;   %%%virdata
                case -1
                    ts_idx = ts_idx(find(abs(dis) <= 1e-6));Range = ts_idx;
            end
        else
            %%%%using new
            ddata_N(ts_idx,:) = myNormlize(data_fea(ts_idx,:), setting.NormFea, ...
                length(feattype));
        end
        
    end
    data_feaA = [data_feaA, ddata_N];
end  
data_fea = data_feaA;clear 'data_feaA'
load([TFstr, '_info_data.mat'], 'data_imsize', 'data_imname')
data_label = data_label(:);
else
    Tdisplace = setting.displace;Trotate = setting.rotate;
    setting.bestS = floor(setting.platent / 4);
    setting.platent = mod(setting.platent, 4);
    protate = mod(setting.platent, 2);
    pdisplace = floor(setting.platent / 2); 
    if protate == 0
        setting.rotate = [0];
    end
    if pdisplace == 0
        setting.displace = [0];
    end
    iindex = cellfun(@numel, setting.MapSub2ind, 'ErrorHandler', @errorfun, ...
        'UniformOutput', true);
    iindex1 = mat2cell([1, cumsum(iindex(1:end-1))+1], 1, ones(1, length(iindex)));
    iindex2 = mat2cell(cumsum(iindex), 1, ones(1, length(iindex)));
    iindex1 = iindex1(find(ismember(Tdisplace, setting.displace)));
    iindex2 = iindex2(find(ismember(Tdisplace, setting.displace)));
    
    setting.rindex = (find(ismember(Trotate, setting.rotate)));
    setting.dindex = cell2mat(cellfun(@(x,y) [x:y], iindex1, iindex2, 'ErrorHandler', @errorfun, ...
        'UniformOutput', false));
     [dataXC, dataY, numSign, CIndex, Tlatentinfo, latentfile, datastr, data_imsize, data_imname, data_label] = getLatentData(...
         feattype, {setting.ts_fold_idx(Range), setting.ts_fold_idx}, ts_idx, tr_idx, setting, fdatabase, ...
         setting.Samplevoted(Range), NotRatio, svotestr);
%      data_label = zeros(1, length(fdatabase{1}.label));
%      data_label(ts_idx) = cell2mat(dataY(:, 1));
% % %      tr_imsize = data_imsize(tr_idx,:);ts_imsize = data_imsize(ts_idx,:);
% % %      tr_imname = data_imname(tr_idx);ts_imname = data_imsize(ts_idx);
     nTrain = length(dataXC) - length(dataY);
     if setting.Mclassfy
         dataX = [cell2mat(cellfun(@(x) x(1,:), dataXC(1:nTrain),  'UniformOutput', false));...
             cell2mat(cellfun(@(x) x(1,:), dataXC(nTrain+1:end),  'UniformOutput', false))];
     end
end
setting.TrainInfo = 0;
if strcmp(cmethod, 'ML') || strcmp(cmethod, 'lmnn') || strcmp(cmethod, 'gblmnn')
    cmethod = 'ML';
end
if ~setting.Mclassfy && ~isempty(setting.Metric_tr_idx)
    setting.TrainInfo = 1;
end
if ~setting.Mclassfy && setting.TrainInfo
    if length(setting.Metric_tr_idx) ~= length(unique(setting.Metric_tr_idx))
        idd = find(setting.Metric_tr_idx == setting.Metric_tr_idx(end));
        setting.Metric_tr_idx = [tr_idx; setting.Metric_tr_idx(idd(1)+1:end)];
    end
    MLtr_label = data_label(setting.Metric_tr_idx);
    MLtr_fea = data_fea(setting.Metric_tr_idx, :);
    xx1 = sort(labelmap); xx2 = [1:length(cindex)];
    if length(xx1) ~= length(xx2) || nnz(xx1(:) - xx2(:))
        Mapping(labelmap) = [1:length(labelmap)];
        MLtr_label = Mapping(MLtr_label);MLtr_label = MLtr_label(:);
    end
    tr_idx = setting.Metric_tr_idx;
end
% [tr_idx, ts_idx, data_label, cindex, Range, labelmap,issubgroup] = TransformData(setting.labelmap, ...
%     setting.cindex, data_label, tr_idx, ts_idx, Range);
tr_label_new = [];tr_fea_new = [];setting.Dic = [];
if ~isfield(setting, 'lamda_dic')
    setting.lamda_dic = 0;
end
tr_idxinit = tr_idx;
if setting.MeanT && ~setting.Mclassfy && ~setting.AllTemp
    tr_fea_new = setting.Metric{4};
    tr_label_new = setting.Metric{5};
    if setting.TSREMPTY
        tr_fea_new = [];tr_label_new = [];
    end
    setting.Dic = setting.Metric{7};
    if ~isempty(setting.Metric_tr_idx)
        tr_idx = setdiff(setting.Metric_tr_idx, setting.tr_idx);
    else
        if ~isempty(setting.Dic) && setting.Newcode
            tr_idx = setting.tr_idx;
            tr_fea_new = [];
            tr_label_new = [];
        else
            tr_idx = [];
        end
    end
    setting.Label = setting.Metric{6};
    setting.Metric = setting.Metric(1:3);
end
[tr_idx, ts_idx, data_label, cindex, Range, labelmap,issubgroup, ...
    tr_label_new, setting.InvMap] = TransformData(setting.labelmap, ...
    setting.cindex, data_label, tr_idx, ts_idx, Range, tr_label_new);

setting.cindex = cindex;nclass = length(cindex);
setting.labelmap = labelmap;
setting.issubgroup = issubgroup;
tr_imname = data_imname(tr_idx);
tr_size = data_imsize(tr_idx, :);
tr_label = data_label(tr_idx);
if ~setting.latent
tr_fea = data_fea(tr_idx, :);

if ~setting.Mclassfy && setting.TrainInfo && ~(setting.MeanT && ~setting.Mclassfy && ~setting.AllTemp)
    tr_label = MLtr_label;
    tr_fea = MLtr_fea;
end
end

fprintf('Training number: %d\n', length(tr_idx));
fprintf('Testing number:%d\n', length(ts_idx));

if strcmp(cmethod, 'MLR')
    TrainFun = @mlr_train;cmethod = 'MLR';
    if setting.latent
        TrainFun = @mlr_train_latent_f;
    end   
end
if strcmp(cmethod, 'RMLR')
    TrainFun = @rmlr_train;cmethod = 'MLR';
end
try
    datasize = size(setting.PCACOEFF{1});
catch
    datasize = [size(data_fea, 2), size(data_fea, 2)];
end
switch cmethod
    case 'CNN'
        knn = 1;
        if multiview
            setting.confidence = 4;
        end
    case 'ML'
        knn = 1;
        [knn_size, outdim, max_iter, quiet,  mu, validation,...
            earlystopping, ntrees] = getPara(cpara, datasize);
    case 'MultiSVM'
        c = cpara;
        knn = 1;
    case 'KNN'
        knn = knnpara(1);
    case 'INNC'
        knn = knnpara(1);
        [lambda_INNC, K_INNC, blocksize_INNC, verbose_INNC, beta_INNC] ...
            = GetINNCpara(cpara);
    case 'MLR'
        knn = knnpara(1);  
        if setting.MetricTemplate
            fprintf('Training Model\n');
            [dataX, dataY] = GetTrainSample(feattype, ...
                tr_idx, setting, fdatabase);
            [Metric, Xi, Diagnostics] = TrainFun(dataX', dataY, setting.C,  ...
                setting.LOSS,  setting.k,  setting.REG, setting.Diagonal, size(dataY, 1), setting.lambda);
            save(fullfile(setting.Modelresult,['Model']), 'Metric');
        end
end

Oknn = knn;
Testt = 0;
if isfield(setting, 'svote') && ~isempty(setting.svote) && ~setting.Mclassfy ...
        || setting.SnippetRatio{1} ~= 1 || setting.UsePos
     
    Oknn = knn;
    knn = length(labelmap);
    if setting.MeanT && ~setting.Mclassfy
        knn = length(tr_label_new);
    end
    
    if strcmp(cmethod, 'INNC')
        Testt = 1;
        knn = length(labelmap);
    end  
    
end

if setting.KNNlatent == length(labelmap)
    FirstALL = 1;
end

% load the testing feaTrues
Samplevoted = setting.Samplevoted;
Samplevoted = Samplevoted(Range);
if setting.Tclassfy && setting.confidence
    Samplevoted(:) = 1;
end
ts_fold_idx = setting.ts_fold_idx;setting = rmfield(setting, 'ts_fold_idx');
ts_fold_idx = ts_fold_idx(Range);
if multiview
    Asubname = setting.Asubname;setting = rmfield(setting, 'Asubname');
end


% load the testing feaTrues
ts_num = length(ts_idx);
ts_label = [];
ts_size = [];
ts_imname = {};

Batchsize = false;
if setting.Mclassfy
    Batchsize = true;
end

setting.isSnippetRatioO = setting.isSnippetRatio;
setting.cmethodorg = cmethodorg;
if setting.Mclassfy && strcmp(cmethod, 'MultiSVM') && setting.isSnippetRatioO
    cmethod = 'MLR';
end

if setting.TrainInfo
    knnlatentO = length(tr_idx);
else
    knnlatentO = length(labelmap);
    if setting.MeanT && ~isempty(tr_label_new)
        knnlatentO = length(tr_label_new);    
    end
end

if ~setting.Mclassfy && ~strcmp(cmethod, 'ML')
    if ~strcmp(cmethod, 'MultiSVM') || ...
            strcmp(cmethod, 'MultiSVM') && setting.isSnippetRatio
        if CasTest == 2
            setting.Metric = setting.Metric{2};
            setting.KNNlatent = knnlatentO;
        end
        if CasTest == 0
            setting.Metric{1} = [];
            setting.Metric{3} = setting.KNNlatent;
        end
        if ~setting.isKNNlatent
            setting.Metric = setting.Metric{2};
            setting.KNNlatent = knnlatentO;
        end
    end
    if setting.MetricL2 || setting.testMetric
        setting.NormFea = {2, setting.Metric};
    end
end





setting.NormFea1 = {setting.Dic, setting.lamda_dic, ...
    setting.method_dic, setting.mult_dic, setting.iter_dic, setting.Newcode};
SampleQulity = [];
SampleQulityT = [];

if SnippetRatio{1} ~= 1 && SnippetRatio{1} > 0
    [a,b,c] = unique(ts_fold_idx(find(Samplevoted)));
    NNum = zeros(1, length(a));
    for tt= 1:length(a)
        idxx = find(c == tt);
        if SnippetRatio{1} < 1
            NNum(tt) = ceil(length(idxx) * SnippetRatio{1});
        else if SnippetRatio{1} > 1
                NNum(tt) = min(max(SnippetRatio{1},1), length(idxx));
            else
            end
        end
    end
end
 
setting.isSnippetRatioO = setting.isSnippetRatio;
if setting.isSnippetRatio
    FirstSnippetAll = setting.SnippetRatio{7};
end
if length(SnippetRatio) > 2
    setting.Loadfeamethod = GetFeaType(SnippetRatio{3}, setting);
else
    setting.Loadfeamethod = '';
end
setting.Psvmtrain = Psvmtrain;
setting.FeatConf = setdiff([1:length(feattype)], setting.AidConf);
setting.knn = knn;  
if SnippetRatio{1} ~= 1 && SnippetRatio{1} ~= -1 && SnippetRatio{1} ~= -2
    if isempty(SnippetRatio{2})
        SnippetRatio{2} = 0;     
    end
end

setting.NormFeaNF = {setting.NormFea, setting.LDAfeaNORM};
if setting.VirUse && setting.Mclassfy
    
ss1 = [''];
if setting.Nmax ~= 50000
    ss1 = ['_' num2str(setting.Nmax)];
end
    data_imnameN = data_imname;
    data_imsizeN = data_imsize;
    data_labelN = data_label;
    data_feaN = data_fea;
    if setting.PCAenergy   %%%PCA for training data
        data_feaN = GetPCAFeature(setting.PCAMethod, setting.featsize, ...
            setting.LocalPCA, setting.NormFea, setting.NormFea1, ...
            [data_feaN, data_labelN], setting.PCACOEFF, setting.FeatConf);    
    end 
    
    data_feaA = [];data_labelA = [];
    for kk = 1:(setting.featNround)
        sprintf('%d / %d \n', kk, (setting.featNround))
            ss = '';
            if (setting.featNround)~=1
               ss= ['_' num2str(kk) ss1]; 
            end
            tdata_fea = [];
            for jj = 1:length(feattype)
       
                load([setting.TFstrVir, '_', setting.feaname{jj}, ss, '_data.mat'], 'data_fea', 'data_label')
                tdata_fea= [tdata_fea, myNormlize(data_fea, setting.NormFea, ...
                length(feattype))];
            
            end
            
            if setting.PCAenergy
                tdata_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, ...
                    setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, ...
                    [tdata_fea, data_label], setting.PCACOEFF, setting.FeatConf);
            end
            data_feaA = [data_feaA;tdata_fea];
            data_labelA  = [data_labelA; data_label];
    end
    
    data_fea = data_feaA;
    data_label = data_labelA;
    clear 'data_feaA';clear 'data_labelA';clear 'tdata_fea'
    load([setting.TFstrVir, '_info_data.mat'], 'data_imsize', 'data_imname')
    data_imname1 = data_imname;
    [~, xx1] = cellfun(@fileparts, cellfun(@Res, data_imnameN(ts_idx), ...
        'ErrorHandler', @errorfun, 'UniformOutput', false),...
        'ErrorHandler', @errorfun, 'UniformOutput', false);    
    [~, xx2] = cellfun(@fileparts, cellfun(@Res, data_imname1, ...
        'ErrorHandler', @errorfun, 'UniformOutput', false),...
        'ErrorHandler', @errorfun, 'UniformOutput', false); 
    index = (find(ismember(xx2, xx1)));
    index1 = (find(ismember(xx1, xx2)));
    if length(index) / length(index1) == setting.VirUseNum
        index1 = (repmat(index1(:), 1, setting.VirUseNum))';
        index1 = index1(:);
        index1 = index1';
    end
    if nnz(cellfun(@strcmp, xx2(index), xx1(index1), ...
        'ErrorHandler', @errorfun, 'UniformOutput',true) - 1)
    pause
    end
    NotRatio = [NotRatio; NotRatio(index1,:)];
    Range = [Range; Range(index1)];
    Samplevoted = [Samplevoted; Samplevoted(index1)];
    conf_tr_fea = [conf_tr_fea; zeros(length(index1), setting.Nquality)];
    ts_fold_idx = [ts_fold_idx; ts_fold_idx(index1)];
    Tmp = data_imname(index);
    data_imname = [data_imnameN(:);  Tmp(:)];
    if size(data_imnameN, 1) == 1
        data_imname = data_imname';    
    end
    data_imsize = [data_imsizeN;  data_imsize(index,:)];
    data_label = [data_labelN;  data_label(index)];
    data_fea = [data_feaN;  data_fea(index,:)];
    ts_idx1 = ts_idx;ts_idx2 = setdiff([1:length(data_imsizeN)], ts_idx1);
    idxrange = [length(data_labelN)+1:length(data_label)];
    ts_idx = [ts_idx; idxrange'];
    clear 'data_imnameN'
    clear 'data_imsizeN'
    clear 'data_labelN'
    clear 'data_feaN'
    clear 'data_imname1'
    clear 'Tmp'
    if setting.PCAenergy
        tr_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, ...
            setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, ...
            [tr_fea, tr_label], setting.PCACOEFF, setting.FeatConf);
    end
    setting.PCAenergy = 0;
    setting.PCACOEFF = {};
    clear 'ts_idx1'
    clear 'ts_idx2'
    clear 'index1'
    clear 'xx1'
    clear 'xx2' 
end

setting.PerD = 0;
if length(SnippetRatio) > 2 & SnippetRatio{1} == -2.5
    SnippetRatio{1}  = -2;
    setting.PerD = 1;
end

% % if setting.latent
% % %     setting.isboost = {setting.isboost, length(setting.rotate)};
% % end
if ~setting.Mclassfy && knnpara > 1 && strcmp(cmethod, 'ML')
    knn = knnpara;
end

if (ts_num < mem_block || (Batchsize))  && ~strcmp(cmethod, 'CNN')
    % load the testing feaTrues directly into memory for testing
    if ~setting.latent
        if strcmp(cmethod, 'MLR')
        Y = cell(length(ts_idx), 2);
    end
    ts_imname = data_imname(ts_idx);
    ts_size = data_imsize(ts_idx, :);
    ts_label = data_label(ts_idx);
    ts_fea = data_fea(ts_idx, :);
    clear 'data_fea'
    conf_tr_fea = GetQulity(setting, ts_imname, [], ts_idx);
    if ~isempty(tr_label)
        for jj = 1:length(ts_idx),
            Y{jj, 1} = find(tr_label == labelmap(ts_label(jj)));
            Y{jj, 2} = setdiff([1:length(tr_label)], Y{jj, 1});
        end
    else
        Y1 = labelmap(ts_label);
        YY2 = (repmat(labelmap, [length(ts_label), 1]))';
        Y2 = YY2 - (repmat(Y1(:), [1, length(labelmap)]))';
        idt = find(Y2);
        [m, n] = size(Y2);
        Y2 = (reshape(YY2(idt), [m-1, n]))';
        data = [Y1(:), Y2];
        Y = mat2cell(data, ones(1, size(data, 1)), [1, m-1]);
    end
    else
        Y = dataY;
        ts_imname = fdatabase{1}.imgpath(ts_idx);
        tr_imname = fdatabase{1}.imgpath(tr_idx);
        ts_label = cell2mat(dataY(:, 1));
        ts_label = ts_label(CIndex(1):CIndex(end));
    end             
    switch cmethod
        case 'MultiSVM'
            ntrain = (size(tr_fea, 1)); idx = find(Samplevoted);
            if setting.Mclassfy
                [PCACOEFF{1}, PCACOEFF{2}, dataX, setting.rdim] =...
                    GetPCAfea({setting.NormFeaNF, setting.NormFea1}, [tr_fea, tr_label], setting.PCA, ...
                    [ts_fea(idx,:), ts_label(idx)], setting.PCACOEFF); 
                model = SVMtrain_S(setting, cpara, dataX,...
                    [tr_label; ts_label(idx)],  Psvmtrain, kerneltype);
                Metric = model;
                if SRTest || (setting.isSnippetRatioO && SnippetRatio{8} && SnippetRatio{1} ~= 1)
                    ranktime_RE = GetSnippetModel([], ntrain, 1, ...
                        Samplevoted, NotRatio, labelmap, isWTA, ts_idx,  ts_label, tr_imname,ts_imname,cmethod, ...
                        WTAindex,dataX(1:ntrain,:), dataX(ntrain+1:end,:), Y, SnippetRatio, conf_tr_fea, setting);
                   
                end
                return;
            else
                if setting.PCAenergy   %%%PCA for training data
                    ts_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [ts_fea, ts_label], setting.PCACOEFF, setting.FeatConf);    
                end
                
                idx = find(Samplevoted);
                th = tic;
                [a, b] = SVMtest_S(ts_fea(idx,:), ts_label(idx), Psvmtrain, setting.Metric);
                ranktime = ranktime + toc(th);
                C = ones(length(ts_label), knn); 
                distance = zeros(length(ts_label), knn); 
                [C(idx, :),distance(idx, :)] = GetSVMDis(Psvmtrain, ...
                    a, b, setting.Metric.Label, setting.Metric.nr_class, knn); 
                
            end

        case 'ML'
            ntrain = (size(tr_fea, 1)); idx = find(Samplevoted);
            if setting.Mclassfy
                [PCACOEFF{1}, PCACOEFF{2}, dataX, setting.rdim] =...
                    GetPCAfea({setting.NormFeaNF, setting.NormFea1}, [tr_fea, tr_label], setting.PCA, [ts_fea(idx,:), ts_label(idx)], setting.PCACOEFF); 
                
                
                switch cmethodorg
                    case 'ML'
                        model = feval(tCL, [tr_label; ts_label(idx)], dataX);
                    case 'lmnn'
                        dataX = dataX';
                        L0=pca(dataX)';
                        
                        cd('mLMNN/mLMNN');setpaths;
                        [model,~] = lmnn2(dataX, [tr_label; ts_label(idx)]',...
                            knn_size,L0,'maxiter',max_iter,'quiet',quiet, ...
                            'outdim',outdim,'mu',mu,'validation',validation,'earlystopping',earlystopping);
                        cd ..
                        cd ..
                        
                    case 'gblmnn'
                        cd('mLMNN/mLMNN');setpaths;
                        
                        dataX = dataX';
                        idt = strfind(setting.Modelresult, 'gblmnn');
                        MModelresult = [setting.Modelresult(1:idt-1), ...
                            'lmnn', setting.Modelresult(idt+length('gblmnn'):end)];
                        
                        idt = strfind(MModelresult, setting.lmnnsuffix1);
                        MModelresult = [MModelresult(1:idt-1), ...
                            setting.lmnnsuffix2, MModelresult(idt+length(setting.lmnnsuffix1):end)];
                        MModelresult =  fullfile(pdir, MModelresult);
                        
                        
                        try
                            load(fullfile(MModelresult,['Model-', setting.ModelMstr]), 'Metric');
                            L = Metric.model;
                        catch
                            L0=pca(dataX)';
                            [L,~] = lmnn2(dataX, [tr_label; ts_label(idx)]',...
                                knn_size,L0,'maxiter',max_iter,'quiet',quiet,'outdim',outdim,'mu',mu,'validation',validation,'earlystopping',earlystopping); 
                            if ~exist(MModelresult) 
                                mkdir(MModelresult); 
                            end
                            if ~exist(fullfile(MModelresult,['Model-', setting.ModelMstr]))
                                Metric.model = L;
                                save(fullfile(MModelresult,['Model-', setting.ModelMstr]), 'Metric');
                            end
                        end
                        model=gb_lmnn(dataX, [tr_label; ts_label(idx)]',...
                            knn_size,L,'ntrees',ntrees,'verbose',true);
                        
%                         model=gb_lmnn(dataX, [tr_label; ts_label(idx)]',...
%                             knn_size,L,'ntrees',ntrees,'verbose',false,'XVAL',xVa,'YVAL',yVa);
                        
                        
                        cd ..
                        cd ..
                end
                
                Metric.model = model;
                Metric.tr_idx = [tr_idx; ts_idx(idx)];
                if SRTest || (setting.isSnippetRatioO && SnippetRatio{8} && SnippetRatio{1} ~= 1)
                    ranktime_RE = GetSnippetModel([], ntrain, 1, ...
                        Samplevoted, NotRatio, labelmap, isWTA, ts_idx,  ts_label, tr_imname,ts_imname,cmethod, ...
                        WTAindex,dataX(1:ntrain,:), dataX(ntrain+1:end,:), Y, SnippetRatio, conf_tr_fea, setting);
                   
                end
                return;
            else
                if setting.PCAenergy   %%%PCA for training data
                    ts_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [ts_fea, ts_label], setting.PCACOEFF, setting.FeatConf); 
                     tr_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [tr_fea, tr_label], setting.PCACOEFF, setting.FeatConf); 
                end
                
                idx = find(Samplevoted);
                th = tic;
                %evaluate model 
                
                switch cmethodorg
                    case 'ML'
                        pred = KNN(tr_label, ...
                            tr_fea, sqrtm(setting.Metric), knn_size, ts_fea(idx,:)); 
                    case 'lmnn'
                        cd('mLMNN/mLMNN');setpaths;
                        pred=knnclassifytree_test(setting.Metric,...
                            tr_fea', tr_label',(ts_fea(idx,:))',(ts_label(idx,:))',knn);fprintf('\n');
                        
                        pred = pred(:);
                        cd ..
                        cd ..
                    case 'gblmnn'
                        cd('mLMNN/mLMNN');setpaths;
                        embed = setting.Metric;
                        pred=knnclassifytree_test([], embed(tr_fea'), ...
                            tr_label',embed((ts_fea(idx,:))'),(ts_label(idx,:))',knn);fprintf('\n');
                        cd ..
                        cd ..
                end
                
                
                
                ranktime = ranktime + toc(th);
                C = ones(length(ts_label), knn); 
                distance = zeros(length(ts_label), knn); 
                
                
                if knn > 1
                    cind = repmat([1:length(curr_ts_label)], knn, 1);
                    rind = (repmat([1:knn], length(curr_ts_label), 1))';
                    curr_C = curr_C';
                    idx = sub2ind(size(curr_C), rind(:), cind(:));
                    curr_C(idx) = pred; curr_C = curr_C';  
                    
                    IDX = zeros(size(curr_C, 1), length(labelmap));
                    t_idx = sub2ind(size(IDX), ...
                        repmat([1:size(IDX, 1)]', knnpara, 1), curr_C(:));
                    [aa,bb,cc] = unique(t_idx);
                    imargin = max(curr_distance, [], 2);
                    curr_distance = -curr_distance;
                    curr_distance = bsxfun(@plus, curr_distance, imargin)+0.001; 
                    if ~setting.WKNN
                        curr_distance(:) = 1;
                    end
                    for ikk = 1:length(aa)
                        IDX(aa(ikk)) = sum(curr_distance(find(cc == ikk)));
                    end
                    [~, C] = max(IDX, [], 2);
                    t_idx = sub2ind(size(IDX), [1:size(IDX, 1)]', C);
                    distance = imargin +0.001 -IDX(t_idx);
                else
                C(idx) = pred;
                end
            end            
            
   
        case 'KNN'
            ntrain = (size(tr_fea, 1));
            if setting.Mclassfy
                [PCACOEFF{1}, PCACOEFF{2}, dataX, setting.rdim] = GetPCAfea({setting.NormFeaNF, setting.NormFea1}, [tr_fea, tr_label], setting.PCA, [ts_fea, ts_label], setting.PCACOEFF);
                
                if SRTest || (setting.isSnippetRatioO && SnippetRatio{8} && SnippetRatio{1} ~= 1)
                    ranktime_RE = GetSnippetModel([], ntrain, 1, ...
                        Samplevoted, NotRatio, labelmap, isWTA, ts_idx,  ts_label, tr_imname,ts_imname,cmethod, ...
                        WTAindex,dataX(1:ntrain,:), dataX(ntrain+1:end,:), Y, SnippetRatio, conf_tr_fea, setting);
                end
                return;
            else
                time1 = tic;
                
                if setting.PCAenergy   %%%PCA for training data
                    ts_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [ts_fea, ts_label], setting.PCACOEFF, setting.FeatConf);    
                    tr_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [tr_fea, tr_label], setting.PCACOEFF, setting.FeatConf);    
                end
                time1 = toc(time1);
                timeforLDA = timeforLDA + time1;
                
                
                th = tic;
                
                if knnpara > 1
                [IDX, curr_distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted(block_idx), ...
                    NotRatio(block_idx,:), setting.BitCount, ...
                    setting.K, isWTA, setting.WTAwithraw, setting.Metric, WTAindex, setting.innerfea, tr_fea, ts_fea, knnpara);
                ranktime = ranktime + toc(th);
                    curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knnpara]);
                    IDX = zeros(size(IDX, 1), length(labelmap));
                    t_idx = sub2ind(size(IDX), ...
                        repmat([1:size(IDX, 1)]', knnpara, 1), curr_C(:));
                    [aa,bb,cc] = unique(t_idx);
                    
                    imargin = max(curr_distance, [], 2);
                    curr_distance = -curr_distance;
                    curr_distance = bsxfun(@plus, curr_distance, imargin)+0.001; 
                    
                    if ~setting.WKNN
                        curr_distance(:) = 1;
                    end
                    for ikk = 1:length(aa)
                        IDX(aa(ikk)) = sum(curr_distance(find(cc == ikk)));
                    end
                    [~, C] = max(IDX, [], 2);
                    t_idx = sub2ind(size(IDX), [1:size(IDX, 1)]', C);
                    distance = imargin +0.001 -IDX(t_idx);
                else
                    
                [IDX, distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted, NotRatio, ...
                    setting.BitCount, setting.K, ...
                    isWTA, setting.WTAwithraw, setting.Metric, WTAindex, setting.innerfea, tr_fea, ts_fea, knn);
                ranktime = ranktime + toc(th);
                C = reshape(tr_label(IDX), [size(IDX, 1), knn]);
                            end
%                 length(find(ts_label~=C))/length(ts_label)
            end
            
        case 'INNC'
            ntrain = (size(tr_fea, 1));
            if setting.Mclassfy
                [PCACOEFF{1}, PCACOEFF{2}, dataX, setting.rdim] = GetPCAfea...
                    (setting.NormFeaNF, setting.NormFea1, [tr_fea, tr_label], setting.PCA, [ts_fea, ts_label], setting.PCACOEFF);
                
                if SRTest || (setting.isSnippetRatioO && SnippetRatio{8} && SnippetRatio{1} ~= 1)
                    ranktime_RE = GetSnippetModel([], ntrain, 1, ...
                        Samplevoted, NotRatio, labelmap, isWTA, ts_idx,  ts_label, tr_imname,ts_imname,cmethod, ...
                        WTAindex,dataX(1:ntrain,:), dataX(ntrain+1:end,:), Y, SnippetRatio, conf_tr_fea, setting);
                end
                return;
            else
                if setting.PCAenergy   %%%PCA for training data
                    ts_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [ts_fea, ts_label], setting.PCACOEFF, setting.FeatConf);    
                    tr_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [tr_fea, tr_label], setting.PCACOEFF, setting.FeatConf);    
                end
                if ~isempty(setting.NormFea1{1})
                    tr_fea_new = myNormlize(tr_fea_new, 1);
                end
                tr_fea = [tr_fea; tr_fea_new];tr_label = [tr_label; tr_label_new];
                
                if blocksize_INNC == -1
                    blocksize_INNC = size(ts_fea,1); 
                end
                th = tic;
                [labels, acc, labelsR, accR, storedW, Resb]    = INNC(GetReFea(tr_fea, ...
                    setting.Metric), tr_label,GetReFea(ts_fea, setting.Metric), ts_label, ...
                    lambda_INNC, K_INNC, blocksize_INNC, verbose_INNC, beta_INNC, setting.innerfea, knn, Testt);
                
                
%                 [IDX, acc, labelsR, accR, storedW, Resb]  = INNC(GetReFea(tr_fea, ...
%                     setting.Metric), tr_label, GetReFea(curr_ts_fea(idx,:), setting.Metric), curr_ts_label(idx), ...
%                     lambda_INNC, K_INNC, blocksize_INNC, verbose_INNC, beta_INNC, setting.innerfea, knn, Testt);
                
                
                ranktime = ranktime + toc(th);
                C = labels;
                distance = -Resb; 
            end
        case 'MLR'
            if setting.MetricTemplate
                th = tic;
                [IDX, distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted, NotRatio, ...
                    setting.BitCount, setting.K, ...
                    isWTA, setting.WTAwithraw, setting.Metric, WTAindex, setting.innerfea, tr_fea, ts_fea, knn, setting.KNNlatent);
                ranktime = ranktime + toc(th);
                C = reshape(tr_label(IDX), [size(IDX, 1), knn]);
            else
                setting.Dic = [];setting.ParaINNC = [];
                if ismember(setting.TemplateINNCK, [0, 1, 2]) && setting.exitDiC
                    setting.ParaINNC = {setting.K_dic, setting.lamda_dic, ...
                        setting.iternum, setting.method_dic, setting.Fbook, setting.mult_dic, setting.iter_dic...
                        , setting.SGD, setting.Nex, setting.Nround, setting.Tfreq, setting.NCP, setting.FIXW, setting.KmeanE, setting.Tnorm}; 
                end
                
                
                if setting.Mclassfy
                    setting.ParaINNC1 = [];
                switch setting.TemplateINNC
                    case 0
                        setting.ParaINNC1 = setting.GammaS;
                    case 1
                        setting.ParaINNC1 = [setting.lambda_INNC, setting.K_INNC, setting.blocksize_INNC, ...
                            setting.verbose_INNC, 1, setting.beta_INNC, setting.GammaS];
                    case 2
                end
                
                    Samplevoted1 = Samplevoted; 
                    isneedtrain = 1;
                    try 
                        load(fullfile(setting.Modelresult,['Model-', setting.ModelMstr]), 'Metric');
                        isneedtrain = 0;
                    end
                    if ~setting.latent
                    ntrain = (size(tr_fea, 1));ntest = size(ts_fea,1);
                    setting.Label = [1:ntrain];
                    dataY = [cell(ntrain, 2); Y];
                    if setting.PCAenergy   %%%PCA for training data
                        [PCACOEFF{1}, PCACOEFF{2}, dataX, setting.rdim] =...
                            GetPCAfea({setting.NormFeaNF, setting.NormFea1}, [tr_fea, tr_label], setting.PCA, [ts_fea, ts_label], setting.PCACOEFF);
                        setting.COEFF = PCACOEFF{1};setting.xmean = PCACOEFF{2};
                    else
                        dataX = [tr_fea; ts_fea];
                    end
                    clear 'tr_fea';clear 'ts_fea';
                    else
                        ntrain = (size(dataX, 1)) - (length(Tlatentinfo));
                        ntest = (length(Tlatentinfo));
                        setting.Label = [1:ntrain];Ntrain = ntrain;
                    end
                    
                    [dataXT, dataY, ntrain, setting, ~, dataXX] = getNewtemplateW(ntrain+1, size(dataX, 1),  ...
                        dataX,  dataY, ts_label,  setting,  []);
                    dataX = dataXT;
                    
                      
                    dataX_Conf = [];
                    if isneedtrain
                        fprintf('Training Model\n');
                        minKNN = 5;maxKNN = ntrain;setting.Metric = cell(1, 3);
                        setting.Metric{1} = [];
                        setting.Metric{2} = [];
                        setting.constr = '';
                        if setting.KNNadptive
                            setting.constr = ['Adp-' num2str(setting.KNNadptive) '-' num2str(setting.KNNadptiveRate)];
                        end
                        if ~isfield(setting, 'KNNadptive') || ~setting.KNNadptive
                            setting.KNNadptiveRate = 1;
                        end
                        acc = {};
                        if setting.isSnippetRatio && SnippetRatio{4} == 0
                            SnippetRatio{4} = setting.KNNlatent;
                        end
                        if ComputeQualiy
                            conf_tr_fea = GetQulity(setting, ts_imname);
                        end
                        if length(setting.FeatConf) < length(feattype)
                        confrange = [];
                        for i = 1:length(setting.FeatConf)
                            confrange = [confrange, setting.rdim{setting.FeatConf(i)}(1):...
                                setting.rdim{setting.FeatConf(i)}(2)];
                        end
                        dataX_Conf = dataX(:, setdiff([1: size(dataX, 2)], confrange));
                        dataX = dataX(:, confrange);
                        if ismember(SnippetRatio{3}, setting.FeatureInter)
                            if ~isfield(setting, 'Cdistance')
                                setting.Cdistance = ComputeDistance(dataX_Conf, ntrain, ntest);                                
                            end
                            Cdistance = setting.Cdistance;
                        end
                        end
                        Yrank = ones(length(Samplevoted1), 1);
                        VoteTid = [];
% %                         if setting.VirUse
% %                             KNNRound = 3;
% %                         end
                        for jjj = 1:KNNRound
                        if setting.isSnippetRatioO && FirstSnippetAll
                            if (jjj == 1 && setting.Ninit == 0) || setting.isboost
                                setting.isSnippetRatio = 0;
                            else
                                setting.isSnippetRatio = setting.isSnippetRatioO;
                            end
                        end
                        Samplevoted2 = Samplevoted;
                        Samplevoted = Samplevoted1;
                        KNNlatentO = setting.KNNlatent;
                        if setting.isKNNlatent || setting.isSnippetRatio && SnippetRatio{1} ~= 1
%%%%%%%%%%%%%%%%%%%%%%
                            disp('test 1');
                            if jjj == 1
                                Metric = [];
                                if FirstALL
                                    KNNlatentO = setting.KNNlatent;
                                    setting.KNNlatent = ntrain;
                                end
                            end
                            if setting.isSnippetRatio && SnippetRatio{1} ~= 1
                                if setting.INNCSP
                                    [s_Metric, s_KNNlatent] = getmetricTest({setting.Metric{1}, ...
                                        setting.Metric{2}, setting.KNNlatent}, CasTest, setting, ntrain);
                                    [lambda_INNC, K_INNC, blocksize_INNC, verbose_INNC, beta_INNC] ...
                                        = GetINNCpara(setting.cparaINNCSP);
                                    if blocksize_INNC == -1
                                        blocksize_INNC = size(dataX,1) - ntrain; 
                                    end
                                    range = [1:length(ts_label)];range = range(idx);
                                    [a, ~, ~, ~, ~, Resb]  = INNC(GetReFea(dataX(1:ntrain,:), ...
                                        s_Metric), setting.Label, GetReFea(dataX(ntrain+range,:), s_Metric), ts_label(idx), ...
                                        lambda_INNC, K_INNC, blocksize_INNC, verbose_INNC, beta_INNC, setting.innerfea, length(setting.labelmap), 1);
                                    
                                    IDX = ones(length(ts_label),length(setting.labelmap));
                                    distance = zeros(length(ts_label),length(setting.labelmap));
                                    IDX(idx, :) = a;distance(idx, :) =  -Resb;
                                else
    
                                switch cmethodorg
                                    case 'MLR'
                                        [s_Metric, s_KNNlatent] = getmetricTest({setting.Metric{1}, ...
                                            setting.Metric{2}, setting.KNNlatent}, CasTest, setting, ntrain);
                                        [IDX, distance] = GetRank_WTA_B(...
                                            {setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted, NotRatio, ...
                                            setting.BitCount, setting.K, ...
                                            isWTA, setting.WTAwithraw, s_Metric, WTAindex, setting.innerfea, dataX(1:ntrain,:), dataX(ntrain+1:end,:), ...
                                            ntrain, s_KNNlatent);
                                    case 'MultiSVM'
                                        range = [1:length(ts_label)];range = range(idx);
                                        [a, b] = SVMtest_S(dataX(ntrain+range,:), cell2mat(dataY(ntrain+range,1)), Psvmtrain, Metric);
                                        IDX = ones(length(idx), knn); 
                                        distance = zeros(length(idx), knn); 
                                        [IDX(idx, :), distance(idx, :)] = ...
                                            GetSVMDis(Psvmtrain, a, b, Metric.Label, Metric.nr_class, knn);
                                end
                                end
                                if setting.MeanT && setting.AllTemp
%                                     IDX1 = bsxfun(@minus,IDX,[1:size(IDX, 1)]');
%                                     IDX2 = reshape(IDX(find(IDX1)), size(IDX, 1), size(IDX, 2) - 1);
%                                     dis = IDX2 - IDX(:, 2:end);
                                    IDX = IDX(:, 2:end);IDX = ts_label(IDX);distance = distance(:, 2:end);
                                end
                                
                                idx = find(Samplevoted);
                                Ypos = cell2mat(Y(:, 1));Ypos = Ypos(idx); 
                                xx = IDX(idx, :);
                                if ~setting.MeanT
                                    GT = ts_label(idx);
                                    AP = xx - repmat(GT, [1, length(labelmap)]); AP1 = find(~AP);
                                    [a,b] = ind2sub(size(xx), AP1);  
                                    [a, ord] = sort(a);b = b(ord);
                                else
                                    b = zeros(1, length(idx));
                                    if size(xx, 2) == length(setting.labelmap)
                                    for tt = 1:length(idx)
                                        b(tt) = find(ismember(xx((tt),:), ...
                                           setting.Label(cell2mat(dataY(ntrain+idx(tt), 1)))), 1, 'first');
                                    end
                                    else
                                        for tt = 1:length(idx)
                                        b(tt) = find(ismember(xx((tt),:), ...
                                           cell2mat(dataY(ntrain+idx(tt), 1))), 1, 'first');
                                        end
                                    end
                                    
                                    [IDX1, distance1] = ...
                                        Multi2SigIDX(IDX(idx, :), setting, distance(idx, :));
                                    IDX = ones(size(IDX, 1), length(setting.labelmap));
                                    distance = zeros(size(IDX, 1), length(setting.labelmap));
                                    
                                    IDX(idx, :) = IDX1;
                                    distance(idx, :) = distance1;
                                    clear 'IDX1';clear 'distance1';
                                end
                                
                                if setting.isSnippetRatio && SnippetRatio{3} == 41
                                    if s_KNNlatent ~= 1
                                        b(find(b>s_KNNlatent)) = s_KNNlatent + 1;
                                    end
                                    Yrank(idx) = 1./b;
                                end
                                if ismember(SnippetRatio{3}, setting.FeatureInter)
                                    vec2ind = sub2ind(size(Cdistance), idx, IDX(idx, 1));
                                    Yrank(idx) = 1 ./ Cdistance(vec2ind);
                                end
                                
                                if jjj > 1
                                    
                                    if strcmp(cmethodorg, 'MultiSVM') && Psvmtrain
                                        if length(find(b == 1)) / length(b) > 0.998;
                                            fprintf('Most sample''s'' rank is 1, Finished in %d iteration \n', jjj)
                                            break;
                                        end
                                    else
                                        if ~nnz(b - 1)
                                            fprintf('All sample''s'' rank is 1, Finished in %d iteration \n', jjj)
                                            break;
                                        end
                                    end
                                   
                                end
                                
                                Clabel1 = IDX(idx, 1);
                                if setting.isCNN
                                    ylabel = double(Clabel1 == ts_label(idx));
                                    cur_ts_label = ts_label(idx);
                                    cur_ts_imname = GetSalName(ts_imname(idx));
                                    pre_ts_imname = GetSalName(tr_imname(Clabel1));
                                    [aa,bb,cc] = unique(cur_ts_label);
                                    labelinfo = aa;
                                    labelimname = cell(length(aa), 2);
                                    preimname = cell(length(aa), 2);
                                    for jj = 1:length(aa)
                                        indtmp = find(cc == jj);
                                        id1tmp = find(ylabel(indtmp) == 1);
                                        labelimname{jj, 1} = cur_ts_imname(indtmp(id1tmp));
                                        preimname{jj, 1} = pre_ts_imname(indtmp(id1tmp));
                                        id2tmp = find(ylabel(indtmp) == 0);
                                        labelimname{jj, 2} = cur_ts_imname(indtmp(id2tmp));
                                        preimname{jj, 2} = pre_ts_imname(indtmp(id2tmp));
                                    end
                                    SampleQulity{jjj}.labelinfo = labelinfo;
                                    SampleQulity{jjj}.labelimname = labelimname;
                                    SampleQulity{jjj}.preimname = preimname;
                                    SampleQulityT = SampleQulity{jjj};
                                    fprintf('Save CNN model in Round %d\n', jjj)
%                                     save(fullfile(setting.Modelresult, ['SampleQulitT_R_', num2str(jjj), setting.resultsuffix,setting.Mstr]) ,'SampleQulityT');
                                    nstr1 = '';nstr = num2str(jjj);
                                    
                                    fprintf('Load CNN Prob in Round %d\n', jjj)
                                    setting.QulityFeadir = [setting.Modelresult, '/'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    disp('test 2');
                                    disp([setting.Modelresult, '/']);
                                    fprintf('File name %s\n', [setting.QulityFeadir, '_' nstr1, 'ResProb_', nstr, '.mat'])
                                    disp([setting.QulityFeadir, '_' nstr1, 'ResProb_', nstr, '.mat']);
                                    pause
                                    
                                    try
                                        load([setting.QulityFeadir, '_' nstr1, 'ResProb_', nstr, '.mat'], 'prob', 'NameList')
                                    catch
                                        fprintf('Can not load CNN Prob in Round %d\n', jjj)
                                        pause;
                                    end
                                    Cscore1 =  Computefeat(fdatabase, feattype, ...
                                        ts_idx(idx), setting, setting.labelmap, nstr, nstr1);
                                    nn = size(Cscore1, 2)/2;
                                    Cscore1 = [mean(Cscore1(:,nn+1:end), 2) - ...
                                        mean(Cscore1(:,1:nn), 2)];
                                else
                                    [Cscore1, Clabel1] = SelectBetterSPScore(setting.Enorm, setting.TrainInfo, setting.Nclass, (distance(idx, :))',...
                                       (IDX(idx, :))', 0, conf_tr_fea(idx,:), LoadQulityFea(setting.QulityFeadir, ...
                                       ts_idx(idx), setting.Loadfeamethod), ...
                                       cmethod, SnippetRatio, Ypos, Yrank(idx), [], []);
                                   disp('test 3');
                                   disp(length(Cscore1));
                                end
                                Cscore = zeros(length(Samplevoted), size(Cscore1,2));
                                Cscore(idx,:) = Cscore1;clear 'Cscore1'
                                Clabel = zeros(length(Samplevoted), size(Clabel1,2));
                                Clabel(idx,:) = Clabel1;clear 'Clabel1'
%%%%%%%%%%%%%%%%%%%%%%%
                                disp('test 4');
                                disp(length(Cscore));
                            end
                            if setting.isKNNlatent
                                [IDX, distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted, NotRatio, ...
                                    setting.BitCount, setting.K, ...
                                    isWTA, setting.WTAwithraw, Metric, WTAindex, setting.innerfea, dataX(1:ntrain,:), dataX(ntrain+1:end,:), ...
                                    ntrain);
                                idt = find(Samplevoted2);
                                
                                xx = IDX(idx, :);
                                if ~setting.MeanT
                                    GT = ts_label(idx);
                                    AP = xx - repmat(GT, [1, length(labelmap)]); AP1 = find(~AP);
                                    [a,b] = ind2sub(size(xx), AP1);  
                                    [a, ord] = sort(a);b = b(ord);
                                else
                                    b = zeros(1, length(idx));
                                    for tt = 1:length(idx)
                                       b(tt) = find(ismember(xx(idx(tt),:), ...
                                           cell2mat(dataY(ntrain+idx(tt), 1))), 1, 'first');
                                    end
                                    [IDX, distance] = Multi2SigIDX(IDX, setting, distance);
                                    
                                end
                                
                                ts_fold_idx1 = ts_label((idt));[a1,b1,c1] = unique(ts_fold_idx1);
                                
                                for kk = 1:length(a1)
                                    index = find(c1 == kk);b1 = sort(b(index));
                                    CKNNlatent(kk) = b1((ceil(length(index)*setting.KNNadptiveRate)));
                                    if setting.KNNadptive == 3
                                        CKNNlatent(kk) = mean(b1);
                                    end
                                end
                                
                                if setting.KNNadptive && jjj > 1
                                    switch setting.KNNadptive
                                    case 1
                                        b1 = sort(b);
                                        setting.KNNlatent = b1((ceil(length(idt)*setting.KNNadptiveRate)));
                                        IDX = IDX(:, 1:setting.KNNlatent);
                                    case 2
                                        IDXX1 = cell(1, size(IDX, 1));
                                        for kk = 1:length(CKNNlatent)
                                            index = find(c1 == kk);
                                            IDX_tmp = IDX(index, 1:CKNNlatent(kk));
                                            IDXX1(idt(index)) = mat2cell(IDX_tmp, ones(1, length(index)),CKNNlatent(kk));
                                        end
                                        IDX = IDX1; clear 'IDXX1';clear 'IDX_tmp';
                                        setting.KNNlatent = round(mean(CKNNlatent));
                                        IDX = IDX(:, 1:setting.KNNlatent);
                                    case 3
                                        setting.KNNlatent = round(mean(b));
                                        IDX = IDX(:, 1:setting.KNNlatent);
                                    end
                                else
                                    IDX = IDX(:, 1:setting.KNNlatent);
                                end
                                if setting.KNNlatent < 2
                                    fprintf('setting.KNNlatent < 2, Finished in %d iteration \n', jjj)
                                    break;
                                end
                                if (~FirstALL && jjj > 1) || (FirstALL && jjj > 2)
                                if setting.KNNlatent < KNNlatent1
                                    IDXmin = IDX;
                                    IDXmax = IDX1;
                                    KNNlatentmin = setting.KNNlatent;
                                    KNNlatentmax = KNNlatent1;
                                else
                                    IDXmin = IDX1;
                                    IDXmax = IDX;
                                    KNNlatentmin = KNNlatent1;
                                    KNNlatentmax = setting.KNNlatent;
                                end
                                T1 = zeros(ntest, ntrain);
                                x1 = repmat([1:ntest]', [1, KNNlatentmax]);
                                subind = sub2ind(size(T1), x1(:), IDXmax(:));
                                T1(subind) = 1;
                                x1 = repmat([1:ntest]', [1, KNNlatentmin]);
                                subind = sub2ind(size(T1), x1(:), IDXmin(:));

                                sizes = [ntest, KNNlatentmin];
                                T1 = ( reshape(T1(subind), sizes) & ones(sizes) );
                                accR = sum(T1,2)/KNNlatentmin;
                                Overlap = min(accR);
                                if Overlap > 1-Exp
                                    fprintf('Overlap > 1-Exp, Finished in %d iteration \n', jjj)
                                    break;
                                end
                                end
                                IDX1 = IDX;
                                if iscell(IDX)
                                    ContainPos = zeros([1,length(IDX)]);
                                    for i = 1:length(IDX)
                                        ContainPos(i) = ismember(dataY{i+ntrain,1}, IDX{i});
                                        IDX{i} = setdiff(IDX{i}, dataY{i+ntrain,1}); 
                                    end
                                    ContainPos = find(ContainPos(find(Samplevoted2)));
                                    dataY(ntrain+1:end,2) = IDX;
                                else
                                    ContainPos = zeros([1,size(IDX,1)]);
                                    for i = 1:size(IDX,1)
                                        ContainPos(i) = ismember(dataY{i+ntrain,1}, IDX(i,:));
                                    end
                                    ContainPos = find(ContainPos(find(Samplevoted2)));
                                    dataY(ntrain+1:end,2) = mat2cell(IDX, ones(1, ntest), setting.KNNlatent);
                                end
                                if setting.KNNadptive
                                    ContainPosN{1}(jjj) = setting.KNNlatent;
                                else
                                    ContainPosN{1}(jjj) = length(find(ContainPos)) / length(find(Samplevoted2));
                                end
                                ContainPosNK{jjj} = CKNNlatent;
                                idx = cellfun(@isempty, dataY(ntrain+1:end,2));
                                idx = intersect(find(~idx), find(Samplevoted));idx = sort(idx);
                                VoteTid = idx;
                            else
                                idx = find(Samplevoted2);
                            end
                            if setting.isSnippetRatio && SnippetRatio{1} ~= 1
                                Cscore = Cscore(idx, :);
                                Clabel = Clabel(idx, :);
                            end
                            dataIndex = [1:ntrain, ntrain+idx'];
%                             dataX1 = [dataX(1:ntrain,:); dataX(ntrain+idx,:)];
%                             dataY1 = [dataY(1:ntrain,:); dataY(ntrain+idx,:)];
                            VoteTid = idx;
                        else
                            idx = find(Samplevoted2);
                            dataIndex = [1:ntrain, ntrain+idx'];
%                             dataX1 = [dataX(1:ntrain,:); dataX(ntrain+idx,:)];
%                             dataY1 = [dataY(1:ntrain,:); dataY(ntrain+idx,:)];
                            VoteTid = idx;
                        end
                        if setting.selfpaced(1) == 1
                            Winit = Metric;
                        else
                            Winit= [];
                        end
                        
                        nn = length(dataIndex) - ntrain;
                        if setting.isboost
                            if jjj == 1
                                SampleW = ones(1, nn) / nn;
                            end
                        else
                            SampleW = ones(1, nn);
                        end
                        
                        if jjj > 1 && setting.isboost
                            IDX = GetRank_WTA(Samplevoted, NotRatio, ...
                                setting.BitCount, setting.K, ...
                                isWTA, setting.WTAwithraw, setting.Metric{2*(jjj-1)-1},...
                                WTAindex, dataX(1:ntrain,:), dataX(ntrain+1:end,:), ...
                                ntrain);  
                                
                            IDX = Multi2SigIDX(IDX, setting);    
                            
                            idx = find(Samplevoted);C = (IDX(idx, :))';
                            label = C(1,:);Clabel = label';
                            ylabel = double(Clabel == ts_label(idx));
                            Et = sum(SampleW' .* (~ylabel));a_t = 0.5 * log((1-Et)/Et);  
                            setting.Metric{2*(jjj-1)} = a_t;
                            
                            if abs(Et) <= 0.001
                                fprintf('Boosting finished, Et %f\n', Et)
                                break;
                            end
                            sizew = size(SampleW);
                            SampleW = SampleW' .* exp(a_t*(2*(~ylabel)-1));
                            SampleW = reshape(SampleW ./ sum(SampleW), sizew);
                        end
                                
                        if setting.isSnippetRatio && SnippetRatio{1} ~= 1
                            SampleW = ones(1, length(Cscore));
                            ylabel = double(Clabel == ts_label(idx));
                            tidx = find(ylabel);
                            if size(Cscore, 2) == 1
                                if ismember(SnippetRatio{1}, setting.Mthresh)
                                    if SnippetRatio{1} == -1
                                        Snippetmodel = getthresh(Cscore, ylabel, length(tidx), SnippetRatio{2});
                                    end
                                    if SnippetRatio{1} == -2
                                        Snippetmodel = SnippetRatio{2};
                                    end
                                    trueid = find(Cscore>Snippetmodel);
                                    savehistfigure(Cscore, ylabel, setting);
                                end
                            else
                                ylabel(find(ylabel == 0)) = -1;
                                if setting.Ninit < 30
%%%%%%%%%%%%%%%%%%%%%%
                                    disp('test 5');
                                    disp(length(Cscore));
                                    [Snippetmodel, C, a, Cscore] = GetSnippetModelBySVM(setting, ylabel, Cscore, Clabel);
                                    disp('test 5');
                                    disp(length(Cscore));
                                    disp(Snippetmodel);
                                    disp(length(C));
                                    disp(length(a));
                                else
                                    Cscore = Cscore(:, 1);
                                    [x1, ~, z1] = unique(ts_label(idx));
                                    for ikk = 1:length(x1)
                                        index = find(z1 == ikk);
                                        imin = min(Cscore(index));
                                        imax = max(Cscore(index));
                                        Cscore(index) = (Cscore(index) - imin) / (imax - imin);
                                    end
%%%%%%%%%%%%%%%%%%%%%%
                                    disp('test 6');
                                end
                                trueid = find(C>0);
                            end
                            
                            SelectIdx = [];
                            if setting.WeightUpC
                                c = ts_label;
                                a = unique(c);
                            else
                                
                                if setting.multiview  %%% for database
                                    [a,b,c] = unique(ts_fold_idx(idx));
                                else
                                    if setting.MultiFold
                                    [a,b,c] = unique(ts_fold_idx(idx));
                                    else
%                                     if isfield(setting, 'WeightUpC') && setting.WeightUpC
%                                         c = ts_label;
%                                         a = unique(c);
%                                     else
                                        a = 1;
                                        c = ones(length(idx), 1);
%                                     end
                                    end
                                end
                            end
                            
                            for tt= 1:length(a)
                                
                                ttindex = find(c == tt);
                                idxx = ttindex;
                                disp('length(idxx):');
                                disp(length(idxx));
                                disp('length(Cscore):');
                                disp(length(Cscore));
                                disp('Cscore:');
                                disp(Cscore);
                                disp('Cscore1:');
                                disp(Cscore(1));
                                %disp(Cscore(idxx));
                                if setting.WeightedMetric && SnippetRatio{1} ~= -5
                                    SampleW(idxx) = Normlizeexp(Cscore(idxx), setting.Ntype, setting.onetype);
                                else
                                    if SnippetRatio{1} == -1
                                        idxx = intersect(trueid, idxx);
                                    else
                                        if SnippetRatio{1} == -4
                                            idxx = idxx(find(Cscore(idxx) >  mean(Cscore(idxx))));
                                        else
                                            if SnippetRatio{1} == -5 && setting.WeightedMetric
                                                idxx = idxx(find(Cscore(idxx) >  mean(Cscore(idxx))));
                                                SampleW(idxx) = Normlizeexp(Cscore(idxx), setting.Ntype, setting.onetype);
                                                
                                            else
                                                [CS, ordx] = sort(Cscore(idxx), 'descend'); 
                                                idxx = idxx(ordx(1:NNum(tt)));
                                            end
                                        end
                                    end
                                    
                                        
                                    if isempty(idxx)
                                        idxx = ttindex;
                                        [CS, ordx] = sort(Cscore(idxx), 'descend');
                                        nnum = ceil(setting.FRatio * length(idxx));
                                        idxx = idxx(ordx(1:nnum));
                                    end
                                end
                                SelectIdx = [SelectIdx; idxx];
                            end
                            if SnippetRatio{1} ~= -1 && SnippetRatio{2}
                                SelectIdx  = intersect(SelectIdx, tidx);
                            end
                            SampleW = SampleW(SelectIdx);
                            
                            dataIndex = dataIndex([[1:ntrain], ntrain+SelectIdx']);
%                             dataX1 = [dataX1(1:ntrain,:); dataX1(ntrain+SelectIdx,:)];
%                             dataY1 = [dataY1(1:ntrain,:); dataY1(ntrain+SelectIdx,:)];
                            idt = find(Samplevoted);
                            Samplevoted(:) = 0;Samplevoted(idt(SelectIdx)) = 1;VoteTid = idt(SelectIdx);
                        end
                        
                        ClassW = ones(1, length(VoteTid));
                        SampleW = gettrainW(SampleW.*ClassW, setting.weightNorm, setting.isboost);
                        
                        if setting.MLRweight
                            [xx, yy, zz] = unique(ts_label(VoteTid));
                            for kkkt = 1:length(xx)
                                index = (find(zz == kkkt)) ;
% %                                 mean(SampleW(index))
                                SampleW(index) = gettrainW(SampleW(index).*ClassW(index), setting.weightNorm, setting.isboost);
% %                             mean(SampleW(index))
                            end
                            ClassW = getWclass(ts_label(VoteTid));
                            SampleWT = gettrainW(SampleW.*ClassW, setting.weightNorm, setting.isboost);
                        else
                            SampleWT = SampleW;
                        end
% % %                         for kkkt = 1:length(xx)
% % % index = (find(zz == kkkt)) ;
% % % [length(index), sum(SampleWT(index))]
% % %                         end

                        
                        SampleWTT = SampleWT;
                        if ~setting.WUp
                            SampleWTT(:) = 1;
                        end
                        switch cmethodorg
                            case 'RMLR'
                                [Metric, Xi, D] = rmlr_train(dataX(dataIndex,:)', ...
                                    iscell2mat(dataY(dataIndex,:), (setting.MeanT && setting.AllTemp)), setting.C, ...
                                    setting.LOSS,  setting.k,  setting.REG, setting.Diagonal, length(dataIndex), setting.lamda);                                
                            case 'MLR'
                                NNmax = length(dataIndex);
                                if setting.VirUse
                                    NNmax = setting.NmaxMLR;
                                    if NNmax == -1
                                        NNmax = length(dataIndex);
                                    end
                                end
                                if jjj == 1
                                    clear 'Metric'
                                else
                                    if ~(setting.FIXW_T)
                                        clear 'Metric'
                                    end
                                end
                                
                                if jjj == 1 && setting.Ninit  %%%new init template
                                    if setting.Ninit > 10 && setting.Ninit <= 20
                                        setting.INITINNC = 0;
                                    end
                                    TemplateINNCW = setting.TemplateINNC;
                                    if setting.Ninit > 20
                                        TemplateINNCW = setting.TemplateINNC;
                                        setting.TemplateINNC = 0;
                                    end
                                    ntrain1 = ntrain;ttidx = dataIndex(ntrain+1:end);
                                    [min(SampleWTT(:)), max(SampleWTT(:)), norm(SampleWTT)]
                                    [dataXT, dataYT, ntrain,  setting] = getNewtemplateW(ntrain+1, length(dataIndex),  ...
                                        dataX(dataIndex,:),  dataY(dataIndex,:), ts_label(ttidx-ntrain),  ...
                                        setting,  Winit, SampleWTT);
                                    dataX = [zeros(ntrain - ntrain1, size(dataX, 2)); dataX];
                                    dataY = [cell(ntrain - ntrain1, size(dataY, 2)); dataY];
                                    dataIndex = [[1:ntrain - ntrain1], dataIndex + ntrain - ntrain1];
                                    dataX(dataIndex,:) = dataXT;
                                    dataY(dataIndex,:) = dataYT;
                                    clear 'dataXT'
                                    clear 'dataYT'
                                    setting.TemplateINNC = TemplateINNCW;
                                end
                                
                                
                                if jjj == 1 && ~isempty(setting.PreModel)
                                   if setting.PreModelType == 1
                                        try
                                            load(fullfile(setting.PreModel,['Model-', setting.resultsuffix,setting.ModelMstr]), 'Metric');
                                            if (setting.TemplateUp == 2 && setting.KmeanA ~= Inf)
                                                dataX(1:ntrain,:) = Metric{4};
                                            end
                                            Metric = Metric{2};
                                            YR   = zeros(length(dataIndex), 1);
                                        end
                                    end
                                    if setting.PreModelType == 2
                                        try
                                            load(fullfile(setting.PreModel,['Metric_1', setting.resultsuffix,setting.ModelMstr]), 'Metric');
                                            YR   = zeros(length(dataIndex), 1);
                                        end
                                    end
                                end
                                NeedTrain = 0;
                           
                                if ~exist('Metric', 'var') || (setting.TemplateUp == 2 && setting.KmeanA ~= Inf && jjj > 1)
                                    NeedTrain = 1;
                                    if exist('Metric', 'var') && setting.FIXW_T
                                        Winit = Metric;
                                    end
                                end
                                ttmp = setting.FIXW_T;
                                ParaINNCTmp = setting.ParaINNC;
                                if setting.FIXW_T && jjj == 1
                                    ttmp = 0;ParaINNCTmp{13} = 0;
                                end
                        
                                if NeedTrain
                                    if setting.latent
                                        [Metric, Xi, D, YR, ~, dataX] = TrainFun(setting.selfpaced, Winit, SampleWTT, dataXC, [cell(Ntrain, 2); dataY], ...
                                            fullfile(datastr{1}, setting.Mstr(1:end-4)), [ones(1, Ntrain), numSign], CIndex, Tlatentinfo, latentfile, setting.rotate, setting.rawsize, ...
                                            datastr{2}, setting.SnippetRatio, ts_imname, tr_imname, setting.Asubname, setting.C,  setting.LOSS,  setting.k,  setting.REG);
                                        
                                        
                                    else
                                        if length(ParaINNCTmp) < 11
                                            ParaINNCTmp{11} = 200;
                                            ParaINNCTmp{12} = 1000;
                                        end
                                        TT = num2str(ParaINNCTmp{11}); 
                                        if ParaINNCTmp{11} < 0 && strcmp(TT(end), '2')
                                            TT  = -ParaINNCTmp{11};
                                            if round(TT) == TT
                                                Round1 = TT;
                                                Round2 = TT;
                                            else
                                                Round1 = fix(TT);
                                                Round2 = num2str(TT - Round1);Round2 = str2num(Round2(3:end-1));
                                            end
                                            iter = [[Round1:Round1+Round2:ParaINNCTmp{12}], [Round1+Round2:Round1+Round2:ParaINNCTmp{12}]];
                                            ii = 1;
                                            
                                            
                                            if jjj == 1
                                                try
                                                    load(fullfile(setting.PreModel1, 'Model-Round10_1.mat')); 
                                                    Metric = Metric{1};
                                                    ii = 2;
                                                end
                                            end
                                            
                                            if ~exist('Metric', 'var')
                                                Metric = [];
                                            end
                                            if ParaINNCTmp{13}
                                                iter = iter(2:2:end);
                                                ii = length(iter);
                                            end
                                                for tt = ii:length(iter)
                                                    if mod(tt, 2)  %%for metric
%                                                     ss = ['-1.' num2str(Round1), '1'];
                                                    ParaINNCTmp{11} = Round1+1;
%                                                     savedot(str2num(ss), length(ss) - 3);
                                                    ParaINNCTmp{12} = Round1;
                                                    else
%                                                     ss = ['-', num2str(Round2) '.11'];
%                                                     ParaINNCTmp{11} = savedot(str2num(ss), 2);
                                                    ParaINNCTmp{11} = 1;
                                                    ParaINNCTmp{12} = Round2;
                                                    xt = ParaINNCTmp{13};
                                                    ParaINNCTmp{13} = 1;
                                                    end
                                                
                                                [Metric, Xi, D, YR, dataX(dataIndex,:), setting.Dic] = TrainFun(Metric, SampleWTT, dataX(dataIndex,:)', ...
                                                iscell2mat(dataY(dataIndex,:), (setting.MeanT && setting.AllTemp)), setting.C,  ...
                                                setting.LOSS,  setting.k,  setting.REG, setting.Diagonal, NNmax, ...
                                                (setting.TemplateUp == 2 && setting.KmeanA ~= Inf), setting.MeanNum, {setting.KmeanA, ttmp, setting.ITERkmean, setting.FeatUpkmean, setting.KmeanELabel, setting.NewinitGD}, setting.FeatUp, ...
                                                setting.TemplateNorm, 1, setting.TemplateINNC, ParaINNCTmp, ...
                                                (GetReal(dataXX, dataIndex))', setting.Dic, setting.innerfea, setting.ParaINNC1,setting.lamda);
                                                if ParaINNCTmp{13} && ~mod(tt, 2)
                                                    ParaINNCTmp{13} = xt;
                                                end
                                            end
                                        else
                                            
                                        [Metric, Xi, D, YR, dataX(dataIndex,:), setting.Dic] = TrainFun(Winit, SampleWTT, dataX(dataIndex,:)', ...
                                                iscell2mat(dataY(dataIndex,:), (setting.MeanT && setting.AllTemp)), setting.C,  ...
                                                setting.LOSS,  setting.k,  setting.REG, setting.Diagonal, NNmax, ...
                                                (setting.TemplateUp == 2 && setting.KmeanA ~= Inf), setting.MeanNum, {setting.KmeanA, ttmp, setting.ITERkmean, setting.FeatUpkmean, setting.KmeanELabel, setting.NewinitGD}, setting.FeatUp, ...
                                                setting.TemplateNorm, 1, setting.TemplateINNC, ParaINNCTmp, ...
                                                (GetReal(dataXX, dataIndex))', setting.Dic, setting.innerfea, setting.ParaINNC1,setting.lamda);
                                        end
                                        
                                        % %                                     dis = Metric1 - Metric;
% %                                     max(abs(dis(:)))
                                    end
                                end
                            case 'MultiSVM'
                                Metric = SVMtrain_S(setting, cpara, dataX(dataIndex(ntrain+1:end),:),...
                                    cell2mat(dataY(dataIndex(ntrain+1:end),1)),  Psvmtrain, kerneltype, SampleWTT, 0);
                        end
                        if setting.MetricL2
                            dataX = myNormlize(dataX, {2, Metric});
                        end
                        
                        SampleWTT = SampleWT;
                        if ~setting.MUp
                            SampleWTT(:) = 1;
                        end
                        if setting.TemplateUp == 1;
                            ntrain1 = ntrain;ttidx = dataIndex(ntrain+1:end);
                            
                            [min(SampleWTT(:)), max(SampleWTT(:)), norm(SampleWTT)]
                            
                            [dataXT, dataYT, ntrain,  setting] = getNewtemplateW(ntrain+1, length(dataIndex),  ...
                                dataX(dataIndex,:),  dataY(dataIndex,:), ts_label(ttidx-ntrain),  ...
                                setting,  Metric, SampleWTT);
                            dataX = [zeros(ntrain - ntrain1, size(dataX, 2)); dataX];
                            dataY = [cell(ntrain - ntrain1, size(dataY, 2)); dataY];
                            dataIndex = [[1:ntrain - ntrain1], dataIndex + ntrain - ntrain1];
                            dataX(dataIndex,:) = dataXT;
                            dataY(dataIndex,:) = dataYT;
                            clear 'dataXT'
                            clear 'dataYT'
                        end
                        
                        Mname = fullfile(setting.Modelresult, ['Metric_',num2str(jjj), setting.resultsuffix,setting.ModelMstr]);
                        if ~(setting.FIXW_T)
                            try
                            save(Mname, 'Metric');
                        catch
                            if exist(Mname)
                                dos(['del ' Mname])
                                save(Mname, 'Metric');
                            end
                            end
                        end
                        if setting.isSnippetRatioO && SnippetRatio{3} == 40
                            Yrank(idx) = YR;
                        end
                                
                        KNNlatent1 = setting.KNNlatent;
%                         clear 'dataX1';clear 'dataY1';
                        if setting.isboost
                            setting.Metric{2*(jjj-1)+1} = Metric;
                        else
                            if jjj > 1
                                setting.Metric{1} = setting.Metric{2};
                                w1 = Metric1; w = Metric;
                                DisConv = 1;
                                if strcmp(cmethodorg, 'MultiSVM')                                    
                                    if Psvmtrain
                                        DisConv = 0;
                                    else
                                        w1= Metric1.w;w= Metric1.w;
                                    end
                                end
                                if DisConv
                                if setting.Comverge
                                    diss = norm(w1 - w) / norm(w1);
                                else
                                    diss = abs(trace(w1) - trace(w)) / abs(trace(w1));
                                end
                                if diss < Exp && ~(setting.FIXW_T)
                                    setting.Metric{2} = Metric;
                                    fprintf('Small differnce of metric, Finished in %d iteration \n', jjj)
                                    break;
                                end
                                end
                            end
                            setting.Metric{2} = Metric;
                        end
                        
                        if FirstALL && jjj == 1
                            setting.KNNlatent = KNNlatentO;
                        else
                            setting.KNNlatent = min(max(round(setting.KNNlatent / Dfactor), minKNN), ntrain);
                        end
                        Metric1 = Metric;
                        acc{jjj} = Metric;
                        end
                        
                        if KNNRound ~= 0
%                             if strcmp(cmethodorg, 'MLR')
%                                 PlotFIG(D.ObjFun, fullfile(setting.Modelresult,['Iteration-', setting.ModelMstr(1:end-4)]));
%                             end
                            if setting.isKNNlatent
%                             save(fullfile(setting.Modelresult,['GTInKNN-', setting.constr, setting.ModelMstr(1:end-4)]), 'ContainPosN', 'ContainPosNK');
%                             PlotFIG(ContainPosN, fullfile(setting.Modelresult,['GTInKNN-', setting.constr, setting.ModelMstr(1:end-4)]));
%                             PlotFIG1(ContainPosNK, fullfile(setting.Modelresult,['K-GTInKNN-', setting.constr, setting.ModelMstr(1:end-4)]));
                            end
                            if ~setting.isboost
                            setting.Metric{3} = KNNlatent1;
                            end
                        end
                        if setting.MeanT && ~setting.AllTemp
                            setting.Metric{4} = dataX(1:ntrain, :);
                            setting.Metric{5} = setting.Label(1:ntrain);
                            setting.Metric{5} = setting.Metric{5}(:);
                            if ~isempty(setting.InvMap)
                                setting.Metric{5} = setting.InvMap(setting.Metric{5});
                            end
                            setting.Metric{6} = setting.Label;
                            setting.Metric{7} = setting.Dic;
                        end
                        
                        Metric = setting.Metric;
%                         save(fullfile(setting.Modelresult, ['SampleQulit_',setting.resultsuffix,setting.ModelMstr]) ,'SampleQulity');
                    end
                    
                    if setting.isboost
                        if ~isempty(setting.Metric{2*(jjj)-1}) && length(setting.Metric) < 2* jjj;
                            IDX = GetRank_WTA(Samplevoted, NotRatio, ...
                                setting.BitCount, setting.K, ...
                                isWTA, setting.WTAwithraw, setting.Metric{2*(jjj)-1}, ...
                                WTAindex, dataX(1:ntrain,:), dataX(ntrain+1:end,:), ...
                                ntrain);
                            idx = find(Samplevoted);
                            C = (IDX(idx, :))';
                            label = C(1,:);Clabel = label';
                            ylabel = double(Clabel == ts_label(idx));
                            Et = sum(SampleW' .* (~ylabel));
                            a_t = 0.5 * log((1-Et)/Et);  
                            setting.Metric{2*(jjj)} = a_t;
                        end
                    end
                        
                    if setting.isSnippetRatio
                        ranktime_RE = Snippetmodel;
                    end
                    if setting.UsePos || SRTest || (setting.isSnippetRatioO && SnippetRatio{8} && SnippetRatio{1} ~= 1)
                        if setting.UsePos || (SnippetRatio{1}~=1 && ~ismember(SnippetRatio{3}, setting.LatentInter))
                            dataX = [dataX, dataX_Conf];
                            ranktime_RE = GetSnippetModel(Metric, ntrain, CasTest, ...
                                Samplevoted1, NotRatio, labelmap, isWTA, ts_idx,  ts_label, tr_imname, ts_imname, cmethod,WTAindex,  ...
                                dataX(1:ntrain,:), dataX(ntrain+1:end,:), Y, SnippetRatio, conf_tr_fea, setting);
                        end
                    end
                    return;
                else
                    if setting.PCAenergy   %%%PCA for training data
                        tr_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [tr_fea, tr_label], setting.PCACOEFF, setting.FeatConf);    
                        ts_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [ts_fea, ts_label], setting.PCACOEFF, setting.FeatConf);    
                    end
                    if ~isempty(setting.NormFea1{1})
                        tr_fea_new = myNormlize(tr_fea_new, 1);
                    end
                    if setting.KNNlatent == length(tr_label)
                        setting.KNNlatent = length(tr_label) + length(tr_label_new);
                    end
                    tr_fea = [tr_fea; tr_fea_new];tr_label = [tr_label; tr_label_new];
                    
                
                
                    
                    
% % %                     if ~isempty(setting.NormFea1{1})
% % %                     tr_fea_new = myNormlize(tr_fea_new, 1);
% % %                 end
% % %                 tr_fea = [tr_fea; tr_fea_new];tr_label = [tr_label; tr_label_new];
% % %                 
% % %                 if blocksize_INNC == -1
% % %                     blocksize_INNC = size(ts_fea,1); 
% % %                 end
% % %                 th = tic;
% % %                 [labels, acc, labelsR, accR, storedW, Resb]    = INNC(GetReFea(tr_fea, ...
% % %                     setting.Metric), tr_label,GetReFea(ts_fea, setting.Metric), ts_label, ...
% % %                     lambda_INNC, K_INNC, blocksize_INNC, verbose_INNC, beta_INNC, setting.innerfea, knn, Testt);
                
                
                
                
                    th = tic;
                    if knnpara ~= knn
                        [IDX, distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted, NotRatio, ...
                        setting.BitCount, setting.K, ...
                        isWTA, setting.WTAwithraw, setting.Metric, WTAindex, setting.innerfea, tr_fea, ts_fea, knnpara, setting.KNNlatent);
                    ranktime = ranktime + toc(th);
                    curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knnpara]);
                    IDX = zeros(size(IDX, 1), length(labelmap));
                    t_idx = sub2ind(size(IDX), ...
                        repmat([1:size(IDX, 1)]', knnpara, 1), curr_C(:));
                    [aa,bb,cc] = unique(t_idx);
                    curr_distance = -distance;
                    if ~setting.WKNN
                        curr_distance(:) = 1;
                    end
                    for ikk = 1:length(aa)
                        IDX(aa(ikk)) = sum(curr_distance(find(cc == ikk)));
                    end
                    [~, C] = max(IDX, [], 2);
                    t_idx = sub2ind(size(IDX), [1:size(IDX, 1)]', curr_C);
                    distance = -IDX(t_idx);
                    
                    else
                        [IDX, distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted, NotRatio, ...
                        setting.BitCount, setting.K, ...
                        isWTA, setting.WTAwithraw, setting.Metric, WTAindex, setting.innerfea, tr_fea, ts_fea, knn, setting.KNNlatent);
                    ranktime = ranktime + toc(th);
%                     C = reshape(tr_label(IDX), [size(IDX, 1), knn]);

                    
                    if setting.MeanT && knn ~= 1
%                         [C, distance] = Multi2SigIDX(IDX, setting, distance);
                        
                        idx = find(Samplevoted);
                        [C1, distance1] = Multi2SigIDX(IDX(idx, :), setting, distance(idx, :));
                        C = ones(size(IDX, 1), length(setting.labelmap));
                        distance = zeros(size(IDX, 1), length(setting.labelmap));
                        C(idx, :) = C1;distance(idx, :) = distance1;
                        clear 'C1';clear 'distance1'; 
                    
                    
                    else
                        C = reshape(tr_label(IDX), [size(IDX, 1), knn]);
                    end
                    end
                    
                   
                    
                end
            end
            


            
    end
    conf_tr_fea = GetQulity(setting, ts_imname);
    if length(SnippetRatio) > 2 && ismember(SnippetRatio{3}, setting.FeatureInter)
        if ~isfield(setting, 'Cdistance')
            setting.Cdistance = ComputeDistance([ctr_fea; cts_fea], length(tr_label), length(ts_idx));
        end
        Cdistance = setting.Cdistance;
    end
    
    else
        
if ~strcmp(cmethod, 'CNN')
     if length(SnippetRatio) > 1 && ismember(SnippetRatio{3}, setting.FeatureInter)
         dataX_Conf_train = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [tr_fea, tr_label], setting.PCACOEFF, setting.AidConf);
     end    
     if ~setting.latent
     tr_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [tr_fea, tr_label], setting.PCACOEFF, setting.FeatConf);
%      if strcmp(cmethod, 'ML')
%      tr_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, tr_fea, setting.PCACOEFF, setting.FeatConf); 
% end        
%     tr_fea_new = myNormlize(tr_fea_new, 1);
if ~isempty(setting.NormFea1{1})
    tr_fea_new = myNormlize(tr_fea_new, 1);
end

    if setting.KNNlatent == length(tr_label)
                        setting.KNNlatent = length(tr_label) + length(tr_label_new);
    end
    tr_fea = [tr_fea; tr_fea_new];tr_label = [tr_label; tr_label_new];
     else
        tr_fea = cell2mat(dataXC(1:nTrain));
     end
     
          
    num_block = floor(ts_num/mem_block);
    rem_fea = rem(ts_num, mem_block);
    curr_ts_fea = zeros(mem_block, ADFea);
    curr_ts_label = zeros(mem_block, 1);
    curr_ts_size = zeros(mem_block, 2);
    curr_ts_imname = cell(mem_block, 1);
    C = [];
    distance = [];    
    for jj = 1:num_block,
        block_idx = (jj-1)*mem_block + (1:mem_block);
        curr_idx = ts_idx(block_idx); 
        curr_ts_label = data_label(curr_idx);curr_ts_size = data_imsize(curr_idx,:);
        curr_ts_imname = data_imname(curr_idx);
        if ~setting.latent
            curr_ts_fea = data_fea(curr_idx,:);
        else
            curr_ts_fea = dataXC(block_idx+nTrain);
        end
        % test the current block feaTrues
        ts_label = [ts_label; curr_ts_label(:)];
        ts_size = [ts_size; curr_ts_size];
        ts_imname = [ts_imname(:); curr_ts_imname(:)];
        if ~setting.latent
            if setting.PCAenergy   %%%PCA for training data
            dataX_Conf_test = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [curr_ts_fea, curr_ts_label], setting.PCACOEFF, setting.AidConf);    
            curr_ts_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [curr_ts_fea, curr_ts_label], setting.PCACOEFF, setting.FeatConf);    
            end
        end
        switch cmethod
            case 'MultiSVM'
                idx = find(Samplevoted(block_idx));
                th = tic;
                [a, b] = SVMtest_S(curr_ts_fea(idx,:), curr_ts_label(idx), Psvmtrain, setting.Metric);
                 ranktime = ranktime + toc(th);
                 curr_C = ones(length(curr_ts_label),knn); 
                [length(find(curr_ts_label(idx) == 1)), length(find(a == 1))]
                curr_distance = zeros(length(curr_ts_label), knn); 
                [curr_C(idx, :), curr_distance(idx, :)] = GetSVMDis(Psvmtrain, a, b, ...
                    setting.Metric.Label,setting.Metric.nr_class, knn); 
            case 'ML'
                idx = find(Samplevoted(block_idx));
                th = tic;
                switch cmethodorg
                    case 'ML'
                        pred = KNN(tr_label, ...
                            tr_fea, sqrtm(setting.Metric), knn_size, curr_ts_fea(idx,:)); 
                    case 'lmnn'
                        cd('mLMNN/mLMNN');setpaths;
                        pred=knnclassifytree_test(setting.Metric,...
                            tr_fea', tr_label',(curr_ts_fea(idx,:))',(curr_ts_label(idx,:))',knn);fprintf('\n');
                        pred = pred(:);
                        cd ..
                        cd ..
                    case 'gblmnn'
                        cd('mLMNN/mLMNN');setpaths;
                        embed = setting.Metric;
                        pred=knnclassifytree_test([], embed(tr_fea'), ...
                            tr_label',embed((curr_ts_fea(idx,:))'),(curr_ts_label(idx,:))',knn);fprintf('\n');
                        pred = pred(:);
                        cd ..
                        cd ..
                end  
                        
                        
                ranktime = ranktime + toc(th);
                curr_C = ones(length(curr_ts_label),knn); 
                curr_distance = zeros(length(curr_ts_label), knn); 
                
                if knn > 1
                    cind = repmat([1:length(curr_ts_label)], knn, 1);
                    rind = (repmat([1:knn], length(curr_ts_label), 1))';
                    curr_C = curr_C';
                    idx = sub2ind(size(curr_C), rind(:), cind(:));
                    curr_C(idx) = pred; curr_C = curr_C';  
                    
                    IDX = zeros(size(curr_C, 1), length(labelmap));
                    t_idx = sub2ind(size(IDX), ...
                        repmat([1:size(IDX, 1)]', knnpara, 1), curr_C(:));
                    [aa,bb,cc] = unique(t_idx);
                    imargin = max(curr_distance, [], 2);
                    curr_distance = -curr_distance;
                    curr_distance = bsxfun(@plus, curr_distance, imargin)+0.001; 
                    if ~setting.WKNN
                        curr_distance(:) = 1;
                    end
                    for ikk = 1:length(aa)
                        IDX(aa(ikk)) = sum(curr_distance(find(cc == ikk)));
                    end
                    [~, curr_C] = max(IDX, [], 2);
                    t_idx = sub2ind(size(IDX), [1:size(IDX, 1)]', curr_C);
                    curr_distance = imargin +0.001 -IDX(t_idx);
                else
                    curr_C(idx) = pred;  
                end
                

                
            case 'KNN'
                th = tic;
                if knnpara > 1
                [IDX, curr_distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted(block_idx), ...
                    NotRatio(block_idx,:), setting.BitCount, ...
                    setting.K, isWTA, setting.WTAwithraw, setting.Metric, WTAindex, setting.innerfea, tr_fea, curr_ts_fea, knnpara);
                ranktime = ranktime + toc(th);
                    curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knnpara]);
                    IDX = zeros(size(IDX, 1), length(labelmap));
                    t_idx = sub2ind(size(IDX), ...
                        repmat([1:size(IDX, 1)]', knnpara, 1), curr_C(:));
                    [aa,bb,cc] = unique(t_idx);
                    
                    imargin = max(curr_distance, [], 2);
                    curr_distance = -curr_distance;
                    curr_distance = bsxfun(@plus, curr_distance, imargin)+0.001; 
                    
                    if ~setting.WKNN
                        curr_distance(:) = 1;
                    end
                    for ikk = 1:length(aa)
                        IDX(aa(ikk)) = sum(curr_distance(find(cc == ikk)));
                    end
                    [~, curr_C] = max(IDX, [], 2);
                    t_idx = sub2ind(size(IDX), [1:size(IDX, 1)]', curr_C);
                    curr_distance = imargin +0.001 -IDX(t_idx);
                else
                                
                [IDX, curr_distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted(block_idx), ...
                    NotRatio(block_idx,:), setting.BitCount, ...
                    setting.K, isWTA, setting.WTAwithraw, setting.Metric, WTAindex, setting.innerfea, tr_fea, curr_ts_fea, knn);
                ranktime = ranktime + toc(th);
                curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knn]);
                end
            case 'INNC'
                if blocksize_INNC == -1
                    blocksize_INNC = size(curr_ts_fea,1); 
                end
                th = tic;
                idx = find(Samplevoted(block_idx));
                curr_C = ones(length(curr_ts_label),knn); curr_distance = zeros(length(curr_ts_label),knn); 
                [IDX, acc, labelsR, accR, storedW, Resb]  = INNC(GetReFea(tr_fea, ...
                    setting.Metric), tr_label, GetReFea(curr_ts_fea(idx,:), setting.Metric), curr_ts_label(idx), ...
                    lambda_INNC, K_INNC, blocksize_INNC, verbose_INNC, beta_INNC, setting.innerfea, knn, Testt);
                ranktime = ranktime + toc(th);
                curr_C(idx, :) = IDX;
                curr_distance(idx, :) = -Resb;
            case 'MLR'
                th = tic;
                if knnpara ~= knn
                    [IDX, curr_distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted(block_idx), ...
                    NotRatio(block_idx,:), setting.BitCount, ...
                    setting.K, isWTA, setting.WTAwithraw, setting.Metric, WTAindex, setting.innerfea, tr_fea, curr_ts_fea, knnpara, setting.KNNlatent);
                    ranktime = ranktime + toc(th);
                    curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knnpara]);
                    IDX = zeros(size(IDX, 1), length(labelmap));
                    t_idx = sub2ind(size(IDX), ...
                        repmat([1:size(IDX, 1)]', knnpara, 1), curr_C(:));
                    [aa,bb,cc] = unique(t_idx);
                    curr_distance = -curr_distance;
                    if ~setting.WKNN
                        curr_distance(:) = 1;
                    end
                    for ikk = 1:length(aa)
                        IDX(aa(ikk)) = sum(curr_distance(find(cc == ikk)));
                    end
                    [~, curr_C] = max(IDX, [], 2);
                    t_idx = sub2ind(size(IDX), [1:size(IDX, 1)]', curr_C);
                    curr_distance = -IDX(t_idx);
                else
                    [IDX, curr_distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted(block_idx), ...
                    NotRatio(block_idx,:), setting.BitCount, ...
                    setting.K, isWTA, setting.WTAwithraw, setting.Metric, WTAindex, setting.innerfea, tr_fea, curr_ts_fea, knn, setting.KNNlatent);
              
                ranktime = ranktime + toc(th);
%                 curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knn]);
%                 [IDX, curr_distance] = Multi2SigIDX(IDX, setting, curr_distance);
                                    
                if setting.MeanT && knn ~= 1
                    idx = find(Samplevoted(block_idx));
                    [curr_C1, curr_distance1] = Multi2SigIDX(IDX(idx, :), setting, curr_distance(idx, :));
                    curr_C = ones(size(IDX, 1), length(setting.labelmap));
                    curr_distance = zeros(size(IDX, 1), length(setting.labelmap));
                    curr_C(idx, :) = curr_C1;curr_distance(idx, :) = curr_distance1;
                    clear 'curr_C1';clear 'curr_distance1';      
                else
                    curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knn]);
                end
                end
        end
        C = [C; curr_C];
        
        conf_tr_fea(block_idx, :) = GetQulity(setting, curr_ts_imname, [], curr_idx);
        
        
        if length(SnippetRatio) > 2 && ismember(SnippetRatio{3}, setting.FeatureInter)
            Cdistance(block_idx, :) = ComputeDistance([dataX_Conf_train; dataX_Conf_test], ...
                length(tr_label), length(block_idx));
        end
        distance = [distance; curr_distance];
    end
    curr_ts_fea = zeros(rem_fea, ADFea);
    curr_ts_label = zeros(rem_fea, 1);
    curr_ts_size = zeros(rem_fea, 2);
    curr_ts_imname = cell(rem_fea, 1);
    curr_idx = ts_idx(num_block*mem_block + (1:rem_fea));
    iindex = num_block*mem_block + (1:rem_fea);

    curr_ts_label = data_label(curr_idx);curr_ts_size = data_imsize(curr_idx,:);
    curr_ts_imname = data_imname(curr_idx);
   
    
    if ~setting.latent
        curr_ts_fea = data_fea(curr_idx,:);
    else
        curr_ts_fea = dataXC(num_block*mem_block + (1:rem_fea)+nTrain);
    end
        
    ts_label = [ts_label; curr_ts_label(:)];
    ts_size = [ts_size; curr_ts_size];
    ts_imname = [ts_imname(:); curr_ts_imname(:)];
    if ~setting.latent
        if setting.PCAenergy   %%%PCA for training data
        dataX_Conf_test = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [curr_ts_fea, curr_ts_label], setting.PCACOEFF, setting.AidConf);    
        curr_ts_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, setting.LocalPCA, setting.NormFeaNF, setting.NormFea1, [curr_ts_fea, curr_ts_label], setting.PCACOEFF, setting.FeatConf);    
        end
    end
    switch cmethod
        
        case 'MultiSVM'
                idx = find(Samplevoted((num_block*mem_block + (1:rem_fea))));
                th = tic;
                [a, b] = SVMtest_S(curr_ts_fea(idx,:), curr_ts_label(idx), Psvmtrain, setting.Metric);
                ranktime = ranktime + toc(th);
                curr_C = ones(length(curr_ts_label), knn); 
                curr_distance = zeros(length(curr_ts_label), knn); 
                [curr_C(idx, :), curr_distance(idx, :)] =...
                    GetSVMDis(Psvmtrain, a, b, setting.Metric.Label, setting.Metric.nr_class, knn); 
        case 'ML'
                idx = find(Samplevoted((num_block*mem_block + (1:rem_fea))));
                th = tic;
                switch cmethodorg
                    case 'ML'
                        pred = KNN(tr_label, ...
                            tr_fea, sqrtm(setting.Metric), knn_size, curr_ts_fea(idx,:)); 
                    case 'lmnn'
                        
                        cd('mLMNN/mLMNN');setpaths;
                        pred=knnclassifytree_test(setting.Metric,...
                            tr_fea', tr_label',(curr_ts_fea(idx,:))',(curr_ts_label(idx,:))',knn);fprintf('\n');
                        pred = pred(:);
                        cd ..
                        cd ..
                        
                    case 'gblmnn'
                        cd('mLMNN/mLMNN');setpaths;
                        embed = setting.Metric;
                        pred=knnclassifytree_test([], embed(tr_fea'), ...
                            tr_label',embed((curr_ts_fea(idx,:))'),(curr_ts_label(idx,:))',knn);fprintf('\n');
                        
                        cd ..
                        cd ..
                end 
                ranktime = ranktime + toc(th);
                curr_C = ones(length(curr_ts_label), knn); 
                curr_distance = zeros(length(curr_ts_label), knn); 
                
                
                
                if knn > 1
                    cind = repmat([1:length(curr_ts_label)], knn, 1);
                    rind = (repmat([1:knn], length(curr_ts_label), 1))';
                    curr_C = curr_C';
                    idx = sub2ind(size(curr_C), rind(:), cind(:));
                    curr_C(idx) = pred; curr_C = curr_C';  
                    
                    IDX = zeros(size(curr_C, 1), length(labelmap));
                    t_idx = sub2ind(size(IDX), ...
                        repmat([1:size(IDX, 1)]', knnpara, 1), curr_C(:));
                    [aa,bb,cc] = unique(t_idx);
                    imargin = max(curr_distance, [], 2);
                    curr_distance = -curr_distance;
                    curr_distance = bsxfun(@plus, curr_distance, imargin)+0.001; 
                    if ~setting.WKNN
                        curr_distance(:) = 1;
                    end
                    for ikk = 1:length(aa)
                        IDX(aa(ikk)) = sum(curr_distance(find(cc == ikk)));
                    end
                    [~, curr_C] = max(IDX, [], 2);
                    t_idx = sub2ind(size(IDX), [1:size(IDX, 1)]', curr_C);
                    curr_distance = imargin +0.001 -IDX(t_idx);
                else
                    curr_C(idx) = pred;  
                end
                
        case 'KNN'
            
            th = tic;
            if knnpara > 1
                [IDX, curr_distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted(iindex), ...
                NotRatio(iindex,:), setting.BitCount, ...
                setting.K, isWTA, setting.WTAwithraw, setting.Metric, WTAindex, setting.innerfea, tr_fea, curr_ts_fea, knnpara);
            ranktime = ranktime + toc(th);
                    curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knnpara]);
                    IDX = zeros(size(IDX, 1), length(labelmap));
                    t_idx = sub2ind(size(IDX), ...
                        repmat([1:size(IDX, 1)]', knnpara, 1), curr_C(:));
                    [aa,bb,cc] = unique(t_idx);
                    
                    imargin = max(curr_distance, [], 2);
                    curr_distance = -curr_distance;
                    curr_distance = bsxfun(@plus, curr_distance, imargin)+0.001; 
%                     curr_distance = -curr_distance;
                    if ~setting.WKNN
                        curr_distance(:) = 1;
                    end
                    for ikk = 1:length(aa)
                        IDX(aa(ikk)) = sum(curr_distance(find(cc == ikk)));
                    end
                    [~, curr_C] = max(IDX, [], 2);
                    t_idx = sub2ind(size(IDX), [1:size(IDX, 1)]', curr_C);
                    curr_distance = imargin +0.001 -IDX(t_idx);
            else
                [IDX, curr_distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted(iindex), ...
                NotRatio(iindex,:), setting.BitCount, ...
                setting.K, isWTA, setting.WTAwithraw, setting.Metric, WTAindex, setting.innerfea, tr_fea, curr_ts_fea, knn);
            ranktime = ranktime + toc(th);   
            curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knn]);
            end
        case 'INNC'
                
                if blocksize_INNC == -1
                    blocksize_INNC = size(curr_ts_fea,1); 
                end
                idx = find(Samplevoted((num_block*mem_block + (1:rem_fea))));
                th = tic;
                curr_C = ones(length(curr_ts_label),knn); curr_distance = zeros(length(curr_ts_label),knn); 
                
                
                [IDX, acc, ~, accR, storedW, Resb]  = INNC(GetReFea(tr_fea, ...
                    setting.Metric), tr_label, GetReFea(curr_ts_fea(idx,:), setting.Metric), curr_ts_label(idx), ...
                    lambda_INNC, K_INNC, blocksize_INNC, verbose_INNC, beta_INNC, setting.innerfea, knn, Testt);
                ranktime = ranktime + toc(th);
                curr_C(idx, :) = IDX;
                curr_distance(idx, :) = -Resb; 
        case 'MLR'
            
            th = tic;
            if knnpara ~= knn
                [IDX, curr_distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted(iindex), ...
                NotRatio(iindex,:), setting.BitCount, ...
                setting.K, isWTA, setting.WTAwithraw,setting.Metric,  WTAindex, setting.innerfea, tr_fea, curr_ts_fea, knnpara, setting.KNNlatent);
                ranktime = ranktime + toc(th);
                    curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knnpara]);
                    IDX = zeros(size(IDX, 1), length(labelmap));
                    t_idx = sub2ind(size(IDX), ...
                        repmat([1:size(IDX, 1)]', knnpara, 1), curr_C(:));
                    [aa,bb,cc] = unique(t_idx);
                    curr_distance = -curr_distance;
                    if ~setting.WKNN
                        curr_distance(:) = 1;
                    end
                    for ikk = 1:length(aa)
                        IDX(aa(ikk)) = sum(curr_distance(find(cc == ikk)));
                    end
                    [~, curr_C] = max(IDX, [], 2);
                    t_idx = sub2ind(size(IDX), [1:size(IDX, 1)]', curr_C);
                    curr_distance = -IDX(t_idx);
                            else
                                [IDX, curr_distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, setting.isboost, Samplevoted(iindex), ...
                NotRatio(iindex,:), setting.BitCount, ...
                setting.K, isWTA, setting.WTAwithraw,setting.Metric,  WTAindex, setting.innerfea, tr_fea, curr_ts_fea, knn, setting.KNNlatent);
            ranktime = ranktime + toc(th); 
            if setting.MeanT && knn ~= 1
%                 [curr_C, curr_distance] = Multi2SigIDX(IDX, setting, curr_distance);
                idx = find(Samplevoted(iindex));
                [curr_C1, curr_distance1] = Multi2SigIDX(IDX(idx, :), setting, curr_distance(idx, :));
                curr_C = ones(size(IDX, 1), length(setting.labelmap));
                curr_distance = zeros(size(IDX, 1), length(setting.labelmap));
                curr_C(idx, :) = curr_C1;curr_distance(idx, :) = curr_distance1;
                clear 'curr_C1';clear 'curr_distance1';      
                    
            else
                curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knn]);
            end
                            end
            
            
    end
    conf_tr_fea(iindex, :) = GetQulity(setting, curr_ts_imname, [], curr_idx);
    
    if length(SnippetRatio) > 2 && ismember(SnippetRatio{3}, setting.FeatureInter)
        Cdistance(iindex, :) = ComputeDistance([dataX_Conf_train; dataX_Conf_test], ...
            length(tr_label), length(iindex));
    end

    
    C = [C; curr_C];
    distance = [distance; curr_distance];  
else
    idx = find(Samplevoted);
    ts_label = data_label(ts_idx);
    ts_size = data_imsize(ts_idx,:);
    ts_imname = data_imname(ts_idx);
    if setting.VirUse
        TFstr = setting.TFstrVir;
        Mnul  = setting.VirUseNum+ 1;
    else
        TFstr = setting.TFstr;
        Mnul  = 1;
    end
         
    if setting.issubgroup
%          ts_idx1 =[TFstr '_ResProb_' setting.Mstr(1:end-4) '_' num2str(length(labelmap)) '.mat']
         fname = [TFstr '_ResProb_' setting.Mstr(1:end-4) '_' num2str(length(labelmap)) '.mat'];
%          load(, 'ClsLabel','prob');
    else
         fname = [TFstr '_ResProb_' setting.Mstr];
%          load([setting.TFstr '_ResProb_' setting.Mstr], 'ClsLabel','prob');
    end
     [a,b,~] = fileparts(fname);
    xx = dir(fullfile(a,[b '*']));
    [~,~,c] = fileparts(xx(1).name);
    if strcmp(c, '.txt')
        prob = textread(fullfile(a,xx(1).name), '%f');
        prob = (reshape(prob, length(setting.labelmap), []));
        fname1 = fullfile('TrainInfo', [setting.dataname setting.VirUsestr],...
            [num2str(length(labelmap)), '_', setting.Mstr(1:end-4) '_Test.txt']);
        ts_idx1 = textread(fname1, '%f');
        
        if nnz(sort(ts_idx) - ts_idx)
         fpritnf('EROOR for prob reading\n')
         pause;
        end
        [~, C] = sort(ts_idx1);
        distance = prob(:,C);
        
%         [aa, bb] = textread(fullfile('image', [setting.dataname, '_N1', ...
%             setting.VirUsestr], 'Label.txt'), '%s\t%d');
%         [~, CC1] = sort(prob',2);
%         1 - nnz(CC1(:, end) - bb(ts_idx1)) /length(bb(ts_idx1))
        
    else
        load(fullfile(a,xx(1).name), 'ClsLabel','prob');
        distance = sum(prob, 1);
        distance = reshape(sum(distance, 1), [size(distance, 2), size(distance, 3)]);
        [aa,bb]  = sort(ts_label);
        if nnz(aa - ts_label)
         fpritnf('EROOR for prob reading\n')
         pause;
        end
    end
     
     [distance1,C1] = sort(-distance', 2);
     
%      if strcmp(c, '.txt')
%         1 - nnz(C1(:, 1) - ts_label) /length(ts_label)
%      end
     
        
     C = ones(length(ts_imname), size(C1, 2)); C(idx, :) = C1;
     distance = zeros(length(ts_imname), size(distance1, 2)); distance(idx, :) = distance1;
     conf_tr_fea = GetQulity(setting, ts_imname);
end

end


        
if setting.UsePos
    idx = find(Samplevoted);
    C1 = C';
    Clable = C1(1,idx);Clable = Clable';
    ylabel = double(Clable == ts_label(idx));   
    cur_ts_label = ts_label(idx);
    cur_ts_imname = GetSalName(ts_imname(idx));
    pre_tr_imname = GetSalName(tr_imname(Clable));
    [aa,bb,cc] = unique(cur_ts_label);
    labelinfo = aa;labelimname = cell(length(aa), 2);preimname = cell(length(aa), 2);
    for jj = 1:length(aa)
        indtmp = find(cc == jj);
        id1tmp = find(ylabel(indtmp) == 1);
        labelimname{jj, 1} = cur_ts_imname(indtmp(id1tmp));
        preimname{jj, 1} = pre_tr_imname(indtmp(id1tmp));
        id2tmp = find(ylabel(indtmp) == 0);
        labelimname{jj, 2} = cur_ts_imname(indtmp(id2tmp));
    preimname{jj, 2} = pre_tr_imname(indtmp(id2tmp));
    end
    SampleQulityT.labelinfo = labelinfo;
    SampleQulityT.labelimname = labelimname;
    SampleQulityT.preimname = preimname;
%     save(fullfile(setting.Modelresult, ['SampleQulitTest_',setting.resultsuffix,setting.ModelMstr]) ,'SampleQulityT');
    
    [a,b,c] = unique(ts_fold_idx(idx));
    SelectIdx = [];
    for tt= 1:length(a)  
        ttindex = find(c == tt);
        idxx = ttindex;
        idxx = idxx(find(ylabel(ttindex) == 1));
        if isempty(idxx)
            idxx = ttindex;
        end
        SelectIdx = [SelectIdx; idxx];
    end
    Samplevoted(:) = 0;
    Samplevoted(idx(SelectIdx)) = 1;
    if isfield(setting, 'svote') && ~isempty(setting.svote) && ~setting.Mclassfy
    else
        distance = distance(:,1); C = C(:,1);
        knn = Oknn;
    end 
% else
%     if isfield(setting, 'svote') && ~isempty(setting.svote) && ~setting.Mclassfy
%     else
%         distance = distance(:,1); C = C(:,1);
%         knn = Oknn;
%     end
end

if setting.SoftCScore
    setting.WCscore = zeros(1, length(Samplevoted));
end
CscoreM = ones(length(Samplevoted), 1) * -2;
setting.ShowScore = 0;

if SnippetRatio{1} ~= 1 && multiview
    if ~ismember(SnippetRatio{3}, setting.LatentInter)
        setting.ShowScore = 1;
    trueid = [];
    idx = find(Samplevoted);
    distance1 = distance'; C1 = C';
    if SnippetRatio{4} == 0
        SnippetRatio{4} = setting.KNNlatent;
    end
    Yrank = [];
    if ismember(SnippetRatio{3}, setting.FeatureInter)
        vec2ind = sub2ind(size(Cdistance), idx, C(idx, 1));
        Yrank = 1 ./ Cdistance(vec2ind);
    end 
%         try
RINDEX = [];Cmaxmin = [];
    if setting.MaxMin
    RINDEX = setting.Snippetmodel.RINDEX;
    Cmaxmin = setting.Snippetmodel.Cmaxmin;
    end
    
    [Cscore, Clable] = SelectBetterSPScore(setting.Enorm, setting.TrainInfo, setting.Nclass, distance1(:, idx), C1(:, idx), ...
        0, conf_tr_fea(idx,:), LoadQulityFea(setting.QulityFeadir, ts_idx(idx), ...
        setting.Loadfeamethod), cmethod, SnippetRatio, [], Yrank, RINDEX, Cmaxmin);
    

    
        yy = double(Clable==ts_label(idx));yy(find(~yy)) = -1;
    if size(Cscore, 2) == 1
        if ismember(SnippetRatio{1}, setting.Mthresh) && setting.isCNN
            trueid = find(Cscore>setting.Snippetmodel);
        end
    else              
        if setting.MultiSVM
            [CRe,a,Cscore] = TestModel(yy, Clable, sparse(Cscore), setting.Snippetmodel, setting.SRKSVM);
        else
            if setting.SRKSVM
                [CRe,a,b] = svmpredict(yy, sparse(Cscore), setting.Snippetmodel);
            else
                [CRe,a,b] = predict(yy, sparse(Cscore), setting.Snippetmodel);
            end
            ids = find(setting.Snippetmodel.Label == 1);
            if ids == 2
                Cscore = -b;
            else
                Cscore = b;
            end
        end
        trueid = find(CRe>0);
        if SnippetRatio{1} == -2 && ~setting.isCNN
            if setting.PerD
                xxt = sort(Cscore);
                trueid = find(Cscore>xxt(round((1-SnippetRatio{2}) * length(Cscore))));
            else
                trueid = find(Cscore>SnippetRatio{2});
            end
        end
    end
    CscoreM(idx) = Cscore;
    [a,b,c] = unique(ts_fold_idx(idx));
    SelectIdx = [];
    for tt= 1:length(a)  
        ttindex = find(c == tt);
        idxx = ttindex;
        if setting.SoftCScore || setting.coverage ~= -1
            setting.WCscoreTmp(idxx) = Normlizeexp(Cscore(idxx), setting.Ntype, setting.onetype);
        end
        
        if setting.coverage == -1
            if setting.UsePos
                idxx = idxx(find(yy(ttindex) == 1));
            else
                if ~setting.UseAll
                    if ismember(SnippetRatio{1}, setting.Mthresh)
                        idxx = intersect(trueid, idxx);
                    else
                        [CS, ordx] = sort(Cscore(idxx), 'descend');
                        idxx = idxx(ordx(1:NNum(tt)));
                    end
                end
            end
        end
        
        if isempty(idxx)
            idxx = ttindex;
            [CS, ordx] = sort(Cscore(idxx), 'descend');
            nnum = ceil(setting.FRatio * length(idxx));
            idxx = idxx(ordx(1:nnum));
        end
        
        idxx = idxx(:);
        SelectIdx = [SelectIdx; idxx];
    end
    if setting.SoftCScore || setting.coverage ~= -1
        setting.WCscore(idx) = setting.WCscoreTmp;
        setting = rmfield(setting, 'WCscoreTmp');
    end
    if ~setting.UseAll
        Samplevoted(:) = 0;
        Samplevoted(idx(SelectIdx)) = 1;
    end
    if isfield(setting, 'svote') && ~isempty(setting.svote) && ~setting.Mclassfy
    else
        distance = distance(:,1); C = C(:,1);
        knn = Oknn;
    end
    else
        setting.WCscore = ones(1, length(Samplevoted));
        CscoreM = ones(length(Samplevoted), 1);
        
        if isfield(setting, 'svote') && ~isempty(setting.svote) && ~setting.Mclassfy
        else
            distance = distance(:,1); C = C(:,1);
            knn = Oknn;
        end
        if setting.coverage ~= -1
            setting.WCscore = 1  -( distance - min(distance)) / (max(distance) - min(distance));
        end
    end
else
    if isfield(setting, 'svote') && ~isempty(setting.svote) && ~setting.Mclassfy
    else
        distance = distance(:,1); C = C(:,1);
        knn = Oknn;
    end
    if setting.coverage ~= -1 || setting.SoftCScore
        setting.WCscore = 1  -( distance - min(distance)) / (max(distance) - min(distance));
    end
end


if isfield(setting, 'svote') && ~isempty(setting.svote) && ~setting.Mclassfy
    AllScore = zeros(size(distance));
    xx = repmat([1:size(AllScore,1)]', [1, size(AllScore,2)]);
    subind = sub2ind(size(AllScore), xx(:), C(:));
    AllScore(subind) = distance(:);
    if setting.confidence == 3
        setting.WEntropy = WbyEntropy(distance);
    end                   
    if setting.softK == 0
        setting.softK = length(setting.ConsiderID);
    end
    setting.softK = min(setting.softK, setting.KNNlatent(1));
    if length(knnpara) > 1
        switch knnpara(2)
            case 1
                setting.Consider = [1:length(cindex)];
                setting.ConsiderID = cindex;
                AllScore(:, setdiff([1:nclass], setting.ConsiderID)) = Inf;
        end
    end
    if isfield(setting, 'svote') && ~isempty(setting.svote)
        infsocre = 0;
        setting.weight = Inf(size(AllScore));
        tid = find(Samplevoted);
        AllScore(tid, setting.ConsiderID) = WeightedScore(cmethod, ...
            AllScore(tid, setting.ConsiderID), setting.svote, ...
            setting.GlobarNorm, setting.softK);
    else
        infsocre = -Inf;
        AllScore = -AllScore;
    end
    AllScore(find(abs(AllScore) == Inf)) = infsocre;
    AllScore(find(Samplevoted == 0), :) = infsocre;
    AllScore(find(NotRatio == 0)) = infsocre;
    
    tr_label = data_label(tr_idx);
    tr_imname = data_imname(tr_idx);
    tr_size = data_size(tr_idx,:);
    
    softK = setting.softK;
    nframe = length(ts_idx);
    [dummy, idx] = sort(AllScore, 2, 'descend');
    IDX = idx(:, 1:setting.softK);
    index = repmat([1:nframe]', [1, softK]) + (IDX-1) * nframe;
    distance = AllScore(index);
    C = reshape(tr_label(IDX), [size(IDX, 1), softK]);
    knn = Oknn;
end

if setting.Tclassfy && setting.confidence
    pred_label = C;
    gnd_label = repmat(ts_label, [1, knn]);   %%%
    F_id = find(sum((pred_label == gnd_label), 2) == 0);
    conf_tr_label = ones(length(ts_imname), 1);
    conf_tr_label(F_id) = -1;    
    model = train(double(conf_tr_label), sparse(conf_tr_fea), '-c 1');
    [C, val, prob_estimates] = predict(conf_tr_label, sparse(conf_tr_fea), model);
    clear conf_tr_fea;
    WConf = model.w;
    return;
end

if setting.confidence
    setting.conf_tr_fea = conf_tr_fea;
end
clear conf_tr_fea;

voted1 = ones(size(C));
if ~exist('ts_label')
    for jj = 1:length(ts_idx),
        fpath = fdatabase{1}.path{1}{ts_idx(jj)};
        load(fpath, 'label');
        ts_label(jj) = label;
    end
end
if isempty(tr_idx)
    tr_imname = data_imname(tr_idxinit); 
    tr_size = data_imsize(tr_idxinit, :);
end
NCC = 1;
% % % if ~exist('tr_imname', 'var')
% % %     tr_imname = data_imname(tr_idx);
% % % end
% % % if ~exist('tr_imsize', 'var')
% % %     tr_size = data_imsize(tr_idx,:);
% % % end
if multiview
    C_1 = C;
    if setting.testonly  %%than one for testing
        tr_imname1 = cell(1, nclass);tr_imname1(tr_label) = tr_imname;
        tr_size1 = zeros(nclass, 2);tr_size1(tr_label,:) = tr_size;
        [CC, Cvoted1, CC_cov] = GetRerank2(setting, Samplevoted, C, distance, nclass,  ts_fold_idx, multiview,Rconfidence,...
            ts_imname, ts_label, tr_imname1, tr_size1, ts_size, knn);
    else
        [C_C, C_voted1, C_C_cov, C_voteinfo] = GetRerank2(setting, Samplevoted, C, distance, nclass,  ts_fold_idx, multiview,Rconfidence,...
            ts_imname, ts_label, tr_imname, tr_size, ts_size, knn);
%         save(fullfile(setting.QualityResult, ['Labelinfo_',setting.resultsuffix,setting.Mstr]) ,'votedis', 'voteinfo');
    end
    if iscell(C_C)
        NCC = length(C_C);
    else
        NCC = 1;
        C = C_C;
        voted1 = C_voted1;
        C_cov = C_C_cov;
        voteinfo = C_voteinfo;
    end
end

acc_RE= cell(1, NCC); 
C_RE= cell(1, NCC); ranktime_RE= cell(1, NCC); 
for kkk = 1:NCC
    if multiview && iscell(C_C)
        C = C_C{kkk};voted1 = C_voted1{kkk};C_cov = C_C_cov{kkk};voteinfo = C_voteinfo{kkk};
    end

strpattern = 'test_UCM_T3-0005-20130503-190839_SignSnippetsRectified_';

[t, a, b] = unique(ts_fold_idx);
CResult{1} = (C(a,:));
if setting.testonly
    CResult{2} = Asubname(t);
    C = CResult;
    return;
end
if setting.FoldACC && ~issave
    FAcc = {};
end
acc = zeros(nclass, 1);
% for jj = 1 : nclass,
%     if ~ismember(jj, cindex)
%         continue;
%     end
%     c = clabel(jj);
%     idx = find(ts_label == c);
%     curr_pred_label = C(idx, :);
%     curr_gnd_label = ts_label(idx); 
%     
%     curr_gnd_label1 = repmat(curr_gnd_label, [1, knn]);
%     tp = sum((curr_pred_label == curr_gnd_label1), 2);
%     tid = find(tp > 0);
%     
%     curr_ts_imname = ts_imname(idx);
%     
%     curr_ts_svoted = Samplevoted(idx);
%     curr_ts_Cscore = CscoreM(idx);
%     
%     curr_ts_idx = ts_fold_idx(idx);
%     voted = voted1(idx, :);
%     result_idx = zeros(length(curr_ts_idx), 1);
%     
%     curr_index = ts_fold_idx(idx);
%     uindex =  unique(curr_index);
%     
%     tpfold = zeros(1, length(uindex));
%     
%     for ii = 1:length(uindex)
%         idc = find(curr_index == uindex(ii));    
%         tmp = ismember(idc, tid);
%         if length(unique(tmp)) > 1
%             fprintf('Error, Some Snippets have different prediction label\n')
%             pause;
%         end
%         subname = Asubname{uindex(ii)};
%         idd = strfind(subname, strpattern);
%         subname = subname(idd+length(strpattern):end);
%         if tmp(1)
%             tpfold(ii) = 1;
%         end
%         if issave
%             if tmp(1)
%                 result_idx(idc) = 1;
%                 tfn = fullfile(nameimresult, 'True', subname);
%                 Mkdirvalid(tfn);
%                 tfn = fullfile(nameimresult, 'True', subname, 'VotedSample');
%                 Mkdirvalid(tfn);       
%             else
%                 ffn = fullfile(nameimresult, 'False', subname);
%                 Mkdirvalid(ffn);
%                 ffn = fullfile(nameimresult, 'False', subname, 'VotedSample');
%                 Mkdirvalid(ffn); 
%             end
%         end
%     end
%     FAcc{jj} = tpfold;
%     acc(jj) = length(find(tpfold==1))/length(uindex); 
%         
%    if issave
%         curr_index = ts_fold_idx(idx);
%         uindex =  unique(curr_index);
%         for ii = 1:length(uindex)
%             idc = find(curr_index == uindex(ii));    
%             tmp = ismember(idc, tid);
%             if length(unique(tmp)) > 1
%                 fprintf('Error, Some Snippets have different prediction label\n')
%                 pause;
%             end
%             subname = Asubname{uindex(ii)};
%             idd = strfind(subname, strpattern);
%             subname = subname(idd+length(strpattern):end);
%             if tmp(1)
%                 result_idx(idc) = 1;
%                 tfn = fullfile(nameimresult, 'True', subname);
%                 Mkdirvalid(tfn);
% %                 tfn = fullfile(nameimresult, 'True', subname, 'VotedSample');
% %                 Mkdirvalid(tfn);       
%             else
%                 ffn = fullfile(nameimresult, 'False', subname);
%                 Mkdirvalid(ffn);
% %                 ffn = fullfile(nameimresult, 'False', subname, 'VotedSample');
% %                 Mkdirvalid(ffn); 
%             end
%         end
%         
%         nn = ceil(knn / 5);
%         col = knn;
%         if knn>=5
%             col = 5;
%         end
%         
%         for ii = 1:length(uindex)
%             idc = find(curr_index == uindex(ii));
%             tmp = ismember(idc, tid);
%             if tmp(1)
%                 continue;
%             end
%             subname = Asubname{uindex(ii)}; 
%             idd = strfind(subname, strpattern);
%             subname = subname(idd+length(strpattern):end);
%             
%             idxcur = curr_index(idc);
% 
%             row = ceil((length(idxcur)) / knn);
%             if knn < 5
%                 col = 5;
%                 row = ceil((length(idxcur)) / 5);
%             end
%             figure;
%             
%             CscoreTmp = curr_ts_Cscore(idc);
%             [CscoreTmp, ord] = sort(CscoreTmp, 'descend');
%             idc = idc(ord);
%             for tt = 1:length(idxcur)
%                 tmp = curr_ts_imname{idc(tt)}; 
%                 id = strfind(tmp, subname);
%                 tmp = tmp(id + length(subname):end);
%                 tmp(find(tmp== '_')) = '-';
%                 im = imread(curr_ts_imname{idc(tt)});
%                 sizx = size(uint8(im));
%                 subplot(row+2, col, tt);
%                 if curr_ts_svoted(idc(tt))
%                     showboxes(uint8(im), [1, 1, sizx(2), sizx(1)]);
%                 else
%                     imshow(uint8(im));
%                 end
%                 if setting.ShowScore
%                     title(num2str(savedot(CscoreTmp(tt), 2)));
%                 end
%             end
%             
%             im = imread(tr_imname{curr_gnd_label(idc(1))});
%             subplot(row+2, col, 1+col*row);imshow(uint8(im));
%             title('Ground truth labeling');
%             index = 0;
%             for j = 1:knn
%                 index = index+1;
%                 im = imread(tr_imname{curr_pred_label(idc(1), j)});
%                 subplot(row+2, col, (row+1)*col+index);
%                 imshow(uint8(im));
%                 title(['Rank ' num2str(j)]);
%             end
%             tmp = ismember(idc, tid);
%             if tmp(1)
%                 print(gcf, '-djpeg', '-r0', fullfile(nameimresult, 'True', [setting.Roundstr, '-' subname, '.jpg'])); 
%             else
%                 print(gcf, '-djpeg', '-r0', fullfile(nameimresult, 'False', [setting.Roundstr, '-' subname, '.jpg'])); 
%             end
% 
%             close all;
%         end
%             
%         curr_pred_label1 = C_1(idx, :);
%         for i = 1:length(curr_ts_imname)
%             if result_idx(i)
%                 continue;
%             end
%             nn = ceil(knn / 5);
%             col = knn;
%             
%             if ~nnz(voted(i,:))
%                 continue;
%             end
%             subname = Asubname{curr_ts_idx(i)};
%             idd = strfind(subname, strpattern);
%             subname = subname(idd+length(strpattern):end);
%             
%             figure;im = imread(curr_ts_imname{i});
%             subplot(nn+2, col, 1);imshow(uint8(im));
%             title('Test sample');
%             
%             im = imread(tr_imname{curr_gnd_label(i)});
%             subplot(nn+2, col, 1+col);imshow(uint8(im));
%             title('Ground truth labeling');
%             index = 0;
%             for j = 1:knn
%                 
%                 if voted(i,j) == 0
%                     continue;
%                 end
%                  
%                
%                 index = index+1;
%                 im = imread(tr_imname{curr_pred_label1(i, j)});
%                 subplot(nn+2, col, 2*col+index);
%                 imshow(uint8(im));
%                 title(['rank ' num2str(j)]);
%             end
%             tmp = curr_ts_imname{i};
%             id = strfind(tmp, subname);
%             tmp = tmp(id + length(subname):end);
%             
%             if result_idx(i)
%                 print(gcf, '-djpeg', '-r0', fullfile(nameimresult, 'True', subname, 'VotedSample', tmp));
%             else
%                 print(gcf, '-djpeg', '-r0', fullfile(nameimresult, 'False', subname, 'VotedSample', tmp));
%             end
%             close all;
%         end
%     end  
% %     acc(jj) = length(tid)/length(idx);
% end


if (strcmp(cmethod, 'MLR') || strcmp(cmethod, 'KNN')) && knnpara > 1
    knn = 1;      
end

CC = [];
for jj = 1 : nclass,
    if ~ismember(jj, cindex)
        continue;
    end
    c = clabel(jj);
    idx = find(ts_label == c);
    curr_pred_label = C(idx, :);
    curr_gnd_label = ts_label(idx); 
    
    curr_gnd_label1 = repmat(curr_gnd_label, [1, knn]);
    tp = sum((curr_pred_label == curr_gnd_label1), 2);
    tid = find(tp > 0);
    
    curr_ts_imname = ts_imname(idx);
    
    curr_ts_svoted = Samplevoted(idx);
    curr_ts_Cscore = CscoreM(idx);
    
    curr_ts_idx = ts_fold_idx(idx);
    voted = voted1(idx, :);
    result_idx = zeros(length(curr_ts_idx), 1);
    
    curr_index = ts_fold_idx(idx);
    [uindex, aa, bb] =  unique(curr_index);
    
    tpfold = zeros(1, length(uindex));
    
    
    
    CC = [CC; curr_pred_label(aa), curr_gnd_label1(aa)];
    
    
    for ii = 1:length(uindex)
        idc = find(curr_index == uindex(ii));    
        tmp = ismember(idc, tid);
        if length(unique(tmp)) > 1 && multiview
            fprintf('Error, Some Snippets have different prediction label\n')
            pause;
        end
        
        if tmp(1)
            tpfold(ii) = 1;
        end
        if issave && multiview
            subname = Asubname{uindex(ii)};
            idd = strfind(subname, strpattern);
            subname = subname(idd+length(strpattern):end);
            if tmp(1)
                result_idx(idc) = 1;
                tfn = fullfile(nameimresult, 'True', subname);
                Mkdirvalid(tfn);
                tfn = fullfile(nameimresult, 'True', subname, 'VotedSample');
                Mkdirvalid(tfn);       
            else
                ffn = fullfile(nameimresult, 'False', subname);
                Mkdirvalid(ffn);
                ffn = fullfile(nameimresult, 'False', subname, 'VotedSample');
                Mkdirvalid(ffn); 
            end
        end
    end
    FAcc{jj} = tpfold;
    acc(jj) = length(find(tpfold==1))/length(uindex); 
        
   if issave
        curr_index = ts_fold_idx(idx);
        uindex =  unique(curr_index);
        for ii = 1:length(uindex)
            idc = find(curr_index == uindex(ii));    
            tmp = ismember(idc, tid);
            if length(unique(tmp)) > 1 && multiview
                fprintf('Error, Some Snippets have different prediction label\n')
                pause;
            end
            subname = Asubname{uindex(ii)};
            idd = strfind(subname, strpattern);
            subname = subname(idd+length(strpattern):end);
            if tmp(1)
                result_idx(idc) = 1;
                tfn = fullfile(nameimresult, 'True', subname);
                Mkdirvalid(tfn);
%                 tfn = fullfile(nameimresult, 'True', subname, 'VotedSample');
%                 Mkdirvalid(tfn);       
            else
                ffn = fullfile(nameimresult, 'False', subname);
                Mkdirvalid(ffn);
%                 ffn = fullfile(nameimresult, 'False', subname, 'VotedSample');
%                 Mkdirvalid(ffn); 
            end
        end
        
        nn = ceil(knn / 5);
        col = knn;
        if knn>=5
            col = 5;
        end
        curr_pred_label1 = C_1(idx, :);
        for ii = 1:length(uindex)
            idc = find(curr_index == uindex(ii));
            tmp = ismember(idc, tid);
%             if tmp(1)
%                 continue;
%             end
            subname = Asubname{uindex(ii)}; 
            idd = strfind(subname, strpattern);
            subname = subname(idd+length(strpattern):end);
            
            idxcur = curr_index(idc);

            row = ceil((length(idxcur)) / knn);
            if knn < 5
                col = 5;
                row = ceil((length(idxcur)) / 5);
            end
            CscoreTmp = curr_ts_Cscore(idc);
            [CscoreTmp, ord] = sort(CscoreTmp, 'descend');
            idc = idc(ord);
            indc = 0;
            ctr_imname= {};ctr_imnameT = {};
            for tt = 1:length(idxcur)
                tmp = curr_ts_imname{idc(tt)}; 
                id = strfind(tmp, subname);
                tmp = tmp(id + length(subname):end);
                tmp(find(tmp== '_')) = '-';
                if curr_ts_svoted(idc(tt))
                    indc = indc +1;
                    ctr_imname{indc} = curr_ts_imname{idc(tt)};
                    ctr_imnameT{indc} = (tr_imname{curr_pred_label1(idc(tt))});
                end
            end
            
            im = imread(tr_imname{curr_pred_label1(i, j)});
            
            tmp = ismember(idc, tid);
            if tmp(1)
                namedir = fullfile(nameimresult, 'True', [setting.Roundstr, '-' subname, '.jpg']); 
            else
                namedir = fullfile(nameimresult, 'False', [setting.Roundstr, '-' subname, '.jpg']); 
            end
            showtemplate1(ctr_imname, [namedir '_Sample'])
            showtemplate1(ctr_imnameT , [namedir '_GT'])
            showtemplate1({tr_imname{curr_pred_label(idc(1))}},[namedir '_Result'])
        end
   end
end

ranktime = ranktime / length(find(Samplevoted));

acc = acc(cindex);

idx = ismember(ts_label, cindex);
curr_pred_label = C(idx, :);
curr_gnd_label = ts_label(idx); 
curr_gnd_label1 = repmat(curr_gnd_label, [1, knn]);
tmp = sum((curr_pred_label == curr_gnd_label1), 2);
acc(end+1) = length(find(tmp> 0)) / length(tmp);
acc(end+1) = -inf;   
% C = {curr_pred_label, curr_gnd_label};
C = CC;
if setting.FoldACC
    acc = FAcc(cindex);
end
acc_RE{kkk} = acc;
ranktime_RE{kkk} = ranktime;
C_RE{kkk} = C;
end

if length(C_RE) == 1
    acc_RE = acc_RE{1};ranktime_RE = ranktime_RE{1};C_RE = C_RE{1};
end