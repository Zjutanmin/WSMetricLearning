% An example code for the algorithm proposed in
%
%   [1] Min Tan, Baoyuan Wang, Zhaohui Wu, Jingdong Wang, Gang Pan.
%   "Weakly Supervised Metric Learning for Traffic Sign Recognition in a
%   LIDAR Equipped Vehicle", T-ITS, 2015
%  [2] R. Timofte and L. Van Gool, ¡°Iterative nearest neighbors for classification
%  and dimensionality reduction,¡± in Proc. IEEE CVPR, 2012, pp. 2456¨C2463.
%[3] B. McFee and G. R. Lanckriet, ¡°Metric learning to rank,¡± in Proc. ICML,
%2010, pp. 775¨C782.
%[4] D. Lim, B. Mcfee, and G. R. Lanckriet, ¡°Robust structural metric learning,¡±
%in ICML, vol. 28, 2013, pp. 615¨C623.

% Written by Min Tan @ 
% =========================================================================
function [CPCave, CRavg, Cranktime, modelresult, CAresult] = ...
    GetRecogRate(dataname, suffix, config_file, cmethod, knnpara, cpara, rawsize,...
    normmerge, multiview, confidence, UseSplit, PCA, selfpaced, KNNlatent, SnippetRatio, ...
    FirstRound, Comverge, useall, APcompute, Fcompute, SetNormFea, ReCnew, coverage)
%       dataname     = database name
%       suffix       = dataset name suffix, i.e. datasetname = [dataname,suffix]
%       config_file  = configuration file for used feature and related parameters
%       cmethod      = used model
%         'KNN'      : KNN classifier
%         'INNC'     : INNC classifier
%         'MLR'      : metric learing based template matching
%         'MultiSVM' : multi-class SVM
%       knnpara      = 1*2 cell {K, set}
%          K         = ['-' num2str(K)]: weight K-NN searching;[num2str(K)]: K-NN search;
%          set       =0: use all classes; otherwise use sub-classes defined by set
%       cpara        = model parameters
%         'KNN'      : 
%         'INNC'     : value of lamda in [2]
%         'MLR'/ 'RMLR': settings for metric learningin [3]/[4] based template matching: 1*3 cell
%               first for metric learning
%                      C, LOSSTYPE, k, REG, isDiagonal, B, isLatiter : refer to C:\Users\Tan\Downloads\mlr\mlr_train.m
%                      lamda                                         : refer to C:\Users\Tan\Downloads\mlr\rmlr_train.m
%                      MLRweight                                     : using sample weight for unbalanced dataset
%                      MetricL2                                      : 
%                      innerfea                                      : distance computing method (1:inner product;0:Eclidean)
%               second for template learning
%              third for INNC search
%                      lamda                                         : value of lamda in [2]
%       rawsize      = normalized image size
%       normmerge    = normalization weight when combining different features
%       multiview    = type of weight
%           0     : single-view training and testing
%           0.5   : multi-view training, single-view testing       
%           3     : multi-view training and testing
%       confidence  : using confidence model when merging reocgnition results for multiple snippets
%       UseSplit     = split number in the N-Fold Training
%          1      : fixed training/testing split
%       PCA          = parameters for dimension reduction
%       selfpaced    = metric initilization
%           0:      random initilization
%           1:      initilization based on covariance matrix
%       KNNlatent    = hard sample training scheme
%           [1]:      unuse hard training
%           [1,a,b,c,d]:    use hard training or less than 5 Round
%                a - floor(a)
%                    0  :   unuse hard training
%                    !0 :   use hard training with [round(10*(a - floor(a)))] ROUND
%                a  :  interation round in hard sample
%       SnippetRatio = parameters for learning reliability feature by 1*13 cell
%          {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}}
%       FirstRound   = evaluating split in the N-fold training mode
%          0:        all N folders
%          i:        the i-th folder
%       Comverge     = converage condition for metric learning
%          1:        norm(w1 - w) / norm(w1) < exp
%          0:        abs(trace(w1) - trace(w)) / abs(trace(w1)) < exp
%       useall       = using templates and 
%           TSREMPTY(floor(useall/ 10)) = 0:including templates; 1:excluding templates
%            useall(mod(useall, 10))    = 0:including training samples; 1:excluding training samples
%       APcompute    = 1:overall accuracy; 0:average per-class accuracy
%       Fcompute     expired
%       SetNormFea   = whether use normalized feature
%       ReCnew       = whether use INNC testing mode
%       coverage     = accuracy under a fixed coverage (refer to [1])

%       CPCave      = accuracy in each class
%       CRavg       = overall accuracy
%       Cranktime   = time consumed in recognition
%       modelresult = directory for storing the recognition model
%       CAresult    = directory for storing the result
ProSetting;
nameresult
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
catch
    PCave = zeros([Nclass,1]);ranktime = 0;Ravg = 0;ranktime = 0;  raccF  = zeros(setting.Ngroup, 1);
% % %     if ~exist(nameresult)
% % %         try
% % %             mkdir(nameresult); 
% % %         end
% % %     end
% % %     % if ~exist(nameresulttmp)  mkdir(nameresulttmp);  end
% % %     if ~exist(nameimresult) && issave mkdir(nameimresult);  end
% % %         if issave
% % %         if ~exist([nameimresult 'True/'])
% % %             mkdir([nameimresult 'True/']);
% % %         end
% % %         if ~exist([nameimresult 'False/'])
% % %             mkdir([nameimresult 'False/']);
% % %         end
% % %     end
% % %     setting.cmethod = cmethod;
% % %     setting_Vir = setting;
% % %     
% % %     %%%compute Features
% % %     [fdatabase, database, dfea, WTAfea,setting] = computeFeature(img_dir1, img_dir, dataname, ...
% % %         mfea_dir, mfea_dir_WTA, setting, copyremove, feattype, suffix, knnpara);
% % %     
% % %     if setting.VirUse
% % %         smfea_dir = mfea_dir;smfea_dir_WTA = mfea_dir_WTA;
% % %         for kk = 1:length(setting.feattype)
% % %             [a,b,c] = fileparts(mfea_dir{kk}{1});
% % %             smfea_dir{kk}{1} = fullfile([a, setting.VirUsestr], [b,c]);
% % %             [a,b,c] = fileparts(mfea_dir_WTA{kk}{1});
% % %             smfea_dir_WTA{kk}{1} = fullfile([a, setting.VirUsestr], [b,c]);
% % %         end
% % %         setting.featNround = computeFeature_D(img_dir1, {[img_dir, setting.VirUsestr], [img_dir, '_N1', setting.VirUsestr],...
% % %             database.cname, setting.cindex, setting.tr_idx, setting.ts_idx, database.path(setting.tr_idx), ...
% % %             database.path(setting.ts_idx)}, [dataname, setting.VirUsestr], ...
% % %             smfea_dir, smfea_dir_WTA, setting_Vir, copyremove, feattype, suffix, knnpara);
% % %         clear 'smfea_dir_WTA'
% % %         clear 'smfea_dir'
% % %         clear 'setting_Vir'
% % %         [a, b] = fileparts(img_dir);
% % %         setting.TFstrVir = fullfile('TrainInfo', [a, '_', b, setting.VirUsestr, '_0']);
% % %     end 
% % %     clear 'setting_Vir'
% % %     
% % %     confidencestr = setting.confidence;
% % %     [setting.Idx_fold, c, b] = unique(setting.ts_fold_idx);
% % %     setting.Label_fold = setting.ts_Fold_label(setting.Idx_fold);
% % %     cindex = unique(setting.Label_fold);
% % %     if multiview
% % %         try
% % %             load([setting.TFstr, '_Nfold' num2str(Nfold) '.mat'], 'idx');
% % %         catch
% % %             idx = cell(1, length(cindex));
% % %             for c = 1:length(cindex)
% % %                 tid = find(setting.Label_fold == cindex(c));
% % %                 idx{c} = randperm(length(tid));
% % %                 idx{c} = tid(idx{c});
% % %             end
% % %             save([setting.TFstr, '_Nfold' num2str(Nfold) '.mat'], 'idx');
% % %         end
% % %     end
% % %     TNfold = Nfold;
% % %     if setting.FirstRound
% % %         if TNfold > 1
% % %             setting.SaveRes = 0;
% % %         end
% % %         TNfold = 1;
% % %     end
% % %     racc = zeros(TNfold, setting.Nclass);
% % %     raccI = zeros(TNfold, 1);
% % %     rranktime = zeros(TNfold, 1); 
% % %     imAP = 0;
% % %     for Kround = 1:TNfold  %%%N-folder testing
% % %         curround = TestRound(Kround);
% % %         rracc = zeros(length(setting.NgroupR), setting.Nclass);
% % %         raccII = zeros(length(setting.NgroupR), 1);
% % %         rrranktime = zeros(length(setting.NgroupR), 1);   
% % %         tt = 0;
% % %         for jjj = (setting.NgroupR) %%%for n-th sub-category set
% % %             tt = tt + 1;
% % %             fprintf('curround: %d, %d, Group: %d, %d\n', curround, Nfold, jjj, setting.Ngroup)
% % %             if setting.Usesubset && setting.Nclass ~= length(cindex)
% % %                 setting.labelmap = setting.RClass(jjj, :);
% % %             end
% % %             setting.curgroup = jjj;
% % %             setting.Cov_strindex = jj;
% % %             [tmp, C, rrranktime(tt,:)] = GetRoundAccuracy(issave, curround, Nfold, setting,img_dir1, dfea, ...
% % %                 WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, nameresult, ...
% % %                 nameimresult,normmerge, multiview, latentresult1);
% % %             if tmp(end) == -inf
% % %                 imAP = 1;
% % %                 raccII(tt) = tmp(end-1);
% % %                 rracc(tt,:) = tmp(1:end-2);
% % %             else
% % %                 rracc(tt,:) = tmp;
% % %             end
% % %             
% % %         end
% % %         raccF(Kround,:) = (mean(rracc, 2))';
% % %         rranktime(Kround) = mean(rrranktime);
% % %         racc(Kround,:) = tmean(rracc, 1);
% % %         raccI(Kround) = tmean(raccII);
% % %     end
% % %     acc = tmean(racc, 1);ranktime = tmean(rranktime);
% % %     
% % %     raccF = tmean(raccF, 1);
% % %     PCave = acc;Ravg = mean(acc);
% % %     fprintf('===============================================');
% % %     fprintf('Average classification accuracy: %f\n', Ravg);
% % %     fprintf('===============================================');
% % %     if unique(acc) == -1
% % %         Error = 1;
% % %     end
% % %     if issave && ~Error && setting.SaveRes
% % %         save([nameimresult 'issave.mat'], 'issave');
% % %     end
% % %     PCaveI = 0;RavgI = tmean(raccI);
% % %     if imAP && ~APcompute
% % %         imAP = 0;
% % %     end
% % %     if ~Error && setting.SaveRes
% % %         if imAP
% % %             save([nameresult 'acc' setting.resultsuffix '_I.mat'], 'PCaveI', 'RavgI', 'ranktime');
% % %         end
% % %         save([nameresult 'acc' setting.resultsuffix '.mat'], 'PCave', 'Ravg', 'ranktime');
% % %     end
% % %     if imAP
% % %         PCave = PCaveI;Ravg = RavgI;
% % %     end
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
modelresult = setting.Modelresult;



function COPYNEW(M1, PATH_F)
M1_N = fullfile(PATH_F, [M1]);
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