function [X, Y, numSign, CIndex, latentinfo, ts_imname, LX, LY, LL, LR, Lscore, Lmargin, SignBased] = GetSampleLatent_bestS(islatent, ts_fold_idx, ts_idx, tr_idx, ...
    Samplevoted, NotRatio, ctr_fea, W, feattype, fdatabase, setting,Lscore, bytelimit, bitsize, bitsize1)
numSign = [];
latentinfo = [];
ts_imname = {};
CIndex = [];
LX =0;LY = 0;LL = 0;LR = 0;
X = [];Y = [];
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
% for jj = 1:length(ts_idx), 
if islatent
    for tt = 1:MaxFlod
        index = find(IDMap == tt);
        HasInstance = 0;
        if ~nnz(Samplevoted(index))
            fprintf('Not voted snippets %d\n', jj)
            continue;
        end
        iused  = iused+1;   
        for kk = 1:length(index)
            jj = index(kk);
            if Samplevoted(jj) == 0
                fprintf('Not voted snippets %d\n', jj)
                continue;
            end
            HasInstance = 1;
            aindex = find(NotRatio(jj,:) ~= 0);
            fprintf('Compute latent position and rotation %d / %d\n', jj, length(ts_idx))
            for i = 1:length(feattype)
                bookfeattype = length(fdatabase{i}.path);
                for j = 1:length(bookfeattype)
                    fpath = fdatabase{i}.path{j}{ts_idx(jj)};
                    load(fpath, 'fea', 'label');
                    ts_imname{iused} = fdatabase{i}.imgpath{ts_idx(jj)};
                    tmp = fea;   
                    if i == 1 && j== 1
                        feat = setting.normweigh(i)*tmp; 
                    else
                        feat = Combine(feat, setting.normweigh(i)*tmp);
                    end
                end
            end
            aindex1 = find(NotRatio(jj,setting.ConsiderID) ~= 0);
            nrotate =  length(setting.rotate);
            latfeat = feat;
            numSign(iused) = numSign(iused) + 1;
            X{iused}(numSign(iused),:) =  reshape(latfeat, [1, numel(latfeat)]); 
            latentinfo{iused}(numSign(iused),:) = 0;
        end
        if ~HasInstance
            continue;
        end
        
        idx = find(setting.tr_label == labelmap(label));
        Y{iused, 1} = ceil(idx(end)/nrotate);
        Y{iused, 2} = setdiff([1:length(setting.tr_label)/nrotate], Y{iused, 1});
        if setting.PCA < 0
            X{(iused)} = (X{(iused)} - repmat(setting.PCACOEFF{2}, ...
                [size(X{(iused)},1),1])) * setting.PCACOEFF{1};
        end
        Xtmp = (X{(iused)});
        thislength = size(Xtmp, 1);
        bitthis = numel(Xtmp)*8;
        bitthis1 = 2*(thislength*orglength)*8+(2*orglength1+1)*8;
        EndRound = 0;
        if (usedbit + bitthis + usedbit1 + bitthis1 > bytelimit)
            EndRound = 1;
            round = round + 1;iend = iused-1;
            ffile = fullfile(setting.latentresult,'XCdata', [num2str(round), '.mat']);
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
    end
else
for jj = 1:length(ts_idx),
    if Samplevoted(jj) == 0
        fprintf('Not voted snippets %d\n', jj)
        continue;
    end
    iused  = iused+1;
    aindex = find(NotRatio(jj,:) ~= 0);
    fprintf('Compute latent position and rotation %d / %d\n', jj, length(ts_idx))
    for i = 1:length(feattype)
        bookfeattype = length(fdatabase{i}.path);
        for j = 1:length(bookfeattype)
            fpath = fdatabase{i}.path{j}{ts_idx(jj)};
            load(fpath, 'fea', 'label');
            ts_imname{iused} = fdatabase{i}.imgpath{ts_idx(jj)};
            tmp = fea;
            if i == 1 && j== 1
                feat = setting.normweigh(i)*tmp; 
            else
                feat = Combine(feat, setting.normweigh(i)*tmp);
            end
        end
    end
    aindex1 = find(NotRatio(jj,setting.ConsiderID) ~= 0);
    nrotate =  length(setting.rotate);
        score = zeros(length(feat), length(aindex));
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
        
        Lmargin(jj) = 0;
        if setting.Flatent
                [rscore, Lmargin(jj)] = ...
                    bestmatchingW_MRR(feat, ctr_fea(Tindex, :), setting.Map, ...
                    setting.PCACOEFF, setting.fsize, W, nrotate);
            else
                [rscore, rxpos, rypos, rrpos] = ...
                    bestmatchingW(feat, ctr_fea(Tindex, :), setting.Map, ...
                    setting.PCACOEFF, setting.fsize, W, nrotate);
            end
            
            tmp = Inf * ones(1, length(labelmap));
            tmp(ComputeID) = rscore; score = tmp(aindex); 

        Lscore(jj,aindex) = score;
        [ss, ord] = min(score);
        sindex = aindex(ord(1));
        
        latentinfo(jj) = sindex;
    end
end

if islatent
    numSign = numSign(1:iused);
    latentinfo = latentinfo(1:iused);
    Y =Y(1:iused,:);
    ts_imname = ts_imname(1:iused);
    round = round + 1;iend = iused;
    ffile = fullfile(setting.latentresult,'XCdata', [num2str(round), '.mat']);
    Xcell = X(istart:iend);
    save(ffile, 'Xcell', '-v7.3')
    CIndex = [CIndex; [istart, iend]];
    clear 'X'
    X = XX';
end
    
nbase = length(tr_idx);
if SignBased && ~islatent
    for tt = 1:MaxFlod
        index = find(IDMap == tt);
        LscoreT = Lscore(index, :);
        
        if setting.Flatent
            [marginB, ord] = max(Lmargin(index));
            ind = sub2ind(size(LscoreT), ord * ones(1,nbase), [1:nbase]);
            ss = LscoreT(ord,:);
        else
            [ss, ord] = min(LscoreT, [], 1);
            ind = sub2ind(size(LscoreT), ord, [1:nbase]);
        end
        
        nn = length(index);
        
        Lscore(index,:) = repmat(reshape(LscoreT(ind), [1, nbase]), [nn, 1]);
        
        [ss, ord1] = min(ss); %%%%
        latentinfo(index) = repmat(ord1, [nn, 1]);
    end
end
