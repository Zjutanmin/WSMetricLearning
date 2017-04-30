dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; str = 'N_GTSRB_dog_py';name = [name, str];
classes = {'0'};classesstr = {'43'};classnum = [43];winit = 1;


load('GBresult', 'result', 'n1', 'CbestVV');
index = [n1+2, n1+4, 2, 1];
result = result(:, index);
CbestVV = CbestVV(:, index);

% result = [zeros(length(classes), 2), result(:, [2, 1])];
% CbestVV = [zeros(length(classes), 2), CbestVV(:, [2, 1])];

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
resultt = reshape(resultt, [length(crange), length(pcarange)*length(classes)]);
[resultt, idx] = max(resultt, [], 1);Cbest = crange(idx);
result = [result, resultt(:)];CbestVV = [CbestVV, Cbest(:)];


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
resultt1 = resultt(1:2:end);resultt2 = resultt(2:2:end);
resultt = reshape(resultt1, [length(crange)*length(krange), length(classes)]);
[resultt, idx] = max(resultt, [], 1);
[idx1, idx2] = ind2sub([length(crange), length(krange)], idx);
Cbest = crange(idx1);kbest = krange(idx2);

fprintf('The Best choise of C under with differnt class and method INN-T\n')
Cbest
fprintf('The Best choise of K under with differnt class and method INN-T\n')
kbest
result = [result, resultt(:)];CbestVV = [CbestVV, Cbest(:)];

resultt = reshape(resultt2, [length(crange)*length(krange), length(classes)]);
[resultt, idx] = max(resultt, [], 1);
[idx1, idx2] = ind2sub([length(crange), length(krange)], idx);
Cbest = crange(idx1);kbest = krange(idx2);

fprintf('The Best choise of C under with differnt class and method MLR-T\n')
Cbest
fprintf('The Best choise of K under with differnt class and method MLR-T\n')
kbest
result = [result, resultt(:)];CbestVV = [CbestVV, Cbest(:)];
resultT = result;CbestVVT = CbestVV;


i = 0;resultt = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 18;
N = (Nnum+Ntype);jj = pcarange;
for tt = 1:length(classes);
    for kk = (krange)
        for ii = crange
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
        end
    end
end 
resultt = reshape(resultt, [N*length(crange)*length(krange), length(classes)]);
[resultt, idx] = max(resultt, [], 1);
[idx1, idx2, idx3] = ind2sub([N, length(crange), length(krange)], idx);
kbest = krange(idx3);cbest = crange(idx2);BestThresh = mod(idx1, 9);BestNorm = ceil(idx1/ 9);
fprintf('The Best choise of C under with differnt class and method WSMLR*-T-K\n')
Cbest
fprintf('The Best choise of K under with differnt class and method WSMLR*-T-K\n')
kbest
fprintf('The Best choise of BestThresh under with differnt class and method WSMLR*-T-K\n')
BestThresh
fprintf('The Best choise of BestNorm under with differnt class and method WSMLR*-T-K\n')
BestNorm
result = [result, resultt(:)];CbestVV = [CbestVV, Cbest(:)];


  
i = 0;result2 = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 36;
N = (Nnum+Ntype);jj = pcarange;

for tt = 1:length(classes);
    for kk = (krange)
        for ii = crange
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
        end
    end
end
resultt = reshape(resultt, [N*length(crange)*length(krange), length(classes)]);
[resultt, idx] = max(resultt, [], 1);
[idx1, idx2, idx3] = ind2sub([N, length(crange), length(krange)], idx);
kbest = krange(idx3);cbest = crange(idx2);BestThresh = mod(idx1, 9);BestNormT = mod(ceil(idx1/ 9), 2);BestNorm = ceil(ceil(idx1/ 9) /2);
fprintf('The Best choise of C under with differnt class and method WSMLR*-T-K-INNC\n')
Cbest
fprintf('The Best choise of K under with differnt class and method WSMLR*-T-K-INNC\n')
kbest
fprintf('The Best choise of BestThresh under with differnt class and method WSMLR*-T-K-INNC\n')
BestThresh
fprintf('The Best choise of BestNorm under with differnt class and method WSMLR*-T-K-INNC\n')
BestNorm
fprintf('The Best choise of BestNormT under with differnt class and method WSMLR*-T-K-INNC\n')
BestNormT
result = [result, resultt(:)];CbestVV = [CbestVV, Cbest(:)];



i = 0;resultt = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 9;
N = (Nnum+Ntype);jj = pcarange;
for tt = 1:length(classes);
    for ii = CbestVV(tt, 4)
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
        end
end 
resultt = reshape(resultt, [N, length(classes)]);
[resultt, idx] = max(resultt, [], 1);
[idx1, idx2] = ind2sub([N, length(krange)], idx);
kbest = krange(idx2);BestThresh = mod(idx1, 9);
fprintf('The Best choise of K under with differnt class and method WSMLR*\n')
kbest
fprintf('The Best choise of BestThresh under with differnt class and method WSMLR*\n')
BestThresh
result = [result, resultt(:)];CbestVV = [CbestVV, Cbest(:)];


% % % org TS
% % % TS = {'KNN', 'INN', 'MLR', 'WSMLR', 'MLR*', 'INN-T', 'MLR*-T', 'WSMLR*-T-K', 'WSMLR*-T-INNC'};
TS = {'KNN', 'MLR', 'WSMLR', 'INNC', 'MLR*','WSMLR*'};
index = [1, 3, 4, 2, 5, 10];
plotFigC(classnum, result(:, index), TS, ['Class_KNNsearch', str], 'Number of Categories', ...
    'Per-class accuracy', 0, dir, 'SouthWest', 1);

TS = {'INN', 'MLR*', 'WSMLR*','INN-T', 'MLR*-T',  'WSMLR*-T-K', 'WSMLR*-T-INNC'};
index = [2, 5, 10, 6, 7, 8, 9];
plotFigC(classnum, result(:, index), TS, ['Class_Pototype', str], 'Number of Categories', ...
    'Per-class accuracy', 0, dir, 'SouthWest', 1);

load('GBresult', 'result', 'n1', 'CbestVV');
index = [4, 5,  n1+2, 6, n1+1, 2, n1+6,1];
GBresult1 = result(:, index);
save('GBresult1', 'GBresult1');
TS = {'LSVM', 'KSVM','INN',  'LMNN', 'gbLMNN', 'MLR*', 'MIKSVM', 'WSMLR*', 'WSMLR*-T-K', 'WSMLR*-T-INNC'};
Oresult = [GBresult1(:, [1:2]), result(:, 2), GBresult1(:, [4:5]), result(:, 5), GBresult1(:, [7]), result(:, [10, 8, 9])];
plotFigC(classnum, Oresult, TS, ['Class_Overall', str], 'Number of Categories', ...
    'Per-class accuracy', 0, dir, 'SouthWest', 1);