% clear all;
fdir = '_NewT7-20-4-T2D';featurestr = 'cHoG_1_color24_0';
pca = 0.95;i = 0;result2 = [];ranktime = [];
pcarange = 0.95;jj = pcarange;
i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, Temp1, ranktime1, ] = GetRecogRate_3('Sign', fdir, featurestr,{'sift'},'KNN', 1, {}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20, 0, 1, {1});
i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, Temp2, ranktime2, ]= GetRecogRate_3('Sign', fdir, featurestr,{'sift'},'KNN', 1, {}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20, 0, 1, {1},0, 0, 0, 0, 1, 0, 0, [0.4]);
i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, Temp3, ranktime3, ] = GetRecogRate_3('Sign', fdir, featurestr,{'sift'},'KNN', 1, {}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20, 0, 1, {1},0, 0, 0, 0, 1, 0, 0, [0.2:0.2:1]);