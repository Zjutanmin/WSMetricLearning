dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; str = 'N_GTSRB_dog_py';name = [name, str];
classes = {'0'};classesstr = {'43'};classnum = [43];winit = 1;
resultt = [];i = 0;
for tt = 1:length(classes);
%     i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'KNN', {'1', classes{tt}}, {}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20, 0, 1, {1},1,0,0,1);
%     i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'KNN', {'1', classes{tt}}, {}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20, 0, 1, {1},1,0,1,1);
    i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'INNC', {'1', classes{tt}}, 0.05, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20, 0, 1, {1},1,0,0,1);
    i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'INNC', {'1', classes{tt}}, 0.05, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20, 0, 1, {1},1,0,1,1);
end
% 0.9609    0.9807

CbestVV  = [  0           0        1536 2048];
i = 0;resultt = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 1;
N = (Nnum+Ntype);jj = pcarange;
for tt = 1:length(classes);
    for ii = CbestVV(tt, 4)
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
        end
end 
% 0.9676


dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; str = 'N_GTSRB_dog_py';name = [name, str];
classes = {'0'};classesstr = {'43'};classnum = [43];winit = 1;
cd 'D:\MinTan\project\Signdetect\SignClassify';
load('GBresult', 'result', 'n1', 'CbestVV');
index = [n1+2, n1+4, 2, 1];
result = result(:, index);
CbestVV = CbestVV(:, index);

krange = [1, 3, 10, 20];
crange = [512, 1024, 1536, 2048];
crange = [2048];
pcarange = 0.95;winit= 1;

i = 0;resultt = [];
for jj = pcarange
        for tt = 1:length(classes);
            for ii = crange
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,1, {1},1,0,0,1);
            end
        end
end
% 0.9680


i = 0;resultt = [];
for tt = 1:length(classes);
jj = pcarange;
    for kk = (krange)
        
            for ii = crange
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[1 0], {1},1,0,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[1], {1},1,0,0,1);
            end
        end
end
% resultt =[   0.9698    0.9725    0.9713    0.9705    0.9705    0.9704    0.9734    0.9728]



dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; str = 'N_GTSRB_dog_py';name = [name, str];
classes = {'0'};classesstr = {'43'};classnum = [43];winit = 1;
cd 'D:\MinTan\project\Signdetect\SignClassify';
load('GBresult', 'result', 'n1', 'CbestVV');
index = [n1+2, n1+4, 2, 1];
result = result(:, index);
CbestVV = CbestVV(:, index);

krange = [1, 3, 10, 20];
crange = [512, 1024, 1536, 2048];
crange = [2048];
pcarange = 0.95;winit= 1;
i = 0;resultt = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 32;
N = (Nnum+Ntype);jj = pcarange;
for tt = 1:length(classes);
    for kk = (krange)
            for ii = crange
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
        
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.1], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.1], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);

            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.25]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.25], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.25]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.25], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);

            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.5]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.5], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.5]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.5], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);

            
            
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22440,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22440,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);



            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, kk]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, kk], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, kk]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, kk], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, kk]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, kk], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);

            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, 3]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, 3], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, 3]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, 3], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, 3]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, 3], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
        
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, -1, -1, 0, -1, 0.7]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, -1, -1, 0, -1, 0.7], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, -1, -1, 0, -1, 0.7]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, -1, -1, 0, -1, 0.7], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, -1, -1, 0, -1, 0.7]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, -1, -1, 0, -1, 0.7], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, -1, -1, 0, -1, 0.5]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, -1, -1, 0, -1, 0.5], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, -1, -1, 0, -1, 0.5]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, -1, -1, 0, -1, 0.5], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05, -1, -1, 0, -1, 0.5]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
%             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05, -1, -1, 0, -1, 0.5], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
        
            end
    end
end 
% resultt = 
% [   0.9726    0.9650    0.9634    0.9660
%     0.9726    0.9614    0.9627    0.9650
%     0.9723    0.9605    0.9637    0.9630
%     0.9732    0.9636    0.9603    0.9626
%     0.9732    0.9648    0.9631    0.9656
%     0.9732    0.9610    0.9634    0.9656
%     0.9728    0.9604    0.9633    0.9629
%     0.9732    0.9634    0.9599    0.9617
%     0.9721    0.9641    0.9625    0.9652
%     0.9721    0.9607    0.9625    0.9646
%     0.9721    0.9603    0.9628    0.9622
%     0.9734    0.9618    0.9596    0.9613
%     0.9715    0.9625    0.9602    0.9639
%     0.9715    0.9587    0.9603    0.9625
%     0.9718    0.9596    0.9585    0.9589
%     0.9716    0.9589    0.9573    0.9580
%     0.9721    0.9629    0.9613    0.9651
%     0.9721    0.9583    0.9613    0.9644
%     0.9717    0.9572    0.9580    0.9599
%     0.9718    0.9580    0.9559    0.9595
%     0.9721    0.9629    0.9600    0.9641
%     0.9721    0.9583    0.9606    0.9625
%     0.9718    0.9572    0.9576    0.9573
%     0.9721    0.9580    0.9553    0.9573
%     0.9726    0.9639    0.9627    0.9651
%     0.9726    0.9603    0.9627    0.9644
%     0.9724    0.9589    0.9610    0.9614
%     0.9728    0.9615    0.9587    0.9592
%     0.9725    0.9636    0.9627    0.9652
%     0.9725    0.9587    0.9615    0.9642
%     0.9727    0.9580    0.9588    0.9595
%     0.9726    0.9592    0.9583    0.9587]

result = reshape(resultt, [N*length(krange), 1]);
[result, idx] = max(result, [], 1);

i = 0;resultt = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 32;
N = (Nnum+Ntype);jj = pcarange;
lrange = [0.1:0.05:0.5];
for tt = 1:length(classes);
    for kk = (krange)
            for ii = crange
            for ll = lrange
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [ll]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[ll], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [ll]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[ll], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            end
            end
    end
end 
result = reshape(resultt, [N*length(krange), 1]);
% xx = [
%     0.9732    0.9648    0.9631    0.9656
%     0.9732    0.9610    0.9634    0.9656
%     0.9728    0.9604    0.9633    0.9629
%     0.9732    0.9634    0.9599    0.9617
%     0.9728    0.9642    0.9627    0.9656
%     0.9728    0.9603    0.9629    0.9652
%     0.9724    0.9602    0.9633    0.9629
%     0.9734    0.9632    0.9600    0.9622
%     0.9736    0.9643    0.9625    0.9655
%     0.9736    0.9603    0.9623    0.9649
%     0.9733    0.9604    0.9630    0.9618
%     0.9731    0.9623    0.9595    0.9610
%     0.9721    0.9641    0.9625    0.9652
%     0.9721    0.9607    0.9625    0.9646
%     0.9721    0.9603    0.9628    0.9622
%     0.9734    0.9618    0.9596    0.9613
%     0.9723    0.9637    0.9625    0.9652
%     0.9723    0.9598    0.9620    0.9644
%     0.9717    0.9595    0.9622    0.9621
%     0.9718    0.9611    0.9591    0.9610
%     0.9722    0.9647    0.9629    0.9643
%     0.9722    0.9590    0.9622    0.9644
%     0.9723    0.9603    0.9604    0.9614
%     0.9721    0.9612    0.9593    0.9604
%     0.9726    0.9633    0.9618    0.9633
%     0.9726    0.9588    0.9616    0.9633
%     0.9721    0.9598    0.9609    0.9606
%     0.9721    0.9603    0.9585    0.9598
%     0.9720    0.9629    0.9604    0.9640
%     0.9720    0.9588    0.9611    0.9626
%     0.9718    0.9604    0.9595    0.9594
%     0.9713    0.9591    0.9581    0.9599
%     0.9715    0.9625    0.9602    0.9639
%     0.9715    0.9587    0.9603    0.9625
%     0.9718    0.9596    0.9585    0.9589
%     0.9716    0.9589    0.9573    0.9580];    



dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; str = 'N_GTSRB_dog_py';name = [name, str];
classes = {'0'};classesstr = {'43'};classnum = [43];winit = 1;
cd 'D:\MinTan\project\Signdetect\SignClassify';
load('GBresult', 'result', 'n1', 'CbestVV');
index = [n1+2, n1+4, 2, 1];
result = result(:, index);
CbestVV = CbestVV(:, index);

krange = [1, 3, 10, 20];
crange = [512, 1024, 1536, 2048];
crange = [2048];
pcarange = 0.95;winit= 1;
i = 0;resultt = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 12;
N = (Nnum+Ntype);jj = pcarange;
for tt = 1:length(classes);
    for kk = (krange)
            for ii = crange
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [1], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [1], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [3], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [3], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
        
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'KNN', -2, 1, 0, 1, 3}, [kk], [1, 0, -1], [1], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'KNN', -2, 1, 0, 1, 3}, [kk], [1, 0, -1], [3], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);


             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.01], 1}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.01], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            end
    end
end
resultt = reshape(resultt, [N, length(krange)])
% rr = [    0.9728    0.9637    0.9622    0.9649
%     0.9728    0.9621    0.9626    0.9649
%     0.9726    0.9654    0.9641    0.9649
%     0.9726    0.9651    0.9627    0.9612
%     0.9728    0.9632    0.9615    0.9668
%     0.9728    0.9629    0.9636    0.9680
%     0.9162    0.9258    0.9521    0.9504
%     0.9155    0.9316    0.9537    0.9551
%     0.9720    0.9371    0.8366    0.8181
%     0.9724    0.9618    0.9458    0.9566
%          0         0         0         0
%          0         0         0         0
%     0.9720    0.9371    0.8366    0.8577
%     0.9724    0.9614    0.9443    0.9560];

i = 0;resultt = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 32;
N = (Nnum+Ntype);jj = pcarange;
lrange = [0.1:0.1:0.5];
for tt = 1:length(classes);
    for kk = (krange)
            for ii = crange
            for ll = lrange
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[ll], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[ll], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22441,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[ll], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[ll], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            end
            end
    end
end
result = reshape(resultt, [length(lrange)*length(krange), 1]);
% xx = [    0.9732         0         0         0
%     0.9732         0         0         0
%     0.9728         0         0         0
%     0.9729         0         0         0
%     0.9737         0         0         0
%     0.9737         0         0         0
%     0.9732         0         0         0
%     0.9732         0         0         0
%     0.9724         0         0         0
%     0.9724         0         0         0
%     0.9717         0         0         0
%     0.9717         0         0         0
%     0.9725         0         0         0
%     0.9725         0         0         0
%     0.9721         0         0         0
%          0         0         0         0
%          0         0         0         0
%          0         0         0         0
%          0         0         0         0
%          0         0         0         0];