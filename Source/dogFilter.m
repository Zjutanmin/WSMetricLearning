function img_dir_new = dogFilter(img_dir, database, setting)

img_dir_new = [img_dir, '_', setting.config_DOG];

% img_dir_new(find(img_dir_new == '/')) = '\';
% img_dir(find(img_dir == '/')) = '\';
%run in linux
img_dir_new(find(img_dir_new == '\')) = '/';
img_dir(find(img_dir == '\')) = '/';


if ~exist(img_dir_new)
    mkdir(img_dir_new)
end
try
    load([img_dir_new, '/isDOG.mat'], 'isDOG')
catch
    getDOGIMAGE(img_dir_new, img_dir, database, setting);
    isDOG = 1;
    save([img_dir_new, '/isDOG.mat'], 'isDOG')
end

 
function getDOGIMAGE(img_dir_new, img_dir, database, setting)
if isfield(setting, 'DOGtype') && strcmp(setting.DOGtype, 'Bilateral')
    getBilateral(img_dir_new, img_dir, database, setting);
    return;
end
if setting.sigma1 > setting.sigma2
    tmp = setting.sigma2;
    setting.sigma2 = setting.sigma1;
    setting.sigma = tmp;
end

subfolders = dir(img_dir);
for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    if ~strcmp(subname, '.') && ~strcmp(subname, '..') && ~strcmp(subname, 'Trainstr.mat'),
        frames = (fullfile(img_dir_new, subname));
        if ~exist(frames)
            mkdir(frames)
        end
        subfolders1 = dir(fullfile(img_dir, subname));
        subfolders2 = dir(fullfile(img_dir, subname, '*.jpg'));
        if length(subfolders2) ~= length(subfolders1) - 2
        for jj = 1:length(subfolders1)
            subname1 = subfolders1(jj).name;
            if ~strcmp(subname1, '.') && ~strcmp(subname1, '..')
                frames1 = (fullfile(img_dir_new, subname, subname1));
                if isdir(fullfile(img_dir, subname, subname1)) && ~exist(frames1)
                    mkdir(frames1)
                end
            end
        end
        end
    end
end

% img_dir(find(img_dir == '/')) = '\';
% run in linux
img_dir(find(img_dir == '\')) = '/';

nFea = length(database.path);
index = strfind(img_dir_new, img_dir);
for iter1 = 1:nFea,  
    if ~mod(iter1, 5),
       fprintf('.');
    end
    if ~mod(iter1, 100),
        fprintf(' %d images processing by DOG\n', iter1);
    end
    fpath = database.path{iter1};
    I = imread(fpath);
    if ndims(I) == 3,
        I = im2double(rgb2gray(I));
    else
        I = im2double(I);
    end;
    warped = imresize(I, setting.rawsize, 'bilinear');
    im = dogImage(warped, setting.hsize, setting.sigma1, setting.sigma2);
    im = (im - min(im(:))) / (max(im(:)) - min(im(:))); %%%range [0:1]
    im = im * 255; %%%range [0:255]

    fpath = [fpath([1:index - 1]), img_dir_new, ...
        fpath([index + length(img_dir):length(fpath)])];
    database.path{iter1} = fpath;
    [a,b,c] = fileparts(fpath);
    if isempty(c)
        imwrite(uint8(im), fpath, 'jpg');
    else
        imwrite(uint8(im), fpath);
    end
end;