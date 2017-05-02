function acc = KNNsearch(tr_idx, ts_idx, dFea, fdatabase, feattype,cpara, cmethod)  
[ADFea, findex] = sumcell(dFea);
mem_block = 3000;                   % maxmum number of testing features loaded each time  
fprintf('Training number: %d\n', length(tr_idx));
fprintf('Testing number:%d\n', length(ts_idx));
    
% load the training features 
tr_fea = zeros(length(tr_idx), ADFea );
tr_label = zeros(length(tr_idx), 1);
for i = 1:length(feattype)
    tr_featmp = zeros(length(tr_idx), dFea{i});
    for jj = 1:length(tr_idx),
        fpath = fdatabase{i}.path{tr_idx(jj)};
        load(fpath, 'fea', 'label');
        tr_featmp(jj, :) = fea';
        tr_label(jj) = label;
    end
    tr_fea(:, findex{i}(1):findex{i}(2)) =  tr_featmp;
end

switch cmethod
    case 'MultiSVM'
        c = cpara;
        options = ['-c ' num2str(c)];
        model = train(double(tr_label), sparse(tr_fea), options);
        clear tr_fea;
    case 'KNN'
        knn = cpara;
end

% load the testing features
ts_num = length(ts_idx);
ts_label = [];
    
if ts_num < mem_block,
    % load the testing features directly into memory for testing
    ts_fea = zeros(length(ts_idx), ADFea);
    ts_label = zeros(length(ts_idx), 1);
    
    for i = 1:length(feattype)
        ts_featmp = zeros(length(ts_idx), dFea{i});
        for jj = 1:length(ts_idx),
            fpath = fdatabase{i}.path{ts_idx(jj)};
            load(fpath, 'fea', 'label');
            ts_fea(jj, :) = fea';
            ts_label(jj) = label;
        end
        ts_fea(:, findex{i}(1):findex{i}(2)) =  ts_featmp;
    end
    
    switch cmethod
        case 'MultiSVM'
            [C] = predict(ts_label, sparse(ts_fea), model);
        case 'KNN'
            IDX = GetRank(tr_fea, ts_fea, knn);
            C = reshape(tr_label(INX), [size(IDX, 1), knn]);
    end

    
else
    % load the testing features block by block
    num_block = floor(ts_num/mem_block);

    rem_fea = rem(ts_num, mem_block);
    
    curr_ts_fea = zeros(mem_block, ADFea);
    curr_ts_label = zeros(mem_block, 1);
        
    C = [];
        
    for jj = 1:num_block,
        block_idx = (jj-1)*mem_block + (1:mem_block);
        curr_idx = ts_idx(block_idx); 
        
        % load the current block of features
        for kk = 1:mem_block,
            for i = 1:length(feattype)
                fpath = fdatabase{i}.path{curr_idx(kk)};
                load(fpath, 'fea', 'label');
                ts_featmp = fea';
                curr_ts_label(kk) = label;
                
                curr_ts_fea(kk, findex{i}(1):findex{i}(2)) =  ts_featmp;
            end
        end
        
        % test the current block features
        ts_label = [ts_label; curr_ts_label];
        
        switch cmethod
            case 'MultiSVM'
                [curr_C] = predict(curr_ts_label, sparse(curr_ts_fea), model);
            case 'KNN'
                IDX = GetRank(tr_fea, curr_ts_fea, knn);
                curr_C = reshape(curr_ts_label(IDX(:)), [size(IDX, 1), knn]);
        end
        
        C = [C; curr_C];
    end
    
    curr_ts_fea = zeros(rem_fea, ADFea);
    curr_ts_label = zeros(rem_fea, 1);
    curr_idx = ts_idx(num_block*mem_block + (1:rem_fea));
        
    for kk = 1:rem_fea,
        for i = 1:length(feattype)
           fpath = fdatabase.path{curr_idx(kk)};
           load(fpath, 'fea', 'label');
%            curr_ts_fea(kk, :) = fea';
           curr_ts_label(kk) = label;
           
           curr_ts_fea(kk, findex{i}(1):findex{i}(2)) =  fea';
        end  
    end
    
    ts_label = [ts_label; curr_ts_label];
    
    [curr_C] = predict(curr_ts_label, sparse(curr_ts_fea), model);
    C = [C; curr_C];     
end

acc = zeros(nclass, 1);
for jj = 1 : nclass,
    if ~ismember(jj, cindex)
        continue;
    end
    c = clabel(jj);
    idx = find(ts_label == c);
    curr_pred_label = C(idx, :);
    curr_gnd_label = ts_label(idx);    
    acc(jj) = length(find(curr_pred_label == curr_gnd_label))/length(idx);
end
acc = acc(cindex);