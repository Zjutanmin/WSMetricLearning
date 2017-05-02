function [AllScore, ranktime, tr_size] = getScoreMatch(feattype, ts_idx, setting, ...
    fdatabase, Mstr, Samplevoted, NotRatio, cindex)
tr_label = zeros(length(tr_idx), 1);ts_label = zeros(length(ts_idx), 1);
% Mstr = [num2str(setting.platent),'.mat'];
% %         Mstr = [num2str(setting.platent), '_', num2str(i), '_',
% %         num2str(j), '.mat'];
Lscore = Inf * ones(length(ts_idx), length(tr_idx));
AllScore = zeros(size(Lscore));
LX = zeros(length(ts_idx), length(tr_idx));
LY = zeros(length(ts_idx), length(tr_idx));
LL = zeros(length(ts_idx), length(tr_idx));
LR = zeros(length(ts_idx), length(tr_idx));
labelmap = setting.labelmap;
ranktime = 0;
for i = 1:length(feattype)
    bookfeattype = length(fdatabase{i}.path);
    for j = 1:length(bookfeattype)
        
        for jj = 1:length(tr_idx),
            fpath = fdatabase{i}.path{j}{tr_idx(jj)};
            load(fpath,  'label');
            tr_label(jj) = label;
            tr_imname{jj} = fdatabase{i}.imgpath{tr_idx(jj)};
            tr_size(jj, :)=  graysize(imread(tr_imname{jj}));
        end
        Mstr = [num2str(setting.platent), '_', num2str(i), '_', num2str(j), '.mat'];
        try
            load(fullfile(setting.latentresult,['latent', Mstr(1:end-4), setting.svotestr, '.mat']), 'LX', 'LY', 'LL', 'LR', 'Lscore','ranktime');
        catch
            th = tic;
            ts_idx1 = ts_idx;
            ts_idx = setting.ts_idx;
            
            ctr_fea = cell(1, length(setting.rotate));
                    for jj = 1:length(tr_idx),
                        
                        fpath = fdatabase{i}.path{j}{tr_idx(jj)};
                        load(fpath, 'fea', 'label');
                        
                        if ~ismember(labelmap(label), setting.Consider)
                            continue;
                        end
                        
                        for tt = 1:length(setting.rotate)   %%%if no rotate then for one
                            ctr_fea{tt}{labelmap(label)} = fea{1}{tt};
                        end
                        tr_label(jj) = labelmap(label);
                        tr_imname{jj} = fdatabase{i}.imgpath{tr_idx(jj)};
                        tr_size(jj, :)=  graysize(imread(tr_imname{jj}));
                    end
           
            for jj = 1:length(ts_idx),
                if Samplevoted(jj) == 0
                    fprintf('Not voted snippets %d\n', jj)
                    continue;
                end
                
                aindex = find(NotRatio(jj,:) ~= 0);
                fprintf('Compute latent position and rotation %d / %d\n', jj, length(ts_idx))
                fpath = fdatabase{i}.path{j}{ts_idx(jj)};
                load(fpath, 'fea', 'label');
                feat = fea{1};
                
                    
                ts_label(jj) = label;
                score = zeros(length(feat), length(aindex));
                xpos = zeros(length(feat), length(aindex));
                ypos = zeros(length(feat), length(aindex));
                rpos = zeros(length(feat), length(aindex));
                
                for hh = 1:length(setting.displace) %%%for each position, if no dispard , then 0
                            aindex1 = find(NotRatio(jj,setting.ConsiderID) ~= 0);
                            [rscore, rxpos, rypos, rrpos] = ...
                                bestmatching(aindex1, feat{hh}, ctr_fea);
                            tmp = Inf * ones(1, length(labelmap));
                            tmp(setting.ConsiderID) = rscore(labelmap(setting.ConsiderID)); score(hh,:) = tmp(aindex); 
                            tmp = Inf * ones(1, length(labelmap));
                            tmp(setting.ConsiderID) = rxpos(labelmap(setting.ConsiderID)); xpos(hh,:) = tmp(aindex); 
                            tmp = Inf * ones(1, length(labelmap));
                            tmp(setting.ConsiderID) = rypos(labelmap(setting.ConsiderID)); ypos(hh,:) = tmp(aindex); 
                            tmp = Inf * ones(1, length(labelmap));
                            tmp(setting.ConsiderID) = rrpos(labelmap(setting.ConsiderID)); rpos(hh,:) = tmp(aindex); 
                end
                score(length(setting.displace)+1:end,:) = Inf;
            
                [score, ord] = min(score);
                index = sub2ind(size(xpos), ord(:), [1:length(ord)]');
                
                LX(jj,aindex) = xpos(index);
                LY(jj,aindex) = ypos(index);
                LL(jj,aindex) = ord;
                LR(jj,aindex) = rpos(index);
                Lscore(jj,aindex) = score;
            end
            ranktime = toc(th);
            
            save(fullfile(setting.latentresult,['latent', Mstr(1:end-4), setting.svotestr, '.mat']), 'LX', 'LY', 'LL', 'LR', 'Lscore', 'ranktime');
            clear 'ctr_fea';
            
            ts_idx = ts_idx1;
            
        end
        if setting.latent > 1
            try
                load(fullfile(setting.latentresult,['newscore_', num2str(i), '_', num2str(j), '.mat']), 'Lscore', 'ranktime');                
            catch
                th = tic;
                ts_idx1 = ts_idx;
                ts_idx = setting.ts_idx;
                
                fprintf('Compute Score by the latent information\n')
                dfeat2 = GetDisMap(setting);
                ctr_fea = cell(1, length(setting.rotate));
                for jj = 1:length(tr_idx)
                    
                    for tt = 1:length(setting.rotate)   %%%if no rotate then for one
                    ctr_fea{tt}{jj} = [];
                    end
                    if setting.WTAwithraw
                    fpath = fdatabase{i}.Rawpath{j}{tr_idx(jj)};
                    load(fpath, 'fea', 'label');
                    for tt = 1:length(setting.rotate)   %%%if no rotate then for one
                        feattmp = fea{2}{tt};
                        ctr_fea{tt}{jj} = [ctr_fea{tt}{jj}; feattmp];
                    end
                    rawlength = length(feattmp);
                    end
                    fpath = fdatabase{i}.path{j}{tr_idx(jj)};
                    load(fpath, 'fea', 'label');
                    for tt = 1:length(setting.rotate)   %%%if no rotate then for one
                        feattmp = fea{2}{tt};
                        ctr_fea{tt}{jj} = [ctr_fea{tt}{jj}; feattmp];
                    end
                    
                end
                for jj = 1:length(ts_idx),
                    if Samplevoted(jj) == 0
                    fprintf('Not voted snippets %d\n', jj)
                    continue;
                    end
                    fprintf('Compute distance by the latent information %d / %d\n', jj, length(ts_idx))
                    if setting.WTAwithraw
                        fpath = fdatabase{i}.Rawpath{j}{ts_idx(jj)};
                        load(fpath, 'fea', 'label');
                        rawfeat = fea{2};
                    end
                    
                    fpath = fdatabase{i}.path{j}{ts_idx(jj)};
                    load(fpath, 'fea', 'label');
                    feat = fea{2};
                    for tt = 1:length(tr_idx),
                        if NotRatio(jj,tt)== 0    
                            continue;
                        end
                        index = dfeat2{LL(jj,tt)}(LX(jj,tt), LY(jj,tt));
                        feat2 = ctr_fea{LR(jj,tt)}{tt};
                        feat1 = feat{LL(jj,tt)}{index};
                        Lscore(jj, tt) = sum((feat1(:) - feat2(:)).^2);   
                    end
                end
                ranktime = toc(th);
                save(fullfile(setting.latentresult,['newscore_', num2str(i), '_', num2str(j), '.mat']), 'Lscore', 'ranktime');
                clear 'ctr_fea';
                
                ts_idx = ts_idx1;
            end
        end
        
        AllScore = AllScore + Lscore;
    end  
end