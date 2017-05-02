function [cindex, cname] = getCindex(img_dir1, img_dir, dataname, ...
    mfea_dir, mfea_dir_WTA, setting, copyremove, feattype, suffix)
if nargin <7
    suffix = '_New';
end
img_diro = img_dir;
if setting.Ratio == 2
    ratio_dir = setting.ratio_dir;
    fratio = fullfile(ratio_dir, 'saveratio.mat');
    try
        load(fratio, 'saveratio');
    catch
        writeRatioinfo(img_dir, ratio_dir);
        save(fratio, 'saveratio');
    end
end

Trainid = 0;
Sel_img_dir = [];
if ~strcmp(dataname, 'Caltech101')
    Trainid = 1;
    tt = strfind(img_dir, suffix);
    if ~isempty(tt)
        Sel_img_dir = img_dir(1:tt(1)-1);
    end
end

datafn = 'TrainInfo';
if ~exist(datafn)
    mkdir(datafn)
end

str = [img_dir '_' num2str(Trainid)];
str(find(str == '\')) = '_';
str(find(str == '/')) = '_';str = fullfile(datafn, str);
TFstr = str;
try
    load([TFstr, '_database.mat'], 'database');
catch
    database = retr_database_dir_img(img_dir, Sel_img_dir, Trainid);
    save([TFstr, '_database.mat'], 'database');
end

database1 = database;

if setting.indexcolor
    setting.img_dir = img_dir;
    setting.database = database;    
end

if isfield(setting,'DoG') && setting.DoG
    img_dir_old = img_dir;
    img_dir = dogFilter(img_dir, database, setting);
    img_dir_old(find(img_dir_old == '/')) = '\';
    nFea = length(database.path);
    for iter1 = 1:nFea,  
        fpath = database.path{iter1};
        index = strfind(fpath, img_dir_old);
        imname = fpath(index+length(img_dir_old)+1:end);
        fpath = fullfile(img_dir, imname);
        database.path{iter1} = fpath;
    end;
end

WTAfea = cell(1, length(feattype));

dfea = cell(1, length(feattype));
fdatabase = cell(1, length(feattype));
for i = 1:length(feattype)
    switch feattype{i}
        case 'llc'
            [fdatabase{i}, database, dfea{i}, WTAfea{i}] = getllcfeature(img_dir, dataname, ...
                mfea_dir{i}, mfea_dir_WTA{i}, i, setting, copyremove, database);
        case 'hog'
            [fdatabase{i}, database, dfea{i}, WTAfea{i}] = getrawfeature(img_dir, dataname, ...
                mfea_dir{i}, mfea_dir_WTA{i}, i, setting, copyremove, database);
        case 'lbp'
            [fdatabase{i}, database, dfea{i}, WTAfea{i}] = getrawfeature(img_dir, dataname, ...
                mfea_dir{i}, mfea_dir_WTA{i}, i, setting, copyremove, database);
        case 'ltp'
            [fdatabase{i}, database, dfea{i}, WTAfea{i}] = getrawfeature(img_dir, dataname, ...
                mfea_dir{i}, mfea_dir_WTA{i}, i, setting, copyremove, database);
            
        case 'color'
            [fdatabase{i}, database, dfea{i}, WTAfea{i}] = getrawfeature(setting.img_dir, dataname, ...
                mfea_dir{i}, mfea_dir_WTA{i}, i, setting, copyremove, setting.database);
        case 'sift'
            [fdatabase{i}, database, dfea{i}, WTAfea{i}] = getrawfeature(img_dir, dataname, ...
                mfea_dir{i}, mfea_dir_WTA{i}, i, setting, copyremove, database);
        case 'bow' 
            [fdatabase{i}, database, dfea{i}, WTAfea{i}] = getrawfeature(img_dir, dataname, ...
                mfea_dir{i}, mfea_dir_WTA{i}, i, setting, copyremove, database);
        case 'siftflow' 
            [fdatabase{i}, database, dfea{i}, WTAfea{i}] = siftflowfeature(img_dir, dataname, ...
                mfea_dir{i}, mfea_dir_WTA{i}, i, setting, copyremove, database);
        otherwise
            display('A non existing assignment method is selected');
    end
end
database = database1;
clabel = unique(fdatabase{1}.label);
nclass = length(clabel);

cindex = [];
for jj = 1:nclass,
    idx_label = find(fdatabase{1}.label == clabel(jj));
    if length( idx_label) > 1
        cindex = [cindex, jj];
    end
end
setting.cindex = cindex;

try
    load([TFstr, '_index.mat'], 'tr_idx', 'ts_idx');
catch 
    fprintf('\n Testing info...\n');
    tr_idx = [];
    ts_idx = [];
    
    for jj = 1:nclass,
        idx_label = find(fdatabase{1}.label == clabel(jj));
        num = length(idx_label);
        if strcmp(dataname, 'Caltech101')
            idx_rand = randperm(num);
            tr_idx = [tr_idx; idx_label(idx_rand(1:tr_num))];
            ts_idx = [ts_idx; idx_label(idx_rand(tr_num+1:end))];
        else
            tindex = find(database.istrain(idx_label) == 1);
            tindex1 = setdiff([1:length(idx_label)], tindex);
            tr_idx = [tr_idx; idx_label(tindex)];
            ts_idx = [ts_idx; idx_label(tindex1)];
        end
    end
    save([TFstr, '_index.mat'], 'tr_idx', 'ts_idx');
end
setting.tr_idx = tr_idx;
setting.ts_idx = ts_idx;
setting.TFstr = TFstr;
multiview = setting.multiview;


if multiview
    try
        load([TFstr, '_Floderinfo.mat'], 'ts_fold_idx', 'Asubname', 'ts_imname', 'ts_size');
    catch
        ts_size = [];
        ts_imname = {};
        ts_imname = cell(length(ts_idx), 1);   
        ts_size = zeros(length(ts_idx), 2);
        ts_Foldname = cell(length(ts_idx), 1);
        for i = 1:length(feattype)        
            bookfeattype = length(fdatabase{i}.path);
            for j = 1:length(bookfeattype)
                for jj = 1:length(ts_idx),
                    ts_imname{jj} = fdatabase{i}.imgpath{ts_idx(jj)};
                    ts_size(jj,:) = graysize(imread(ts_imname{jj})); 
                    idx = (find(ts_imname{jj} == '\'));
                    ff = ts_imname{jj}(idx(end)+1:end);
                    idx = (find(ff == '_'));
                    ts_Foldname{jj} = ff(1:idx(end -1));
                end
            end
        end
%         ts_fold_idx = zeros(1, length(ts_imname));
        [Asubname, a, ts_fold_idx] = unique(ts_Foldname);
        
        % img_dir = 'image\Sign';
        
%         subfolders = dir(fullfile(img_dir1, 'TrueSign\-1'));
%         jj = 0;
%         for ii = 1:length(subfolders),
%             subname = subfolders(ii).name;
%             if ~strcmp(subname, '.') && ~strcmp(subname, '..'),
%                 jj =jj +1;
%                 subname = [subname, '_'];
%             index = (strfind(ts_imname, subname));
%             b = cellfun('isempty',index);
%             paindex = find(b == 0);
%             for tt = 1:length(paindex)
%                 if isempty(strfind(ts_imname{paindex(tt)}, subname))
%                     fprintf('Error, Something error with strfind \n');
%                     pause
%                 end
%             end
%             
%             if nnz(ts_fold_idx(paindex))
%                 fprintf('Error, more than two file contains this sample \n');
%                 subname
%                 ts_imname{paindex(1)};
%                 pause
%             end
%             ts_fold_idx(paindex) = jj;
%             Asubname{jj} = subname;
%             end
%         end
        save([TFstr, '_Floderinfo.mat'], 'ts_fold_idx', 'Asubname', 'ts_imname', 'ts_size');

    end
    
    try
        load([TFstr, '_FlodLabel.mat'],  'ts_Fold_label');
    catch
        ts_label = zeros(length(ts_idx), 1);
        for i = 1:length(feattype)
            bookfeattype = length(fdatabase{i}.path);
            for j = 1:length(bookfeattype)
                for jj = 1:length(ts_idx),
                    fpath = fdatabase{i}.path{j}{ts_idx(jj)};
                    load(fpath,'label');
                    ts_label(jj) = label; 
                end
            end
        end
        unorm = 0;
        
        load(fullfile(img_diro, 'Trainstr.mat'), 'datastruct');
            
        index = strfind(datastruct.name, 'Country');
        index = find(~cellfun(@isempty, index));
        
        index1 = strfind(datastruct.name, '#FileName');
        index1 = find(~cellfun(@isempty, index1));
        
        index2 = strfind(datastruct.name, 'AspectRatio');
        index2 = find(~cellfun(@isempty, index2));
            
        index3 = strfind(datastruct.name, 'ClassName');
        index3 = find(~cellfun(@isempty, index3));
        
        index4 = strfind(datastruct.name, 'SourceName');
        index4 = find(~cellfun(@isempty, index4));

        
        TestData = datastruct.value;
        for i = 1:length(TestData)
            ind = str2num(TestData{i}{index1}(1:end-4)); 
            
            Country{ind} = TestData{i}{index};
            Ratio{ind} = TestData{i}{index2};
            ClassName{ind} = TestData{i}{index3};
            SourceName{ind} = TestData{i}{index4};
        end
            
        [ts_fold_idx1, a, b] = unique(ts_fold_idx);
        ts_Fold_label = zeros(1, length(Asubname));
        
        deled = zeros(1, length(database.cname));
        for tt = 1:length(ts_fold_idx1)
            if ts_fold_idx(a(tt))~=ts_fold_idx1(tt)
                fprintf('Error\n');
                pause;
            end
            tindex = unique(ts_label(find(b == tt)));
%             tindex
            if length((tindex)) > 1
                fprintf('More than 2 label for one fold\n')
                pause
                unorm = unorm + 1;
                figure;
                col = ceil(sqrt(length(tindex)));
                suc = 0;
                for jj = 1:length(tindex)
                    try
                        subplot(col, col, jj);
                    im = imread(fullfile(img_diro, database.cname{(tindex(jj))}, ...
                        ['train_', database.cname{(tindex(jj))}, '.jpg']));
                    imshow(im);
                    ind = str2num(database.cname{(tindex(jj))});
                    if ~strfind(Country{ind}, 'UnitedStates')
                        fprintf('Country Error\n');
                        pause;
                    end
                    str = ['"' SourceName{ind}, '"-"' Ratio{ind}, '"-"', ClassName{ind} '"' ];title(str);
                    suc = suc +1;
                    catch
                        t = 1;
                    end
                end
                if suc == 1
                    continue;
                end
%                 print(gcf, '-djpeg', '-r0', fullfile(img_diro, [num2str(unorm), '.jpg']));
                ss = input('Input the final: '); 
                merged = setdiff(tindex, tindex(ss));
                
                for jj = 1:length(merged);
                    if deled(tindex(jj))
                       continue;
                    end
                    
                    %%%%MerSample
                    subf = dir(fullfile(img_diro, database.cname{(tindex(jj))}, ...
                        ['test_*.jpg']));
                    
                    for kk = 1:length(subf)
                        subname = fullfile(img_diro, database.cname{(tindex(jj))}, subf(kk).name);
                        dstfile = fullfile(img_diro, database.cname{(tindex(ss))}, subf(kk).name);
                        dos(['copy "' subname '" "' dstfile '"']);
                    end
                    
                    deled(tindex(jj)) = 1;
                    rmdir(fullfile(img_diro, database.cname{(tindex(jj))}), 's');
                end
            end
            
            ts_Fold_label(ts_fold_idx1(tt)) = ts_label(a(tt));
        end
        save([TFstr, '_FlodLabel.mat'],  'ts_Fold_label');
    end

    setting.ts_fold_idx = ts_fold_idx;
    setting.ts_Fold_label = ts_Fold_label;
    setting.Asubname = Asubname;
end
 
[a, b, c] = unique(setting.ts_Fold_label); 
for ii = 1:length(a)
    len(ii) = length(find(c == ii));
end
ii = find(a == 0);tmp = setdiff([1:length(len)], ii);
len = len(tmp);c = c(tmp);a = a(tmp);
% load([img_diro, '\datainfo.mat']);
index = find(len >= 20);
i = 1;j = 1;
for jj = 1:length(ts_idx),
    fpath = fdatabase{i}.path{j}{ts_idx(jj)};
    load(fpath,'label');
    ts_label(jj) = label; 
end
cindex = a(index);