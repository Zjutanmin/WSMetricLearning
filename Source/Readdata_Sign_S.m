function [Trainstr, TrainAlpha, datastruct, datastruct_test] = Readdata_Sign_S(...
    rt_img_dir, fn, templateDir, foldname, rename, filename, outdir)
fn = [pwd '\' fn];
Trainstr = [];
TrainAlpha = [];
datastruct = [];
disp('Convert file structure...');

% %%%template
disp('Convert file from SignTemplates...');

rt_img_dir1 = templateDir;
fnmeta = fullfile(rt_img_dir1, '_Metadata.tsv');
if ~exist(fnmeta)
    disp('Error for Templates file, no Metadata.tsv...');
end
[Trainstr, TrainAlpha, datastruct] = ReadSigndata_S(rt_img_dir1, fn, 1);
%%
datastruct_test = [];
disp('Convert file from Test image...');
rt_img_dir2 = [rt_img_dir, foldname];    


if nargin < 6 || isempty(filename)
    subfolders = dir(rt_img_dir2);
else
    subfolders = struct('name', {}, 'date', '', 'bytes', 0, 'isdir', 0, 'datenum', 0);
    for jj = 1:length(filename)
        subfolders(jj).name = filename{jj};
        subfolders(jj).isdir = 1;
    end
end

numdisp = 10;
nround = round(length(subfolders) / numdisp);

signnum= {};signname = {};label = {};signTemp = {};
fndir = fullfile(rt_img_dir2, 'SignMatcherMapEntitiesWithPaths_filtered.txt');
if exist(fndir)
    fid = fopen(fndir, 'r');
    i = 0;
    while ~feof(fid)
        str = fgets(fid);
        index = strfind(str, '	');
        i = i + 1;
        signnum{i} = str2num(str(1:index(1)-1));
        signname{i} = (str(index(1)+1:index(2)-1));
        label{i}  = str2num(str(index(2)+1:index(3)-1));
        signTemp{i}  = (str(index(3)+1:end));
    end
    fclose(fid);
    datainfo.signnum = cell2mat(signnum(1:end-1));
    datainfo.signname = signname(1:end-1);
    datainfo.label = cell2mat(label(1:end-1));
    datainfo.signTemp = signTemp(1:end-1);
end

jj = 0;
for ii = 1:length(subfolders),
    if mod(ii, nround) == 0
        fprintf('Convert Subfile: %d/%d\n', ii, length(subfolders))
    end
    subname = subfolders(ii).name;
    if ~strcmp(subname, '.') & ~strcmp(subname, '..'),
        if ~subfolders(ii).isdir
            continue;
        end
        jj = jj + 1;
        subname1 = subname;subname = [subname '\'];
        fnmeta = [rt_img_dir2 subname '_Metadata.tsv'];
        if ~exist(fnmeta)
            disp('Error for Templates file, no Metadata.tsv  in %s...', [rt_img_dir2 subname]);
        end
        [Teststr, TestAlpha, datastruct_tmp] = ReadSigndata_S([rt_img_dir2, subname], ...
            fn, 0, subname1,rename, outdir, datainfo);
        if jj > 1
            datastruct_test.value(end+1:end+length(datastruct_tmp.value)) = datastruct_tmp.value;
        else
            datastruct_test = datastruct_tmp;
        end
    end
end;