function [fdatabase, database, cdFea, WTAFea, padx, pady] = getrawfeature(img_dir, dataname, fea_dir,  ...
    fea_dir_WTA, i, setting, copyremove, database, colorpath)

% data_dir = ['data/' dataname '/' setting.codestr{i}];        % directory for saving SIFT descriptors
% % -------------------------------------------------------------------------
% % extract SIFT descriptors, we use Prof. Lazebnik's matlab codes in this package
% % change the parameters for SIFT extraction inside function 'extr_sift'
% extr_sift(img_dir, data_dir, copyremove, feattype, setting);
if setting.latent
    [fdatabase, database, cdFea, WTAFea, padx, pady] = getrawfeature_L(img_dir, dataname, fea_dir,  ...
        fea_dir_WTA, i, setting, copyremove, database, colorpath);
    return;
end
Trainid = 0;
if ~strcmp(dataname, 'Caltech101')
    Trainid = 1;
end
addpath('sift');
% database = retr_database_dir_img(img_dir, Trainid);
% -------------------------------------------------------------------------
% retrieve the directory of the database and load the codebook

if isempty(database),
    error('Data directory error!');
end

nFea = length(database.path);


% dFea = setting.featsize(i) * prod(patch);
fdatabase = struct;
fdatabase.path = cell(1, 1);         % path for each image feature
fdatabase.path{1} = cell(nFea, 1);         % path for each image feature
fdatabase.label = zeros(nFea, 1);       % class label for each image feature

fea_dir = fea_dir{1};
fea_dir_WTA = fea_dir_WTA{1};

ulabel = unique(database.label);
if setting.Fcompute
if exist(fea_dir)
try    rmdir(fea_dir, 's');mkdir(fea_dir); end
end
if setting.WTA
    if exist(feaPath_WTA)
try    rmdir(feaPath_WTA, 's');mkdir(feaPath_WTA);  end
    end
end
end

for ii = 1:length(ulabel)
    feaPath = fullfile(fea_dir, num2str(ulabel(ii)));
    if ~exist(feaPath)
        mkdir(feaPath);
    end
end
if setting.WTA
    for ii = 1:length(ulabel)
        feaPath_WTA = fullfile(fea_dir_WTA, num2str(ulabel(ii)));
        if ~exist(feaPath_WTA)
            mkdir(feaPath_WTA);
        end
    end
end


dFea = 0;
dWTAFeaFea = 0;
curfeat  = 0;

ind = find(database.istrain == 1);
setting.pady = 0;
setting.padx = 0;
if setting.featPad
    iter1 = ind(1);
    fpath = database.path{iter1};
    im = double(color(imreadx(fpath)));
    warped = imresize(im, setting.rawsize, 'bilinear');
    if setting.latent
        fea = FeatureMapCompute(setting, warped, i, 1, database.istrain(iter1)); 
    end
    sizef = size(fea{1}{1});
    setting.pady = sizef(1);setting.padx = sizef(2);
end

if isfield(setting,'DoG') && setting.DoG
    if ~isempty(setting.indexcolor) && setting.indexcolor == i
        fpathorg = colorpath;
    else
        fpathorg = database.path;
    end
else
    fpathorg = database.path;
end
% % for iter1 = 54000:nFea,
for iter1 = 1:nFea,  
    if ~mod(iter1, 5),
       fprintf('.');
    end
    if ~mod(iter1, 100),
        fprintf(' %d images processed\n', iter1);
    end
    fpath = fpathorg{iter1};
    flabel = database.label(iter1);
    try
    cname = database.cname{flabel};
    catch
        t = 1;
    end
    
    [rtpath, fname] = fileparts(fpath);
    feaPath = fullfile(fea_dir, num2str(flabel), [fname '.mat']);
    try
        load(feaPath, 'label', 'fea');
    catch
        label = database.label(iter1);
        if setting.precom
            sFolder = num2str(label - 1, '%05d');
            [aa,bb,cc] = fileparts(feaPath);
            if database.istrain(iter1)
                im = double(color(imreadx(fpath)));
                im = imresize(im, setting.imsize{i}, 'bilinear');               
                Params = [setting.hog.orientation setting.csize{i} setting.hog.bsize ...
                    strcmp(setting.hog.issigned, 'signed') 0.2];
                warped = sqrt(double(im) / 255);
                fea = HoG(warped, Params);
            else
                if ismember(iter1, database.Trainset)
                    ddir = fullfile(setting.ffdir, sFolder);
                else
                    ddir = setting.ffdir2;
                end
                lfile = fullfile(pwd, ddir, [bb, '.txt']);
                fea = importdata(lfile);
            end
        else
%             if ~strcmp(setting.feattype{i}, 'Hue')
%             im = double(color(imreadx(fpath)));
%             warped = imresize(im, setting.rawsize, 'bilinear');
%             if mod(setting.latent, 5)
%                 fea = FeatureMapCompute(setting, warped, i, setting.latent, database.istrain(iter1));          
%             else
%                 if setting.Fpyramid
%                     fea = pyrafeaturecompute(setting, warped, i);
%                 else
%                     fea = featurecompute(setting, warped, i);
%                 end
%             end
%             else
%                 im = double(color(imreadx(fpath)));
%                 fea = featurecompute(setting, im, i);
%             end
            
            if strcmp(setting.feattype{i}, 'sphog') || strcmp(setting.feattype{i}, 'Pixel') || strcmp(setting.feattype{i}, 'PixelO') ...
                    || strcmp(setting.feattype{i}, 'sphogM') || strcmp(setting.feattype{i}, 'PixelM') ||...
                    strcmp(setting.feattype{i}, 'sphog1') || strcmp(setting.feattype{i}, 'Pixel1') ...
                    || strcmp(setting.feattype{i}, 'sphogM1') || strcmp(setting.feattype{i}, 'PixelM1')
                if ndims((imread(fpath))) == 2
                    im = double(imread(fpath));
                else
                    im = double(rgb2gray(imread(fpath)));
                end
            else
                im = double(color(imreadx(fpath)));
            end
            
            
            Fpyramid = setting.Fpyramid;
            if ~strcmp(setting.feattype{i}, 'Hue')
                warped = imresize(im, setting.rawsize, 'bilinear');
            else
                warped = im;Fpyramid = 0;
            end

            if mod(setting.latent, 5)
                fea = FeatureMapCompute(setting, warped, i, setting.latent, database.istrain(iter1));          
            else
                if Fpyramid
                    fea = pyrafeaturecompute(setting, warped, i);
                else
                    fea = featurecompute(setting, warped, i);
                end
            end
            
        end
        save(feaPath, 'fea', 'label');
    end
    
    curfeat = 0;
    if mod(setting.latent, 5)
        curfeat = numel(fea{1}{1});
    else
        curfeat = length(fea);
    end

    Acurfeat = 0;
    if setting.WTAwithraw
        if iter1 == 1
            Acurfeat = curfeat;
        end
        fdatabase.Rawpath{1}{iter1} = feaPath;
    end
    Currdfea = Acurfeat;
    
    if setting.WTA
        feaPath_WTA = fullfile(fea_dir_WTA, num2str(flabel), [fname '.mat']);
        try
            load(feaPath_WTA, 'fea', 'label');
        catch
            if iter1 > 1 && length(fea) ~= curfeat
                fprintf(' %d feature size eror \n', iter1);
                pause;
            end
            fullpath = fullfile(fea_dir_WTA, 'WTAperm.mat');
            try
                load(fullpath, 'WTAperm');
            catch
                WTAperm = zeros(setting.N, setting.K);
                for tt = 1:setting.N
                    index = randperm([length(fea)]);
                    WTAperm(tt,:) = index(1:setting.K);
                end
                save(fullpath, 'WTAperm');
            end
            fea = fea(:);
            fea = GenerateCode(fea, WTAperm, setting.N, setting.K);
            save(feaPath_WTA, 'fea', 'label');
        end
        feaPath = feaPath_WTA;
        
        dWTAFeaFea = length(fea);
        Currdfea = Currdfea + dWTAFeaFea;
    end
    if setting.WTA
        dFea = max(dFea, Currdfea);
    else
        dFea = max(dFea, length(fea));
    end
    
    fdatabase.label(iter1) = flabel;
    fdatabase.path{1}{iter1} = feaPath;
    fdatabase.imgpath{iter1} = database.orgimpath{iter1};
end;
cdFea{1} = dFea;
WTAFea{1} = dWTAFeaFea;
pady = setting.pady;
padx = setting.padx;