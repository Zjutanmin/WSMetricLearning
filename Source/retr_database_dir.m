function [database] = retr_database_dir(rt_data_dir, rt_img_dir, Sel_img_dir, Trainid)
%=========================================================================
% inputs
% rt_data_dir   -the rootpath for the database. e.g. '../data/caltech101'
% outputs
% database      -a tructure of the dir
%                   .path   pathes for each image file
%                   .label  label for each image file
% written by Jianchao Yang
% Mar. 2009, IFP, UIUC
%=========================================================================
if nargin < 3
    Sel_img_dir = [];
end
if nargin < 4
    Trainid = 0;
end
fprintf('dir the database...');
subfolders = dir(rt_data_dir);


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

for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    
    if ~strcmp(subname, '.') & ~strcmp(subname, '..') & ~strcmp(subname, 'Trainstr.mat'),
        database.nclass = database.nclass + 1;
        
        database.cname{database.nclass} = subname;
        
        frames = dir(fullfile(rt_data_dir, subname, '*.mat'));
        c_num = length(frames);
                    
        database.imnum = database.imnum + c_num;
        database.label = [database.label; ones(c_num, 1)*database.nclass];

        if Trainid
            fn = fullfile(rt_img_dir, subname, 'trainlist.txt');
            ids = textread(fn, '%s');
        end


        for jj = 1:c_num,
            c_path = fullfile(rt_data_dir, subname, frames(jj).name);
            database.path = [database.path, c_path];
            database.orgimpath = [database.orgimpath, c_path];
            forBook = 0;
            
            istrain = 0;
            if Trainid
                tmp = [frames(jj).name(1:end-4), '.jpg'];
                xx = strfind(ids, tmp);
                b = cellfun('isempty',xx);
                if nnz(b-1)
                    istrain = 1;
                    tt = findstr(tmp, 'train_');tmp1 = tmp(tt+6:end);
                    if ~isempty(Sel_img_dir) && exist(fullfile(fullfile(Sel_img_dir, ...
                            'selected'), tmp1))
                        forBook = 1;
                    end
                    
                end
            end
            database.isForBook = [database.isForBook, forBook];
            database.istrain = [database.istrain; istrain];
        end; 
    end;
end;
disp('done!');