function [dataX1, dataY, numSign, CIndex, Tlatentinfo, latentfile,...
    datastr, data_imsize, data_imname, data_label] = getLatentData(...
    feattype, ts_fold_idx, ts_idx, tr_idx, setting, fdatabase, ...
    Samplevoted, NotRatio, svotestr)   
tr_size = [];
setting.selfpaced = 0;
Mstr = setting.Mstr;
addpath(genpath('mlr/'));
PCACOEFF = [];
% 4GB file limit
bytelimit = setting.GBlimit*2^30;
tr_label = zeros(length(tr_idx), 1);ts_label = zeros(length(ts_idx), 1);
clabel = unique(fdatabase{1}.label);
if setting.Mclassfy
    Lscore = 0;
else
    Lscore = Inf * ones(length(ts_idx), length(tr_idx));
end
labelmap = setting.labelmap;
ranktime = 0;
    str = '';
for jj = 1:length(feattype)
    [ff1, ff2, ff3] = fileparts([setting.mfea_dir{jj}{1}, '.mat']);str = [str, ff2];
end
if setting.Fpyramid
    str = [str 'FPY' num2str(setting.Fpyramid)];
end
% % try
% %         load(fullfile(setting.Modelresult,['ctr_fea-', Mstr]), 'ctr_fea', 'tr_label');
% %     catch
% %         [ctr_fea, tr_label] = GetFeastr(fdatabase, feattype, tr_idx, setting, labelmap);
% %         save(fullfile(setting.Modelresult,['ctr_fea-', Mstr]), 'ctr_fea', 'tr_label');
% %     end
    
    try
        load([setting.TFstr, '_', str, '_', setting.config_latent, 'ctr_fea-', Mstr], 'ctr_fea', 'tr_label');
    catch
        [ctr_fea, tr_label] = GetFeastr(fdatabase, feattype, tr_idx, setting, labelmap);
        save([setting.TFstr, '_', str, '_', setting.config_latent, 'ctr_fea-', Mstr], 'ctr_fea', 'tr_label');
    end
    
tindex = (reshape([1:size(ctr_fea, 1)], size(ctr_fea, 1)/length(setting.tr_idx), []))';
tindex = (tindex(:, setting.rindex));
ctr_fea = ctr_fea(sort(tindex(:)),:);tr_label = tr_label(sort(tindex(:)));

try
    load([setting.TFstr, '_', str, '_dataInfo.mat'], 'data_imsize', 'data_imname', 'data_label')
    catch
    for jj = 1:length(fdatabase{1}.path{1})
        data_imname{jj} = fdatabase{1}.imgpath{jj};
        im = imread(data_imname{jj});
        data_imsize(jj,:) = [size(im,1), size(im,2)];
        data_label(jj) = fdatabase{1}.label(jj);
    end
    save([setting.TFstr, '_', str, '_dataInfo.mat'], 'data_imsize', 'data_imname', 'data_label')
    end
    
    setting.fsize = [];
    if mod(setting.latent, 5)
    jj = 1;fsize = [];
    for i = 1:length(feattype)
        bookfeattype = length(fdatabase{i}.path);
        for j = 1:length(bookfeattype)
            fpath = fdatabase{i}.path{j}{tr_idx(jj)};load(fpath{1}, 'fea', 'label');
            fsize = [fsize; size(fea{1}{1})];
        end
    end
    setting.fsize = [fsize(1,1:2), sum(fsize(:,3))];
    end
    
    Ntrain = size(ctr_fea,1);
    if ~setting.isKNNlatent
        KNNlatent = Ntrain/length(setting.rotate) - 1;
    else
        KNNlatent = setting.KNNlatent(1);
    end
    if KNNlatent < 1
        if KNNlatent > 0
            KNNlatent = ceil(abs(KNNlatent) * length(labelmap));
        else
            setting.rankKNN = 1;
            KNNlatent = abs(KNNlatent);
        end
    end
    

    setting.tr_label = tr_label;
    tr_imname = GetTrname(tr_idx, fdatabase);
    bitsize1 = size(ctr_fea, 1) * size(ctr_fea, 1) * 8;
    bitsize = numel(ctr_fea) * 8; 
            setting.datastr = fullfile(setting.latentresult,'XCdata');
            datastr = setting.datastr;
            if ~exist(setting.datastr)
                mkdir(setting.datastr)
            end
            pcastr = '';
            if isempty(setting.DRstr)
                if setting.PCAenergy ~= -0.9
                    pcastr = [pcastr '_E' num2str(setting.PCA)];
                end
            else
                if setting.PCAenergy ~= -0.9
                    pcastr = [pcastr '_E' setting.DRstr];
                end
            end
            if setting.LocalPCA
                pcastr = [pcastr, '_L'];
            end
            if ~isempty(setting.RRatiostr)
                pcastr = [setting.RRatiostr, pcastr];
            end 
            
            th = tic;

            [dataX, dataY, numSign, CIndex, latentinfo, ts_imname] = GetSampleLatent(pcastr, 1, ts_fold_idx, ts_idx, tr_idx, Samplevoted, NotRatio, ...
                ctr_fea, [], feattype, fdatabase, setting, Lscore, bytelimit, bitsize, bitsize1);           
            

            th = toc(th);
            fprintf('Time for Get latent Samples : %d \n', th)
            Ntrain = size(ctr_fea, 1);           
            numD = size(CIndex, 1);
            
            th = tic;
            if setting.PCA > 0
                TrainPCA = (ctr_fea - repmat(setting.PCACOEFF{2}, ...
                    [size(ctr_fea,1),1])) * setting.PCACOEFF{1};
                dataX = [TrainPCA;cell2mat(dataX)];
            end
            
% % %             if setting.PCA >= 0
% % %                 bitsize = size(ctr_fea,1)*size(dataX, 2) * 8; 
% % %                 CIndex = GetPCADATA(setting, numD, numSign, CIndex, bytelimit, bitsize, bitsize1);
% % %             end
            
            dataX = mat2cell(dataX, [ones(1, size(dataX,1))], size(dataX, 2));
            
            th = toc(th);
            fprintf('Time for PCA : %d \n', th)
            
            th = tic;
            setting.numSign = [ones(1, size(ctr_fea,1)), numSign];
            Tlatentinfo = latentinfo;
            
            latentfile = fullfile(setting.latentresult,['latent', Mstr(1:end-4), svotestr], 'Train');
            
            dataX([1:Ntrain]) = ChangeRotateOrd(dataX([1:Ntrain]), length(setting.rotate));
            th = tic;
            dataX1= dataX;
            
            if setting.selfpaced(1) == 1
                load(fullfile(setting.ModelresultO,['Model-', Mstr]), 'Metric');
                Winit = Metric;
            else
                Winit= [];
            end
                
            if size(CIndex, 1) == 1
                dataX(Ntrain+1:end) = GetCellX([setting.Mstr(1:end-4), '_'] , setting.datastr, CIndex);
                dataX1 = dataX;
            else
            end
            datastr = {datastr, KNNlatent};

            

function feat = Combine(feat, fea, latent)
for i = 1:length(feat)
    for j = 1:length(fea{i})
        if latent == 1
    feat{i}{j}(:,:, end+1:end+size(fea{i}{j}, 3)) = fea{i}{j};
        end
        if latent == 2
    feat{i}{j}(end+1:end+length(fea{i}{j}),:) = fea{i}{j};
        end
    end
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
                feat = setting.normweigh(i)*fea{1}; 
            else
                feat = Combine(feat, setting.normweigh(i)*fea{1}, setting.latent);
            end
            if setting.latent == 2
                if i == 1 && j== 1
                    feat = setting.normweigh(i)*fea{2};
                else
                    feat = Combine(feat, setting.normweigh(i)*fea{2}, setting.latent);
                end
            end
        end
    end
    for hh = 1:length(setting.displace) %%%for each position, if no dispard , then 0
        Map{jj,hh} = ComputeDistance(feat{hh}, ctr_fea, setting.fsize);             
    end
end


function [X, Y, numSign, CIndex, latentinfo, ts_imname, LX, LY, LL, LR, Lscore, Lmargin, SignBased] = GetSampleLatent(pcastr, islatent, ts_fold_idx, ts_idx, tr_idx, ...
    Samplevoted, NotRatio, ctr_fea, W, feattype, fdatabase, setting,Lscore, bytelimit, bitsize, bitsize1)
if (setting.bestS || setting.KNNlatentTrain) && ~setting.latent
    [X, Y, numSign, CIndex, latentinfo, ts_imname, LX, LY, LL, LR, Lscore, Lmargin, SignBased] = GetSampleLatent_bestS(islatent, ts_fold_idx, ts_idx, tr_idx, ...
        Samplevoted, NotRatio, ctr_fea, W, feattype, fdatabase, setting,Lscore, bytelimit, bitsize, bitsize1);
    return;
end


numSign = [];
latentinfo = [];
ts_imname = {};
CIndex = [];
if islatent
    LX =0;LY = 0;LL = 0;LR = 0;
else
    
LX = zeros(length(ts_idx), length(tr_idx));
LY = zeros(length(ts_idx), length(tr_idx));
LL = zeros(length(ts_idx), length(tr_idx));
LR = zeros(length(ts_idx), length(tr_idx));
end
X = [];Y = [];
if iscell(ts_fold_idx)
    ts_fold_idx1 = ts_fold_idx{2};
    ts_fold_idx = ts_fold_idx{1};
end
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
iused = 0;
round = 0;istart = 1;
orglength = sqrt(bitsize1 / 8)';
orglength1 = orglength;
usedbit = bitsize;
usedbit1 = orglength*orglength*8;
str = '';
for jj = 1:length(feattype)
    [ff1, ff2, ff3] = fileparts([setting.mfea_dir{jj}{1}, '.mat']);str = [str, ff2];
end
if setting.Fpyramid
    str = [str 'FPY' num2str(setting.Fpyramid), '_', setting.config_latent];
end
try
    load([setting.TFstr, '_', setting.pcasstr, '_data.mat'], 'cfeat')
catch
%     for jj = 1:length(fdatabase{1}.path{1})
    cfeat = {};
    for ijj = 1:length(setting.ts_idx)
        jj = setting.ts_idx(ijj);
        iused  = iused+1;
        for i = 1:length(feattype)
            bookfeattype = length(fdatabase{i}.path);
            for j = 1:length(bookfeattype)
                fpath = fdatabase{i}.path{j}{jj};ts_imname{iused} = fdatabase{i}.imgpath{jj};
                if setting.latent == 2
                    if i == 1 && j== 1
                        feat = {};
                        for jjj = 1:length(fpath)
                            load(fpath{jjj}, 'fea', 'label');
                            for kkk = 1:length(fea{2}{1})
                                feat{jjj}{kkk} = setting.normweigh(i)*fea{2}{1}{kkk};
                            end
                        end
                    else
                        feat1 = {};
                        for jjj = 1:length(fpath)
                            load(fpath{jjj}, 'fea', 'label');
                            for kkk = 1:length(fea{2}{1})
                                feat1{jjj}{kkk} = setting.normweigh(i)*fea{2}{1}{kkk};
                            end
                        end
                        feat = Combine(feat, feat1, setting.latent );
                    end
                else
                    if setting.latent == 1
                        
                        if i == 1 && j== 1
                        feat = {};
                        for jjj = 1:length(fpath)
                            load(fpath{jjj}, 'fea', 'label');
                            for kkk = 1:length(fea{1})
                                feat{jjj}{kkk} = setting.normweigh(i)*reshape(fea{1}{kkk}, [], 1);
                            end
                        end
                    else
                        feat1 = {};
                        for jjj = 1:length(fpath)
                            load(fpath{jjj}, 'fea', 'label');
                            for kkk = 1:length(fea{1})
                                feat1{jjj}{kkk} = setting.normweigh(i)*reshape(fea{1}{kkk}, [], 1);
                            end
                        end
                        feat = Combine(feat, feat1, setting.latent );
                    end
                        
                else
                    if i == 1 && j== 1
                        feat = setting.normweigh(i)*tmp; 
                    else
                        feat = Combine(feat, setting.normweigh(i)*tmp, setting.latent);
                    end
                end
                end
            end
        end
        if (~iscell(setting.PCA) && setting.PCA > 0)
            for li = 1:length(feat)
                for ii = 1:length(feat{li})
                    feat{li}{ii} = ((feat{li}{ii}' - setting.PCACOEFF{2})*setting.PCACOEFF{1})';
                end
            end
        end
        if iscell(setting.PCA)
            for li = 1:length(feat)
                for ii = 1:length(feat{li})
                    feat{li}{ii} = feat{li}{ii}'*setting.PCACOEFF{1};
                end
            end
        end
        
        cfeat{jj} = feat;
    end
    save([setting.TFstr, '_', setting.pcasstr, '_data.mat'], 'cfeat')
end

if islatent
    try
        load([setting.TFstr, '_', setting.pcasstr, '_celldata.mat'], 'Y', 'X', 'TnumSign', 'latentinfo')            
    catch
        nrotate =  length(setting.rotate);
        
        fpath = fdatabase{1}.path{1}{setting.tr_idx(1)};nrotate = length(fpath);
                  
        TnumSign = zeros(1, max(setting.ts_idx));
        for ijj = 1:length(setting.ts_idx)
            jj = setting.ts_idx(ijj);
            feat = cfeat{(jj)};
            fpath = fdatabase{1}.path{1}{jj};
            load(fpath{1}, 'label');             
            iused  = jj;
            if setting.latent == 1
            for li = 1:length(feat) %%%for each position, if no dispard , then 0
            xdim = size(feat{li}, 1) - setting.fsize(1);
            ydim = size(feat{li}, 2) - setting.fsize(2);
            for xi = 1:xdim+1
                for yi = 1:ydim+1
                    latfeat = feat{li}(xi:xi+setting.fsize(1)-1, yi:yi+setting.fsize(2)-1,:);
                    TnumSign(iused) = TnumSign(iused) + 1;
                    X{iused}(TnumSign(iused),:) =  reshape(latfeat, [1, numel(latfeat)]); 
                    index = setting.MapSub2ind{li}(xi, yi);
                    latentinfo{iused}(TnumSign(iused),:) = [setting.MapRange(index, :),jj,ts_fold_idx1(ijj)];
                end
            end
            end
            else
            for li = 1:length(feat)  %%%for each position, if no dispard , then 0
                for xi = 1:length(feat{li})
                    latfeat = feat{li}{xi};
                    TnumSign(iused) = TnumSign(iused) + 1;
                    X{iused}(TnumSign(iused),:) =  reshape(latfeat, [1, numel(latfeat)]); 
                    index = setting.MapSub2ind{li}(setting.Map{li}(xi,1),setting.Map{li}(xi,2));
                    latentinfo{iused}(TnumSign(iused),:) = [setting.MapRange{li}(index, :),jj,ts_fold_idx1(ijj)];
                end
            end
            end
            idx = find(setting.tr_label == labelmap(label));
            Y{iused, 1} = ceil(idx(end)/nrotate);Y{iused, 2} = setdiff([1:length(setting.tr_label)/nrotate], Y{iused, 1});
            Xtmp = (X{(iused)});
        end
        save([setting.TFstr, '_', setting.pcasstr, '_celldata.mat'], 'Y', 'X', 'TnumSign', 'latentinfo')            
    end
end
feat = cfeat(ts_idx);Y = Y(ts_idx,:);X = X(ts_idx);
latentinfo = latentinfo(ts_idx);numSign = TnumSign(ts_idx);
for ii = 1:length(X)
    X{ii} = X{ii}(setting.dindex,:);
    numSign(ii) = length(setting.dindex);
end
clear 'cfeat';
for jj = 1:length(ts_idx),
    if Samplevoted(jj) == 0
        fprintf('Not voted snippets %d\n', jj)
        continue;
    end
    iused  = iused+1;
    aindex = find(NotRatio(jj,:) ~= 0);
    fprintf('Compute latent position and rotation %d / %d\n', jj, length(ts_idx))
    ts_imname{iused} = fdatabase{1}.imgpath{ts_idx(jj)};
    fpath = fdatabase{1}.path{1}{ts_idx(jj)}; load(fpath{1}, 'label');   
    aindex1 = find(NotRatio(jj,setting.ConsiderID) ~= 0);
    nrotate =  length(setting.rotate);
    if islatent   %%trining           
        idx = find(setting.tr_label == labelmap(label));
        Xtmp = (X{(iused)});
        thislength = size(Xtmp, 1);
        bitthis = numel(Xtmp)*8;
        bitthis1 = 2*(thislength*orglength)*8+(2*orglength1+1)*8;
        EndRound = 0;
        if (usedbit + bitthis + usedbit1 + bitthis1 > bytelimit)
            EndRound = 1;
            round = round + 1;iend = iused-1;
            ffile = fullfile(setting.latentresult,'XCdata', [setting.Mstr(1:end-4), '_', num2str(round), '.mat']);
            Xcell = X(istart:iend);
            save(ffile, 'Xcell', '-v7.3');clear 'Xcell'
            CIndex = [CIndex; [istart, iend]];
            X(istart:iend) = cell(iend-istart+1,1);
            istart = iend+1;
            usedbit = bitsize;
            usedbit1 = orglength*orglength*8;
        end
        usedbit = usedbit + bitthis;
        usedbit1 = usedbit1 + bitthis1;
        orglength1 = orglength1 + 1;
        XX{iused} = Xtmp(1,:); %%%%%for the first one
    else
        score = zeros(length(feat), length(aindex));
        xpos = zeros(length(feat), length(aindex));
        ypos = zeros(length(feat), length(aindex));
        rpos = zeros(length(feat), length(aindex));
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

if islatent
    numSign = numSign(1:iused);
    latentinfo = latentinfo(1:iused);
    Y =Y(1:iused,:);
    ts_imname = ts_imname(1:iused);
    
    round = round + 1;iend = iused;
    ffile = fullfile(setting.latentresult,'XCdata', [setting.Mstr(1:end-4), '_', num2str(round), '.mat']);
    Xcell = X(istart:iend);
    save(ffile, 'Xcell', '-v7.3')
    CIndex = [CIndex; [istart, iend]];
    clear 'X'
    X = XX';
end
    
nbase = size(LL, 2);
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
        LY(index,:) = repmat(reshape(LYT(ind), [1, nbase]), [nn, 1]);
        LL(index,:) = repmat(reshape(LLT(ind), [1, nbase]), [nn, 1]);
        LR(index,:) = repmat(reshape(LRT(ind), [1, nbase]), [nn, 1]);
        Lscore(index,:) = repmat(reshape(LscoreT(ind), [1, nbase]), [nn, 1]);
        
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


function CIndex = GetPCADATA(setting, numD, numSign, CIndex, bytelimit, bitsize, bitsize1)
round = 0;
XcellT = {};CIndexT = [];
istart = 1;

usedbit = bitsize;
% usedbit1 = 0;
orglength = sqrt(bitsize1 / 8)';
usedbit1 = orglength*orglength*8;
orglength1 = orglength;


for jj = 1:numD
    tsize = numSign(CIndex(jj, 1):CIndex(jj, 2));
    ffile1 = fullfile(setting.latentresult,'XCdata', [num2str(jj), '.mat']);
    load(ffile1, 'Xcell')
    Xtmp = cell2mat(Xcell);
    Xtmp = (Xtmp - repmat(setting.PCACOEFF{2}, [size(Xtmp,1),1])) * setting.PCACOEFF{1};

    EndRound = 0;
    Xcell = mat2cell(Xtmp, tsize, size(Xtmp, 2));
    XXcell = Xcell;
    
    thislength = size(Xtmp, 1);
    bitthis = numel(Xtmp)*8;
    bitthis1 = 2*(thislength*orglength)*8 + (2*orglength1+1)*8;   
    
%     if (usedbit + bitthis > bytelimit) || (usedbit1 + bitthis1 > bytelimit)
    if (usedbit + bitthis + usedbit1 + bitthis1 > bytelimit)
        
        EndRound = 1;
        round = round + 1;
        ffile = fullfile(setting.latentresult,'XCdata_PCA', [setting.Mstr(1:end-4), '_', num2str(round), '.mat']);
        iend = jj - 1;
        Xcell = XcellT';save(ffile, 'Xcell', '-v7.3')
%         usedbit = 0;
        XcellT = {};
        CIndexT(end+1,:) = [CIndex(istart,1), CIndex(iend,2)];
        istart = iend+1;
        
        usedbit = bitsize;
        usedbit1 = orglength*orglength*8;
        
    end
%     usedbit = usedbit + bitthis;
        usedbit = usedbit + bitthis;
        usedbit1 = usedbit1 + bitthis1;
        orglength1 = orglength1 + length(Xcell);
        

    XcellT(end+1:end+length(XXcell)) = XXcell; 
    
end

if (~EndRound) || (EndRound && jj == numD)
    round = round + 1;iend = jj;
    ffile = fullfile(setting.latentresult,'XCdata_PCA', [setting.Mstr(1:end-4), '_', num2str(round), '.mat']);
    Xcell = XcellT';save(ffile, 'Xcell', '-v7.3')
    CIndexT(end+1,:) = [CIndex(istart,1), CIndex(iend,2)];
end
CIndex = CIndexT;


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
                    load(fpath{1}, 'fea', 'label');
                    if ~ismember(labelmap(label), setting.Consider)
                        continue;
                    end
                    if mod(setting.latent, 5)
                        for tt = 1:length(fpath)    %%%if no rotate then for one
                            load(fpath{tt}, 'fea');
                            tmp = fea{1}{1}(:);
                            if setting.latent == 2
                                tmp = fea{2}{1}(:);
                            end
                            ctr_fea_t = [ctr_fea_t; setting.normweigh(i)*tmp'];
                            tr_label = [tr_label; labelmap(label)];
                        end
                    else
                        tmp = fea;
                        ctr_fea_t = [ctr_fea_t; setting.normweigh(i)*tmp'];
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

function dataX = GetCellX(Mstr, datastr, CIndex)
BatchRound = size(CIndex, 1);
dataX = cell(CIndex(end, 2), 1);
for R = 1:BatchRound
    index = [CIndex(R, 1):CIndex(R, 2)];
    load(fullfile(datastr,[Mstr, num2str(R) '.mat']), 'Xcell'); 
    dataX(index) = Xcell;
end
            
