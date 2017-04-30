function [acc, C, ranktime] = GetRoundAccuracy(issave, iround, Nfold, setting,img_dir1, dfea, ...
    WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, nameresult, ...
    nameimresult,normmerge, multiview, latentresult1)
% try
global PATH_F;
setting.Pacc = 0;setting.issave = issave;
setting.FoldACC = 0;
[setting.Idx_fold, c, b] = unique(setting.ts_fold_idx);
setting.Label_fold = setting.ts_Fold_label(setting.Idx_fold);
cindex = unique(setting.Label_fold);
latentresult = setting.latentresult;
Modelresult = setting.Modelresult;
setting.Roundstr = '';
setting.RRatiostr = '';
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

if (isempty(fdatabase{1}.Testset) || isempty(fdatabase{1}.Trainset)) || (Nfold > 1)
try
    load([setting.TFstr, '_RoundInfo' num2str(Nfold) '_' num2str(iround) setting.RRatiostr '.mat'], 'Trainset', 'Testset');
    if multiview
        load([setting.TFstr, '_RoundInfoFold' num2str(Nfold) '_' num2str(iround) setting.RRatiostr '.mat'], 'AsubTrain');
    end
catch
    try
        if strcmp(setting.samesplit, setting.dataname)
            setting.TFstr1 = 'TrainInfo/image_Sign_NewT2_1';
            load([setting.TFstr1, '_RoundInfoFold' num2str(Nfold) '_' num2str(iround) setting.RRatiostr '.mat'], 'AsubTrain');
            ids = find(ismember(setting.Asubname, AsubTrain));
            Trainset = find(ismember(setting.ts_fold_idx, ids));
            Testset = setdiff([1:length(setting.ts_fold_idx)], Trainset);
            save([setting.TFstr, '_RoundInfo' num2str(Nfold) '_' num2str(iround) setting.RRatiostr '.mat'], 'Trainset', 'Testset');
            save([setting.TFstr, '_RoundInfoFold' num2str(Nfold) '_' num2str(iround) setting.RRatiostr '.mat'], 'AsubTrain');
        else
            load([setting.TFstr, '_RoundInfo' num2str(Nfold) '_' num2str(iround) setting.RRatiostr '.mat'], 'Trainset', 'Testset');
            if multiview
                load([setting.TFstr, '_RoundInfoFold' num2str(Nfold) '_' num2str(iround) setting.RRatiostr '.mat'], 'AsubTrain');
            end
        end
    catch
        if strcmp(setting.dataname, 'face_YaleBE') || strcmp(setting.dataname, 'face_ORL') || strcmp(setting.dataname(1:8), 'face_PIE')
            Ftrainidx = fullfile('image/dataset', setting.dataname, [num2str(setting.SplitRatio), 'Train']);
            load(fullfile(Ftrainidx, [num2str(iround), '.mat']));
            [~, name] = cellfun(@fileparts, fdatabase{1}.path{1}, 'ErrorHandler', @errorfun, ...
                'UniformOutput', false);
            nameidx = cellfun(@str2num, (name), 'ErrorHandler', @errorfun, ...
                'UniformOutput', true);
            Trainset = ismember(nameidx, trainIdx);
            Trainset = find(Trainset);
            Testset = ismember(nameidx, testIdx);
            Testset = find(Testset);
            if  nnz([sort(trainIdx) - sort(nameidx(Trainset))]) || nnz([sort(testIdx) - sort(nameidx(Testset))])
            sprintf('TrainIdx Error\n')
            pause
            end
%             [Trainset, Testset] = getsplit(b, idx, 1, cindex, setting.SplitRatio);
        else
            try
            load([setting.TFstr, '_Round' num2str(Nfold) '_' num2str(iround) setting.RRatiostr '.mat'], 'idx');
            catch
            idx = cell(1, length(cindex));
            for c = 1:length(cindex)
                tid = reshape(find(setting.Label_fold == cindex(c)), 1, []);
                idx{c} = randperm(length(tid));
                idx{c} = tid(idx{c});
            end
            save([setting.TFstr, '_Round' num2str(Nfold) '_' num2str(iround) setting.RRatiostr '.mat'], 'idx');
            end
            [Trainset, Testset] = getsplit(b, idx, 1, cindex, setting.SplitRatio);
        end
        save([setting.TFstr, '_RoundInfo' num2str(Nfold) '_' num2str(iround) setting.RRatiostr '.mat'], 'Trainset', 'Testset');
        if multiview
            AsubTrain = setting.Asubname(unique(setting.ts_fold_idx(Trainset)));
            save([setting.TFstr, '_RoundInfoFold' num2str(Nfold) '_' num2str(iround) setting.RRatiostr '.mat'], 'AsubTrain');
        end
    end
end
else
    Trainset = fdatabase{1}.Trainset;Testset = fdatabase{1}.Testset;
    fdatabase{1} = rmfield(fdatabase{1}, 'Trainset');
    fdatabase{1} = rmfield(fdatabase{1}, 'Testset');
end



if setting.sRatio ~= 1 
    SStr = '';
    if setting.SplitRatio ~= 70
        SStr = ['_', num2str(setting.SplitRatio)];
    end
    load(fullfile(PATH_F, ['TrainInfo/image_face_PIE_0_ClassRandIdx' SStr '.mat']), 'Vindextr', 'Vindexte')
    load(fullfile(PATH_F, ['TrainInfo/image_face_PIE_0_ClassRand.mat']), 'cindex')
    try
        Tmp = num2str(setting.sRatio);
        load(fullfile(PATH_F, ['TrainInfo/image_face_PIE_0_ClassRandIdxR' SStr num2str(iround)...
            setting.RRatiostr Tmp(2:end) '.mat']), 'idx')
%         1/rand(1,4)
    catch
        nid = [setting.sRatio :(1-setting.sRatio ) / (length(cindex)-1):1];
        nid = nid(cindex);
        idx = [];
        for i = 1:length(cindex)
            for j = 1:length(Vindextr)
                len = length(Vindextr{j}{i});
                ttidx = Vindextr{j}{i};
                len1 = max(round(nid(i)*len), 1);
                idx = [idx; ttidx(1:len1)];
            end
        end
        
% % %         
% % %         nid(:)= 1;
% % %         for i = 1:length(cindex)
% % %             idx = [];
% % %             for j = 1:length(Vindextr)
% % %                 len = length(Vindextr{j}{i});
% % %                 ttidx = Vindextr{j}{i};
% % %                 idx = [idx; ttidx(1:ceil(nid(i)*len))];
% % %             end
% % %             nnz(sort(idx) - sort(Trainset(find(fdatabase{1}.label(Trainset) == i))))
% % %         end
% % %         for i = 1:length(cindex)
% % %             idx = [];
% % %             for j = 1:length(Vindexte)
% % %                 len = length(Vindexte{j}{i});
% % %                 ttidx = Vindexte{j}{i};
% % %                 idx = [idx; ttidx(1:ceil(nid(i)*len))];
% % %             end
% % %             nnz(sort(idx) - sort(Testset(find(fdatabase{1}.label(Testset) == i))))
% % %         end
        save(fullfile(PATH_F, ['TrainInfo/image_face_PIE_0_ClassRandIdxR' SStr num2str(iround)...
            setting.RRatiostr Tmp(2:end) '.mat']), 'idx')
    end
    SRR = length(Trainset) / length(idx);
    Trainset = sort(idx);
    if setting.RC == 1
        setting.C = setting.C / SRR;
    end
    if setting.RC == -1
        setting.C = setting.C * SRR;
    end
end
setting.ts_idx_conf = Trainset;
RMstr = ['Round' num2str(Nfold) '_' num2str(iround)];
if setting.SetNormFea && setting.multiview
    RMstr = [RMstr, 'NF'];
end
if setting.TSREMPTY
    tr_idx = [];ES = 'TE';
else
    tr_idx = setting.tr_idx;ES = '';
end

RMstr = [RMstr];
Usesubset = setting.Usesubset;
if setting.NclassPCA == length(setting.cindex)
    Usesubset = 0;
end
if Usesubset
    Mstr = [RMstr 'G' num2str(setting.Ngroup) '_' num2str(setting.curgroup) '.mat'];
    if setting.PCAenergy > 0
        setting = getPCABYdata(setting, fdatabase, feattype, [tr_idx; ...
            setting.ts_idx(Trainset)], [num2str(setting.NclassPCA), '_' Mstr(1:end-4)]);
    end
else
    Mstr = [RMstr '.mat'];
    if setting.PCAenergy > 0
        setting = getPCABYdata(setting, fdatabase, feattype, [tr_idx; ...
            setting.ts_idx(Trainset)], RMstr);
    end
end
ModelMstr = Mstr;setting.ModelMstr = ModelMstr;
RMstr = [RMstr, ES];
if setting.Usesubset
    Mstr = [RMstr 'G' num2str(setting.Ngroup) '_' num2str(setting.curgroup) '.mat'];
else
    Mstr = [RMstr '.mat'];
end

% % %  ranktime = 0;C = 0;
% % %  acc = -1 * ones(1, setting.Nclass);
% % %  return;


setting.Mstr = Mstr;



try
    if ~isempty(setting.PreModel) && setting.PreModelType == 0
        1/rand([1, 4])
    end
    
    load(fullfile(nameresult,['Result' setting.resultsuffix '-', Mstr]), 'accF', 'ranktimeF'); 
    try
        tmp = accF;
        load(fullfile(nameresult,['Result' setting.resultsuffix1 '-', Mstr]), 'accF', 'ranktimeF'); 
        accF = [tmp;accF;-inf];
    end
    acc = accF;ranktime = ranktimeF;C = 0;
catch
    setting.Fbook = fullfile(setting.Modelresult,['Cbook-', ModelMstr]);
    Snippetmodel = [];

    TemplateINN = setting.TemplateINNC;setting.TemplateINNCK = setting.TemplateINNC;
    if strcmp(cmethod, 'MLR') || strcmp(cmethod, 'RMLR')
    if setting.TestINNC && (~setting.TestKNN)
        if strcmp(cpara{2}, 'KNN') && length(cpara) > 3
        if setting.k == -1
            setting.k = setting.K_INNC;
        else
            if setting.k == -2 
                if setting.MeanNum ~= 0
                setting.k = setting.MeanNum;
                else
                setting.k = 1;
                end
            end
        end
    end
    end
    end
    
    if TemplateINN == -1 || ~setting.TrainINNC
    setting.TemplateINNC = 0;
    if ~setting.TrainINNC
        setting.TemplateINNCK = -1;
    end
    if setting.INNCSP
        setting.cparaINNCSP = [setting.lambda_INNC, setting.K_INNC, setting.blocksize_INNC, ...
            setting.verbose_INNC, -1, setting.beta_INNC];
    end
    end
    if setting.TSREMPTY
    if ~(strcmp(cmethod, 'MLR') || strcmp(cmethod, 'RMLR'))
        setting.tr_idx = [];
    end
    end
    
    if ~strcmp(seachtype, 'knn') && ~strcmp(cmethod, 'CNN')
    setting.platent = setting.Mplatent;
    try
        if isempty(setting.PreModel) || (~isempty(setting.PreModel) && setting.PreModelType ~= 0)
            load(fullfile(setting.Modelresult,['Model-', ModelMstr]), 'Metric');
            Metric;
            if setting.UseRound
                Metric1 = Metric;
                load(fullfile(setting.Modelresult,['Metric_', ...
                    num2str(setting.UseRound), ModelMstr]), 'Metric');
                Metric1{1} = Metric;
                Metric1{2} = Metric;
                Metric = Metric1;
                clear 'Metric1'
            end
        else
            try
                load(fullfile(setting.Modelresult,['Model-', ModelMstr]), 'Metric');
                Metric;
                M1 = Metric{2};
                
                load(fullfile(setting.PreModel,['Metric_1', ModelMstr]), 'Metric');
                M2 = Metric;
                dis = M1 - M2;
                if max(abs(dis(:))) > 1e-6
                    dos(['del ' fullfile(setting.QualityResult,['SPModel-', Mstr])])   
                    1/rand([1, 4]);
                end
                
                try
                    load(fullfile(nameresult,['Result' setting.resultsuffix '-', Mstr]), 'accF', 'ranktimeF'); 
                    try
                        tmp = accF;
                        load(fullfile(nameresult,['Result' setting.resultsuffix1 '-', Mstr]), 'accF', 'ranktimeF'); 
                        accF = [tmp;accF;-inf];
                    end
                    acc = accF;ranktime = ranktimeF;C = 0;
                    return
                catch
                    1/ rand([1, 4])
                end
                
            catch
                load(fullfile(setting.PreModel,['Metric_1', ModelMstr]), 'Metric');
                Metric1 = {[], Metric, 1};
                Metric = Metric1;
                if ~exist(setting.Modelresult)  
                    mkdir(setting.Modelresult)   
                end
                save(fullfile(setting.Modelresult,['Model-', ModelMstr]), 'Metric');
                clear 'Metric1'
            end
            
        end
        if ~exist('Metric')
            dos(['del ', fullfile(setting.Modelresult,['Model-', ModelMstr])])
        end
        Metric;
        if setting.isSnippetRatio && setting.SnippetRatio{1} ~= 1
            if ~ismember(mod(setting.SnippetRatio{3}, 100), setting.LatentInter)
            if setting.SnippetRatio{1} == -2 && setting.isCNN
                Snippetmodel = setting.SnippetRatio{2};
            else
                try
                    load(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
                    if ~isstruct(Snippetmodel) && Snippetmodel == 0
                        dos(['del ' fullfile(setting.QualityResult,['SPModel-', Mstr])])
                        1/rand(1, 4)
                    end
                catch
                    if setting.ReQuality || ~isemtpy(setting.useallstr)
                        load(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
                    else
                        load(fullfile(setting.Modelresult,['SPModel-', Mstr]), 'Snippetmodel');
                        save(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
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
        fprintf('Training Model %d / %d \n', iround, Nfold);
        setting.Mclassfy = 1;setting.Tclassfy = 0;setting.latentresult = latentresult1;
        [accT, CT, ranktime, WConf, Metric, PCACOEFF] =  Classify_2(setting, img_dir1, setting.tr_idx,...
            setting.ts_idx(setting.ts_idx_conf), dfea, ...
            WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, ...
            setting.cindex, nameresult, nameimresult, 0, normmerge, 0, 0);
            try
                save(fullfile(setting.Modelresult,['Model-', ModelMstr]), 'Metric');
            catch
                mkdir(setting.Modelresult);save(fullfile(setting.Modelresult,['Model-', ModelMstr]), 'Metric');
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
    
    if setting.TSREMPTY && setting.useall
    setting.tr_idx = [];
    end
    if isfield(setting.Metric, 'tr_idx')
    setting.Metric_tr_idx = setting.Metric.tr_idx;
    setting.Metric = setting.Metric.model;
    else
    setting.Metric_tr_idx = [];
    end
    
    if setting.useall || isempty(setting.tr_idx)
        if (~strcmp(cmethod, 'MLR') && ~strcmp(cmethod, 'RMLR')) || setting.useall
    if isempty(setting.Metric_tr_idx)
        setting = get_tr_idx(setting);
    end
        end
    end
    if setting.TestOneR
    if strcmp(cmethod, 'MLR')
        try
            load(fullfile(setting.Modelresult, ['Metric_',num2str(setting.TestR), setting.ModelMstr]) ,...
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
        fprintf('Training Model %d / %d \n', iround, Nfold);
        setting.Mclassfy = 1;setting.Tclassfy = 0;setting.latentresult = latentresult1;
        [accT, CT, ranktime, WConf, Metric, PCACOEFF] =  Classify_2(setting, img_dir1, setting.tr_idx,...
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
    if ~setting.TrainError
    setting.ts_idx_conf = Testset; 
    end
    ranktime = 0;C = 0;
    if strcmp(cmethod, 'MLR') || strcmp(cmethod, 'RMLR')
    if setting.TestINNC && (~setting.TestKNN)
        cmethod = 'INNC';
        cpara = [setting.lambda_INNC, setting.K_INNC, setting.blocksize_INNC, ...
            setting.verbose_INNC, -1, setting.beta_INNC];
%     else
%         if knnpara(1)~=1
%             cmethod = 'KNN';
%         end
    end
    end
    
    nameimresultt = fullfile(nameimresult, Mstr(1:end-4));
    ffidx = setting.ts_fold_idx((setting.ts_idx_conf));
    setting.multiview = setting.testmultiview;
    multiview = setting.testmultiview;
    if setting.multiview && length(unique(ffidx)) == length(ffidx)
    setting.multiview = 0;
    multiview = 0;
    end
    try
        if setting.recompute
            load([nameresult 'TTM.mat'], 'PCave', 'Ravg', 'ranktime'); 
        else
            load(fullfile(nameresult,['Result' setting.resultsuffix '-', Mstr]), 'accF', 'ranktimeF');
            if issave
                load([nameimresultt 'issave'], 'issave');
            end
        end
    catch
    fprintf('Testing Model %d / %d \n', iround, Nfold);
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
            [accF, C, ranktimeF] =  Classify_2(setting, img_dir1, setting.tr_idx, setting.ts_idx(setting.ts_idx_conf), dfea, ...
                WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, setting.cindex, nameresult, ...
                nameimresultt, issave, normmerge, multiview, setting.Rconfidence);
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
        [CaccF, CC, CranktimeF] =  Classify_2(setting, img_dir1, setting.tr_idx, setting.ts_idx(setting.ts_idx_conf), dfea, ...
            WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, setting.cindex, nameresult, nameimresultt, issave, normmerge, ...
            multiview, setting.Rconfidence);
    end
    if iscell(CC)
    for kkk = 1:length(CC)
        accF = CaccF{kkk};
        C = CC{kkk};
        ranktimeF = CranktimeF{kkk};

    accFO = accF;
    if accF(end) == -inf
        accF = accFO(end-1);
        save(fullfile(nameresult,['Result' setting.cresultsuffix1{kkk} '-', Mstr]), 'accF', 'ranktimeF'); 
        accF = accFO(1:end-2);
    end
    save(fullfile(nameresult,['Result' setting.cresultsuffix{kkk} '-', Mstr]), 'accF', 'ranktimeF'); 
    save(fullfile(nameresult,['recogRes' setting.cresultsuffix{kkk} '-', Mstr]), 'C'); 
    if issave
        save([nameimresultt 'issave.mat'], 'issave');
    end
    accF = accFO;
    end
    acc = accF;ranktime = ranktimeF;
    
   
    accF = CaccF{setting.Cov_strindex-1};
    C = CC{setting.Cov_strindex-1};
    ranktimeF = CranktimeF{setting.Cov_strindex-1};
    else
        accF = CaccF;
        C = CC;
        ranktimeF = CranktimeF;
    end
    
    

    accFO = accF;
    if accF(end) == -inf
        accF = accFO(end-1);
        try
        save(fullfile(nameresult,['Result' setting.resultsuffix1 '-', Mstr]), 'accF', 'ranktimeF'); 
        end
        accF = accFO(1:end-2);
    end
    try
    save(fullfile(nameresult,['Result' setting.resultsuffix '-', Mstr]), 'accF', 'ranktimeF'); 
%     save(fullfile(nameresult,['recogRes' setting.resultsuffix '-', Mstr]), 'C'); 
    catch
        t = 1;
    end
    if issave
        save([nameimresultt 'issave.mat'], 'issave');
    end
    accF = accFO;
    end
    acc = accF;ranktime = ranktimeF;
end

% catch
%     ranktime = 0;C = 0;
%     acc = -1 * ones(1, setting.Nclass);
% end