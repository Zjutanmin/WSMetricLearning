function [database] = retr_database_dir_img(rt_img_dir, Trainid)
%=========================================================================
%Reading data from rootpath rt_img_dir, and save the dataset information
%INPUT
% rt_data_dir    :  the rootpath for the database. e.g. '../image/Sign_NewT5'
% Trainid        :  1 / 0: Does the dataset contains the file 'trainlist.txt' to assign the template set
%OUTPUT
% database       : a tructure of the dir
%                   .path       pathes for each image file
%                   .label      label for each image file
%                   .imnum      Total number of images
%                   .cname      name of all the categories
%                   .istrain    indicator vector to define whether the image is a template
%                   .isForBook  indicator vector to define whether the image is for training the codebook (for LLC)
%                   .nclass     number of categories
%                   .orgimgpath pathes for each image file
    
%=========================================================================
if nargin < 2
    Trainid = 0;
end
%=========================================================================
% if nargin < 2
%     Sel_img_dir = '';
% end
[dir1, fname] = fileparts(rt_img_dir);

if length(fname) > 3 && (strcmp(fname(1:3), 'TSR') || ...
        strcmp(fname(1:5), 'digit'))
    [database] = ExtractTS(rt_img_dir, Trainid);
    if strcmp(fname(1:3), 'TSR')    database.Data = 'TSR';    end
    if strcmp(fname(1:5), 'digit')    database.Data = 'digit';    end
    return;
else
    if length(fname) > 4 && (strcmp(fname(1:4), 'Sign') || strcmp(fname(1:4), 'face'))
    else
        fprintf('Add here for reading images of your own dataset...');
        pause;
    end
end

fprintf('dir the database...');

subfolders = dir(rt_img_dir);


database = [];
database.imnum = 0; % total image number of the database
database.cname = {}; % name of each class
database.label = []; % label of each class
database.istrain = [];
database.isForBook = [];
database.path = {}; % contain the pathes for each image of each class
database.nclass = 0;
database.imgpath = {};

database.orgimpath = {};
% {iter1} = database.path{iter1};
for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    if ~strcmp(subname, '.') & ~strcmp(subname, '..') & ~strcmp(subname, 'Trainstr.mat')
        if length(dir(fullfile(rt_img_dir, subname, '*.jpg'))) > 0
            namestr = '.jpg';
        end
        if length(dir(fullfile(rt_img_dir, subname, '*.bmp'))) > 0
            namestr = '.bmp';
        end
        frames = dir(fullfile(rt_img_dir, subname, ['*', namestr]));
        c_num = length(frames);             
        database.imnum = database.imnum + c_num;
        
        if strcmp(subname, '-2')
            database.label = [database.label; ones(c_num, 1)];
        else
            database.nclass = database.nclass + 1;
            database.cname{database.nclass} = subname;
            database.label = [database.label; ones(c_num, 1)*database.nclass];
            if Trainid
                fn = fullfile(rt_img_dir, subname, 'trainlist.txt');
                ids = textread(fn, '%s');
            end
            
        end
        for jj = 1:c_num,
            c_path = fullfile(rt_img_dir, subname, frames(jj).name);
            database.path = [database.path, c_path];
            database.orgimpath = [database.orgimpath, c_path];
            
            forBook = 0;
            istrain = 0;
            if ~strcmp(subname, '-2') && Trainid
                tmp = [frames(jj).name(1:end-4), [namestr]];
                xx = strfind(ids, tmp);
                b = cellfun('isempty',xx);
                if nnz(b-1)
                    istrain = 1;
                    tt = findstr(tmp, 'train_');tmp1 = tmp(tt+6:end);
                end
            end
            database.isForBook = [database.isForBook, forBook];
            database.istrain = [database.istrain; istrain];
        end; 
    end;
end;
disp('done!');