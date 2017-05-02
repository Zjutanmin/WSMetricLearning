dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; str = '_NewT5';name = [name, str];
load(['D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\result\' name '-result.mat'], 'CbestV', 'result')
result3 = result;
classes = {'-3.13', '-3.20', '-3.26', '-3.33', '-3.39', '-3.46', '0'};
classesstr = {'13', '20', '26', '33', '39', '46', '52'};
classnum = [13, 20, 26, 33, 39, 46, 52];
crange = [0.1250, 2, 32, 512];
pcarange = 0.95;winit = 1;
CbestVV = CbestV;

resultt = [];i = 0;
for tt = 1:length(classes);
%     i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'KNN', {'1', classes{tt}}, {}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,0.95,0,0,20, 0, 1, {1}, 1, 0);
%     i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'KNN', {'1', classes{tt}}, {}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,0.95,0,0,20, 0, 1, {1}, 1, 0, 1);
    i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'INNC', {'1', classes{tt}}, 0.05, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,0.95,0,0,20, 0, 1, {1}, 1, 0);
    i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'INNC', {'1', classes{tt}}, 0.05, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,0.95,0,0,20, 0, 1, {1}, 1, 0, 1);
end
% xx = [    0.9721    0.9557    0.9475    0.9243    0.9093    0.8929    0.8756
%     0.9976    0.9970    0.9957    0.9881    0.9840    0.9822    0.9791];

i = 0;resultt = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 9;
N = (Nnum+Ntype);jj = pcarange;
for tt = 1:length(classes);
    for ii = CbestVV(tt, 4)
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
        end
end 
% xx = [
%     0.9930    0.9969    0.9964    0.9923    0.9920    0.9886    0.9865
%     0.9930    0.9969    0.9964    0.9927    0.9935    0.9878    0.9866
%     0.9930    0.9969    0.9964    0.9929    0.9928    0.9880    0.9881
%     0.9930    0.9969    0.9964    0.9927    0.9929    0.9885    0.9865
%     0.9930    0.9969    0.9964    0.9921    0.9920    0.9886    0.9865
%     0.9930    0.9969    0.9964    0.9927    0.9935    0.9884    0.9872
%     0.9930    0.9969    0.9964    0.9927    0.9933    0.9885    0.9861
%     0.9930    0.9969    0.9964    0.9929    0.9928    0.9891    0.9865
%     0.9930    0.9969    0.9964    0.9921    0.9928    0.9886    0.9865];


dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; str = '_NewT5';name = [name, str];
load(['D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\result\' name '-result.mat'], 'CbestV', 'result')
result3 = result;
classes = {'-3.13', '-3.20', '-3.26', '-3.33', '-3.39', '-3.46', '0'};
classesstr = {'13', '20', '26', '33', '39', '46', '52'};
classnum = [13, 20, 26, 33, 39, 46, 52];
cd 'D:\MinTan\project\Signdetect\SignClassify';
load('MSresult', 'result', 'n1', 'CbestVV');
index = [n1+2, n1+4, 2, 1];
result = result(:, index);
CbestVV = CbestVV(:, index);

krange = [1, 3, 10, 20];
crange = [0.1250, 2, 32, 512];
pcarange = 0.95;winit= 1;
crange = crange(1);

i = 0;resultt = [];
for jj = pcarange
        for tt = 1:length(classes);
                for ii = CbestVV(tt, 3);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20,0,1, {1},1);
            end
        end
end
resultt = reshape(resultt, [length(crange), length(pcarange)*length(classes)]);
[resultt, idx] = max(resultt, [], 1);Cbest = crange(idx);
result = [result, resultt(:)];CbestVV = [CbestVV, Cbest(:)];
% xx = [ 0.9837    0.9895    0.9929    0.9876    0.9853    0.9834    0.9808];

i = 0;resultt = [];
for tt = 1:length(classes);
jj = pcarange;
    for kk = (krange)
        
%             for ii = crange
                for ii = CbestVV(tt, 3);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20,0,[1 0], {1},1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20,0,[1], {1},1);
            end
        end
end
% xx = [
%     0.9928    0.9798    0.9787    0.9600    0.9477    0.9289    0.9158
%     0.9966    0.9978    0.9984    0.9906    0.9856    0.9828    0.9775
%     0.9888    0.9839    0.9789    0.9572    0.9456    0.9307    0.9265
%     0.9974    0.9969    0.9963    0.9875    0.9824    0.9766    0.9772
%     0.9838    0.9892    0.9897    0.9779    0.9662    0.9553    0.9454
%     0.9974    0.9986    0.9975    0.9881    0.9866    0.9825    0.9790
%     0.9928    0.9945    0.9896    0.9858    0.9718    0.9631    0.9539
%     0.9974    0.9978    0.9972    0.9896    0.9861    0.9835    0.9821];


dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; str = '_NewT5';name = [name, str];
load(['D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\result\' name '-result.mat'], 'CbestV', 'result')
result3 = result;
classes = {'-3.13', '-3.20', '-3.26', '-3.33', '-3.39', '-3.46', '0'};
classesstr = {'13', '20', '26', '33', '39', '46', '52'};
classnum = [13, 20, 26, 33, 39, 46, 52];
cd 'D:\MinTan\project\Signdetect\SignClassify';
load('MSresult', 'result', 'n1', 'CbestVV');
index = [n1+2, n1+4, 2, 1];
result = result(:, index);
CbestVV = CbestVV(:, index);

krange = [1, 3, 10, 20];
crange = [0.1250, 2, 32, 512];
pcarange = 0.95;winit= 1;
crange = crange(1);
i = 0;resultt = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 36;
N = (Nnum+Ntype);jj = pcarange;
for tt = 1:length(classes);
    for kk = (krange)
%             for ii = crange
                for ii = CbestVV(tt, 4);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            
            
            
            
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [2]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
        end
    end
end 


 
dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; str = '_NewT5';name = [name, str];
load(['D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\result\' name '-result.mat'], 'CbestV', 'result')
result3 = result;
classes = {'-3.13', '-3.20', '-3.26', '-3.33', '-3.39', '-3.46', '0'};
classesstr = {'13', '20', '26', '33', '39', '46', '52'};
classnum = [13, 20, 26, 33, 39, 46, 52];
cd 'D:\MinTan\project\Signdetect\SignClassify';
load('MSresult', 'result', 'n1', 'CbestVV');
index = [n1+2, n1+4, 2, 1];
result = result(:, index);
CbestVV = CbestVV(:, index);

krange = [1, 3, 10, 20];
crange = [0.1250, 2, 32, 512];
pcarange = 0.95;winit= 1;
crange = crange(1); 
i = 0;result2 = [];
Ntype = 0;
pcarange = 0.95;winit= 1;
Nnum = 36;
N = (Nnum+Ntype);jj = pcarange;

for tt = 1:length(classes);
    for kk = (krange)
%             for ii = crange
                for ii = CbestVV(tt, 4);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [1]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {0.8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {3,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {4,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {5,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], {[0.05], [3]}}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,winit,[1,5,1,0,1], {8,[],22404,10, 'Norm',0,1,1, 'NA', 'max2'},1,1);
        end
    end
end
