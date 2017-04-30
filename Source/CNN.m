clear all;
i = 0;
classes = {'-3.13', '-3.20', '-3.26', '-3.33', '-3.39', '-3.46', '0'};
pcarange = 0.95;winit = 1;
for tt = 1:length(classes);
i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, result2(i), ranktime(i), ] = GetRecogRate_3('Sign', '_NewT5', 'cHoG_1',{'sift'},'CNN', {'1',classes{tt}}, {}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,0.95,0,0,20, 0, 1, {1}, 1);
end
result= result2;