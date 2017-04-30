function [dis, dis2, Res] = GetPerf3(fdir1, index, rate, MetricL2, funE, DELCOPY, type, Level, RRate)              
if nargin < 2
    index = 3;
end
if nargin < 3
    rate = 0.2;
end
if nargin < 4
    MetricL2 = 0;
end
if nargin < 5
    funE = 0;
end
switch funE
    case 1
        funName = @GetRecogRate_31;
    case 0
        funName = @GetRecogRate_3;
    case 2
        funName = @GetRecogRate_32;  
end
if index
    fdir1 = [fdir1 '-' num2str(rate) '-' num2str(index)];
end

if nargin < 6
    DELCOPY = 1;
end
if nargin < 7
    type = 0;
end
if nargin < 8;
    Level = 3;
end
if nargin < 9;
    RRate = 0.8;
end

if type ~= 0
    fdir1 = [fdir1 '-T' num2str(type)];
end
if Level~= 3
    fdir1 = [fdir1 '-L' num2str(Level)];
end
if RRate~= 0.8
    fdir1 = [fdir1 '-R' num2str(RRate)];
end
if DELCOPY
    fdir1 = [fdir1 'D'];
end



% clear all;
i = 0;
classes = { '0'};
crange = [2, 32,  512, 1024, 1536, 2048];%%%%crange <
pcarange = 0.95;winit = 1;
Ntype = 1;
N = (9+Ntype);
for jj = pcarange
    for ii = crange
        for tt = 1:length(classes);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1, 0, 0, 0, MetricL2);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.3,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1, 0, 0, 0, MetricL2);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.4,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1, 0, 0, 0, MetricL2);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.5,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1, 0, 0, 0, MetricL2);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.8,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1, 0, 0, 0, MetricL2);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {3,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1, 0, 0, 0, MetricL2);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {4,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1, 0, 0, 0, MetricL2);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {5,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1, 0, 0, 0, MetricL2);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {8,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1, 0, 0, 0, MetricL2);
            
            i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'}, 'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20, 0, 1, {1}, 1,0, 0, 0, 0, MetricL2);
            
        end
    end
end
result = (reshape(result2, [N, length(classes)*length(crange)]))';
[tmp, BestThresh] = max(result(:, 1:9), [], 2);
result = [tmp,  result(:, 9+1:end)];
result= reshape(result, [length(classes), length(crange), size(result, 2)]);
[result,Cbest] = max(result, [], 2);
result = reshape(result, [size(result, 1), size(result, 3)]);
Cbest = reshape(Cbest, [size(Cbest, 1), size(Cbest, 3)]);
idx = sub2ind(([length(classes), length(crange)]),[1:length(classes)]', Cbest(:, 1));
BestThresh =BestThresh(idx);CbestV = crange(Cbest);
result1 = result;


crange = [0.0157, 0.0313, 0.0625, 0.1250, 2, 32, 512, 1024, 2048];
pcarange = 0.95;winit = 1;
Ntype = 2;i = 0;result2 = [];
N = (0+Ntype);
for jj = pcarange
    for ii = crange
        for tt = 1:length(classes);
            i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'}, 'MultiSVM', {'1',classes{tt}}, [ii,1,0], 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20, 0, 1, {1}, 1,0, 0, 0, 0, MetricL2);
            i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'}, 'MultiSVM', {'1',classes{tt}}, [ii,1,2], 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20, 0, 1, {1}, 1,0, 0, 0, 0, MetricL2);
        end
    end
end
result = (reshape(result2, [N, length(classes)*length(crange)]))';
[result, BestThresh] = max(result);
result2 = max(result);

dis = result1(1) - result1(2);
dis2 = result1(1) - result2;
Res = result1(1);



% % % %     0.9085    0.9114    0.9076    0.9065    0.9085    0.9101
% % % %     0.9217    0.9287    0.9242    0.9217    0.9217    0.9265
% % % %     0.9240    0.9311    0.9342    0.9296    0.9240    0.9324
% % % %     0.9231    0.9295    0.9301    0.9276    0.9231    0.9283
% % % %     0.9184    0.9233    0.9253    0.9253    0.9184    0.9235
% % % %     0.9184    0.9233    0.9253    0.9253    0.9184    0.9235
% % % % 
% % % %   Columns 7 through 10
% % % % 
% % % %     0.9065    0.9101    0.9085    0.8557
% % % %     0.9238    0.9207    0.9217    0.8780
% % % %     0.9309    0.9261    0.9240    0.8834
% % % %     0.9279    0.9242    0.9231    0.8834
% % % %     0.9220    0.9209    0.9184    0.8834
% % % %     0.9220    0.9209    0.9184    0.8834
% % % %     
% % % %     
% % % %     0.8427    0.0099
% % % %     0.8626    0.0099
% % % %     0.8742    0.0099
% % % %     0.8809    0.0099
% % % %     0.8829    0.7124
% % % %     0.8784    0.8783
% % % %     0.8784    0.8831
% % % %     0.8784    0.8821
% % % %     0.8784    0.8821