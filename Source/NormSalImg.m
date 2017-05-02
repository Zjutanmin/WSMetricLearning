function NormSalImg(Infile, subname, Outfile)
infilename = fullfile(Infile, subname);
% outfilename = fullfile(Outfile, subname);
fsubname=dir(infilename);
% filename2 = fullfile(outfilename, 'tmp\output');
% if ~exist(filename2)
%     mkdir(filename2)
% end

filename1 = fullfile(outfilename, 'tmp\input');
if ~exist(filename1)
    mkdir(filename1)
end


% %%%Put file together
for i = 1:length(fsubname)
    if strcmp(fsubname(i).name, 'Trainstr.mat') || strcmp(fsubname(i).name, '..') || strcmp(fsubname(i).name, '.')
        continue;
    end
    filename = fullfile(infilename, fsubname(i).name);
    imgname=dir(fullfile(infilename, fsubname(i).name, '*.jpg'));
    if length(imgname) ==1 
        str = [fsubname(i).name, '_', imgname.name];
        nameorg = fullfile(infilename, fsubname(i).name, imgname.name);
        copyfile(nameorg, fullfile(filename1, str));
    else
        for j = 1:length(imgname)
            str = [fsubname(i).name, '_', imgname(j).name];            
            nameorg = fullfile(filename, imgname(j).name);
            copyfile(nameorg, fullfile(filename1, str));
        end
    end
end