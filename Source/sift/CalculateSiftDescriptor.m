function [database, lenStat] = CalculateSiftDescriptor(rt_img_dir, ...
    rt_data_dir, gridSpacing, patchSize, maxImSize, nrml_threshold, ...
    copyremove, feattype, setting)
%==========================================================================
% usage: calculate the sift descriptors given the image directory
%
% inputs
% rt_img_dir    -image database root path
% rt_data_dir   -feature database root path
% gridSpacing   -spacing for sampling dense descriptors
% patchSize     -patch size for extracting sift feature
% maxImSize     -maximum size of the input image
% nrml_threshold    -low contrast normalization threshold
%
% outputs
% database      -directory for the calculated sift features
%
% Lazebnik's SIFT code is used.
%
% written by Jianchao Yang
% Mar. 2009, IFP, UIUC
%==========================================================================
if nargin < 7
    copyremove = 0;
end
if nargin < 8
    feattype = 'sift';
end
if nargin < 9
    setting = '';
end
fprintf('Compute %s features for LLC : %s\n', feattype{1});
fprintf('\n');
subfolders = dir(rt_img_dir);

siftLens = [];

database = [];

database.imnum = 0; % total image number of the database
database.cname = {}; % name of each class
database.label = []; % label of each class
database.path = {}; % contain the pathes for each image of each class
database.nclass = 0;

overlap = 1;setting.overlap = overlap;
swin = patchSize;setting.swin = swin;
stride = swin / 2;setting.stride = stride;
descriptor = {'c'};setting.descriptor = descriptor;


for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    
    if ~strcmp(subname, '.') & ~strcmp(subname, '..'),
        if ~mod(ii, 100)
            fprintf('Compute book features for subfolders : %d/%d\n', ii, length(subfolders));
        end
            
        database.nclass = database.nclass + 1;
        
        database.cname{database.nclass} = subname;
        
        frames = dir(fullfile(rt_img_dir, subname, '*.jpg'));
        
        c_num = length(frames);           
        database.imnum = database.imnum + c_num;
        database.label = [database.label; ones(c_num, 1)*database.nclass];
        
        for tt = 1:length(feattype)
            
        siftpath = fullfile(rt_data_dir{tt}, subname);        
        if ~isdir(siftpath),
            mkdir(siftpath);
        end;
        
        for jj = 1:c_num,
            
            imgpath = fullfile(rt_img_dir, subname, frames(jj).name);
            
            if copyremove && length(strfind(frames(jj).name, '- Copy')) > 0   %%the file is a copy
                cwd = pwd;
                cd(fullfile(cwd,fullfile(rt_img_dir, subname)));
                dos(['del "' frames(jj).name '"']);
                cd(cwd);
                continue;
            end
            
            [pdir, fname] = fileparts(frames(jj).name);                        
            fpath = fullfile(rt_data_dir{tt}, subname, [fname '.mat']);
            
            try
                load(fpath, 'feaSet');
            catch
  
            I = imread(imgpath);
            I1 = I;
            if ndims(I) == 3,
                I = im2double(rgb2gray(I));
            else
                I = im2double(I);
            end;
            
            [im_h, im_w] = size(I);
            
            if max(im_h, im_w) > maxImSize,
                I = imresize(I, maxImSize/max(im_h, im_w), 'bicubic');
                [im_h, im_w] = size(I);
            end;
           
            switch feattype{tt}
                case 'hog'
                    feaSet = computesigle(feattype, setting, I1,swin, stride, tt);
                case 'lbp'
                    feaSet = computesigle(feattype, setting, I1,swin, stride, tt);
                case 'ltp'
                    feaSet = computesigle(feattype, setting, I1,swin, stride, tt);
                case 'color'
                    feaSet = computesigle(feattype, setting, I1,swin, stride, tt);
                case 'sift'
                    % make grid sampling SIFT descriptors
                    remX = mod(im_w-patchSize,gridSpacing);
                    offsetX = floor(remX/2)+1;
                    remY = mod(im_h-patchSize,gridSpacing);
                    offsetY = floor(remY/2)+1;
    
                    [gridX,gridY] = meshgrid(offsetX:gridSpacing:im_w-patchSize+1, offsetY:gridSpacing:im_h-patchSize+1);

                    fprintf('Processing %s: wid %d, hgt %d, grid size: %d x %d, %d patches\n', ...
                        frames(jj).name, im_w, im_h, size(gridX, 2), size(gridX, 1), numel(gridX));
                    % find SIFT descriptors
                    siftArr = sp_find_sift_grid(I, gridX, gridY, patchSize, 0.8);
                    [siftArr, siftlen] = sp_normalize_sift(siftArr, nrml_threshold);
                    siftLens = [siftLens; siftlen];
            
                    feaSet.feaArr = siftArr';
                    feaSet.x = gridX(:) + patchSize/2 - 0.5;
                    feaSet.y = gridY(:) + patchSize/2 - 0.5;

            end
            feaSet.width = im_w;
            feaSet.height = im_h;
            
            [pdir, fname] = fileparts(frames(jj).name);                        
            fpath = fullfile(rt_data_dir{tt}, subname, [fname '.mat']);
            
            save(fpath, 'feaSet');
            end
        end
     
            database.path = [database.path, fpath];
        end;    
    end;
end;
    
lenStat = hist(siftLens, 100);


function feaSet = computesigle(feattype, setting, I1,swin, stride, tt)
setting.feattype = feattype(tt);
fea = mulfeatures_im(double(I1), setting, 1, setting.stride(1),1, -1,[],[]);
[a,b,c] = size(fea);fea = reshape(fea, [a, b*c]);   
[s1,s2,s3] = size(I1);
                    
feaSet.feaArr = fea;
xrange = [stride+swin:stride:b*stride + swin];
yrange = [stride+swin:stride:c*stride + swin];
[gridX,gridY] = meshgrid(yrange, xrange); 
feaSet.x = gridX(:);
feaSet.y = gridY(:);