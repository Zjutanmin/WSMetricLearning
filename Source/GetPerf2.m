function [dis, dis2, Res] = GetPerf2(fdir1, index, rate, MetricL2, funE, DELCOPY, type, Level, RRate)              
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
crange = [512];
pcarange = 0.95;winit = 1;
Ntype = 1;
N = (9+Ntype);
for jj = pcarange
    for ii = crange
        for tt = 1:length(classes);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = funName('Sign', fdir1, 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},0,1, 0, 1, 0, MetricL2);
            
        end
    end
end
dis= 0; dis2 = 0;Res = 0;