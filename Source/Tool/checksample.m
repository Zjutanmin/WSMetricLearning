function checksample(rt_data_dir)

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

inum = zeros(length(id), 1);
for jj = 1:length(id) - 1 
    rt_data_dir_tmp = fullfile(datadir, num2str(id{jj})); 
    fprintf('Current class is %d\n', (id{jj}));
    
    subfolders = dir(rt_data_dir_tmp);
    for kk = 1:length(subfolders)
        subname = subfolders(kk).name;
        
    
    if ~strcmp(subname, '.') & ~strcmp(subname, '..') & ~strcmp(subname, 'Trainstr.mat'),
        
        inum(jj) = inum(jj) + 1';
        
        subfolders1 = dir(fullfile(rt_data_dir_tmp,subname, '*.jpg'));
        
        fprintf('%s\n', fullfile(rt_data_dir_tmp,subname));
        
        
     
        figure(2)
        set (2,'Position',[600,350,500,500])
        n = length(subfolders1);
        col = ceil(sqrt(n));
        row = ceil(sqrt(n));
        for tt = 1:n
            im = fullfile(rt_data_dir_tmp, subname, subfolders1(tt).name);
            subplot(row, col, tt);
            imshow(im);
        end
        pause;
        
        close 2;
    end
    end
    
    figure(2)
    im = rand([200,200,3]);
    imshow(uint8(im));title('The end of this class')
    pause;
end


% inum