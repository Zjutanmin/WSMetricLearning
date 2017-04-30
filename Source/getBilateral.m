function getBilateral(img_dir_new, img_dir, database, setting)

subfolders = dir(img_dir);
for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    if ~strcmp(subname, '.') & ~strcmp(subname, '..') & ~strcmp(subname, 'Trainstr.mat'),
        frames = (fullfile(img_dir_new, subname));
        if ~exist(frames)
            mkdir(frames)
        end
    end
end

esp = 0.001;

img_dir(find(img_dir == '/')) = '\';
nFea = length(database.path);
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
    if abs(max(warped(:)) -  min(warped(:))) < esp
        im = ones(size(warped)) * 128;
    else
        im = bilateralFilter(warped, [], max(warped(:)), min(warped(:)));
        im = (im - min(im(:))) / (max(im(:)) - min(im(:))); %%%range [0:1]
        im = im * 255; %%%range [0:255]
    end
    
    index = strfind(fpath, img_dir);
    imname = fpath(index+length(img_dir)+1:end);
%     database.orgpath{iter1} = fpath;
    
    fpath = fullfile(img_dir_new, imname);
    database.path{iter1} = fpath;
    imwrite(uint8(im), fpath, 'jpg');     
end;