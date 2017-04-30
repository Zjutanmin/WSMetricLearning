function Trainstr = ReadSigndata(rt_img_dir, newfn, isTemplate, subname)
if nargin < 3
    isTemplate = 0;
end
if nargin < 4
    subname = '';
end

sdelimiter = sprintf('\t');
fn = [rt_img_dir '_Metadata.tsv'];
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
    idrange = -1;
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

numdisp = 5;
nround = round(nimages / numdisp);
for i = 1:nimages
    if mod(i, nround) == 0
        fprintf('Convert Image from %s: %d/%d\n', subname, i, nimages)
    end
    strtitle = imgtext{i};
    idx = [1, strfind(strtitle, sdelimiter)];
   
    strname = strtitle(idx(index1):idx(index1+1)-1);
    img = imread([rt_img_dir strname]);
    
    
    if isempty(index2)  %%if no groundtruth
        classid = -1;
    else
        strid = strtitle(idx(index2):idx(index2+1)-1);
        classid = str2num(strid);
    end
    
    Trainname = [newfn '\' num2str(classid) '\' suffix strname];
    if isTemplate
        nclass(classid) = nclass(classid)+1;
        Trainstr{classid}{nclass(classid)} = strname;
    end
    
    fnlist = [newfn, '\', num2str(classid), liststr];
    fid = fopen(fnlist, 'a');
    fprintf(fid, '%s \r\n',[suffix strname]);
    fclose(fid);
    
    try
        imwrite(img, Trainname,'jpg');
    catch
        fprintf('can not write image %s\n', Trainname);
        pause;
    end
%     for i = 1:length(idx)
%         datastruct.value{i}()
%         = {i}.value() = strtitle(istart+1:idx(i));
%         istart = idx(i)+1;
%     end
%     if isTemplate
%         datastruct.value{i} = strtitle(istart+1:end);
%     end
end