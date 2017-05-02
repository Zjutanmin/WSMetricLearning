function database = TemplateS(database, sBasePath, tmpname, Trainid)
sBasePath = [sBasePath, '\template']; 
if ~exist(sBasePath)
    mkdir(sBasePath)
end
if Trainid
    n1 = database.imnum;
end
try
    database.imnum = database.imnum + numel(tmpname);
    
    if ~isempty(tmpname)
        classes = [0:length(unique(database.label)) - 1];
    database.label = [database.label; classes(:)];
    database.Rois = [database.Rois; zeros(numel(tmpname),  size(database.Rois, 2))];
    
        ImgFile = [sBasePath, '\', [tmpname{1}, '.jpg']];
   
    if ~exist(ImgFile)
        for i = 1:numel(tmpname)
            ImgFileO = ['image\Sign\SignTemplates_Germany\', [tmpname{i}, '.jpg']];
            ImgFile = [sBasePath, '\', [tmpname{i}, '.jpg']];
            copyfile(ImgFileO, ImgFile);
        end
    end
    
%     col = ceil(sqrt(numel(tmpname)));
    for i = 1:numel(tmpname)
        ImgFile = [sBasePath, '\', [tmpname{i}, '.jpg']];
        database.path = [database.path, ImgFile];
        database.orgimpath = [database.orgimpath,ImgFile];
%         subplot(col, col, i);
%         imshow(uint8(imread(ImgFile)));
    end
    
    end
catch ME
    getReport(ME)
end

if Trainid
    n2 = database.imnum;
    database.istrain(n1+1:n2) = 1;
end