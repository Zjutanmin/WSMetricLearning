% % clear all
dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; 
dataset = 'Sign';str = '_NewT7-20-4-T2D';featurestr = 'cHoG_1_color24_0';
dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
load('D:\MinTan\project\Signdetect\SignClassify\MSresult', 'result', 'n1', 'CbestVV');
Bresult = result;Bn1 = n1;BCbestVV= CbestVV;
name = [name, str];

% % load('TrainInfo\image_Sign_NewT7-20-4-T2D_1_database.mat', 'database');
% % setting.rawsize =[90, 75];
% % [f1, f2] = fileparts(fileparts(fileparts(database.path{1})));
% % % % if ~exist(fullfile('TrainInfo', f2))
% % % %     mkdir(fullfile('TrainInfo', f2));
% % % % end
% % for i = 1:length(database.cname)
% %     ffdir = (fullfile(f1, f2, database.cname{i}));
% %     if ~exist(ffdir)
% %         mkdir(ffdir)
% %     end
% % end
% % for i = 1:database.imnum
% %     [a,b,c] = fileparts(database.path{i});
% %     [~,bb] = fileparts(a);
% %     im = imread(fullfile(f1, f2, f2, bb, [b,c]));
% %     warped = imresize(im, setting.rawsize, 'bilinear');
% %     imwrite(warped,  database.path{i});
% % end


classes = {'0'};
classesstr = {'101'};
classnum = [101];
PCAM =0.95; MetricL2 = 0;
crangeMLR = [10];
cd 'D:\MinTan\project\Signdetect\SignClassify';
dir = [dir, str, '\'];
if ~exist(dir) mkdir(dir); end
resultN = [];CbestVV = [];
crange = crangeMLR;
pcarange = 0.95;winit = 1;
Ntype = 1;
N = (9+Ntype);
i = 0; result2 = [];ranktime = [];
for jj = pcarange
    for ii = crange
        for tt = 1:length(classes);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = GetRecogRate_32(dataset, str, featurestr,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},0,1);
        end
    end
end


classes = {'-3.21', '-3.31', '-3.41', '-3.51', '-3.61', '-3.71', '-3.81', '-3.91', '0'};
classesstr = {'21', '31', '41', '51', '61', '71', '81', '91', '101'};
classnum = [21,31,41,51,61,71,81,91,101];
PCAM =0.95; MetricL2 = 0;
crangeMLR = [10];
crangeSVM = [0.0157, 0.0313, 0.0625, 0.1250, 2, 32, 512, 1024];
cd 'D:\MinTan\project\Signdetect\SignClassify';
dir = [dir, str, '\'];
if ~exist(dir) mkdir(dir); end
resultN = [];CbestVV = [];
crange = crangeMLR;
pcarange = 0.95;winit = 1;
Ntype = 1;
N = (9+Ntype);
i = 0; result2 = [];ranktime = [];
for jj = pcarange
    for ii = crange
        for tt = 1:length(classes);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = GetRecogRate_32(dataset, str, featurestr,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
        end
    end
end