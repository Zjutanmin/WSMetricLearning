function Snippetmodel = GetSnippetModel(Metric, ntrain, CasTest, ...
    Samplevoted, NotRatio, labelmap, isWTA, ts_idx,  ts_label, tr_imname, ts_imname,cmethod, ...
    WTAindex, dataX1, dataX2, Y, SnippetRatio, conf_tr_fea, setting)
Snippetmodel = [];
Psvmtrain = setting.Psvmtrain;
if length(setting.FeatConf) < length(setting.feattype) 
    if ismember(SnippetRatio{3}, setting.FeatureInter)
        if ~isfield(setting, 'Cdistance')
            confrange = [];
            for i = 1:length(setting.FeatConf)
                confrange = [confrange, setting.rdim{setting.FeatConf(i)}(1):...
                    setting.rdim{setting.FeatConf(i)}(2)];
            end
            dataX1_Conf = dataX1(:, setdiff([1: size(dataX1, 2)], confrange));
            dataX2_Conf = dataX2(:, setdiff([1: size(dataX1, 2)], confrange));
            dataX1 = dataX1(:, confrange);dataX2 = dataX2(:, confrange);
            Cdistance = ComputeDistance([dataX1_Conf;dataX2_Conf], ntrain, size(dataX2, 1));
        else
            Cdistance = setting.Cdistance;
        end
    end
end
if setting.isboost
    s_Metric = setting.Metric;
    s_KNNlatent = 1;
else
    [s_Metric, s_KNNlatent] = getmetricTest(Metric, CasTest, setting, ntrain);
end

idx = find(Samplevoted);
Ypos = cell2mat(Y(:, 1));Ypos = Ypos(idx);

if setting.INNCSP
    [lambda_INNC, K_INNC, blocksize_INNC, verbose_INNC, beta_INNC] ...
            = GetINNCpara(setting.cparaINNCSP);
    if blocksize_INNC == -1
        blocksize_INNC = size(dataX2,1); 
    end
    idx = find(Samplevoted);
    [a, ~, ~, ~, ~, Resb]  = INNC(GetReFea(dataX1, ...
        s_Metric), setting.Label, GetReFea(dataX2(idx,:), s_Metric), ts_label(idx), ...
        lambda_INNC, K_INNC, blocksize_INNC, verbose_INNC, beta_INNC, setting.innerfea, length(setting.labelmap), 1);
    IDX = ones(length(ts_label),length(setting.labelmap));
    distance = zeros(length(ts_label),length(setting.labelmap));
    IDX(idx, :) = a;distance(idx, :) =  -Resb;                                    
else
switch setting.cmethodorg
    case 'MLR'
        if setting.USEINNC
            [IDX, ~, ~, ~, ~, distance]    = INNC(GetReFea(dataX1, ...
                s_Metric), setting.labelmap,GetReFea(dataX2, s_Metric), ts_label, ...
                setting.lambda_INNC, setting.K_INNC, setting.blocksize_INNC, ...
                setting.verbose_INNC, setting.beta_INNC, setting.innerfea, ntrain);
            distance = -distance;
        else
            [IDX, distance] = GetRank_WTA_B({setting.Dic, setting.lamda_dic, setting.latent, length(setting.rotate)}, ...
                setting.isboost, Samplevoted, NotRatio, ...
                setting.BitCount, setting.K, ...
                isWTA, setting.WTAwithraw, s_Metric, WTAindex, setting.innerfea, dataX1, dataX2, ...
                ntrain, s_KNNlatent);   
            
        end
    case 'MultiSVM'
        idx = find(Samplevoted);
        [a, b] = SVMtest_S(dataX2(idx,:), Ypos, Psvmtrain, s_Metric);
        ntrain = setting.knn;
        IDX = ones(length(Ypos), ntrain);
        distance = zeros(length(Ypos), ntrain);
        [IDX(idx, :), distance(idx, :)] = GetSVMDis(Psvmtrain, a, b, ...
            s_Metric.Label, s_Metric.nr_class, ntrain);
    
end
end

if setting.MeanT && setting.AllTemp
    IDX = IDX(:, 2:end);IDX = ts_label(IDX);distance = distance(:, 2:end);
end

[IDX1, distance1] = Multi2SigIDX(IDX(idx, :), setting, distance(idx, :));                         
IDX = ones(size(IDX, 1), length(setting.labelmap));
distance = zeros(size(IDX, 1), length(setting.labelmap));
IDX(idx, :) = IDX1;distance(idx, :) = distance1;
clear 'IDX1';clear 'distance1';
                                
Yrank = ones(size(IDX, 1), 1);
if length(SnippetRatio) > 2 && ismember(SnippetRatio{3}, setting.FeatureInter)
    vec2ind = sub2ind(size(Cdistance), idx, IDX(idx, 1));
    Yrank(idx) = 1 ./ Cdistance(vec2ind);
end
                                
C = (IDX(idx, :))';
label = C(1,:);Clabel = label';
ylabel = double(Clabel == ts_label(idx));

cur_ts_label = ts_label(idx);
cur_ts_imname = GetSalName(ts_imname(idx));

if length(tr_imname) > 1
pre_ts_imname = GetSalName(tr_imname(Clabel));
[aa,bb,cc] = unique(cur_ts_label);
labelinfo = aa;labelimname = cell(length(aa), 2);preimname = cell(length(aa), 2);
for jj = 1:length(aa)
    indtmp = find(cc == jj);
    id1tmp = find(ylabel(indtmp) == 1);
    labelimname{jj, 1} = cur_ts_imname(indtmp(id1tmp));
    preimname{jj, 1} = pre_ts_imname(indtmp(id1tmp));
    
    id2tmp = find(ylabel(indtmp) == 0);
    labelimname{jj, 2} = cur_ts_imname(indtmp(id2tmp));
    preimname{jj, 2} = pre_ts_imname(indtmp(id2tmp));
end
SampleQulityT.labelinfo = labelinfo;
SampleQulityT.labelimname = labelimname;
SampleQulityT.preimname = preimname;
% % try
% %     load(fullfile(setting.Modelresult, ['SampleQulitT_',setting.resultsuffix,setting.Mstr]) ,'SampleQulityT');
% % catch
% %     save(fullfile(setting.Modelresult, ['SampleQulitT_',setting.resultsuffix,setting.Mstr]) ,'SampleQulityT');
% % end
end

if setting.UsePos
    return;
end
if setting.isCNN
    save(fullfile(setting.Modelresult,['SampleQulitT_',setting.resultsuffix,setting.Mstr]) ,'SampleQulityT');
    nstr1 = '';nstr = '';          
    setting.QulityFeadir = [setting.Modelresult, '/'];
    fprintf('File name %s\n', [setting.QulityFeadir, '_' nstr1, 'ResProb_', nstr, '.mat'])
    pause
    try
        load([setting.QulityFeadir, '_' nstr1, 'ResProb_', nstr, '.mat'], 'prob', 'NameList')
                                   
    catch
        fprintf('Can not load CNN Prob in Round %d\n', jjj)
        pause;
    end
    Cscore =  Computefeat(fdatabase, feattype, ...
        ts_idx(idx), setting, setting.labelmap, nstr, nstr1);
    nn = size(Cscore, 2)/2;
    Cscore = [mean(Cscore(:,nn+1:end), 2) - ...
        mean(Cscore(:,1:nn), 2)];                
else
    [Cscore, Clabel, RINDEX, Cmaxmin] = SelectBetterSPScore(setting.Enorm, setting.TrainInfo, setting.Nclass, (distance(idx, :))',...
    (IDX(idx, :))', 0, conf_tr_fea(idx,:), LoadQulityFea(setting.QulityFeadir, ts_idx(idx), setting.Loadfeamethod), ...
    cmethod, SnippetRatio, Ypos, Yrank(idx), [], []);
% % % if setting.CMaxMin
% % %     RINDEX = cumsum(RINDEX);
% % %     RINDEX = [0, RINDEX];
% % %     Cmaxmin = [];
% % %     for i = 1:length(RINDEX) - 1
% % %         Imax = max(max(Cscore(:, RINDEX(i)+1:RINDEX(i+1))));
% % %         Imin = min(min(Cscore(:, RINDEX(i)+1:RINDEX(i+1))));
% % %         if abs(Imax - Imin) > 1e-6
% % %             Cscore(:, RINDEX(i)+1:RINDEX(i+1)) = (Cscore(:,...
% % %                 RINDEX(i)+1:RINDEX(i+1)) - Imin) / (Imax - Imin);
% % %         end
% % %         Cmaxmin = [Cmaxmin, Imax, Imin];
% % %     end
% % % end
end
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
        savehistfigure(Cscore, ylabel, setting);
    end
else
    ylabel(find(ylabel == 0)) = -1;
    [Snippetmodel, C, a, b] = GetSnippetModelBySVM(setting, ylabel, Cscore, Clabel);
end
if floor(SnippetRatio{3}) ~= SnippetRatio{3}
    Snippetmodel.RINDEX = RINDEX;
    Snippetmodel.Cmaxmin = Cmaxmin;
end