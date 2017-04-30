function [Trainstr, TrainAlpha, datastruct] = ReadSigndata_S(rt_img_dir, ...
    newfn, isTemplate, subname, rename, outdir, datainfo)
if nargin < 3 isTemplate = 0; end
if nargin < 4 subname = '';   end
if nargin < 7 datainfo = {};  end
TrainAlpha = [];
Trainstr = [];
sdelimiter = sprintf('\t');
fn = fullfile(rt_img_dir, '_Metadata.tsv');
strtext = textread(fn,'%s', 'headerlines',1, 'delimiter', '\n');
strtitle = strtext{1};
nimages = length(strtext) - 1;
indexstr = strfind(strtitle, sdelimiter);

keys1 = '#FileName';
idstart = strfind(strtitle, keys1);
idend = idstart + length(keys1);%%%%filename index
index1 = find(indexstr == idend);

keys2 = 'Id';
idstart = strfind(strtitle, keys2);
index2 = '';
if ~isempty(idstart)
    idend = idstart + length(keys2);%%%%filename index
    index2 = find(indexstr == idend);
end

idx = strfind(strtitle, sdelimiter);
istart = 0;
for i = 1:length(idx)
    datastruct.name{i} = strtitle(istart+1:idx(i)-1);
    istart = idx(i);
end
datastruct.name{i+1} = strtitle(istart+1:end);
imgtext = strtext(2:end);

idrange = [];
for i = 1:nimages
    strtitle = imgtext{i};
    idx = [1, strfind(strtitle, sdelimiter)];
   
    strid = strtitle(idx(index2):idx(index2+1)-1);
    classid = str2num(strid);
    idrange = [idrange, classid];
end

if isempty(index2)
    if nargin < 6
        idrange = -1;
    else
        idrange = str2num(outdir);
    end
end

idrange = unique(idrange);
for i = idrange
    fnimage = [newfn, '\', num2str(i)];
    if ~exist(fnimage)
        mkdir(fnimage);
    end
end
Trainstr = cell(1, max(idrange));
nclass = zeros(1, max(idrange));
if isTemplate
    liststr = '\trainlist.txt';
    suffix = 'train_';
else
    liststr = '\testlist.txt';
    suffix = ['test_' subname '_'];
end

for i = idrange
    fnlist = [newfn, '\', num2str(i), liststr];
    fid = fopen(fnlist, 'w');fclose(fid);
end


strsuffix = 'Truth_Rectified_';
numdisp = 5;
nround = round(nimages / numdisp);
datastruct.value = cell(1, nimages);
for i = 1:nimages
    if mod(i, nround) == 0
        fprintf('Convert Image from %s: %d/%d\n', subname, i, nimages)
    end
    
    strtitle = imgtext{i};
    idx = [1, strfind(strtitle, sdelimiter)];
   
    strname = strtitle(idx(index1):idx(index1+1)-1);

    try
        [img, map, alpha] = imread([rt_img_dir strname]);
    catch
        continue;
    end

    if ~isempty(alpha)
        [row, col] = find(alpha > 40);
        window = [min(row), max(row), min(col), max(col)];
        alpha = alpha(window(1):window(2), window(3):window(4),:);
        img = img(window(1):window(2), window(3):window(4),:);
    else
        alpha = uint8(ones(size(img)));
    end
    
    
    if isempty(index2)  %%if no groundtruth
        classid = idrange;
    else
        strid = strtitle(idx(index2):idx(index2+1)-1);
        classid = str2num(strid);
    end
    
    Trainname = [newfn '\' num2str(classid) '\' suffix strname];
    fnname = [suffix strname];
 
    if ~isTemplate
        if rename
            strname = RenameOldConvention(strname);
        end
        
        iindex = strfind(strname, '_'); 
        pindex = strfind(strname, strsuffix);
        dir = [newfn '\' num2str(classid) '\' suffix ...
            strname(pindex:length(strsuffix)) strname(iindex(end)+1:end-4)];  
        
        if ~isempty(datainfo.signnum)
            index = find( datainfo.signnum == str2num(strname(iindex(end)+1:end-4)));
            if ~isempty(index) && datainfo.label(index)
                classid = datainfo.label(index);
            end
        end
        
        
        if ~exist(dir)
            mkdir(dir);
        end
        
        fname = [strname(iindex(2)+1:iindex(end)-1), '.jpg'];
        Trainname = fullfile(dir, fname);
        fnname = [suffix strname(pindex:length(strsuffix)) ...
            strname(iindex(end)+1:end-4) '\' fname];
        fnnamestr = [suffix strname(pindex:length(strsuffix)) ...
            strname(iindex(end)+1:end-4) '_' fname];
    end

    
    if isTemplate
        nclass(classid) = nclass(classid)+1;
        Trainstr{classid}{nclass(classid)} = strname;
        TrainAlpha{classid}{nclass(classid)} = alpha;
    end
    
    fnlist = [newfn, '\', num2str(classid), liststr];
    fid = fopen(fnlist, 'a');
    fprintf(fid, '%s \r\n',fnname);
    fclose(fid);
    
    datastruct.value{i} = cell(1, length(idx));
    
    try
        imwrite(img, Trainname,'jpg');
    catch
        fprintf('can not write image %s\n', Trainname);
        pause;
    end


    for jj = 1:length(idx) - 1 
        datastruct.value{i}{jj} = [strtitle(idx(jj):idx(jj+1)-1)];
    end
    if ~isTemplate
        datastruct.value{i}{index1} = fnnamestr;
    end

end