function featNround = computeFeature_D(img_dir1, img_dir, dataname, ...
    mfea_dir, mfea_dir_WTA, setting, fcopyremove, feattype, suffix, knnpara)
% save('info', 'img_dir1', 'img_dir', 'dataname', ...
%     'mfea_dir', 'mfea_dir_WTA', 'setting', 'fcopyremove', 'feattype', 'suffix', 'knnpara')

setting.dataname = dataname;
copyremove = 1;
if iscell(img_dir)
    img_dir_Vir = img_dir{2};cname = img_dir{3};cindex = img_dir{4};
    tr_idx_Vir = img_dir{5}(:);
    ts_idx_Vir = img_dir{6}(:);
    [~, path_Vir_tr, C] = cellfun(@fileparts, img_dir{7}, 'ErrorHandler', @errorfun, 'UniformOutput', false);
    path_Vir_tr = cellfun(@(x, y) [x, y], path_Vir_tr, C, 'ErrorHandler', @errorfun, 'UniformOutput', false);
    path_Vir_tr = path_Vir_tr(:);
    [~, path_Vir, C] = cellfun(@fileparts, img_dir{8}, 'ErrorHandler', @errorfun, 'UniformOutput', false);
    path_Vir = cellfun(@(x, y) [x, y], path_Vir, C, 'ErrorHandler', @errorfun, 'UniformOutput', false);
    path_Vir = path_Vir(:);
    img_dir = img_dir{1};
end
setting.cindex = cindex;
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
%     Trainid = 1;
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

% % % % % % % % % % % % % % try
% % % % % % % % % % % % % %     load([TFstr, '_database.mat'], 'database');
% % % % % % % % % % % % % % catch
% % % % % % % % % % % % % %     database = retr_database_dir_img(img_dir, Trainid);
% % % % % % % % % % % % % %     save([TFstr, '_database.mat'], 'database');
% % % % % % % % % % % % % % end
% % % % % % % % % % % % % % 
% % % % % % % % % % % % % % cindex = unique(database.label);setting.cindex = cindex;


try
    load([TFstr, '_database.mat'], 'database');
catch
    try
    [a,b] = textread(fullfile(img_dir_Vir, 'Label.txt'), '%s\t%d');
    index = [setting.VirUseNum+1: setting.VirUseNum+1: length(a)];
    index = setdiff([1:length(a)], index);
    a = a(index);b = b(index);

    database.label = b;
    database.cname = cname;
    
    
    database.imgpath = {};
    database.imnum = length(a);
    database.nclass = length(unique(b));
    
    
    database.istrain = zeros(length(a), 1);
    database.isForBook = zeros(length(a), 1);
    a = cellfun(@(x, y) GetName(x, y, img_dir), (database.cname(b))', a, 'ErrorHandler', @errorfun, ...
        'UniformOutput', false);
    database.path = a;
    database.orgimpath = a;
    
    catch     
        database = retr_database_dir_img(img_dir, Trainid);
    end
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
    if ~isempty(strfind(dataname, 'Sign_NewT10')) || ~isempty(strfind(dataname, 'Sign_NewT8')) ...
            ~isempty(strfind(dataname, 'Sign_NewT9'))
        fdatabase{i} = database;
        fdatabase{i}.imgpath = database.path;
    else
    [f1, f2, f3] = fileparts([mfea_dir{i}{1}, '.mat']);
    try
        load([TFstr, '_' f2, '_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
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
        save([TFstr, '_' f2, '_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
            'WTAfea1', 'padx', 'pady'); 
    end
    end
end

clear 'colorpath'
clear 'fdatabase1'

database = database1;clear 'database1'
clabel = unique(fdatabase{1}.label);
nclass = length(clabel);

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


ts_label = database.label(ts_idx);



tr_ratio = [];
ts_ratio = [];
if setting.Ratio
    try
        load([TFstr, '_TrRatio.mat'], 'tr_ratio');
    catch
        
        tr_ratio = zeros(length(tr_idx), 1);
        
        for jj = 1:length(tr_idx),
            index = find(tr_imname{jj} == '\');str = tr_imname{jj};
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
                index = find(ts_imname{jj} == '\');str = ts_imname{jj};
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




tr_label = database.label(tr_idx);
setting.NSplit = 1;
setting = getlabelmap(knnpara, fdatabase, feattype, ...
    setting, nclass,cindex,  tr_label, TFstr, tr_idx);
featNround = setting.featNround;
try
    load([TFstr, '_info_data.mat'], 'data_imsize', 'data_imname')
catch
    ttidx = [setting.tr_idx; setting.ts_idx];
    load([TFstr, '_sizeinfo.mat'],  'ts_imname', 'ts_size', 'tr_imname', 'tr_size');
    data_imsize(ttidx,:) = [tr_size; ts_size];
    data_imname(ttidx) = [tr_imname; ts_imname];

% %     
% %     [~, ts_imname1, C] = cellfun(@fileparts, ts_imname, 'ErrorHandler', @errorfun, 'UniformOutput', false);
% %     ts_imname1 = cellfun(@(x, y) [x, y], ts_imname1, C, 'ErrorHandler', @errorfun, 'UniformOutput', false);
% %     ts_imname1 = cellfun(@Res, ts_imname1, 'ErrorHandler', @errorfun, 'UniformOutput', false);
% % 
% %     
% %     [~, tr_imname1, C] = cellfun(@fileparts, tr_imname, 'ErrorHandler', @errorfun, 'UniformOutput', false);
% %     tr_imname1 = cellfun(@(x, y) [x, y], tr_imname1, C, 'ErrorHandler', @errorfun, 'UniformOutput', false);
% %     tr_imname1 = tr_imname1(:);
% %     
% %     if (length(ts_imname1) == ((length(path_Vir))*setting.VirUseNum)) && ...
% %             nnz(~cellfun(@strcmp, ts_imname1, reshape((repmat(path_Vir, 1, setting.VirUseNum))', [], 1),'ErrorHandler', @errorfun,'UniformOutput', true))
% %         ts_index = reshape((repmat(setting.ts_idx, 1, setting.VirUseNum))', [], 1);
% %     tr_idx_Vir = img_dir{5}(:);
% %     ts_idx_Vir
% %     
% %     
% %     else
% %         ts_index = zeros(length(ts_imname1), 1);
% %         [aa,bb,cc] = unique(ts_imname1);
% %         for kk = 1:length(aa)
% %             ts_index(find(cc == kk)) = find(ismember(path_Vir, aa{kk}));
% %         end
% %     end
% %     tr_index = zeros(length(tr_imname1), 1);
% %         [aa,bb,cc] = unique(tr_imname1);
% %         for kk = 1:length(aa)
% %             tr_index(find(cc == kk)) = find(ismember(path_Vir_tr, aa{kk}));
% %         end
% %     data_index(ttidx) = [tr_index; ts_index];
    save([TFstr, '_info_data.mat'], 'data_imsize', 'data_imname')
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


function x = GetName(y, x, img_dir)
x = fullfile(img_dir, y, x);