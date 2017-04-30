function Trainstr = Readdata_Sign(rt_img_dir, fn)
fn = [pwd '\' fn];
disp('Convert file structure...');

% %%%template
disp('Convert file from SignTemplates...');
rt_img_dir1 = [rt_img_dir, '\SignTemplates\'];
fnmeta = [rt_img_dir1 '_Metadata.tsv'];
if ~exist(fnmeta)
    disp('Error for Templates file, no Metadata.tsv...');
end
Trainstr = ReadSigndata(rt_img_dir1, fn, 1);

%%
disp('Convert file from Test image...');
rt_img_dir2 = [rt_img_dir, '\TrueSign\Rectified\'];
subfolders = dir(rt_img_dir2);
database = [];
database.imnum = 0; % total image number of the database
database.cname = {}; % name of each class
database.label = []; % label of each class
database.path = {}; % contain the pathes for each image of each class
database.nclass = 0;

numdisp = 10;
nround = round(length(subfolders) / numdisp);

for ii = 1:length(subfolders),
    if mod(ii, nround) == 0
        fprintf('Convert Subfile: %d/%d\n', ii, length(subfolders))
    end
    
    subname = subfolders(ii).name;
    if ~strcmp(subname, '.') & ~strcmp(subname, '..'),
        subname1 = subname;
        subname = [subname '\'];
        fnmeta = [rt_img_dir2 subname '_Metadata.tsv'];
        if ~exist(fnmeta)
            disp('Error for Templates file, no Metadata.tsv  in %s...', [rt_img_dir2 subname]);
        end
        ReadSigndata([rt_img_dir2, subname], fn, 0, subname1);
    end
end;