function [acc, ranktime] = Classify_2(setting, img_dir, tr_idx, ts_idx, ...
    dFea, WTAfea, fdatabase, feattype, cpara, cmethod,  cindex, ...
    nameresult, nameimresult, issave, normmerge, multiview, Rconfidence)
if nargin < 14
    issave = 0;
end
if nargin < 15
    normmerge = 0;
end
if nargin < 16
    multiview = 0;
    Rconfidence = 0.5;
end

% setting.SQ = {'size', 'amgle', 'distance', 'stdR', 'stdG', 'stdB', };
setting.SQ = {'sizex', 'sizey', 'stdR', 'stdG', 'stdB', 'feat'};
setting.Nquality = length(setting.SQ);

if strcmp(cmethod, 'Siftflow')
    [acc, ranktime] = SiftFlow_Match(setting, img_dir, tr_idx, ts_idx, ...
        dFea, WTAfea, fdatabase, feattype, cpara, cindex, ...
        nameresult, nameimresult, issave, normmerge, multiview, Rconfidence);
    return;
end

if setting.latent
    [acc, ranktime] = Classify_2_latent(setting, img_dir, tr_idx, ts_idx, ...
        dFea, WTAfea, fdatabase, feattype, cpara, cmethod,  cindex, ...
        nameresult, nameimresult, issave, normmerge, multiview, Rconfidence);
    return;
end

setting.fast = 1;

ranktime = 0;

isWTA = setting.WTA;

[ADFea, findex, normmerge, WTAindex] = sumcell(dFea, WTAfea, normmerge);
mem_block = 3000;                   % maxmum number of testing feaTrues loaded each time  
fprintf('Training number: %d\n', length(tr_idx));
fprintf('Testing number:%d\n', length(ts_idx));

% load the training feaTrues 
tr_fea = zeros(length(tr_idx), ADFea );
tr_size = zeros(length(tr_idx), 2);
tr_label = zeros(length(tr_idx), 1);

if setting.confidence
    ts_quality = zeros(length(tr_idx), 1);
end

for jj = 1:length(tr_idx),
    bookfeattype = length(fdatabase{1}.path);
    for j = 1:length(bookfeattype)
    td = [fdatabase{1}.imgpath{tr_idx(jj)}];
    for i = 2:length(feattype)
        td1 = fdatabase{i}.imgpath{tr_idx(jj)};
        if ~strcmp(td, td1)
            fprintf('name error')
            pause;
        end
    end
    
    end
end
    
    
    
tr_imname = cell(length(tr_idx), 1);

for i = 1:length(feattype)
    bookfeattype = length(fdatabase{i}.path);
    for j = 1:length(bookfeattype)
    
    
    tr_featmp = zeros(length(tr_idx), dFea{i}{j});
    for jj = 1:length(tr_idx),
        tfea = [];
        if setting.WTAwithraw
            fpath = fdatabase{i}.Rawpath{j}{tr_idx(jj)};
            load(fpath, 'fea', 'label'); if normmerge fea = normlize(fea); end
            tfea = [tfea, fea'];
        end 
        fpath = fdatabase{i}.path{j}{tr_idx(jj)};
        load(fpath, 'fea', 'label'); if (normmerge && ~isWTA) fea = normlize(fea); end
        tfea = [tfea, double(fea')];
        
        tr_featmp(jj, :) = tfea;
        tr_label(jj) = label;

        tr_imname{jj} = fdatabase{i}.imgpath{tr_idx(jj)};

        tr_size(jj, :)=  graysize(imread(tr_imname{jj}));
        
    end
    tr_fea(:, findex{i}{j}(1):findex{i}{j}(2)) =  tr_featmp;
    
    end
end


clabel = unique(fdatabase{1}.label);
nclass = length(clabel);
    
switch cmethod
    case 'MultiSVM'
        c = cpara;
        options = ['-c ' num2str(c)];
        model = train(double(tr_label), sparse(tr_fea), options);
        clear tr_fea;
    case 'KNN'
        knn = cpara;
end

% load the testing feaTrues
Samplevoted = setting.Samplevoted;
if multiview
    ts_fold_idx = setting.ts_fold_idx;setting = rmfield(setting, 'ts_fold_idx');
    Asubname = setting.Asubname;setting = rmfield(setting, 'Asubname');
end

NotRatio = uint8(ones(length(ts_idx), length(tr_idx)));
if setting.Ratio
    setting.ts_ratio = setting.ts_ratio(:);
    setting.tr_ratio = setting.tr_ratio(:);
    Map1 = repmat(setting.ts_ratio, [1, length(setting.tr_ratio)]);
    Map2 = repmat(setting.tr_ratio', [length(setting.ts_ratio), 1]);
    dis = abs(Map1 - Map2) ./ Map2;
    NotRatio(find(dis > setting.RRatio)) = 0;
end

% load the testing feaTrues
ts_num = length(ts_idx);
ts_label = [];
ts_size = [];
ts_imname = {};

if ts_num < mem_block,

    % load the testing feaTrues directly into memory for testing
    ts_fea = zeros(length(ts_idx), ADFea);
    ts_label = zeros(length(ts_idx), 1);
    
    ts_size = zeros(length(ts_idx), 2);
    
    ts_imname = cell(length(ts_idx), 1);
    
    for i = 1:length(feattype)
        
        bookfeattype = length(fdatabase{i}.path);
        for j = 1:length(bookfeattype)
        
        ts_featmp = zeros(length(ts_idx), dFea{i}{j});
        for jj = 1:length(ts_idx),
            tfea = [];
            if setting.WTAwithraw
                fpath = fdatabase{i}.Rawpath{j}{ts_idx(jj)};
                load(fpath, 'fea', 'label');if normmerge fea = normlize(fea); end
                tfea = [tfea, fea'];
            end
            
            fpath = fdatabase{i}.path{j}{ts_idx(jj)};
            load(fpath, 'fea', 'label');if (normmerge && ~isWTA) fea = normlize(fea); end
            tfea = [tfea, double(fea')];

        
            ts_featmp(jj, :) = tfea;
            ts_label(jj) = label;
            
            ts_imname{jj} = fdatabase{i}.imgpath{ts_idx(jj)};

            ts_size(jj,:) = graysize(imread(ts_imname{jj})); 
            

            if setting.confidence
                ts_quality(jj,:) = Getqulity(imread(ts_imname{jj})); 
            end
            
        end
        ts_fea(:, findex{i}{j}(1):findex{i}{j}(2)) =  ts_featmp;
        
        end
    end
    
    switch cmethod
        case 'MultiSVM'
            [C] = predict(ts_label, sparse(ts_fea), model);
        case 'KNN'
            th = tic;
            [IDX, distance] = GetRank_WTA(Samplevoted, NotRatio, ...
                setting.BitCount, setting.K, ...
                isWTA, setting.WTAwithraw, WTAindex, tr_fea, ts_fea, knn);
            ranktime = ranktime + toc(th);
            C = reshape(tr_label(IDX), [size(IDX, 1), knn]);
    end

    
else
    % load the testing feaTrues block by block
    num_block = floor(ts_num/mem_block);

    rem_fea = rem(ts_num, mem_block);
    
    curr_ts_fea = zeros(mem_block, ADFea);
    curr_ts_label = zeros(mem_block, 1);
    
    curr_ts_size = zeros(mem_block, 2);
    
    curr_ts_imname = cell(mem_block, 1);
    
    
    curr_ts_quality = zeros(mem_block, 1);

        
    C = [];
    distance = [];
        
    for jj = 1:num_block,
        block_idx = (jj-1)*mem_block + (1:mem_block);
        curr_idx = ts_idx(block_idx); 
        
        % load the current block of feaTrues
        for kk = 1:mem_block,
            for i = 1:length(feattype)
                
                bookfeattype = length(fdatabase{i}.path);
                for j = 1:length(bookfeattype)
                tfea = [];
                if setting.WTAwithraw
                    fpath = fdatabase{i}.Rawpath{j}{curr_idx(kk)};
                    load(fpath, 'fea', 'label');if normmerge fea = normlize(fea); end
                    tfea = [tfea, fea'];
                end
                
                fpath = fdatabase{i}.path{j}{curr_idx(kk)};
                load(fpath, 'fea', 'label');if (normmerge && ~isWTA) fea = normlize(fea); end
                tfea = [tfea, double(fea')];
                
                ts_featmp = tfea;
                curr_ts_label(kk) = label;
                
                
                
                curr_ts_fea(kk, findex{i}{j}(1):findex{i}{j}(2)) =  ts_featmp;
                
                curr_ts_imname{kk} = fdatabase{i}.imgpath{curr_idx(kk)};
                
                curr_ts_size(kk,:) = graysize(imread(curr_ts_imname{kk}));
                
                if setting.confidence
                    curr_ts_quality(kk,:) = Getqulity(imread(curr_ts_imname{kk})); 
                end
            
                
                end
            end
        end
        
        % test the current block feaTrues
        ts_label = [ts_label; curr_ts_label];
        
        ts_size = [ts_size; curr_ts_size];
        
        ts_imname = [ts_imname, curr_ts_imname];
        
        switch cmethod
            case 'MultiSVM'
                [curr_C] = predict(curr_ts_label, sparse(curr_ts_fea), model);
            case 'KNN'
                th = tic;
                [IDX, curr_distance] = GetRank_WTA(Samplevoted(block_idx), ...
                    NotRatio(block_idx,:), setting.BitCount, ...
                    setting.K, isWTA, setting.WTAwithraw, WTAindex, tr_fea, curr_ts_fea, knn);
                ranktime = ranktime + toc(th);

                curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knn]);
        end
        
        C = [C; curr_C];
        
        distance = [distance; curr_distance];
    end
    
    curr_ts_fea = zeros(rem_fea, ADFea);
    curr_ts_label = zeros(rem_fea, 1);
    
    curr_ts_size = zeros(rem_fea, 2);
    
    curr_ts_imname = cell(rem_fea, 1);
    
    curr_idx = ts_idx(num_block*mem_block + (1:rem_fea));
    iindex = num_block*mem_block + (1:rem_fea);
        
    for kk = 1:rem_fea,
        for i = 1:length(feattype)
            bookfeattype = length(fdatabase{i}.path);
            for j = 1:length(bookfeattype)
                tfea = [];
                if setting.WTAwithraw
                    fpath = fdatabase{i}.Rawpath{j}{curr_idx(kk)};
                    load(fpath, 'fea', 'label');if normmerge fea = normlize(fea); end
                    tfea = [tfea, fea'];
                end
                
                
                fpath = fdatabase{i}.path{j}{curr_idx(kk)};
                load(fpath, 'fea', 'label');if (normmerge && ~isWTA) fea = normlize(fea); end
                tfea = [tfea, double(fea')];
                
                
                curr_ts_label(kk) = label;
                
                curr_ts_fea(kk, findex{i}{j}(1):findex{i}{j}(2)) =  tfea;
           
                curr_ts_imname{kk} = fdatabase{i}.imgpath{curr_idx(kk)};
                curr_ts_size(kk,:) = graysize(imread(curr_ts_imname{kk}));
           
            end
        end  
    end
    
    ts_label = [ts_label; curr_ts_label];
    
    ts_size = [ts_size; curr_ts_size];
    
    ts_imname = [ts_imname; curr_ts_imname];
    

    switch cmethod
        case 'MultiSVM'
            [curr_C] = predict(curr_ts_label, sparse(curr_ts_fea), model);
        case 'KNN'
            th = tic;
            [IDX, curr_distance] = GetRank_WTA(Samplevoted(iindex), ...
                NotRatio(iindex,:), setting.BitCount, ...
                setting.K, isWTA, setting.WTAwithraw, WTAindex, tr_fea, curr_ts_fea, knn);
            ranktime = ranktime + toc(th);   
            curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knn]);
            
    end

    C = [C; curr_C];
    distance = [distance; curr_distance];   
end

if setting.TConfidence
    pred_label = C;
    gnd_label = repmat(ts_label, [1, knn]);   %%%
    F_id = find(sum((pred_label == gnd_label), 2) == 0);
    
    
%     setting.ts_ratio = setting.ts_ratio(:);
%     setting.tr_ratio = setting.tr_ratio(:);
%     Map1 = repmat(setting.ts_ratio, [1, length(setting.tr_ratio)]);
%     Map2 = repmat(setting.tr_ratio', [length(setting.ts_ratio), 1]);
%     conf_tr_fea(:, 1) = abs(Map1 - Map2) ./ Map2;
 
%     setting.ts_size = setting.ts_ratio(:);
%     setting.tr_ratio = setting.tr_ratio(:);
%     Map1 = repmat(setting.ts_ratio, [1, length(setting.tr_ratio)]);
%     Map2 = repmat(setting.tr_ratio', [length(setting.ts_ratio), 1]);
%      = abs(Map1 - Map2) ./ Map2;
    
    
%     xtr_size = tr_size(:,1);ytr_size = tr_size(:,2);
%     xts_size = ts_size(:,1);yts_size = ts_size(:,2);
%     Map1 = repmat(setting.ts_ratio, [1, length(setting.tr_ratio)]);
%     Map2 = repmat(setting.tr_ratio', [length(setting.ts_ratio), 1]);
%     dis = abs(Map1 - Map2) ./ Map2;
%     \
            
            
    %     c = cpara;
%         options = ['-c ' num2str(c)];
    model = train(double(conf_tr_label), sparse(conf_tr_fea), options);
    clear tr_fea;
        
        
        
    [curr_C] = predict(curr_ts_label, sparse(curr_ts_fea), model);
    
    
    
    
    
end


voted1 = ones(size(C));
if multiview
    C_1 = C;
    [C, voted1] = GetRerank2(C, distance, nclass,  ts_fold_idx, multiview,Rconfidence,...
        ts_imname, tr_imname, tr_size, ts_size);
end


strpattern = 'test_UCM_T3-0005-20130503-190839_SignSnippetsRectified_';

acc = zeros(nclass, 1);
for jj = 1 : nclass,
    if ~ismember(jj, cindex)
        continue;
    end
    c = clabel(jj);
    idx = find(ts_label == c);
    curr_pred_label = C(idx, :);
    curr_gnd_label = ts_label(idx); 
    
    curr_gnd_label1 = repmat(curr_gnd_label, [1, knn]);
    tp = sum((curr_pred_label == curr_gnd_label1), 2);
    tid = find(tp > 0);
    
    curr_ts_imname = ts_imname(idx);
    curr_ts_idx = ts_fold_idx(idx);
    voted = voted1(idx, :);
    result_idx = zeros(length(curr_ts_idx), 1);
    
    curr_index = ts_fold_idx(idx);
    uindex =  unique(curr_index);
    
    tpfold = zeros(1, length(uindex));
    
    for ii = 1:length(uindex)
        idc = find(curr_index == uindex(ii));    
        tmp = ismember(idc, tid);
        if length(unique(tmp)) > 1
            fprintf('Error, Some Snippets have different prediction label\n')
            pause;
        end
        subname = Asubname{uindex(ii)};
        idd = strfind(subname, strpattern);
        subname = subname(idd+length(strpattern):end);
        if tmp(1)
            tpfold(ii) = 1;
        end
        if issave
            if tmp(1)
                result_idx(idc) = 1;
                tfn = fullfile(nameimresult, 'True', subname);
                Mkdirvalid(tfn);
                tfn = fullfile(nameimresult, 'True', subname, 'VotedSample');
                Mkdirvalid(tfn);       
            else
                ffn = fullfile(nameimresult, 'False', subname);
                Mkdirvalid(ffn);
                ffn = fullfile(nameimresult, 'False', subname, 'VotedSample');
                Mkdirvalid(ffn); 
            end
        end
    end
    acc(jj) = length(find(tpfold==1))/length(uindex); 
        
   if issave
        curr_index = ts_fold_idx(idx);
        uindex =  unique(curr_index);
        for ii = 1:length(uindex)
            idc = find(curr_index == uindex(ii));    
            tmp = ismember(idc, tid);
            if length(unique(tmp)) > 1
                fprintf('Error, Some Snippets have different prediction label\n')
                pause;
            end
            subname = Asubname{uindex(ii)};
            idd = strfind(subname, strpattern);
            subname = subname(idd+length(strpattern):end);
            if tmp(1)
                result_idx(idc) = 1;
                tfn = fullfile(nameimresult, 'True', subname);
                Mkdirvalid(tfn);
                tfn = fullfile(nameimresult, 'True', subname, 'VotedSample');
                Mkdirvalid(tfn);       
            else
                ffn = fullfile(nameimresult, 'False', subname);
                Mkdirvalid(ffn);
                ffn = fullfile(nameimresult, 'False', subname, 'VotedSample');
                Mkdirvalid(ffn); 
            end
        end
        
        nn = ceil(knn / 5);
        col = knn;
        if knn>=5
            col = 5;
        end
        
        for ii = 1:length(uindex)
            
            idc = find(curr_index == uindex(ii));
            subname = Asubname{uindex(ii)}; 
            idd = strfind(subname, strpattern);
            subname = subname(idd+length(strpattern):end);
            
            idxcur = curr_index(idc);

            row = ceil((length(idxcur)) / knn);
            if knn < 5
                col = 5;
                row = ceil((length(idxcur)) / 5);
            end
            figure;
            for tt = 1:length(idxcur)
                tmp = curr_ts_imname{idc(tt)}; 
                id = strfind(tmp, subname);
                tmp = tmp(id + length(subname):end);tmp(find(tmp== '_')) = '-';
                
                im = imread(curr_ts_imname{idc(tt)});
                subplot(row+2, col, tt);imshow(uint8(im));
                title(tmp);
            end
            im = imread(tr_imname{curr_gnd_label(idc(1))});
            subplot(row+2, col, 1+col*row);imshow(uint8(im));
            title('Ground truth labeling');
            index = 0;
            for j = 1:knn
                index = index+1;
                im = imread(tr_imname{curr_pred_label(idc(1), j)});
                subplot(row+2, col, (row+1)*col+index);
                imshow(uint8(im));
                title(['Rank ' num2str(j)]);
            end
            tmp = ismember(idc, tid);
            if tmp(1)
                print(gcf, '-djpeg', '-r0', fullfile(nameimresult, 'True', [subname, '.jpg'])); 
            else
                print(gcf, '-djpeg', '-r0', fullfile(nameimresult, 'False', [subname, '.jpg']));
            end


%             if tmp(1)
%                 print(gcf, '-djpeg', '-r0', fullfile(nameimresult, 'True', subname, 'Merged.jpg')); 
%             else
%                 print(gcf, '-djpeg', '-r0', fullfile(nameimresult, 'False', subname, 'Merged.jpg'));
%             end
            close all;
        end
            
%         curr_pred_label1 = C_1(idx, :);
%         for i = 1:length(curr_ts_imname)
%             nn = ceil(knn / 5);
%             col = knn;
%             
%             if ~nnz(voted(i,:))
%                 continue;
%             end
%             subname = Asubname{curr_ts_idx(i)};
%             idd = strfind(subname, strpattern);
%             subname = subname(idd+length(strpattern):end);
%             
%             figure;im = imread(curr_ts_imname{i});
%             subplot(nn+2, col, 1);imshow(uint8(im));
%             title('Test sample');
%             
%             im = imread(tr_imname{curr_gnd_label(i)});
%             subplot(nn+2, col, 1+col);imshow(uint8(im));
%             title('Ground truth labeling');
%             index = 0;
%             for j = 1:knn
%                 
%                 if voted(i,j) == 0
%                     continue;
%                 end
%                  
%                
%                 index = index+1;
%                 im = imread(tr_imname{curr_pred_label1(i, j)});
%                 subplot(nn+2, col, 2*col+index);
%                 imshow(uint8(im));
%                 title(['rank ' num2str(j)]);
%             end
%             tmp = curr_ts_imname{i};
%             id = strfind(tmp, subname);
%             tmp = tmp(id + length(subname):end);
%             
%             if result_idx(i)
%                 print(gcf, '-djpeg', '-r0', fullfile(nameimresult, 'True', subname, 'VotedSample', tmp));
%             else
%                 print(gcf, '-djpeg', '-r0', fullfile(nameimresult, 'False', subname, 'VotedSample', tmp));
%             end
%             close all;
%         end
    end  
%     acc(jj) = length(tid)/length(idx);
end
acc = acc(cindex);