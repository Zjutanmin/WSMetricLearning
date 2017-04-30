function [fdatabase, database, dFea] = getllcfeature1(img_dir, dataname, fea_dir,  ...
    i, setting, copyremove)
% -------------------------------------------------------------------------
% parameter setting
pyramid = setting.pyramid;
knn = setting.knn;
feattype = setting.bookfeat;

% -------------------------------------------------------------------------
% set path
addpath('Liblinear/matlab');        % we use Liblinear package, you need 


data_dir = ['data/' dataname '/' setting.codestr{i}{1}];        % directory for saving SIFT descriptors
Trainid = 0;
if ~strcmp(dataname, 'Caltech101')
    Trainid = 1;
    tt = strfind(img_dir, '_d');
    if ~isempty(tt)
        Sel_img_dir = img_dir(1:tt(1)-1);
    end
end

database = retr_database_dir(data_dir, img_dir, Trainid);
if isempty(database),
    error('Data directory error!');
end
nFea = length(database.path);
fdatabase = struct;
fdatabase.path = cell(length(feattype), 1);         % path for each image feature
fdatabase.label = zeros(nFea, 1);       % class label for each image feature
dFea = cell(1, length(feattype));


data_dir_mf = cell(1, length(feattype));
for jj = 1:length(feattype)
    fdatabase.path{jj} = cell(nFea, 1); 
    
    data_dir_mf{jj} = ['data/' dataname '/' setting.codestr{i}{jj}]; 
    extr_sift(img_dir, data_dir_mf(jj), copyremove, feattype(jj), setting);
    
    
    database = retr_database_dir(data_dir_mf{jj}, img_dir, Sel_img_dir, Trainid);

    if isempty(database),
        error('Data directory error!');
    end

    B = getcodebook(database, dataname, setting, setting.bookstr{i}{jj}); 
    
    nCodebook = size(B, 2);              % size of the codebook\
    dFea{jj} = sum(nCodebook*pyramid.^2);
    fdatabase.path{jj} = cell(nFea, 1);         % path for each image feature
    for iter1 = 1:nFea, 
        if ~mod(iter1, 5),
            fprintf('.');
        end
        if ~mod(iter1, 100),
            fprintf(' %d images processed\n', iter1);
        end
    fpath = database.path{iter1};
    flabel = database.label(iter1);
    
    cname = database.cname{flabel};
    
    load(fpath);
    [rtpath, fname] = fileparts(fpath);
    feaPath = fullfile(fea_dir{jj}, num2str(flabel), [fname '.mat']);
    
    imgPath = fullfile(img_dir, num2str(cname), [fname '.jpg']);
    try
        load(feaPath, 'fea', 'label');
    catch
        fea = LLC_pooling(feaSet, B, pyramid, knn);
        label = database.label(iter1);
        if ~isdir(fullfile(fea_dir{jj}, num2str(flabel))),
            mkdir(fullfile(fea_dir{jj}, num2str(flabel)));
        end
        save(feaPath, 'fea', 'label');
    end

    
    fdatabase.label(iter1) = flabel;
    fdatabase.path{jj}{iter1} = feaPath;
    fdatabase.imgpath{iter1} = imgPath;
    end;
end