function [database] = ExtractTS(img_dir, Trainid)
% ExtractTS(rt_img_dir, Trainid);
%=========================================================================
% inputs
% data_dir   -the rootpath for the database. e.g. '../data/caltech101'
% outputs
% database      -a tructure of the dir
%                   .path   pathes for each image file
%                   .label  label for each image file
% written by Jianchao Yang
% Mar. 2009, IFP, UIUC
%=========================================================================
database = [];

database.imnum = 0; % total image number of the database
database.cname = {}; % name of each class
database.label = []; % label of each class
database.istrain = [];
database.isForBook = [];
database.path = {}; % contain the pathes for each image of each class
database.nclass = 0;
database.imgpath = {};
database.Rois = [];
database.orgimpath = {};
database.istrain = zeros(1, database.imnum);
img_dir(find(img_dir == '/')) = '\';
database = TrainTrafficSigns(database, img_dir);
% if 

ResultFile = [img_dir, '\Test\classification_results.csv'];
if exist(ResultFile)
    database = EvalTrafficSigns(database, img_dir);
    tmpname = {'925', '926', '929', '930', '931', '932', '1016',  ...
    '921', '923', '840', '841', '894', '740', '1014',  ...
    '978', '1025', '843', '1020', '770', '905', '906',  ...
    '1012', '1017', '918', '896', '1019', '1023', '1024',  ...
    '759', '747', '800', '1011', '774', '768', '761',  ...
    '1018', '763', '764', '760', '762', '898', '1021',  ...
    '1022'};
else
    database = TrainTrafficSigns(database, img_dir, '\Testing');
    ffile = fullfile(img_dir, 'reducedSetTS.txt');
    tmpname = {};
    if exist(ffile)
        fid = fopen(ffile, 'r');
        ss = fgetl(fid);i = 0;
        while ~isempty(ss) && ~feof(fid)
        i = i +1;
        ss = fgetl(fid);
        tmpname{i} = ss;
        end
        fclose(fid);
    end
end

database = TemplateS(database, img_dir, tmpname, Trainid);