dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others';
dataset = 'TSR';str = '_BTSRB';Config = 'sphog';name = [name, str];
crangeMLR = [32, 128, 512, 1024, 1536, 2048, 20480 40960, 61440, 81920, 102400];
crangeMLR = crangeMLR(1:2:end);
crangeSVM = [0.0157, 0.0313, 0.0625, 0.1250, 2, 32, 512];
cConfig = {'Pixel', 'sphog', 'PixelM', 'sphogM', 'Pixel1', 'sphog1', 'PixelM1', 'sphogM1'};
cDOGfig = {'','', '','', '','', '',''};
cimsize = {[28, 28], [28, 28], [28, 28], [28, 28],[28, 28], [28, 28], [28, 28], [28, 28]};
cnpyra = {0, 0, 0, 0,0, 0, 0, 0};
classes = {'0'};classesstr = {'62'};classnum = [62];winit = 1;
PCAM ={{0.95, 'LDA', 1, 1}};
range = 2;
multiview = [3];  %%%norlization
MMulti = [0 3];
MID = 1;
BaseP = [0.9747 0.9767];
clear 'resultB1';clear 'resultB';
resultB1 = cell(length(multiview), length(cDOGfig));
% % for ct = range
% % Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct};   imsize = cimsize{ct};
% % for mm = 1:length(MMulti)
% % i = 0;resultt = [];
% % for tt = 1:length(classes);
% % i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'KNN', {'1', classes{tt}}, {}, 1, 0, imsize, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20, 0, 1, {1}, 0, 0, 0, 1);
% % i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'INNC', {'1', classes{tt}}, 0.05, 1, 0, imsize, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20, 0, 1, {1}, 0, 0, 0, 1);
% % i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'KNN', {'1', classes{tt}}, {}, 1, 0, imsize, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20, 0, 1, {1}, 0, 0, 11, 1);
% % i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'INNC', {'1', classes{tt}}, 0.05, 1, 0, imsize, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20, 0, 1, {1}, 0, 0, 11, 1);
% % end
% % resultB1{mm, ct} = resultt;
% % end
% % end
% % BaseP
% % dis = resultB1{MID, range}(3:4) - BaseP
% % resultB = cell(length(MMulti), length(cDOGfig));
for ct = range
Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct};
kkki = 0;
for kkk = MMulti
kkki = kkki + 1;
i = 0;clear 'resultt';pcarange = 0.95;
crange = crangeMLR;N = 10;
for jj = pcarange
for ii = crange
for tt = 1:length(classes);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20,0,[1], {1},1,0,0,1);
end
end
end
resultN = max(resultt);
for mm = 1:length(multiview)
i = 0;clear 'resultt';pcarange = 0.95;
crange = crangeMLR;
for jj = pcarange
for ii = crange
for tt = 1:length(classes);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {0.3,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {0.4,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {0.5,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {0.8,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {3,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {4,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {5,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {8,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
end
end
end
result = (reshape(resultt, [], length(classes)*length(crange)))';
result= reshape(result, [length(classes), length(crange), size(result, 2)]);
[result,Cbest] = max(result, [], 2);
result = reshape(result, [size(result, 1), size(result, 3)]);
Cbest = reshape(Cbest, [size(Cbest, 1), size(Cbest, 3)]);
[result, idx] = max(result);
Cbest = Cbest(idx);
resultN = [resultN, result];
fprintf('The Best choise of C under with differnt class and method\n')
CbestVV = crange(Cbest);
i = 0;resultt = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 1;
N = (Nnum+Ntype);jj = pcarange;
for tt = 1:length(classes);
for ii = CbestVV(tt, 1)
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {0.3,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {0.4,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {0.5,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {0.8,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {3,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {4,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {5,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {8,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
end
end
resultN = [resultN, max(resultt)];
end
resultB{kkki, ct} = resultN;
end
end
resultB1 = resultB1(:, range);
resultB = resultB(:, range);
for i = 1:length(range)
[cell2mat(resultB1(:, i)), cell2mat(resultB(:, i))]
end