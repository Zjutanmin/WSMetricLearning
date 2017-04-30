function [AllScore, tr_size] = getScoreSVM(feattype, ts_idx, tr_idx, setting, fdatabase, ...
    Mstr, Samplevoted, NotRatio, cindex, normmerge, knnpara, cpara)
tr_label = zeros(length(tr_idx), 1);ts_label = zeros(length(ts_idx), 1);
clabel = unique(fdatabase{1}.label);
nclass = length(clabel);
Psvmtrain = setting.Psvmtrain;kerneltype = setting.kerneltype;


% Lscore = Inf * ones(length(setting.ts_idx), length(tr_idx));
Lscore = Inf * ones(length(ts_idx), length(tr_idx));


AllScore = zeros(size(Lscore));
LX = zeros(length(ts_idx), length(tr_idx));
LY = zeros(length(ts_idx), length(tr_idx));
LL = zeros(length(ts_idx), length(tr_idx));
LR = zeros(length(ts_idx), length(tr_idx));
% labelmap = (length(cindex)+1) * ones(nclass, 1);
% labelmap(cindex) = [1:length(cindex)];
labelmap = setting.labelmap;
for i = 1
    for j = 1
        for jj = 1:length(tr_idx),
            fpath = fdatabase{i}.path{j}{tr_idx(jj)};
            load(fpath,  'label');
            tr_label(jj) = label;
            tr_imname{jj} = fdatabase{i}.imgpath{tr_idx(jj)};
            tr_size(jj, :)=  graysize(imread(tr_imname{jj}));
        end
    end
end

try
    load(fullfile(setting.latentresult,['latent', Mstr(1:end-4), setting.svotestr, '.mat']), 'LX', 'LY', 'LL', 'LR', 'Lscore');
catch
    ts_idx1 = ts_idx;
    ts_idx = setting.ts_idx;
    
    try
        load(fullfile(setting.Modelresult,['Model-', Mstr]), 'model');
    catch
        ctr_fea = []; 
        for i = 1:length(feattype)
            bookfeattype = length(fdatabase{i}.path);
            for j = 1:length(bookfeattype)
                c = cpara(1);
                w = cpara(2);
                ctr_fea_t = []; tr_label = [];
                for jj = 1:length(tr_idx),
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
        
        if Psvmtrain
            wstr = ' -b 1';
        else
            wstr = '';
        end
        if w ~= 0
            xx = hist(tr_label, [1:length(cindex)+1]);
            xx = xx / sum(xx);
            wi = min(xx) ./ xx; 
            [tt, idx] = min(wi);
            wi(idx) = w * wi(idx); 
            wstr = getWstr(wi);
        end
        if c == -1
            [cbest, dbest, gbest, rbest, options, Vpara] = CrossValidate(kerneltype, ...
                wstr, tr_label, ctr_fea, Psvmtrain, setting.Crange);
            save(fullfile(setting.Modelresult,['Validate', Mstr]), ...
                'cbest', 'dbest', 'gbest', 'rbest', 'Vpara');  
        else
            
            cbest = c;
                            if Psvmtrain
                                options = ['-c ' num2str(c) wstr ' -b 1'];
                            else
                                options = ['-c ' num2str(c) wstr];
                            end
        end
        if Psvmtrain
            model = svmtrain(double(tr_label), sparse(ctr_fea), options);
            [C,a,b] = svmpredict(tr_label, sparse(ctr_fea), model);
        else
            model = train(double(tr_label), sparse(ctr_fea), options);
            [C,a,b] = predict(tr_label, sparse(ctr_fea), model);
        end
        
        save(fullfile(setting.Modelresult,['TrainError', Mstr]), 'a', 'C');
        clear ctr_fea;
        save(fullfile(setting.Modelresult,['Model-', Mstr]), 'model');
    end
    modelW = {};
    jj = 1;fsize = [];
    for i = 1:length(feattype)
        bookfeattype = length(fdatabase{i}.path);
            for j = 1:length(bookfeattype)
                fpath = fdatabase{i}.path{j}{tr_idx(jj)};load(fpath, 'fea', 'label');
                fsize = [fsize; size(fea{1}{1})];
            end
    end
    fsize = [fsize(1,1:2), sum(fsize(:,3))];
    
    if ~Psvmtrain
        if nnz(model.Label' - [1:length(model.Label)])
            model.w(model.Label,:) = model.w;
            model.Label = [1:length(model.Label)]';
            save(fullfile(setting.Modelresult,['Model-', Mstr]), 'model');
        end
        if setting.latent == 1
            for jj = 1:size(model.w,1)
                modelW{jj} = reshape(model.w(jj,:), fsize);
            end
            model.FLabel(model.Label) = [1:length(model.Label)];
        end
    else
        Adiag = repmat(model.Label', [length(model.Label),1 ]);A = tril(Adiag, -1);
        model.A = A(find(A~=0));
        Bdiag = repmat(model.Label, [1, length(model.Label)]);B = tril(Bdiag, -1);
        model.B = B(find(B~=0));
    end
    
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
                if i == 1 && j== 1
                    feat = fea{1};
                else
                    feat = Combine(feat, fea{1});
                end
                
                ts_label(jj) = label;
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
        
        for hh = 1:length(setting.displace) %%%for each position, if no dispard , then 0
            [rscore, rxpos, rypos, rrpos] = ...
                bestmatchSVM(aindex, feat{hh}, labelmap(label), model, modelW, Psvmtrain, fsize);
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
    save(fullfile(setting.latentresult,['latent', Mstr(1:end-4), setting.svotestr, '.mat']), 'LX', 'LY', 'LL', 'LR', 'Lscore');
    if setting.latent > 1
            try
                load(fullfile(setting.latentresult,['newscore_', num2str(i), '_', num2str(j), '.mat']), 'Lscore');                
            catch
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
                save(fullfile(setting.latentresult,['newscore_', num2str(i), '_', num2str(j), '.mat']), 'Lscore');
                clear 'ctr_fea';
                
                
            end
    end
    ts_idx = ts_idx1;
    AllScore = AllScore + Lscore; 
end

function feat = Combine(feat, fea)
for i = 1:length(feat)
    feat{i}(:,:,end+1:end+size(fea{i},3)) = fea{i};
end