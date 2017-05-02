function [fdatabase, database, dfea, WTAfea, setting] = computeFeature(img_dir1, img_dir, dataname, ...
    mfea_dir, mfea_dir_WTA, setting, fcopyremove, feattype, suffix, knnpara)
setting.dataname = dataname;
copyremove = 1;
if nargin <7
    suffix = '_New';
end
if iscell(img_dir)
    Timg_dir = img_dir{1};
    img_dir = img_dir{2};
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
if ~strcmp(dataname, 'Caltech101') && ...
        ~strcmp(dataname, 'face_YaleBE') && ~strcmp(dataname, 'face_ORL') && ~strcmp(dataname(1:8), 'face_PIE')
    Trainid = 1;
    tt = strfind(img_dir, suffix);
    if ~isempty(tt)
        Sel_img_dir = img_dir(1:tt(1)-1);
    end
end
% % % if strcmp(dataname, 'face_YaleBE')
% % %     Trainid = 0;
% % % end
datafn = 'TrainInfo';
if ~exist(datafn)
    mkdir(datafn)
end

str = [img_dir '_' num2str(Trainid)];
str(find(str == '\')) = '_';
str(find(str == '/')) = '_';str = fullfile(datafn, str);

if setting.TDataNew
    Tstr = [Timg_dir '_' num2str(Trainid)];
    Tstr(find(Tstr == '\')) = '_';
    Tstr(find(Tstr == '/')) = '_';Tstr = fullfile(datafn, Tstr);
    TTFstr = [pwd '/' Tstr];setting.TTFstr = TTFstr;
end

TFstr = [pwd '/' str];
try
    load([TFstr, '_database.mat'], 'database');
catch
    database = retr_database_dir_img(img_dir, Trainid);
    save([TFstr, '_database.mat'], 'database');
end
if ~isfield(database, 'Trainset') || ~isfield(database, 'Testset')
    database.Trainset = '';database.Testset = '';
end
xx = unique(database.label);
if xx(1) == 0
    database.label = database.label + 1;
    save([TFstr, '_database.mat'], 'database');
end

database1 = database;
if setting.indexcolor
    setting.img_dir = img_dir;
    setting.database = database;    
end
colorpath = '';
if isfield(setting,'DoG') && setting.DoG
    if setting.indexcolor
        colorpath = database.path;
    end
    img_dir_old = img_dir;
    img_dir = dogFilter(img_dir, database, setting);
    %img_dir_old(find(img_dir_old == '/')) = '\';
    %to run in Linux
    img_dir_old(find(img_dir_old == '\')) = '/';
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
    if ~isempty(strfind(dataname, 'Sign_NewT10')) || ~isempty(strfind(dataname, 'Sign_NewT8')) ...
            ~isempty(strfind(dataname, 'Sign_NewT9'))
        fdatabase{i} = database;
        fdatabase{i}.imgpath = database.path;
    else
    [f1, f2, f3] = fileparts([mfea_dir{i}{1}, '.mat']);
    
%     test error
%     disp([TFstr, '_' f2, setting.latentfstr, '_fdatabase.mat']);
%     disp(TFstr);
%     disp(['f2:' f2]);
%     disp(setting.latentfstr);
    
    try
        load([TFstr, '_' f2, setting.latentfstr, '_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
            'WTAfea1', 'padx', 'pady');
        fdatabase{i} = fdatabase1;dfea{i} = dfea1;WTAfea{i} = WTAfea1;
    catch
        if strcmp(feattype{i}, 'llc')
            [fdatabase{i}, database, dfea{i}, WTAfea{i}, padx, pady] = getllcfeature(img_dir, dataname, ...
                mfea_dir{i}, mfea_dir_WTA{i}, i, setting, copyremove, database, colorpath);
        else
            if strcmp(feattype{i}, 'siftflow' )
                [fdatabase{i}, database, dfea{i}, WTAfea{i}, padx, pady] = siftflowfeature(img_dir, dataname, ...
                    mfea_dir{i}, mfea_dir_WTA{i}, i, setting, copyremove, database, colorpath);
            else
                [fdatabase{i}, database, dfea{i}, WTAfea{i}, padx, pady] = getrawfeature(img_dir, dataname, ...
                    mfea_dir{i}, mfea_dir_WTA{i}, i, setting, copyremove, database, colorpath);
            end
        end
        fdatabase1 = fdatabase{i};dfea1 = dfea{i};WTAfea1 = WTAfea{i};
        save([TFstr, '_' f2, setting.latentfstr, '_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
            'WTAfea1', 'padx', 'pady'); 
    end
    end
end

clear 'colorpath'
database = database1;
clabel = unique(fdatabase{1}.label);
nclass = length(clabel);
setting.usedel = 0;
if isempty(strfind(dataname, 'Sign_NewT8')) && isempty(strfind(dataname, 'Sign_NewT9')) && isempty(strfind(dataname, 'Sign_NewT10'))
    setting.usedel = 1;
end
if ~isempty(strfind(dataname, 'Sign_NewT11'))
    setting.usedel = 2;
end

if setting.minLEN == -1
if isfield(database, 'Data')  && (strcmp(database.Data, 'TSR') || ...
        strcmp(database.Data, 'digit') || strcmp(database.Data, 'face'))
    minLEN = 0;setting.DELVIR = 1;
else
    setting.DELVIR = 1;minLEN = 0;
    if setting.usedel == 1
        if strcmp(dataname(end), 'D')
            setting.DELVIR = 1;minLEN = 8;
        else
            setting.DELVIR = 0;minLEN = 20;
        end
    end
    if setting.usedel == 2
        setting.DELVIR = 1;minLEN = 40;
    end
end
else
    minLEN = setting.minLEN;
end

cindex = [];
for jj = 1:nclass,
    idx_label = find(fdatabase{1}.label == clabel(jj));
    if length( idx_label) > 1
        cindex = [cindex, jj];
    end
end
setting.cindex = cindex;
flabel = zeros(database.imnum, 1);
flabel(database.Trainset) = 1;
flabel(database.Testset) = 2;
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
            if ~isempty(database.istrain)
            tindex = find(database.istrain(idx_label) == 1);
            else
                tindex = [];
            end
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

database.Trainset = find(flabel(setting.ts_idx) == 1);
database.Testset = find(flabel(setting.ts_idx) == 2);
multiview = setting.multiview;

try
    load([TFstr, '_sizeinfo.mat'],  'ts_imname', 'ts_size', 'tr_imname', 'tr_size');
catch
    ts_imname = cell(length(ts_idx), 1);ts_size = zeros(length(ts_idx), 2);i = 1;
    tr_imname = cell(length(tr_idx), 1);tr_size = zeros(length(tr_idx), 2);
    for jj = 1:length(ts_idx),
        ts_imname{jj} = fdatabase{i}.imgpath{ts_idx(jj)};
        ts_size(jj,:) = graysize(imread(ts_imname{jj})); 
    end
    for jj = 1:length(tr_idx),
        tr_imname{jj} = fdatabase{i}.imgpath{tr_idx(jj)};
        tr_size(jj, :)=  graysize(imread(tr_imname{jj}));
    end
    save([TFstr, '_sizeinfo.mat'], 'ts_imname', 'ts_size', 'tr_imname', 'tr_size');
end


% ts_label = zeros(length(ts_idx), 1);
% for jj = 1:length(ts_idx),
%     fpath = fdatabase{1}.path{1}{ts_idx(jj)};
%     load(fpath,'label');
%     ts_label(jj) = label; 
% end
  
ts_label = database.label(ts_idx);

if multiview
    if isfield(database, 'Data') && strcmp(database.Data, 'TSR')
        try
            load([TFstr, '_Floderinfo.mat'], 'ts_fold_idx', 'Asubname');
        catch
            img_diroO = img_diro;
            img_diroO(find(img_diroO == '\')) = '_';
            img_diroO(find(img_diroO == '/')) = '_';
            ts_Foldname = cellfun(@(x) getfoldname(x, img_diroO), ts_imname, 'ErrorHandler', @errorfun, ...
                'UniformOutput', false);
            [Asubname, a, ts_fold_idx] = unique(ts_Foldname);
            setting.Asubname = Asubname;
            setting.ts_fold_idx = ts_fold_idx;
            save([TFstr, '_Floderinfo.mat'], 'ts_fold_idx', 'Asubname');
        end
        
        try
            load([TFstr, '_FlodLabel.mat'],  'ts_Fold_label');
        catch
            ts_Fold_label = zeros(1, length(Asubname));
            for i = 1:length(Asubname)
                 aa = unique(ts_label(ts_fold_idx == i));
                 if length(aa) ~= 1
                     sprintf('ERROE, ts_label(ts_fold_idx == i) not unique')
                     pause;
                 end
                 ts_Fold_label(i) = aa;
            end
            save([TFstr, '_FlodLabel.mat'],  'ts_Fold_label');
        end
        
        setting.ts_fold_idx = ts_fold_idx;
        setting.ts_Fold_label = ts_Fold_label;
        setting.Asubname = Asubname;
else
    try
        load([TFstr, '_Floderinfo.mat'], 'ts_fold_idx', 'Asubname');
    catch
        try
            load([TFstr, '_sizeinfo.mat'], 'ts_imname', 'ts_size');
        catch
            ts_imname = cell(length(ts_idx), 1);
            ts_size = zeros(length(ts_idx), 2);
            i = 1;j = 1;   
            for jj = 1:length(ts_idx),
                ts_imname{jj} = fdatabase{i}.imgpath{ts_idx(jj)};
                ts_size(jj,:) = graysize(imread(ts_imname{jj})); 
            end
        end
        ts_Foldname = cell(length(ts_idx), 1);
        for i = 1:length(feattype)        
            bookfeattype = length(fdatabase{i}.path);
            for j = 1:length(bookfeattype)
                for jj = 1:length(ts_idx),
                    idx = (find(ts_imname{jj} == '/'));
                    ff = ts_imname{jj}(idx(end)+1:end);
                    idx = (find(ff == '_'));
                    ts_Foldname{jj} = ff(1:idx(end -1));
                end
            end
        end
        [Asubname, a, ts_fold_idx] = unique(ts_Foldname);
        save([TFstr, '_Floderinfo.mat'], 'ts_fold_idx', 'Asubname');
    end
    try
        load([TFstr, '_FlodLabel.mat'],  'ts_Fold_label');
    catch
        
        unorm = 0;
        
%         load(fullfile(img_diro, 'Trainstr.mat'), 'datastruct');
            load('image/Trainstr.mat', 'datastruct');
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
    if strfind(dataname, 'Sign_NewT6')
        index = [1:length(a)];
    else
        index = find(len >= minLEN);
    end
    setting.cindex = a(index);
else
%     if strcmp(database.Data, 'TSR') && setting.MultiFold
%         try
%             load([TFstr, '_Floderinfo.mat'], 'ts_fold_idx', 'Asubname');
%         catch
%             img_diroO = img_diro;
%             img_diroO(find(img_diroO == '\')) = '_';
%             img_diroO(find(img_diroO == '/')) = '_';
%             ts_Foldname = cellfun(@(x) getfoldname(x, img_diroO), ts_imname, 'ErrorHandler', @errorfun, ...
%                 'UniformOutput', false);
%             [Asubname, a, ts_fold_idx] = unique(ts_Foldname);
%             setting.Asubname = Asubname;
%             setting.ts_fold_idx = ts_fold_idx;
%             save([TFstr, '_Floderinfo.mat'], 'ts_fold_idx', 'Asubname');
%         end
%         
%         try
%             load([TFstr, '_FlodLabel.mat'],  'ts_Fold_label');
%         catch
%             ts_Fold_label = zeros(1, length(Asubname));
%             for i = 1:length(Asubname)
%                  aa = unique(ts_label(ts_fold_idx == i));
%                  if length(aa) ~= 1
%                      sprintf('ERROE, ts_label(ts_fold_idx == i) not unique')
%                      pause;
%                  end
%                  ts_Fold_label(i) = aa;
%             end
%             save([TFstr, '_FlodLabel.mat'],  'ts_Fold_label');
%         end
%         
%         setting.ts_fold_idx = ts_fold_idx;
%         setting.ts_Fold_label = ts_Fold_label;
%         setting.Asubname = Asubname;
%     else
        setting.ts_fold_idx = [1:length(ts_idx)];
        ts_Fold_label = ts_label;
        setting.ts_Fold_label = ts_Fold_label;
%     end
end

% for jj = 1:length(ts_idx),
%     ts_label(jj) = database.label(ts_idx(jj));
% end

if multiview
    index = find(ismember(ts_label, a(index)));
    ts_idx = ts_idx(index); setting.ts_idx = ts_idx;
    ts_fold_idx = ts_fold_idx(index); setting.ts_fold_idx = ts_fold_idx;
    ts_imname = ts_imname(index);
    ts_size = ts_size(index,:);
end

% others = setdiff(a, a(index));
% for tt = others
%     idd = find(ts_label == tt);
%     flod = ts_imname{idd(1)};
%     [aa,bb,cc] = fileparts(flod);
%     rmdir(aa, 's');
% end
% 
% if strcmp(dataname, 'Sign_NewT4')
%     index1 = find(len >= 8);
%     index1 = setdiff(index1, index);
%     aa = a(index1);
%     %%%Max num 24
%     maxnum = 24;Rotate = [5,8,10,15];Rlabel = [-1, 1];dis = 2;
%     [a, b, c] = unique(setting.ts_Fold_label); 
%     for ii = 1:length(aa)
%         ccname = database.cname(aa(ii));
%         idx = find(setting.ts_Fold_label == aa(ii));
%         orgfold = length(idx);
%         Virfold = maxnum - orgfold;
%         ord = randperm(Virfold);
%         if Virfold <= length(idx)
%             idx = idx(ord(1:Virfold));
%         end
%         Round = ceil(Virfold  / orgfold);
%         cur = 0;
%         for kkk = 1:Round
%             if cur > Virfold
%                 break;
%             end
%         Virsubname = Asubname(idx);
%         for jj = 1:length(Virsubname)
%             if cur > Virfold
%                 break;
%             end
%             
%             cur = cur+1;
%             tid = randperm(2);
%             sidx = find(idx(jj) == setting.ts_fold_idx);
%             rot = Rlabel(tid(1)) * rand(1) * Rotate(kkk);
%             for kk = 1:length(sidx)
%                 idd = randperm(2);
%                 rott = rot + Rlabel(idd(1)) * rand(1) * dis;
%                 img = imread(ts_imname{sidx(kk)});
%                 [dirf, name, ext] = fileparts(ts_imname{sidx(kk)});
%                 idt = strfind(dirf, '\');
%                 idt = strfind(name, '_');idt = idt(end-1);
%                 imname = [name(1:idt-1),'C',num2str(kkk),name(idt:end), ext];
%                 namenew = fullfile(dirf, imname);
%                 imgr = imrotate(img, rott, 'crop');
%                 J = imnoise(imgr,'gaussian');
%                 imwrite(J, namenew);           
%             end
%         end
%         end
%     end
%     
% end
if isfield(database, 'Data') && ~strcmp(database.Data, 'TSR') && ~strcmp(database.Data, 'digit') && ~strcmp(database.Data, 'face')
try
    load([TFstr, '_Sname.mat'],  'Sname', 'SCname');
catch
    load(fullfile(img_diro, 'Trainstr.mat'), 'datastruct');
    TestData = datastruct.value;
    index1 = strfind(datastruct.name, '#FileName');
    index1 = find(~cellfun(@isempty, index1));
    index2 = strfind(datastruct.name, 'ClassName');
    index2 = find(~cellfun(@isempty, index2));
    index3 = strfind(datastruct.name, 'SourceName');
    index3 = find(~cellfun(@isempty, index3));
    for i = 1:length(TestData)
        ffname{i} =  TestData{i}{index1}(1:end-4);
    end
    namestr = database.cname(setting.cindex);
    Sname = cell(1, length(setting.cindex));
    SCname = cell(1, length(setting.cindex));
    for i = 1:length(setting.cindex)
        idx = ismember(ffname,namestr{i});
        Sname{i} = TestData{find(idx)}{index2};
        SCname{i} = TestData{find(idx)}{index3};
    end
    save([TFstr, '_Sname.mat'],  'Sname', 'SCname');
end
end





suffix = '';
str = getparastr(setting.Rconfidence);
suffix = ['MV_' num2str(multiview) '_' str(2:end)];

% if setting.fast && multiview == 3 && setting.Rconfidence == 0.5
%     load([TFstr, '_Votedinfo.mat'], 'Samplevoted', 'tr_imname', 'tr_size');
%     save([TFstr, '_Votedinfo' suffix '.mat'], 'Samplevoted', 'tr_imname', 'tr_size');
%         
%     load([TFstr, '_SamplevotedC'], 'Samplevoted');
%     save([TFstr, '_SamplevotedC' suffix '.mat'], 'Samplevoted');
% end
if setting.NewFormatFold
    saveempty = 1;
else
    saveempty = 0;
end
if setting.fast && multiview == 3
    try
        load([TFstr, '_Votedinfo' suffix '.mat'], 'Samplevoted');
    catch
        try
            load([TFstr, '_sizeinfo.mat'], 'tr_imname', 'tr_size');
        catch
            tr_imname = cell(length(tr_idx), 1);
            tr_size = zeros(length(tr_idx), 2);i = 1;
            for jj = 1:length(ts_idx),
                tr_imname{jj} = fdatabase{i}.imgpath{tr_idx(jj)};
                tr_size(jj, :)=  graysize(imread(tr_imname{jj}));
            end
        end
        height = tr_size(:, 1);
        width = tr_size(:, 2);
        means = [mean(height), mean(width)];
        Samplevoted = GetvotedId(nclass, ts_fold_idx, multiview, ts_imname, tr_imname, ...
            tr_size, ts_size, setting.Rconfidence, means, saveempty);

        save([TFstr, '_Votedinfo' suffix '.mat'], 'Samplevoted');
    end
else
    Samplevoted = ones([length(setting.ts_fold_idx), 1]);
end
setting.Samplevoted = Samplevoted;


% Samplevoted1 = {};
if setting.confidence
    try
        load([TFstr, '_SamplevotedC' suffix '.mat'], 'Samplevoted');
    catch
        exp = 0.001;
        if exist([setting.TFstr, '_Qulity.mat'])
            conf_tr_fea = GetQulity(setting, ts_imname);
        else
            conf_tr_fea = GetQulity(setting, ts_imname, ts_idx);
        end
        Samplevoted(find(conf_tr_fea(:,end) < exp)) = 0;
        Samplevoted(prod(ts_size,2) <= 1) = 0;
        
        if setting.fast && multiview == 4
            Samplevoted(prod(ts_size,2) <= 1) = 0;
            [a,b,c] = unique(ts_fold_idx);
            for tt = 1:length(a)
                indx = find(c == tt);
        voted = Samplevoted(indx);
        range = find(voted);
        range = randperm(length(range));
        range = setdiff([1:length(range)], range(1:min(length(range), setting.Rconfidence)));
        Samplevoted(indx(range)) = 0;
            end
        end
        
        if setting.fast && multiview == 5
            NROUND = setting.Rconfidence(2);
            Samplevoted1 = cell(1, NROUND);
            for i = 1:NROUND
                Samplevoted1{i} = Samplevoted;
                [a,b,c] = unique(ts_fold_idx);
                for tt = 1:length(a)
                    indx = find(c == tt);
                    voted = Samplevoted(indx);
                    range = find(voted);
                    range = randperm(length(range));
                    range = setdiff([1:length(range)], range(1:min(length(range), setting.Rconfidence)));
                    Samplevoted1{i}(indx(range)) = 0;
                end    
            end
            Samplevoted = Samplevoted1;
            save([TFstr, '_SamplevotedC' suffix '.mat'], 'Samplevoted');
        else
            save([TFstr, '_SamplevotedC' suffix '.mat'], 'Samplevoted');
        end
    end
end
if isfield(database, 'Data') && strcmp(database.Data, 'TSR')
    Samplevoted(:) = 1;
end
if ~isempty(strfind(dataname, 'Sign_NewT11'))
    Samplevoted(:) = 1;
end

setting.Samplevoted = Samplevoted;


tr_ratio = [];
ts_ratio = [];
if setting.Ratio
    try
        load([TFstr, '_TrRatio.mat'], 'tr_ratio');
    catch
        
        tr_ratio = zeros(length(tr_idx), 1);
        
        for jj = 1:length(tr_idx),
            index = find(tr_imname{jj} == '/');str = tr_imname{jj};
            load(fullfile(setting.ratio_dir, [str(index(end)+1:end-4), '_Ratio.mat']), 'ratio'); 
            tr_ratio(jj) = ratio;
        end
        save([TFstr, '_TrRatio.mat'], 'tr_ratio');
    end
    
    try
        load([TFstr, '_', num2str(setting.Ratio), '_TsRatio.mat'], 'ts_ratio');
    catch
        tRatio = mod(setting.Ratio, 2);
        FRatio = ceil(setting.Ratio / 2);    
        
        ts_ratio = zeros(length(ts_idx), 1);
     
        if tRatio == 0
            for jj = 1:length(ts_idx),
                index = find(ts_imname{jj} == '/');str = ts_imname{jj};
                load(fullfile(setting.ratio_dir, [str(index(end)+1:end-4), '_Ratio.mat']), 'ratio'); 
                ts_ratio(jj) = ratio;
            end   
        end
        if tRatio == 1
            ts_ratio = ts_size(:, 2) ./ ts_size(:, 1);
        end
        
        if FRatio == 2
            ts_fold = unique(ts_fold_idx);
            for jj = 1:length(ts_fold)
                index = find(ts_fold_idx == ts_fold(jj));
                ts_ratio(index) = mean(ts_ratio(index));
            end
        end
        
        save([TFstr, '_', num2str(setting.Ratio), '_TsRatio.mat'], 'ts_ratio');
    end
end
setting.tr_ratio = tr_ratio;
setting.ts_ratio = ts_ratio;


setting.Map = [];
if floor(setting.platent/2)
    i = 1;jj = 1;
    ts_imname{jj} = fdatabase{i}.imgpath{1};fpath = ts_imname{jj};
    if strcmp(setting.feattype{1}, 'sphog') || strcmp(setting.feattype{1}, 'Pixel') ...
                    || strcmp(setting.feattype{1}, 'sphogM') || strcmp(setting.feattype{1}, 'PixelM') ||...
                    strcmp(setting.feattype{1}, 'sphog1') || strcmp(setting.feattype{1}, 'Pixel1') ...
                    || strcmp(setting.feattype{1}, 'sphogM1') || strcmp(setting.feattype{1}, 'PixelM1')
                im = double(rgb2gray(imread(fpath)));
    else
                im = double(color(imreadx(fpath)));
    end
    warped = imresize(im, setting.rawsize, 'bilinear');
    [setting.Map, setting.MapSub2ind, setting.MapRange] = INDEXMap(setting, warped, 1, setting.latent, padx, pady);
end

if isfield(setting, 'testonly') && setting.testonly
    idx = (cellfun(@str2num,database.cname));
    index = find(idx < 0);
    Range = find(database.label == index);   %%%%testrange
    setting.ts_idx_conf = Range;
else
    setting.testonly = 0;
end

% tr_label = zeros(length(tr_idx), 1);
% i = 1;j = 1;
% for jj = 1:length(tr_idx),
%     fpath = fdatabase{i}.path{j}{tr_idx(jj)};
%     load(fpath,'label');
%     tr_label(jj) = label;
% end


tr_label = database.label(tr_idx);

if ~setting.latent
setting = getlabelmap(knnpara, fdatabase, feattype, ...
    setting, nclass,cindex,  tr_label, TFstr, tr_idx);
try
    load([TFstr, '_info_data.mat'], 'data_imsize', 'data_imname')
catch
    ttidx = [setting.tr_idx; setting.ts_idx];
    load([TFstr, '_sizeinfo.mat'],  'ts_imname', 'ts_size', 'tr_imname', 'tr_size');
    data_imsize(ttidx,:) = [tr_size; ts_size];
    data_imname(ttidx) = [tr_imname; ts_imname];
    save([TFstr, '_info_data.mat'], 'data_imsize', 'data_imname')
end
end
% data_imname = data_imname(:);
% save([TFstr, '_info_data.mat'], 'data_imsize', 'data_imname')

if ~strcmp(setting.cmethod, 'CNN')
    setting.QulityFeadir = [TFstr, '_', setting.strfea, setting.featNormstr];
else
    setting.QulityFeadir = TFstr;
end


if setting.isSnippetRatio && floor(setting.SnippetRatio{3} / 10000) == 1 && mod(setting.SnippetRatio{3},100) == setting.feaInter
    try
        load([setting.QulityFeadir '-ALL_fea.mat'], 'ctr_fea');
    catch
        ComputeAllfeat([setting.QulityFeadir '-ALL_fea.mat'], fdatabase, feattype, setting);
    end
end
if setting.isSnippetRatio && floor(setting.SnippetRatio{3} / 10000) == 1 && ...
        ismember(mod(setting.SnippetRatio{3},100),setting.EdgeInter)
     try
         load([setting.QulityFeadir '-edge_fea.mat'], 'edge_fea');
     catch
        ComputeEdgefeat([setting.QulityFeadir '-edge_fea.mat'], fdatabase, feattype, setting);
     end 
end
if setting.isSnippetRatio && floor(setting.SnippetRatio{3} / 10000) == 1 && ...
        ismember(mod(setting.SnippetRatio{3},100),setting.CNNInter)
     try
         load([setting.QulityFeadir '-CNN_fea.mat'], 'CNN_fea');
     catch
        ComputeCNNfeat([setting.QulityFeadir '-CNN_fea.mat'], fdatabase, feattype, setting);
     end 
end

if setting.isSnippetRatio && floor(setting.SnippetRatio{3} / 10000) == 1 && ...
        ismember(mod(setting.SnippetRatio{3},100),setting.CNNmInter)
     try
         load([setting.QulityFeadir '-mCNN_fea.mat'], 'mCNN_fea');
     catch
        mComputeCNNfeat([setting.QulityFeadir '-mCNN_fea.mat'], fdatabase, feattype, setting);
     end 
end

if setting.isSnippetRatio && floor(setting.SnippetRatio{3} / 10000) == 1
    if ismember(mod(setting.SnippetRatio{3},100),setting.CNNm_newInter)
        namestr = '-mCNN_fea_new.mat';nstr = 'new';
        computeCNNfea(setting, namestr, fdatabase, feattype, nstr);
    end
    if ismember(mod(setting.SnippetRatio{3},100),setting.CNNm_new2Inter)
        namestr = '-mCNN_fea_new2.mat';nstr = 'new2';
        computeCNNfea(setting, namestr, fdatabase, feattype, nstr);
    end
    if ismember(mod(setting.SnippetRatio{3},100),setting.CNNm_new3Inter)
        namestr = '-mCNN_fea_new3.mat';nstr = 'new3';
        computeCNNfea(setting, namestr, fdatabase, feattype, nstr);
    end
    
    if ismember(mod(setting.SnippetRatio{3},100),setting.CNNm_new3Inter)
        namestr = '-mCNN_fea_new3.mat';nstr = 'new3';
        computeCNNfea(setting, namestr, fdatabase, feattype, nstr);
    end
    
    if ismember(mod(setting.SnippetRatio{3},100),setting.CNNm_new3Inter)
        namestr = '-mCNN_fea_new3.mat';nstr = 'new3';
        computeCNNfea(setting, namestr, fdatabase, feattype, nstr);
    end
    
    if ismember(mod(setting.SnippetRatio{3},100),setting.CNNm_new3Inter)
        namestr = '-mCNN_fea_new3.mat';nstr = 'new3';
        computeCNNfea(setting, namestr, fdatabase, feattype, nstr, nstr1);
    end
    switch mod(setting.SnippetRatio{3},100)
        case 30
            namestr = '-mCNN_fea_train1.mat';nstr = '1';nstr1 = 'Test';computeCNNfea(setting, namestr, fdatabase, feattype, nstr, nstr1);
        case 31
            namestr = '-mCNN_fea_train2.mat';nstr = '2';nstr1 = 'Test';computeCNNfea(setting, namestr, fdatabase, feattype, nstr, nstr1);
        case 32
            namestr = '-mCNN_fea_train3.mat';nstr = '3';nstr1 = 'Test';computeCNNfea(setting, namestr, fdatabase, feattype, nstr, nstr1);
        case 33
            namestr = '-mCNN_fea_train4.mat';nstr = '4';nstr1 = 'Test';computeCNNfea(setting, namestr, fdatabase, feattype, nstr, nstr1);
        case 34
            namestr = '-mCNN_fea_train5.mat';nstr = '5';nstr1 = 'Test';computeCNNfea(setting, namestr, fdatabase, feattype, nstr, nstr1);
        case 35
            namestr = '-mCNN_fea_train6.mat';nstr = '6';nstr1 = 'Test';computeCNNfea(setting, namestr, fdatabase, feattype, nstr, nstr1);
    end
end
fdatabase{1}.Trainset  = database.Trainset;
fdatabase{1}.Testset  = database.Testset;
if ~isfield(database, 'Data')
    database.Data =  '';
end

if ~setting.Usetemplate
    setting.tr_idx = [];
end

setting.NormFea = 0;
if strcmp(database.Data, 'TSR')
    setting.NormFea = 1;
%     setting.WeightUpC = 1;
else
    if strcmp(dataname, 'face_YaleBE') || strcmp(dataname, 'digit_MNIST')...
            || strcmp(dataname, 'face_ORL')
        setting.NormFea = 1;
    else
    if setting.SetNormFea
        setting.NormFea = 1;
    end
    end
end

function ts_Foldname = getfoldname(tsname, img_diroO)
[a,b] = fileparts(tsname);
index = find(b == '_');
if ~isempty(index)
    ts_Foldname = b(1:index(end));
else
    ts_Foldname = [b, '_'];
end
a(find(a == '\')) = '_';
a(find(a == '/')) = '_';
index = findstr(a, img_diroO);
ts_Foldname = [a(1+index+length(img_diroO):end), '_', ts_Foldname];
% image\TSR_GTSRB\Training\00000\00000_00000.ppm