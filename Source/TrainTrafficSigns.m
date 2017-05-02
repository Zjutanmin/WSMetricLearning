function database = TrainTrafficSigns(database, img_dir, suffix)
% MATLAB Version 7.11.0.584 (R2010b)
%
% Traffic Sign Recognition Benchmark
%
% This function provides a base to train the classifier that will later
% compete in the traffic sign recognition benchmark. You should download
% and extract the benchmark data and keep the file structure that it
% provides.
%
% Change the lines that are marked with a TODO to your needs.
if nargin < 3
    suffix = '\Training';
end
isfortrain = 0;
if strcmp(suffix, '\Training')
    isfortrain = 1;
end

% TODO!
% replace this string by the path you saved the benchmark data in


img_dirW = img_dir;
[a,b] = fileparts(img_dir);
img_dir = fullfile(a,'dataset', b);


sBasePath = [img_dir, suffix]; 
sBasePathW = [img_dirW, suffix]; 

n1 = database.imnum;

if ~isfortrain || (isfield(database, 'cname') && ~isempty(database.cname))
    NC = length(database.cname) - 1;
else
    NC = 0;
    ffdir = dir(sBasePath);
    for i = 1:length(ffdir)
    if strcmp(ffdir(i).name, '.') || strcmp(ffdir(i).name, '..')
        continue;
    end
    if isdir(fullfile(sBasePath, ffdir(i).name))
        NC = NC + 1;
    end
    end
    NC = NC - 1;
end

formatstr = '%05d';
if strcmp(b(1:5), 'digit')
    formatstr = '%d';
end

for nNumFolder = 0:NC
    
    
    sFolder = num2str(nNumFolder, formatstr);
    
    sPath = [sBasePath, '\', sFolder, '\'];

    if isdir(sPath)
        
        
        
        try
            [ImgFiles, Rois, Classes, HIWI] = readSignData([sPath, '\GT-', num2str(nNumFolder, '%05d'), '.csv']);
        
        xx = hist(c, [1:length(a)]);
        if length(a) ~= length(c)
            tid  = find(xx > 1); 
            for jj = tid
                idx = find(c == jj);
                nn = size(unique(Rois(idx, :), 'rows'), 1) ;
                if nn > 1
                    sprintf('For %s there are %d distinct annotations:ROIS', a{jj}, nn)
                    paus
                end
                nn = size(unique(Classes(idx, :), 'rows'), 1);
                if nn > 1
                    sprintf('For %s there are %d distinct annotations:class', a{jj}, nn)
                    paus
                end
            end
        end
        catch
            Rois = [];
            ffn = dir(sPath);kkk = 0;
            ImgFiles = {};
            for jj = 1:length(ffn)
                if ~strcmp(ffn(jj).name, '.') && ~strcmp(ffn(jj).name, '..')
                    kkk = kkk +1;
                    ImgFiles{kkk} = ffn(jj).name;
                end
            end
        end
        if isfortrain
            database.nclass = database.nclass + 1;
            database.cname{database.nclass} = sFolder;
        end
        database.imnum = database.imnum + numel(ImgFiles);
        ssPath = [sBasePathW, '\', sFolder, '\'];
        if ~exist(ssPath)
            mkdir(ssPath)
        end
        [a,b,c] = unique(ImgFiles);
        try
            database.label = [database.label; Classes];
        catch
            database.label = [database.label; ones(length(ImgFiles), 1)*(nNumFolder+1)];
        end
        for jj= 1:numel(ImgFiles)
            impathO = fullfile(sPath, ImgFiles{jj});
            impath = fullfile(ssPath, ImgFiles{jj});
            
            database.path = [database.path, impath];
            database.orgimpath = [database.orgimpath,impath];
            Img = imread(impathO);
            if ~isempty(Rois)
            if nnz([size(Img, 1),size(Img, 2)]  - HIWI(jj, :))
                Img = Img(Rois(jj, 2) + 1:Rois(jj, 4) + 1, Rois(jj, 1) + 1:Rois(jj, 3) + 1,:);
            else
                Img = Img(Rois(jj, 1) + 1:Rois(jj, 3) + 1, Rois(jj, 2) + 1:Rois(jj, 4) + 1,:);
            end
            end
            imwrite(Img, impath);
        end
    end   
end
n2 = database.imnum;
% % database = GetUniqueData(database, n1, n2);
% % n2 = database.imnum;
if isfortrain
    database.Trainset = [n1+1:n2];
else
    database.Testset = [n1+1:n2];
end




function [rImgFiles, rRois, rClasses, rHIWI] = readSignData(aFile)
% Reads the traffic sign data.
%
% aFile         Text file that contains the data for the traffic signs
%
% rImgFiles     Cell-Array (1 x n) of Strings containing the names of the image
%               files to operate on
% rRois         (n x 4)-Array containing upper left column, upper left row,
%               lower left column, lower left row of the region of interest
%               of the traffic sign image. The image itself can have a
%               small border so this data will give you the exact bounding
%               box of the sign in the image
% rClasses      (n x 1)-Array providing the classes for each traffic sign

    fID = fopen(aFile, 'r');
    
    fgetl(fID); % discard line with column headers
    
    f = textscan(fID, '%s %d %d %d %d %d %d %d', 'Delimiter', ';');
    
    rImgFiles = f{1}; 
    rHIWI = [f{2}, f{3}];
    rRois = [f{4}, f{5}, f{6}, f{7}];
    
    rClasses = f{8};
    
    fclose(fID);
    
    
function MyTrainingFunction(aImg, aClasses)

fprintf(1, 'You should replace the function MyTrainingFunction() by your own training function.\n');



function database = GetUniqueData(database, n1, n2) %%%delete multiple data
range = [n1+1:n2];

rpath = database.path(range);
rlabel = database.label(range);
rorgimpath = database.orgimpath(range);

database.path = database.path(1:n1);
database.label = database.label(1:n1);
database.orgimpath = database.orgimpath(1:n1);

    
[a,b,c] = unique(rpath);
if length(a) ~= length(c)
    xx = hist(c, [1:length(a)]);
    tid  = find(xx > 1); 
    for jj = tid
        idx = find(c == jj);
        tt = unique(rlabel(idx));
        if length(tt) > 1
            sprintf('The same %s in %d category', a{jj}, length(tt))
            pause
        end
    end
    
    b = sort(b);
    
    database.imnum = n1 + length(b);
    range = [(n1+1:database.imnum)];
    
    database.label(range) = rlabel(b);
    database.path(range) = rpath(b);
    database.orgimpath(range) = rorgimpath(b);
end
% % imnum: 4591
% %         cname: {1x62 cell}
% %         label: [4591x1 int32]
% %       istrain: [1x0 double]
% %     isForBook: []
% %          path: {1x4591 cell}
% %        nclass: 62
% %       imgpath: {}
% %          Rois: []
% %     orgimpath: {1x4591 cell}
