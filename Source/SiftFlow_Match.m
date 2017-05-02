function [acc, ranktime] = SiftFlow_Match(setting, img_dir, tr_idx, ts_idx, ...
    dFea, WTAfea, fdatabase, feattype, cpara, cindex, ...
    nameresult, nameimresult, issave, normmerge, multiview, Rconfidence)
addpath('siftflow')

if isfield(setting, 'fast') && setting.fast
    [acc, ranktime] = SiftFlow_Match1(setting, img_dir, tr_idx, ts_idx, ...
        dFea, WTAfea, fdatabase, feattype, cpara, cindex, ...
        nameresult, nameimresult, issave, normmerge, multiview, Rconfidence);
    return;
end

ranktime = 0;


isWTA = setting.WTA;

[ADFea, findex, normmerge, WTAindex] = sumcell(dFea, WTAfea, normmerge);
mem_block = 3000;                   % maxmum number of testing feaTrues loaded each time  
fprintf('Training number: %d\n', length(tr_idx));
fprintf('Testing number:%d\n', length(ts_idx));

% load the training feaTrues 
% tr_fea = zeros(length(tr_idx), ADFea );

tr_fea = cell(length(tr_idx), 1);

tr_size = zeros(length(tr_idx), 2);

tr_label = zeros(length(tr_idx), 1);

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
    
    
    tr_featmp = cell(length(tr_idx), 1);
    
    for jj = 1:length(tr_idx),
        fpath = fdatabase{i}.path{j}{tr_idx(jj)};
        load(fpath, 'fea', 'label'); if (normmerge && ~isWTA) fea = normlize(fea); end
        tr_featmp{jj} = fea;
        
        tr_label(jj) = label;

        tr_imname{jj} = fdatabase{i}.imgpath{tr_idx(jj)};

        tr_size(jj, :)=  graysize(imread(tr_imname{jj}));
        
    end
    tr_fea =  tr_featmp;
    
    end
end

clabel = unique(fdatabase{1}.label);
nclass = length(clabel);
    
knn = cpara;

% load the testing feaTrues
ts_num = length(ts_idx);
ts_label = [];
ts_size = [];
ts_imname = {};

if ts_num < mem_block,

    % load the testing feaTrues directly into memory for testing
    ts_fea = cell(length(ts_idx), 1);
    
    ts_label = zeros(length(ts_idx), 1);
    
    ts_size = zeros(length(ts_idx), 2);
    
    ts_imname = cell(length(ts_idx), 1);
    
    for i = 1:length(feattype)
        
        bookfeattype = length(fdatabase{i}.path);
        for j = 1:length(bookfeattype)
        
        ts_featmp = cell(length(ts_idx), 1);
        for jj = 1:length(ts_idx),

            fpath = fdatabase{i}.path{j}{ts_idx(jj)};
            load(fpath, 'fea', 'label');if (normmerge && ~isWTA) fea = normlize(fea); end
            ts_featmp{jj} = fea;
        
        
            ts_label(jj) = label;
            
            ts_imname{jj} = fdatabase{i}.imgpath{ts_idx(jj)};

            ts_size(jj,:) = graysize(imread(ts_imname{jj})); 
            
        end
        ts_fea =  ts_featmp;
        
        end
    end
    
    th = tic;
    [IDX, distance] = GetRank_SFLOW(setting, tr_fea, ts_fea, knn);
    ranktime = ranktime + toc(th);
    C = reshape(tr_label(IDX), [size(IDX, 1), knn]);


    
else
    % load the testing feaTrues block by block
    num_block = floor(ts_num/mem_block);

    rem_fea = rem(ts_num, mem_block);
    
%     curr_ts_fea = zeros(mem_block, ADFea);

    curr_ts_fea = cell(mem_block, 1);
    
    
    curr_ts_label = zeros(mem_block, 1);
    
    curr_ts_size = zeros(mem_block, 2);
    
    curr_ts_imname = cell(mem_block, 1);
    
        
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

                fpath = fdatabase{i}.path{j}{curr_idx(kk)};
                load(fpath, 'fea', 'label');if (normmerge && ~isWTA) fea = normlize(fea); end

                curr_ts_label(kk) = label;
                
                
                
                curr_ts_fea{kk} =  fea;
                
                curr_ts_imname{kk} = fdatabase{i}.imgpath{curr_idx(kk)};
                
                curr_ts_size(kk,:) = graysize(imread(curr_ts_imname{kk}));
                
                end
            end
        end
        
        % test the current block feaTrues
        ts_label = [ts_label; curr_ts_label];
        
        ts_size = [ts_size; curr_ts_size];
        
        ts_imname = [ts_imname, curr_ts_imname];
        
        th = tic;
        [IDX, curr_distance] = GetRank_SFLOW(setting, tr_fea, curr_ts_fea, knn);
        ranktime = ranktime + toc(th);
        curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knn]);
        
        C = [C; curr_C];
        
        distance = [distance; curr_distance];
    end
    
%     curr_ts_fea = zeros(rem_fea, ADFea);
    curr_ts_label = zeros(rem_fea, 1);
    curr_ts_fea = cell(rem_fea, 1);
    curr_ts_size = zeros(rem_fea, 2);
    
    curr_ts_imname = cell(rem_fea, 1);
    
    curr_idx = ts_idx(num_block*mem_block + (1:rem_fea));
        
    for kk = 1:rem_fea,
        for i = 1:length(feattype)
            bookfeattype = length(fdatabase{i}.path);
            for j = 1:length(bookfeattype)
                fpath = fdatabase{i}.path{j}{curr_idx(kk)};
                load(fpath, 'fea', 'label');if (normmerge && ~isWTA) fea = normlize(fea); end
                curr_ts_fea{kk} =  fea;
                
                
                curr_ts_label(kk) = label;
                
                curr_ts_imname{kk} = fdatabase{i}.imgpath{curr_idx(kk)};
                curr_ts_size(kk,:) = graysize(imread(curr_ts_imname{kk}));
           
            end
        end  
    end
    
    ts_label = [ts_label; curr_ts_label];
    
    ts_size = [ts_size; curr_ts_size];
    
    ts_imname = [ts_imname; curr_ts_imname];
    

    th = tic;
    [IDX, curr_distance] = GetRank_SFLOW(setting, tr_fea, curr_ts_fea, knn);
    
    ranktime = ranktime + toc(th);   
    curr_C = reshape(tr_label(IDX(:)), [size(IDX, 1), knn]);
    
    C = [C; curr_C];
    distance = [distance; curr_distance];   
end




voted1 = ones(size(C));
if multiview
    ts_idx = zeros(1, length(ts_imname));
    % img_dir = 'image\Sign';
    subfolders = dir(fullfile(img_dir, 'TrueSign\-1'));
    jj = 0;
    for ii = 1:length(subfolders),
        subname = subfolders(ii).name;
    
        if ~strcmp(subname, '.') & ~strcmp(subname, '..'),
            jj =jj +1;
            subname = [subname, '_'];
            index = (strfind(ts_imname, subname));
            b = cellfun('isempty',index);
            paindex = find(b == 0);
            for tt = 1:length(paindex)
                if isempty(strfind(ts_imname{paindex(tt)}, subname))
                    fprintf('Error, Something error with strfind \n');
                    pause
                end
            end
            
            if nnz(ts_idx(paindex))
                fprintf('Error, more than two file contains this sample \n');
                subname
                ts_imname{paindex(1)}
                pause
            end
            ts_idx(paindex) = jj;
            Asubname{jj} = subname;
        end
        
    end;
    C_1 = C;
    [C, voted1] = GetRerank2(C, distance, nclass,  ts_idx, multiview,Rconfidence,...
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
    curr_ts_idx = ts_idx(idx);
    voted = voted1(idx, :);
    result_idx = zeros(length(curr_ts_idx), 1);
    
    curr_index = ts_idx(idx);
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
        curr_index = ts_idx(idx);
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