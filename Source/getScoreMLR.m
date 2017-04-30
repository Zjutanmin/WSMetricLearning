function [AllScore, ranktime, tr_size, Metric, PCACOEFF] = getScoreMLR(...
    feattype, ts_fold_idx, ts_idx, tr_idx, setting, fdatabase, ...
    Mstr, Samplevoted, NotRatio, cindex, normmerge, knnpara, cpara)
tr_size = [];

% % % % setting.Flatent = 1;
% % % % % setting.Mclassfy = 0;
% % % % % setting.testSOutput = 1;
% % % % % 
% ts_idx = ts_idx(1:300);
% ts_fold_idx = ts_fold_idx(1:300);
% Samplevoted = Samplevoted(1:300);
% NotRatio = NotRatio(1:300,:);
% setting.ts_idx_conf = setting.ts_idx_conf(1:300);

%%6GB memory

% maxnum = max(length(pos)*10, maxnum+length(pos));
% %6GB file limit
% bytelimit = 3*2^31;

Mstr = setting.Mstr;
addpath(genpath('mlr/'));
PCACOEFF = [];

tr_label = zeros(length(tr_idx), 1);ts_label = zeros(length(ts_idx), 1);
clabel = unique(fdatabase{1}.label);
Lscore = Inf * ones(length(ts_idx), length(tr_idx));
% AllScore = zeros(size(Lscore));
labelmap = setting.labelmap;
ranktime = 0;
% if setting.Mplatent == 0 && setting.Tplatent > 0
%     [ctr_fea, tr_label] = GetFeastr(fdatabase, feattype, tr_idx, setting, labelmap);
% else
%    
    try
        load(fullfile(setting.Modelresult,['ctr_fea-', Mstr]), 'ctr_fea', 'tr_label');
    catch
        [ctr_fea, tr_label] = GetFeastr(fdatabase, feattype, tr_idx, setting, labelmap);
        save(fullfile(setting.Modelresult,['ctr_fea-', Mstr]), 'ctr_fea', 'tr_label');
    end 
% end
    jj = 1;fsize = [];
    for i = 1:length(feattype)
        bookfeattype = length(fdatabase{i}.path);
        for j = 1:length(bookfeattype)
            fpath = fdatabase{i}.path{j}{tr_idx(jj)};load(fpath, 'fea', 'label');
            fsize = [fsize; size(fea{1}{1})];
        end
    end
    setting.fsize = [fsize(1,1:2), sum(fsize(:,3))];
    setting.tr_label = tr_label;
    tr_imname = GetTrname(tr_idx, fdatabase);

    if setting.Mclassfy
        try
            if setting.PCA > 0
                load(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric', 'PCACOEFF');
            else
                load(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
            end
        catch
            %%%% get latent testing samples
            Metric = eye(prod(setting.fsize));
          
            
            th = tic;
            [dataX, dataY, numSign, latentinfo, ts_imname] = GetSampleLatent(1, ts_fold_idx, ts_idx, tr_idx, Samplevoted, NotRatio, ...
                ctr_fea, Metric, feattype, fdatabase, setting, Lscore);
            th = toc(th);
            fprintf('Time for Get latent Samples : %d \n', th)
            
            index = find(~cellfun(@isempty, dataX));
            dataX = dataX(index);dataY = dataY(index,:);
            Ntrain = size(ctr_fea, 1);
            
            th = tic;
            if setting.PCA
%                 if setting.PCA > 0
%                     [PCACOEFF{1}, PCACOEFF{2}, dataX] = GetPCAfea([ctr_fea;cell2mat(dataX)], setting.PCA);
%                 else
%                     [PCACOEFF{1}, PCACOEFF{2}, TrainX] = GetPCAfea(ctr_fea, -setting.PCA);
%                     TestData = (cell2mat(dataX) - repmat(PCACOEFF{2}, [size(cell2mat(dataX),1),1])) * PCACOEFF{1};
%                     dataX = [TrainX; TestData]; 
%                     clear 'TestData';clear 'TrainX';
%                 end
                [PCACOEFF{1}, PCACOEFF{2}, dataX] = GetPCAfea(ctr_fea, setting.PCA, cell2mat(dataX), setting.PCACOEFF);
                setting.COEFF = PCACOEFF{1};setting.xmean = PCACOEFF{2};
                dataX = mat2cell(dataX, [ones(1, Ntrain), numSign], size(dataX, 2));
            end
            th = toc(th);
            fprintf('Time for PCA : %d \n', th)
            
            th = tic;
            setting.numSign = [ones(1, size(ctr_fea,1)), numSign(index)];
            
%             [Metric, Xi, D] = mlr_train_latent(dataX, [cell(size(ctr_fea,1), 2); dataY], ...
%                 setting.numSign, setting.C,  setting.LOSS,  setting.k,  setting.REG);

            Tlatentinfo = latentinfo;
            latentfile = fullfile(setting.latentresult,['latent', Mstr(1:end-4), setting.svotestr], 'Train');
            dataX([1:Ntrain]) = ChangeRotateOrd(dataX([1:Ntrain]), length(setting.rotate));
            
            th= tic(th);
            
            [Metric, Xi, D] = mlr_train_latent(dataX, [cell(Ntrain, 2); dataY], ...
                setting.numSign, Tlatentinfo, latentfile, setting.rotate, setting.rawsize, ...
                ts_imname, tr_imname, setting.Asubname, setting.C,  setting.LOSS,  setting.k,  setting.REG);

            ranktime = toc(th);
            
            fprintf('Time for metric learning : %d \n', th)
            if setting.PCA > 0
                save(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric', 'PCACOEFF');
            else
                save(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
            end
        end
    end
    if ~setting.Mclassfy   %%%%testing
        try
            if setting.PCA > 0
                load(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric', 'PCACOEFF');
            else
                load(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric');
                PCACOEFF = setting.PCACOEFF;
            end
            load(fullfile(setting.latentresult,['latent', Mstr(1:end-4), setting.svotestr, '.mat']), 'LX', 'LY', 'LL', 'LR', 'Lscore', 'ranktime');
        catch
            setting.PCACOEFF = PCACOEFF;
            if setting.PCA
                ctr_fea = (ctr_fea - repmat(setting.PCACOEFF{2}, [size(ctr_fea,1),1])) * setting.PCACOEFF{1};
            end
            th = tic;
            try
                load(fullfile(setting.Modelresult,['Model-', Mstr]), 'Metric', 'PCACOEFF');
            catch
                fprintf('Error Load for Model\n');
                pause;
            end
            latentfile = fullfile(setting.latentresult,['latent', Mstr(1:end-4), setting.svotestr], 'Test');
            
            if setting.Flatent
                sizet = size(ctr_fea);Nrotate = length(setting.rotate);
                ctr_fea = permute(reshape(ctr_fea, [Nrotate, size(ctr_fea, 1) / Nrotate,...
                    size(ctr_fea, 2)]), [2 1 3]);
                ctr_fea = reshape(ctr_fea, sizet);
            end
            
            [X, Y, numSign, latentinfo, ts_imname, LX, LY, LL, LR, Lscore, Lmargin, SignBased] = GetSampleLatent(0, ts_fold_idx, ts_idx, tr_idx,...
                Samplevoted, NotRatio, ctr_fea, Metric, feattype, fdatabase, setting, Lscore);
            ranktime = toc(th);
            
            save(fullfile(setting.latentresult,['latent', Mstr(1:end-4), setting.svotestr, '.mat']), 'LX', 'LY', 'LL', 'LR', 'Lscore', 'Lmargin', 'ranktime');      
            ffile = fullfile(setting.latentresult,['latent', Mstr(1:end-4), setting.svotestr], 'Test');
            
%             if SignBased
%                 ShowLatent(ffile, latentinfo, ts_imname, tr_imname, setting.Asubname, setting.rotate, setting.rawsize, 2);
%             else
%                 ShowLatent(ffile, latentinfo, ts_imname, tr_imname, setting.Asubname, setting.rotate, setting.rawsize, 3);
%             end
            
        end
    end
AllScore = Lscore;

function feat = Combine(feat, fea)
for i = 1:length(feat)
    feat{i}(:,:,end+1:end+size(fea{i},3)) = fea{i};
end

function Map = ComputeOrgDistance(ts_idx, ctr_fea, feattype, fdatabase, setting)
Map = cell(length(ts_idx), length(setting.displace));
for jj = 1:length(ts_idx),  %%%compute for each sample
    fprintf('Compute latent position and rotation %d / %d\n', jj, length(ts_idx))
    for i = 1:length(feattype)
        bookfeattype = length(fdatabase{i}.path);
        for j = 1:length(bookfeattype)
            fpath = fdatabase{i}.path{j}{ts_idx(jj)};
            load(fpath, 'fea', 'label');
            if i == 1 && j== 1
                feat = fea{1}; 
            else
                feat = Combine(feat, fea{1});
            end
            if setting.latent == 2
                if i == 1 && j== 1
                    feat = fea{2};
                else
                    feat = Combine(feat, fea{2});
                end
            end
        end
    end
    for hh = 1:length(setting.displace) %%%for each position, if no dispard , then 0
        Map{jj,hh} = ComputeDistance(feat{hh}, ctr_fea, setting.fsize);             
    end
end


function [X, Y, numSign, latentinfo, ts_imname, LX, LY, LL, LR, Lscore, Lmargin, SignBased] = GetSampleLatent(islatent, ts_fold_idx, ts_idx, tr_idx, ...
    Samplevoted, NotRatio, ctr_fea, W, feattype, fdatabase, setting,Lscore)

numSign = [];
latentinfo = [];
ts_imname = {};
LX = zeros(length(ts_idx), length(tr_idx));
LY = zeros(length(ts_idx), length(tr_idx));
LL = zeros(length(ts_idx), length(tr_idx));
LR = zeros(length(ts_idx), length(tr_idx));
X = [];Y = [];
dim = prod(setting.fsize);
Range = setting.ts_idx_conf;

if isfield(setting, 'ts_fold_idx')
    ts_Fold_label = setting.ts_fold_idx(Range);
else
    ts_Fold_label = ts_fold_idx;
end
        
labelmap = setting.labelmap;
SignBased = 1;


if setting.bestS
    if islatent || (~islatent && setting.testSOutput)
        [idd, b, c] = unique(ts_Fold_label);
        IDMap = c;
        MaxFlod =(max(unique(c))); 
        numSign = zeros(1, MaxFlod);
    else
        MaxFlod = length(ts_idx);
        IDMap = [1:length(ts_idx)];
        numSign = zeros(1, MaxFlod);
        SignBased = 0;
    end
else
    MaxFlod = length(ts_idx);
    IDMap = [1:length(ts_idx)];
    numSign = zeros(1, MaxFlod);
    SignBased = 0;
end

if islatent
%     Samplevoted(:) = 1;   %%%let the 
    NotRatio(:) = 1;
    X = cell(length(ts_idx), 1);
    Y = cell(length(ts_idx), 2);
    latentinfo = cell(length(ts_idx), 1);
    if setting.bestS
        X = cell(MaxFlod, 1);
        Y = cell(MaxFlod, 2); 
        latentinfo = cell(MaxFlod, 1);
    end
end


ts_imname = cell(1, length(ts_idx));
Lmargin = zeros(1, length(ts_idx));

for jj = 1:length(ts_idx),
    if Samplevoted(jj) == 0
        fprintf('Not voted snippets %d\n', jj)
        continue;
    end
    aindex = find(NotRatio(jj,:) ~= 0);
    fprintf('Compute latent position and rotation %d / %d\n', jj, length(ts_idx))
    for i = 1:length(feattype)
        bookfeattype = length(fdatabase{i}.path);
        for j = 1:length(bookfeattype)
            fpath = fdatabase{i}.path{j}{ts_idx(jj)};
            load(fpath, 'fea', 'label');
            
            ts_imname{jj} = fdatabase{i}.imgpath{ts_idx(jj)};
            
    
            if i == 1 && j== 1
                feat = fea{1}; 
            else
                feat = Combine(feat, fea{1});
            end
            if setting.latent == 2
                if i == 1 && j== 1
                    feat = fea{2};
                else
                    feat = Combine(feat, fea{2});
                end
            end
        end
    end
    
    score = zeros(length(feat), length(aindex));
    xpos = zeros(length(feat), length(aindex));
    ypos = zeros(length(feat), length(aindex));
    rpos = zeros(length(feat), length(aindex));
    aindex1 = find(NotRatio(jj,setting.ConsiderID) ~= 0);
    nrotate =  length(setting.rotate);
        
    if islatent   %%trining
        if setting.latent == 1
            
            for li = 1:length(setting.displace) %%%for each position, if no dispard , then 0
            xdim = size(feat{li}, 1) - setting.fsize(1);
            ydim = size(feat{li}, 2) - setting.fsize(2);
            for xi = 1:xdim+1
                for yi = 1:ydim+1
                    latfeat = feat{li}(xi:xi+setting.fsize(1)-1, yi:yi+setting.fsize(2)-1,:);
                    numSign(IDMap(jj)) = numSign(IDMap(jj)) + 1;
                    X{IDMap(jj)}(numSign(IDMap(jj)),:) =  reshape(latfeat, [1, numel(latfeat)]); 
                    
                    index = setting.MapSub2ind{li}(xi, yi);
                    latentinfo{IDMap(jj)}(numSign(IDMap(jj)),:) = [setting.MapRange(index, :),jj,ts_Fold_label(jj)];
                  
                end
            end
            end
   
        else
            for li = 1:length(feat) %%%for each position, if no dispard , then 0
                for xi = 1:length(feat{li})
                    latfeat = feat{li}{xi};
                    numSign(IDMap(jj)) = numSign(IDMap(jj)) + 1;
                    X{IDMap(jj)}(numSign(IDMap(jj)),:) =  reshape(latfeat, [1, numel(latfeat)]); 
                    
                    index = setting.MapSub2ind{li}(setting.Map{li}(xi,1),setting.Map{li}(xi,2));
                    latentinfo{IDMap(jj)}(numSign(IDMap(jj)),:) = [setting.MapRange{li}(index, :),jj,ts_Fold_label(jj)];
                end
            end     
        end
        
        idx = find(setting.tr_label == labelmap(label));
        Y{IDMap(jj), 1} = ceil(idx(end)/nrotate);
        Y{IDMap(jj), 2} = setdiff([1:length(setting.tr_label)/nrotate], Y{IDMap(jj), 1});

    else
        Index = intersect([1:length(labelmap)], aindex1);
        
        if setting.Flatent
            Tindex = repmat(Index(:), [1, nrotate]) + repmat([0:nrotate-1]*length(labelmap), [length(Index), 1]); 
            Tindex = Tindex(:);
        else
            TindexY = repmat(Index, [nrotate, 1]);
            TindexX = repmat([1:nrotate]', [1, length(Index)]);
            Tindex = sub2ind([nrotate, length(labelmap)], TindexX, TindexY);
            Tindex = Tindex(:);
        end
        
        ComputeID = setting.ConsiderID(aindex1);
        
        margin = zeros(1, length(setting.displace));
        for hh = 1:length(setting.displace) %%%for each position, if no dispard , then 0
            if setting.Flatent
                [rscore, rxpos, rypos, rrpos, margin(hh)] = ...
                    bestmatchingW_MRR(feat{hh}, ctr_fea(Tindex, :), setting.Map{hh}, ...
                    setting.PCACOEFF, setting.fsize, W, nrotate);
            else
                [rscore, rxpos, rypos, rrpos] = ...
                    bestmatchingW(feat{hh}, ctr_fea(Tindex, :), setting.Map{hh}, ...
                    setting.PCACOEFF, setting.fsize, W, nrotate);
            end
            
            tmp = Inf * ones(1, length(labelmap));
            tmp(ComputeID) = rscore; score(hh,:) = tmp(aindex); 
            tmp = Inf * ones(1, length(labelmap));
            tmp(ComputeID) = rxpos; xpos(hh,:) = tmp(aindex); 
            tmp = Inf * ones(1, length(labelmap));
            tmp(ComputeID) = rypos; ypos(hh,:) = tmp(aindex); 
            tmp = Inf * ones(1, length(labelmap));
            tmp(ComputeID) = rrpos; rpos(hh,:) = tmp(aindex);  
        end
        score(length(setting.displace)+1:end,:) = Inf;
        
        if setting.Flatent
            [Lmargin(jj), ord] = max(margin);
            index = sub2ind(size(score), ord*ones(size(score,2), 1), [1:size(score,2)]');
            score = score(ord, :);
            LL(jj,aindex) = ord;Ltmp = ord.*ones(length(index),1);
        else
            [score, ord] = min(score, [], 1);
            index = sub2ind(size(xpos), ord(:), [1:length(ord)]');
            LL(jj,aindex) = ord;Ltmp = ord;
        end

        LX(jj,aindex) = xpos(index);Xtmp = xpos(index);
        LY(jj,aindex) = ypos(index);Ytmp = ypos(index);
        
        LR(jj,aindex) = rpos(index);Rtmp = rpos(index);
        
        Lscore(jj,aindex) = score;
        [ss, ord] = min(score);
        sindex = aindex(ord(1));
        
        index = setting.MapSub2ind{Ltmp(ord(1))}(Xtmp(ord(1)), Ytmp(ord(1)));
        latentinfo(jj,:) = [setting.MapRange{Ltmp(ord(1))}(index, :),jj,...
            ts_Fold_label(jj), Rtmp(ord(1)), sindex];
    end
end

nbase = size(LL, 2);
% try
if SignBased && ~islatent
    for tt = 1:MaxFlod
        index = find(IDMap == tt);
        LXT = LX(index, :);
        LYT = LY(index, :);
        LRT = LR(index, :);
        LLT = LL(index, :);
        LscoreT = Lscore(index, :);
        
        if setting.Flatent
            [marginB, ord] = max(Lmargin(index));
            ind = sub2ind(size(LscoreT), ord * ones(1,nbase), [1:nbase]);
            ss = LscoreT(ord,:);
        else
            [ss, ord] = min(LscoreT, [], 1);
            ind = sub2ind(size(LscoreT), ord, [1:nbase]);
        end
        
        nn = size(LXT, 1);
        
        LX(index,:) = repmat(reshape(LXT(ind), [1, nbase]), [nn, 1]);
        %dis = LX(index,:) - repmat(LXT(ord,:), [nn, 1]);max(abs(dis(:)))
        
        LY(index,:) = repmat(reshape(LYT(ind), [1, nbase]), [nn, 1]);
        %dis = LY(index,:) - repmat(LYT(ord,:), [nn, 1]);max(abs(dis(:)))
        
        LL(index,:) = repmat(reshape(LLT(ind), [1, nbase]), [nn, 1]);
        %dis = LL(index,:) - repmat(LLT(ord,:), [nn, 1]);max(abs(dis(:)))
        
        LR(index,:) = repmat(reshape(LRT(ind), [1, nbase]), [nn, 1]);
        %dis = LR(index,:) - repmat(LRT(ord,:), [nn, 1]);max(abs(dis(:)))
        
        Lscore(index,:) = repmat(reshape(LscoreT(ind), [1, nbase]), [nn, 1]);
        %dis = Lscore(index,:) - repmat(LscoreT(ord,:), [nn, 1]);max(abs(dis(:)))
        
        [ss, ord1] = min(ss); %%%%
        if setting.Flatent
            row = ord;
        else
            row = ord(ord1);
        end
        xi = LXT(row, ord1);
        yi = LYT(row, ord1);
        li = LLT(row, ord1);
        ri = LRT(row, ord1);
        tindex = setting.MapSub2ind{li}(xi, yi);
        jjj = ts_Fold_label(index);
        latentinfo(index,:) = [repmat([setting.MapRange{li}(tindex, :), index(row)], [nn,1]), jjj(:), repmat([ri, ord1], [nn, 1])];
    end
end

% catch
%     t = 1;
%     pause
% end

function Map = ComputeDistance(feat, ctr_fea, fsize)
[m, n] = size(ctr_fea);
xdim = size(feat, 1) - fsize(1);
ydim = size(feat, 2) - fsize(2);
Map = cell(xdim+1, ydim+1);
for i = 1:xdim+1
    for j = 1:ydim+1
        Map{i,j} = cell(1, m);
        feattmp = feat(i:i+fsize(1)-1,j:j+fsize(2)-1,:);
        feattmp = feattmp(:);
        for t = 1:m
            dis = feattmp' - ctr_fea(t,:);
            Map{i,j}{t} = dis'*dis;      
        end
    end
end

function [ctr_fea, tr_label] = GetFeastr(fdatabase, feattype, tr_idx, setting, labelmap)
ctr_fea = []; 
for i = 1:length(feattype)
            bookfeattype = length(fdatabase{i}.path);
            for j = 1:length(bookfeattype)
                ctr_fea_t = []; tr_label = [];
                for jj = 1:length(tr_idx),
                    if ~mod(jj, 5),
                        fprintf('.');
                    end
                    if ~mod(jj, 100),
                        fprintf(' %d images processed\n', jj);
                    end
                    fpath = fdatabase{i}.path{j}{tr_idx(jj)};
                    load(fpath, 'fea', 'label');
                    if ~ismember(labelmap(label), setting.Consider)
                        continue;
                    end
                    for tt = 1:length(setting.rotate)   %%%if no rotate then for one
                        tmp = fea{1}{tt}(:);
                        if setting.latent == 2
                            tmp = fea{2}{tt}(:);
                        end
                        ctr_fea_t = [ctr_fea_t; tmp'];
                        tr_label = [tr_label; labelmap(label)];
                    end
                end
                ctr_fea = [ctr_fea,ctr_fea_t]; 
             end
        end
        clear 'ctr_fea_t'

function tr_imname = GetTrname(tr_idx, fdatabase)
tr_imname = cell(length(tr_idx), 1);
i = 1;
    for jj = 1:length(tr_idx),
        tr_imname{jj} = fdatabase{i}.imgpath{tr_idx(jj)};
    end
