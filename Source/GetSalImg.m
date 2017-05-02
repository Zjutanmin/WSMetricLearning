function GetSalImg(Infile, subname, Outfile)
infilename = fullfile(Infile, subname);
outfilename = fullfile(Outfile, subname);
fsubname=dir(infilename);
filename2 = fullfile(outfilename, 'tmp\output');
if ~exist(filename2)
    mkdir(filename2)
end

filename1 = fullfile(outfilename, 'tmp\input');
if ~exist(filename1)
    mkdir(filename1)
end


% %%%Put file together
% for i = 1:length(fsubname)
%     if strcmp(fsubname(i).name, 'Trainstr.mat') || strcmp(fsubname(i).name, '..') || strcmp(fsubname(i).name, '.')
%         continue;
%     end
%     filename = fullfile(infilename, fsubname(i).name);
%     imgname=dir(fullfile(infilename, fsubname(i).name, '*.jpg'));
%     if length(imgname) ==1 
%         str = [fsubname(i).name, '_', imgname.name];
%         nameorg = fullfile(infilename, fsubname(i).name, imgname.name);
%         copyfile(nameorg, fullfile(filename1, str));
%     else
%         for j = 1:length(imgname)
%             str = [fsubname(i).name, '_', imgname(j).name];            
%             nameorg = fullfile(filename, imgname(j).name);
%             copyfile(nameorg, fullfile(filename1, str));
%         end
%     end
% end
% cmd = ['.\ImgSaliency\Release\ImgSaliency ' filename1 '\*.jpg ' filename2];
% dos(cmd);

%%merge file
fsubname = dir(fullfile(filename2, '*_RC.png'));
for i = 1:length(fsubname)
    filename = fsubname(i).name;
    ids = findstr(filename, '_');
    subname = filename(1:ids(1)-1);
    imgname = filename(ids(1)+1:end);
    
    nameorg = fullfile(filename2, filename);
    outpath = fullfile(outfilename, subname);
    namedes = fullfile(outpath, imgname);     
    if ~exist(outpath)
        mkdir(outpath)
    end
    copyfile(nameorg, namedes);
    dos(['del ' nameorg]);
end