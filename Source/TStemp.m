dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; str = 'N_GTSRB_NewTemplate';name = [name, str];
classes = {'0'};classesstr = {'43'};classnum = [43];winit = 1;

i = 0;clear 'resultt';pcarange = 0.95;
crange = [512, 1024, 1536, 2048];
N = 2;
for jj = pcarange
    for ii = crange
        for tt = 1:length(classes);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[1], {1},1,0,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
        end
    end
end
result = (reshape(resultt, [N, length(classes)*length(crange)]))';
result= reshape(result, [length(classes), length(crange), size(result, 2)]);
[result,Cbest] = max(result, [], 2);
result = reshape(result, [size(result, 1), size(result, 3)]);
Cbest = reshape(Cbest, [size(Cbest, 1), size(Cbest, 3)]);
fprintf('The Best choise of C under with differnt class and method\n')
CbestVV = crange(Cbest);

CbestV = CbestVV(:, 1);
i = 0;clear 'resultt'
for tt = 1:length(classes);
    ii = CbestV(tt);
    i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[1], {1},1,0,1,1);
end
result(:, end+1) = resultt(:);CbestVV(:,end+1) = CbestV;


resultt = []; i = 0;
pcarange = 0.95;N = 4;
for jj = pcarange
    for ii = crange
        for tt = 1:length(classes);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [1], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[1], {1},1,0,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [3], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[1], {1},1,0,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [10], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[1], {1},1,0,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [20], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[1], {1},1,0,0,1);
        end
    end
end
resultt = (reshape(resultt, [N, length(classes)*length(crange)]))';
resultt= reshape(resultt, [length(classes), length(crange), size(resultt, 2)]);
[resultt,Cbest] = max(resultt, [], 2);
resultt = reshape(resultt, [size(resultt, 1), size(resultt, 3)]);
Cbest = reshape(Cbest, [size(Cbest, 1), size(Cbest, 3)]);
fprintf('The Best choise of C under with differnt class and method\n')
Vbaset = crange(Cbest);
result(:, end+1:end+size(resultt, 2)) = resultt;CbestVV(:,end+1:end+size(Vbaset, 2)) = Vbaset;




resultt = []; i = 0;
pcarange = 0.95;N = 4;
for jj = pcarange
    for ii = crange
        for tt = 1:length(classes);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [1], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[5], {1},1,0,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [3], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[5], {1},1,0,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [10], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[5], {1},1,0,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [20], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[5], {1},1,0,0,1);
        end
    end
end
resultt = (reshape(resultt, [N, length(classes)*length(crange)]))';
resultt= reshape(resultt, [length(classes), length(crange), size(resultt, 2)]);
[resultt,Cbest] = max(resultt, [], 2);
resultt = reshape(resultt, [size(resultt, 1), size(resultt, 3)]);
Cbest = reshape(Cbest, [size(Cbest, 1), size(Cbest, 3)]);
fprintf('The Best choise of C under with differnt class and method\n')
Vbaset = crange(Cbest);
result(:, end+1:end+size(resultt, 2)) = resultt;CbestVV(:,end+1:end+size(Vbaset, 2)) = Vbaset;




resultt = []; i = 0;
pcarange = 0.95;N = 4;
for jj = pcarange
    for ii = crange
        for tt = 1:length(classes);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [1], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [3], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [10], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [20], [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
        end
    end
end
resultt = (reshape(resultt, [N, length(classes)*length(crange)]))';
resultt= reshape(resultt, [length(classes), length(crange), size(resultt, 2)]);
[resultt,Cbest] = max(resultt, [], 2);
resultt = reshape(resultt, [size(resultt, 1), size(resultt, 3)]);
Cbest = reshape(Cbest, [size(Cbest, 1), size(Cbest, 3)]);
fprintf('The Best choise of C under with differnt class and method\n')
Vbaset = crange(Cbest);
result(:, end+1:end+size(resultt, 2)) = resultt;CbestVV(:,end+1:end+size(Vbaset, 2)) = Vbaset;


resultt = []; i = 0;
pcarange = 0.95;N = 4;
for jj = pcarange
    for ii = crange
        for tt = 1:length(classes);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [1]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [3]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [10]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [20]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
        end
    end
end
resultt = (reshape(resultt, [N, length(classes)*length(crange)]))';
resultt= reshape(resultt, [length(classes), length(crange), size(resultt, 2)]);
[resultt,Cbest] = max(resultt, [], 2);
resultt = reshape(resultt, [size(resultt, 1), size(resultt, 3)]);
Cbest = reshape(Cbest, [size(Cbest, 1), size(Cbest, 3)]);
fprintf('The Best choise of C under with differnt class and method\n')
Vbaset = crange(Cbest);
result(:, end+1:end+size(resultt, 2)) = resultt;CbestVV(:,end+1:end+size(Vbaset, 2)) = Vbaset;



resultt = []; i = 0;
pcarange = 0.95;N = 2;
for jj = pcarange
    for ii = crange
        for tt = 1:length(classes);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [0]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,4,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,2,1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('TSR', '_GTSRB', 'HOG_02',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [0]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,0,0,'','',0,0,0,0.5,0,'',0,2,[],0,1,{{0.95, 'LDA', 1, 1}},0,0,20,0,[1], {1},1,0,2,1);
      end
    end
end
resultt = (reshape(resultt, [N, length(classes)*length(crange)]))';
resultt= reshape(resultt, [length(classes), length(crange), size(resultt, 2)]);
[resultt,Cbest] = max(resultt, [], 2);
resultt = reshape(resultt, [size(resultt, 1), size(resultt, 3)]);
Cbest = reshape(Cbest, [size(Cbest, 1), size(Cbest, 3)]);
fprintf('The Best choise of C under with differnt class and method\n')
Vbaset = crange(Cbest);
result(:, end+1:end+size(resultt, 2)) = resultt;CbestVV(:,end+1:end+size(Vbaset, 2)) = Vbaset;

% TS = {'MLR', 'WSMLR',  'MLR_A', 'MLR_1', 'MLR_3', 'MLR_10', 'MLR_20', 'WSMLR_1', 'WSMLR_3', 'WSMLR_10', 'WSMLR_20', 'WSMLR_1_S', 'WSMLR_3_S', 'WSMLR_10_S', 'WSMLR_20_S', 'MLR_C', 'WSMLR_C'};
TS = {'T', 'T',  'A', '1', '3', '10', '20', '1(5)', '3(5)', '10(5)', '20(5)', '1_S', '3_S', '10_S', '20_S', '1', '3', '10', '20', 'C', 'C'};


% index = [1, 4:7, 12, 3];
index = [1, 4:11, 3];
plotFigC(classnum, result(:, index), TS(index), ['MLR_TEMP', str], 'MLR-Method', ...
    'Per-image accuracy', 0, dir, 'SouthWest', 1);


% index = [2, 8:11, 13];
% index = [2, 8:15];
index = [2, 12:19];
plotFigC(classnum, result(:, index), TS(index), ['WSMLR_TEMP', str], 'WSMLR-Method', ...
    'Per-image accuracy', 0, dir, 'SouthWest', 1);