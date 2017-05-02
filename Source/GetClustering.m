function [acc, C, ranktime] = GetClustering(issave, round, Nfold, setting,img_dir1, dfea, ...
    WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, nameresult, ...
    nameimresult,normmerge, multiview, latentresult1)
setting.Pacc = 0;setting.issave = issave;
setting.FoldACC = 0;
[setting.Idx_fold, c, b] = unique(setting.ts_fold_idx);
setting.Label_fold = setting.ts_Fold_label(setting.Idx_fold);
cindex = unique(setting.Label_fold);
latentresult = setting.latentresult;
Modelresult = setting.Modelresult;

setting.Roundstr = '';
% setting.MetricL2 = 0;
setting.RRatiostr = '';
% % if setting.SplitRatio ~= 0.25
% %     setting.RRatiostr = ['R_' num2str(setting.SplitRatio)];
% % end
seachtype = 'non';
if strcmp(cmethod, 'KNN') || strcmp(cmethod, 'INNC') 
    seachtype = 'knn';
end


if setting.SplitRatio ~= 0.5 && strcmp(setting.dataname, 'Sign_NewT5')
    setting.RRatiostr = ['R_' num2str(setting.SplitRatio)];
end
if setting.SplitRatio ~= 0.25 && ~strcmp(setting.dataname, 'Sign_NewT5')
    setting.RRatiostr = ['R_' num2str(setting.SplitRatio)];
end

% if ~isfield(fdatabase{1}, 'Testset') || ~isfield(fdatabase{1},
% 'Trainset')
if ~setting.testonly
if isempty(fdatabase{1}.Testset) || isempty(fdatabase{1}.Trainset)
try
    load([setting.TFstr, '_RoundInfo' num2str(Nfold) '_' num2str(round) setting.RRatiostr '.mat'], 'Trainset', 'Testset');
    load([setting.TFstr, '_RoundInfoFold' num2str(Nfold) '_' num2str(round) setting.RRatiostr '.mat'], 'AsubTrain');
catch
    try
        if strcmp(setting.samesplit, setting.dataname)
            setting.TFstr1 = 'TrainInfo\image_Sign_NewT2_1';
            load([setting.TFstr1, '_RoundInfoFold' num2str(Nfold) '_' num2str(round) setting.RRatiostr '.mat'], 'AsubTrain');
            ids = find(ismember(setting.Asubname, AsubTrain));
            Trainset = find(ismember(setting.ts_fold_idx, ids));
            Testset = setdiff([1:length(setting.ts_fold_idx)], Trainset);
            save([setting.TFstr, '_RoundInfo' num2str(Nfold) '_' num2str(round) setting.RRatiostr '.mat'], 'Trainset', 'Testset');
            save([setting.TFstr, '_RoundInfoFold' num2str(Nfold) '_' num2str(round) setting.RRatiostr '.mat'], 'AsubTrain');
        else
            load([setting.TFstr, '_RoundInfo' num2str(Nfold) '_' num2str(round) setting.RRatiostr '.mat'], 'Trainset', 'Testset');
            load([setting.TFstr, '_RoundInfoFold' num2str(Nfold) '_' num2str(round) setting.RRatiostr '.mat'], 'AsubTrain');
        end
    catch
        try
            load([setting.TFstr, '_Round' num2str(Nfold) '_' num2str(round) setting.RRatiostr '.mat'], 'idx');
        catch
            idx = cell(1, length(cindex));
            for c = 1:length(cindex)
                tid = find(setting.Label_fold == cindex(c));
                idx{c} = randperm(length(tid));
                idx{c} = tid(idx{c});
            end
            save([setting.TFstr, '_Round' num2str(Nfold) '_' num2str(round) setting.RRatiostr '.mat'], 'idx');
        end
        [Trainset, Testset] = getsplit(b, idx, 1, cindex, setting.SplitRatio);
        save([setting.TFstr, '_RoundInfo' num2str(Nfold) '_' num2str(round) setting.RRatiostr '.mat'], 'Trainset', 'Testset');
        AsubTrain = setting.Asubname(unique(setting.ts_fold_idx(Trainset)));
        save([setting.TFstr, '_RoundInfoFold' num2str(Nfold) '_' num2str(round) setting.RRatiostr '.mat'], 'AsubTrain');
    end
end
else
    Trainset = fdatabase{1}.Trainset;Testset = fdatabase{1}.Testset;
    fdatabase{1} = rmfield(fdatabase{1}, 'Trainset');
    fdatabase{1} = rmfield(fdatabase{1}, 'Testset');
end
else
    Trainset = fdatabase{1}.Trainset;Testset = fdatabase{1}.Testset;
    fdatabase{1} = rmfield(fdatabase{1}, 'Trainset');
    fdatabase{1} = rmfield(fdatabase{1}, 'Testset');
end

% % id = randperm(length(Trainset));
% % Trainset = Trainset(id(1:100));
% % id = randperm(length(Testset));
% % Testset = Testset(id(1:100));

setting.ts_idx_conf = Trainset; 
RMstr = ['Round' num2str(Nfold) '_' num2str(round)];
if setting.Usesubset
    Mstr = [RMstr 'G' num2str(setting.Ngroup) '_' num2str(setting.curgroup) '.mat'];
    if setting.PCAenergy > 0
        setting = getPCABYdata(setting, fdatabase, feattype, [setting.tr_idx; ...
            setting.ts_idx(Trainset)], [num2str(setting.NclassPCA), '_' Mstr(1:end-4)]);
    end
else
    Mstr = [RMstr '.mat'];
    if setting.PCAenergy > 0
        setting = getPCABYdata(setting, fdatabase, feattype, [setting.tr_idx; ...
            setting.ts_idx(Trainset)], RMstr);
    end
end
setting.redo = 0;
% %  ranktime = 0;C = 0;
% %  acc = -1 * ones(1, setting.Nclass);
setting.Mstr = Mstr;
setting.Fbook = fullfile(setting.Modelresult,['Cbook-', Mstr]);
Snippetmodel = [];
setting.ShowExist = 1;
TemplateINN = setting.TemplateINNC;
if TemplateINN == -1
    setting.TemplateINNC = 0;
end
if ~strcmp(seachtype, 'knn') && ~strcmp(cmethod, 'CNN')
    setting.platent = setting.Mplatent;
    try
        if setting.testonly
            try
                load(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
            catch
                idx = strfind(setting.Modelresult, setting.dataname);
                load(fullfile('SVMModel/Sign_test', setting.Modelresult(idx+length(setting.dataname):end),['Model-', Mstr]), 'Metric');
                if ~exist(setting.Modelresult)
                                mkdir(setting.Modelresult)
                end
                save(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
            end
        else 
        try
            setting.redo = loadx(setting.ShowExist, fullfile(setting.Modelresult,['Model-', Mstr]), 0);
        catch
            setting.redo = 1;
            load('abcdefg.mat')
        end
        end
        
        load(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
        
        fullfile(setting.Modelresult,['Model-', Mstr])
        
        if setting.testonly
            fsize1 = size(setting.PCACOEFF{1}, 2);
            fsize2 = size(Metric{2}, 1);
            if fsize1~=fsize2
                fprintf('dimension mis-match: \n The feature dimension %d, but the size of Metric is %d * %d\n', fsize1, fsize2, fsize2)
                pause;
                acc = 0;
                C = [];ranktime = 0;
                return;
            end
        end
        if setting.isSnippetRatio && setting.SnippetRatio{1} ~= 1
            if ~ismember(mod(setting.SnippetRatio{3}, 100), setting.LatentInter)
            if setting.SnippetRatio{1} == -2 && setting.isCNN
                Snippetmodel = setting.SnippetRatio{2};
            else
                try
                    
                    if setting.testonly
                        try
                            load(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
                        catch
                            idx = strfind(setting.QualityResult, setting.dataname);
                            load(fullfile('SVMModel/Sign_test', setting.QualityResult(idx+length(setting.dataname):end),['SPModel-', Mstr]), 'Snippetmodel');
                            if ~exist(setting.QualityResult)
                                mkdir(setting.QualityResult)
                            end
                                save(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
                        end
                    else
                        load(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
                    end
            
                catch
                    if setting.ReQuality || ~isemtpy(setting.useallstr)
                        load(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
                    else
                        load(fullfile(setting.Modelresult,['SPModel-', Mstr]), 'Snippetmodel');
                        save(fullfile(setting.Qualityresult,['SPModel-', Mstr]), 'Snippetmodel');
                        dos(['del ' fullfile(setting.Modelresult,['SPModel-', Mstr])])
                    end
                end
            end
            setting.Snippetmodel = Snippetmodel;
            else
                setting.Snippetmodel = 0;
            end
        end
        if setting.UsePos
            load(fullfile(setting.Modelresult, ['SampleQulitT_',setting.resultsuffix,setting.Mstr]) ,'SampleQulityT');
        end
    catch
        fprintf('Training Model %d / %d \n', round, Nfold);
        setting.Mclassfy = 1;setting.Tclassfy = 0;setting.latentresult = latentresult1;
        [accT, CT, ranktime, WConf, Metric, PCACOEFF] =  Classify_2(setting, img_dir1, setting.tr_idx,...
            setting.ts_idx(setting.ts_idx_conf), dfea, ...
            WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, ...
            setting.cindex, nameresult, nameimresult, 0, normmerge, 0, 0);
            try
                save(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
            catch
                mkdir(setting.Modelresult);save(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
            end
            mcMetric = accT;
%             save(fullfile(setting.Modelresult,['mcModel-', Mstr]), 'mcMetric');

        if setting.isSnippetRatio && setting.SnippetRatio{1} ~= 1
            Snippetmodel = ranktime;
            save(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
            setting.Snippetmodel = Snippetmodel;
        end
    end
    setting.Metric = Metric;
else
    setting.Metric = [];
    setting.Snippetmodel = [];
    if ~isfield(setting, 'PCACOEFF')
        setting.PCACOEFF = {};
    end
end

if isfield(setting.Metric, 'tr_idx')
    setting.Metric_tr_idx = setting.Metric.tr_idx;
    setting.Metric = setting.Metric.model;
else
    setting.Metric_tr_idx = [];
end

if setting.useall || isempty(setting.tr_idx)
    if isempty(setting.Metric_tr_idx)
        setting = get_tr_idx(setting);
    end
end

            
if setting.TestOneR
    if strcmp(cmethod, 'MLR')
        try
            loadx(setting.ShowExist, fullfile(setting.Modelresult, ['Metric_',num2str(setting.TestR), setting.Mstr]) ,...
                0);
            load(fullfile(setting.Modelresult, ['Metric_',num2str(setting.TestR), setting.Mstr]) ,...
                'Metric');
            setting.Metric = {Metric, Metric, setting.Metric{3}};
        catch
            ranktime = 0;C = 0;
            acc = -1 * ones(1, setting.Nclass);
            return;
        end
    end
end


if strcmp(seachtype, 'knn') && setting.isSnippetRatio && setting.SnippetRatio{1} ~= 1
    setting.platent = setting.Mplatent;
    try
        if setting.isSnippetRatio && setting.SnippetRatio{1} ~= 1
            load(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
            setting.Snippetmodel = Snippetmodel;
        end
    catch
        fprintf('Training Model %d / %d \n', round, Nfold);
        setting.Mclassfy = 1;setting.Tclassfy = 0;setting.latentresult = latentresult1;
        [accT, CT, ranktime, WConf, Metric, PCACOEFF] =  cluster(setting, img_dir1, setting.tr_idx,...
            setting.ts_idx(setting.ts_idx_conf), dfea, ...
            WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, ...
            setting.cindex, nameresult, nameimresult, 0, normmerge, 0, 0);
        if setting.isSnippetRatio && setting.SnippetRatio{1} ~= 1
            Snippetmodel = ranktime;
            save(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
            setting.Snippetmodel = Snippetmodel;
        end
    end
end

% if strcmp(cmethod, 'CNN')
%     try
%         load([setting.QulityFeadir '-mCNN_fea.mat'], 'mCNN_fea');
%     catch
%         namestr = ['-mCNN_fea' Mstr];nstr = Mstr(1:end-4);computeCNNfea(setting, namestr, fdatabase, feattype, nstr);   
%     end
% end

if ~setting.TrainError
    setting.ts_idx_conf = Testset; 
end

% if setting.MeanT && ~setting.AllTemp && setting.TemplateINNC
% if TemplateINNC
%     setting.MetricL2 = 1;
% end

ranktime = 0;C = 0;
%  acc = -1 * ones(1, setting.Nclass);

if TemplateINN && (~setting.TestKNN)
    if TemplateINN~=2
    cmethod = 'INNC';
    cpara = [setting.lambda_INNC, setting.K_INNC, setting.blocksize_INNC, ...
        setting.verbose_INNC, -1, setting.beta_INNC];
    end
end

nameimresultt = fullfile(nameimresult, Mstr(1:end-4));
fprintf('Testing Model %d / %d \n', round, Nfold);
    setting.platent = setting.Tplatent;
    setting.Mclassfy = 0;setting.Tclassfy = 0;
    setting.latentresult = latentresult;
    setting.Modelresult = Modelresult;
    if iscell(setting.Samplevoted)
        setting.FoldACC = 1;
        Samplevoted1 = setting.Samplevoted;
        TaccF = cell(1, length(cindex));
        for ii = 1:setting.Rconfidence(2)
            setting.Roundstr = [num2str(ii), '-', num2str(setting.Rconfidence(2))];
            setting.Samplevoted = Samplevoted1{ii};
            [accF, C, ranktimeF] =  cluster(setting, ...
                setting.ts_idx(setting.ts_idx_conf), feattype);
        
            for t = 1:length(cindex)
                TaccF{t}(:, ii) = (accF{t})';
            end
        end
        clear 'accF'
        for t = 1:length(cindex)
            trueF = sum(TaccF{t}, 2);
            prob = trueF / setting.Rconfidence(2);
            accF(t) = length(find(trueF)) / length((prob));
        end
    else
        [accF, C, ranktimeF] =  cluster(setting, ...
            setting.ts_idx(setting.ts_idx_conf), feattype);
    end
    acc = accF;ranktime = ranktimeF;
    
function [KMean, Label, filename] =  cluster(setting, ts_idx, feattype)
if isfield(setting, 'ts_idx_conf') && ~isempty(setting.ts_idx_conf)
    Range = setting.ts_idx_conf;
else
    Range = [1:length(ts_idx)];
end
Samplevoted = setting.Samplevoted;
Samplevoted = Samplevoted(Range);
if setting.Tclassfy && setting.confidence
    Samplevoted(:) = 1;
end
TFstr = setting.TFstr;       
data_feaA = [];
for jj = 1:length(feattype)
    load([TFstr, '_', setting.feaname{jj}, '_data.mat'], 'data_fea', 'data_label')
    data_feaA = [data_feaA, myNormlize(data_fea, setting.NormFea, ...
        length(feattype))];
end  
data_fea = data_feaA;clear 'data_feaA'
load([TFstr, '_info_data.mat'], 'data_imsize', 'data_imname')
data_label = data_label(:);
data_imname = data_imname(:);
curr_idx = ts_idx; 
curr_ts_label = data_label(curr_idx);        
curr_ts_fea = data_fea(curr_idx,:);
curr_ts_imname = data_imname(curr_idx);
setting.NormFea1 = {[], 1};
setting.FeatConf = setdiff([1:length(feattype)], setting.AidConf);
if setting.PCAenergy   %%%PCA for training data
    curr_ts_fea = GetPCAFeature(setting.PCAMethod, setting.featsize, ...
        setting.LocalPCA, setting.NormFea, setting.NormFea1, ...
        [curr_ts_fea, curr_ts_label], setting.PCACOEFF, setting.FeatConf);    
end
idx = find(Samplevoted);
filename = curr_ts_imname(idx);
Metric = setting.Metric{2};
if ~isempty(Metric)
    [vecs,vals] = eig(0.5 * (Metric + Metric'));
    L = real(abs(vals)).^0.5 * vecs';
    curr_ts_fea = L*curr_ts_fea';
else
    curr_ts_fea = curr_ts_fea';
end
[KMean, Label] = vl_kmeans(curr_ts_fea, setting.K);
