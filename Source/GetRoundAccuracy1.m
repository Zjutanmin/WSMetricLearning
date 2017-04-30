function [acc, C, ranktime] = GetRoundAccuracy1(issave, round, Nfold, setting,img_dir1, dfea, ...
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

setting.RRatiostr = '';
% % if setting.SplitRatio ~= 0.25
% %     setting.RRatiostr = ['R_' num2str(setting.SplitRatio)];
% % end

if setting.SplitRatio ~= 0.5 && strcmp(setting.dataname, 'Sign_NewT5')
    setting.RRatiostr = ['R_' num2str(setting.SplitRatio)];
end
if setting.SplitRatio ~= 0.25 && ~strcmp(setting.dataname, 'Sign_NewT5')
    setting.RRatiostr = ['R_' num2str(setting.SplitRatio)];
end
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
setting.ts_idx_conf = Trainset; 

% Trainset= Trainset(1:30);
% Testset= Testset(1:30);



RMstr = ['Round' num2str(Nfold) '_' num2str(round)];
if setting.Usesubset
    Mstr = [RMstr 'G' num2str(setting.Ngroup) '_' num2str(setting.curgroup) '.mat'];
    if setting.PCA > 0
        setting = getPCABYdata(setting, fdatabase, feattype, [setting.tr_idx; ...
            setting.ts_idx(Trainset)], [num2str(setting.NclassPCA), '_' Mstr(1:end-4)]);
    end
else
    Mstr = [RMstr '.mat'];
    if setting.PCA > 0
        setting = getPCABYdata(setting, fdatabase, feattype, [setting.tr_idx; ...
            setting.ts_idx(Trainset)], RMstr);
    end
end


setting.Mstr = Mstr;
Snippetmodel = [];
if ~strcmp(cmethod, 'KNN') && ~strcmp(cmethod, 'CNN')
    setting.platent = setting.Mplatent;
    try
        load(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
        if setting.isSnippetRatio && setting.SnippetRatio{1} ~= 1
            if ~ismember(mod(setting.SnippetRatio{3}, 100), setting.LatentInter)
            if setting.SnippetRatio{1} == -2 && setting.isCNN
                Snippetmodel = setting.SnippetRatio{2};
            else
                try
                    load(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
                catch
                    if setting.ReQuality 
                        load(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
                    else
                        load(fullfile(setting.ModelResult,['SPModel-', Mstr]), 'Snippetmodel');
                        save(fullfile(setting.Qualityresult,['SPModel-', Mstr]), 'Snippetmodel');
                        dos(['del ' fullfile(setting.ModelResult,['SPModel-', Mstr])])
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
        [accT, CT, ranktime, WConf, Metric, PCACOEFF] =  classify_21(setting, img_dir1, setting.tr_idx,...
            setting.ts_idx(setting.ts_idx_conf), dfea, ...
            WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, ...
            setting.cindex, nameresult, nameimresult, 0, normmerge, 0, 0);
            save(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
            mcMetric = accT;
            save(fullfile(setting.Modelresult,['mcModel-', Mstr]), 'mcMetric');

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



ranktime = 0;C = 0;
 acc = -1 * ones(1, setting.Nclass);
% % % % 
% % % %             
% % % % if setting.TestOneR
% % % %     if strcmp(cmethod, 'MLR')
% % % %         try
% % % %             load(fullfile(setting.Modelresult, ['Metric_',num2str(setting.TestR), setting.Mstr]) ,...
% % % %                 'Metric');
% % % %             setting.Metric = {Metric, Metric, setting.Metric{3}};
% % % %         catch
% % % %             ranktime = 0;C = 0;
% % % %             acc = -1 * ones(1, setting.Nclass);
% % % %             return;
% % % %         end
% % % %     end
% % % % end
% % % % 
% % % % 
% % % % if strcmp(cmethod, 'KNN') && setting.isSnippetRatio && setting.SnippetRatio{1} ~= 1
% % % %     setting.platent = setting.Mplatent;
% % % %     try
% % % %         if setting.isSnippetRatio && setting.SnippetRatio{1} ~= 1
% % % %             load(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
% % % %             setting.Snippetmodel = Snippetmodel;
% % % %         end
% % % %     catch
% % % %         fprintf('Training Model %d / %d \n', round, Nfold);
% % % %         setting.Mclassfy = 1;setting.Tclassfy = 0;setting.latentresult = latentresult1;
% % % %         [accT, CT, ranktime, WConf, Metric, PCACOEFF] =  classify_21(setting, img_dir1, setting.tr_idx,...
% % % %             setting.ts_idx(setting.ts_idx_conf), dfea, ...
% % % %             WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, ...
% % % %             setting.cindex, nameresult, nameimresult, 0, normmerge, 0, 0);
% % % %         if setting.isSnippetRatio && setting.SnippetRatio{1} ~= 1
% % % %             Snippetmodel = ranktime;
% % % %             save(fullfile(setting.QualityResult,['SPModel-', Mstr]), 'Snippetmodel');
% % % %             setting.Snippetmodel = Snippetmodel;
% % % %         end
% % % %     end
% % % % end
% % % % 
% % % % % if strcmp(cmethod, 'CNN')
% % % % %     try
% % % % %         load([setting.QulityFeadir '-mCNN_fea.mat'], 'mCNN_fea');
% % % % %     catch
% % % % %         namestr = ['-mCNN_fea' Mstr];nstr = Mstr(1:end-4);computeCNNfea(setting, namestr, fdatabase, feattype, nstr);   
% % % % %     end
% % % % % end
% % % % 
% % % % if ~setting.TrainError
% % % %     setting.ts_idx_conf = Testset; 
% % % % end
% % % % 
% % % % 
% % % % ranktimeF = 0;C = 0;
% % % % nameimresultt = fullfile(nameimresult, Mstr(1:end-4));
% % % % try
% % % % if setting.recompute
% % % % load([nameresult 'TTM.mat'], 'PCave', 'Ravg', 'ranktime'); 
% % % % else
% % % %     load(fullfile(nameresult,['Result' setting.resultsuffix '-', Mstr]), 'accF', 'ranktimeF'); 
% % % %     if issave
% % % %         load([nameimresultt 'issave'], 'issave');
% % % %     end
% % % % end
% % % % catch
% % % %     fprintf('Testing Model %d / %d \n', round, Nfold);
% % % %     setting.platent = setting.Tplatent;
% % % %     setting.Mclassfy = 0;setting.Tclassfy = 0;
% % % %     setting.latentresult = latentresult;
% % % %     setting.Modelresult = Modelresult;
% % % %     if iscell(setting.Samplevoted)
% % % %         setting.FoldACC = 1;
% % % %         Samplevoted1 = setting.Samplevoted;
% % % %         TaccF = cell(1, length(cindex));
% % % %         for ii = 1:setting.Rconfidence(2)
% % % %             setting.Roundstr = [num2str(ii), '-', num2str(setting.Rconfidence(2))];
% % % %             setting.Samplevoted = Samplevoted1{ii};
% % % %             [accF, C, ranktimeF] =  classify_21(setting, img_dir1, setting.tr_idx, setting.ts_idx(setting.ts_idx_conf), dfea, ...
% % % %                 WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, setting.cindex, nameresult, ...
% % % %                 nameimresultt, issave, normmerge, multiview, setting.Rconfidence);
% % % %             for t = 1:length(cindex)
% % % %                 TaccF{t}(:, ii) = (accF{t})';
% % % %             end
% % % %         end
% % % %         clear 'accF'
% % % %         for t = 1:length(cindex)
% % % %             trueF = sum(TaccF{t}, 2);
% % % %             prob = trueF / setting.Rconfidence(2);
% % % %             accF(t) = length(find(trueF)) / length((prob));
% % % %         end
% % % %     else
% % % %         [accF, C, ranktimeF] =  classify_21(setting, img_dir1, setting.tr_idx, setting.ts_idx(setting.ts_idx_conf), dfea, ...
% % % %             WTAfea, fdatabase, feattype,knnpara, cpara, cmethod, setting.cindex, nameresult, nameimresultt, issave, normmerge, ...
% % % %             multiview, setting.Rconfidence);
% % % %     end
% % % %     
% % % %     save(fullfile(nameresult,['Result' setting.resultsuffix '-', Mstr]), 'accF', 'ranktimeF'); 
% % % %     if issave
% % % %         save([nameimresultt 'issave'], 'issave');
% % % %     end
% % % % end
% % % % acc = accF;ranktime = ranktimeF;

