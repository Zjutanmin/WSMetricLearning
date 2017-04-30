function labelsample(rt_data_dir)

%%%rule: not discard folder:   the width or heigth of the top beta% sample larger than alfa * template resolution
beta = 0.2;

datadir = 'D:\MinTan\project\Signdetect\SignClassify\image\DATA';
rt_data_dir = fullfile(datadir, '-1');
tmp_dir = 'D:\MinTan\project\Signdetect\SignClassify\image\sign\SignTemplates';

fn1 = dir(fullfile(tmp_dir, '*.jpg'));
imsize = [];
for i = 1:length(fn1)
    im = imread(fullfile(tmp_dir,fn1(i).name ));
    imsize = [imsize; [size(im, 1), size(im, 2)]];
end
means = (mean(imsize));
% means = prod(mean(imsize));
alfa = 0.8;


id = {291, 84, 325, 326, 496, 497, 978, -2};
% tmp_fn = {'325.jpg', '496.jpg', '497.jpg', '84.jpg','978.jpg'};
tmp_file = cell(1, length(id));
for t = 1:length(id)
    tmp_file{t} = fullfile(tmp_dir, [num2str(id{t}), '.jpg']);
    fn = fullfile(datadir, num2str(id{t}));
    
    if ~exist(fn)
        mkdir(fn)
    end
    
end

fn = fullfile(datadir, '-3');
    
if ~exist(fn)
    mkdir(fn)
end

figure(1);
nn = length(tmp_file)-1;
for ii = 1:nn
    im = imread(tmp_file{ii});
    subplot(3, 3, ii);
    imshow(uint8(im))
    title(num2str(id{ii}))
end
set (1,'Position',[200,450,400,400])

subfolders = dir(rt_data_dir);
stitle = ['please label it as 1-' num2str(length(id)), ',' num2str(length(id)) 'for others:  '];
for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    
    if ~strcmp(subname, '.') & ~strcmp(subname, '..') & ~strcmp(subname, 'Trainstr.mat'),
        subfolders1 = dir(fullfile(rt_data_dir, subname, '*.jpg'));
        
        n = length(subfolders1);
        meansize = [];
        for tt = 1:n
            fn = fullfile(rt_data_dir, subname, subfolders1(tt).name);
            im = imread(fn);
            meansize = [meansize; [size(im,1), size(im, 2)]];
        end
        nump = ceil(beta*n);
        
        height = meansize(:,1);
        width = meansize(:,2);
        [height,ord] = sort(height, 'descend'); height = height((1:nump));
        [width,ord] = sort(width, 'descend'); width = width((1:nump));
        
        xindex = height > alfa * repmat(means(1), [size(height, 1), 1]);
        yindex = width > alfa * repmat(means(2), [size(width, 1), 1]);
        
        idx = sum(xindex) == nump; %%%bu manzu
        idy = sum(yindex) == nump;
        
        if ~idx && ~idy
            newfn = fullfile(datadir, '-3', subname);
            copyfile(fullfile(rt_data_dir, subname),newfn);
            rmdir(fullfile(rt_data_dir, subname), 's')
            continue;
        end


        figure(2)
        set (2,'Position',[600,350,500,500])
        n = length(subfolders1);
        col = ceil(sqrt(n));
        row = ceil(sqrt(n));
        for tt = 1:n
            im = fullfile(rt_data_dir, subname, subfolders1(tt).name);
            subplot(row, col, tt);
            imshow(im);
        end
        label = input(stitle,'s');
        index = str2num(label);
        newfn = fullfile(datadir, num2str(id{index}), subname);
        copyfile(fullfile(rt_data_dir, subname),newfn);
        rmdir(fullfile(rt_data_dir, subname), 's')
        close 2;
    end
end


        