% % clear all
name = 'Class-others'; 
[str,dataset, featurestr, VSNIPPET, classes, classesstr, classnum, ...
    crangeMLR, crangeSVM, strThresh, ratio, row, col, kkrange, outdim, ntree] = GetSetting(str);

dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
load('D:\MinTan\project\Signdetect\SignClassify\MSresult', 'result', 'n1', 'CbestVV');
Bresult = result;Bn1 = n1;BCbestVV= CbestVV;

load(['MSresult' str VSNIPPET{3}], 'result', 'n1', 'CbestVV');
legend = {'WSMLR', 'MLR', 'LSVM', 'KSVM',  'CNN', 'LMNN'};n1 = length(legend);
legendN = {'gblmnn', '1-NN', 'KNN-A', 'INNC', 'INNC-A','MLR-A', 'MIL'};

TS = {'1-NN', 'KNN-A','MLR', 'MLR-A'};
index = [n1+2, n1+3, 2, n1+6];
plotFigC(classnum, result(:, index), TS, ['Class_Template', str VSNIPPET{3}], 'Number of Categories', ...
    'Per-class accuracy', 0, dir, 'SouthWest', 1);


TS = {'LSVM', 'KSVM','CNN', 'INNC', 'INNC-A',  'LMNN', 'gbLMNN', 'MLR', 'MIL', 'WSMLR', 'WSMLR*'};
index = [3, 4, 5, n1+4, n1+5, 6, n1+1, 2, n1+7,1, n1+8];

 range = [1:2,4:length(index)];
 plotFigC(classnum, result(:, index( range)), TS( range), ['Class_method', str, VSNIPPET{3}], 'Number of Categories', ...
    'Per-class accuracy', 0, dir, 'SouthWest', 1);

plotFigC(classnum, bsxfun(@minus, result(:, index( range(end))) ,...
    result(:, index( range([1:end-2])))), TS(range([1:end-2])), ['Class_method_dis', str, VSNIPPET{3}], 'Number of Categories', ...
    'Per-class accuracy', 0, dir, 'SouthWest', 1);

save(['MSresult' str VSNIPPET{3}], 'result', 'n1', 'CbestVV');
index = [3, 4, 5,n1+4, n1+5, 6, n1+1, 2, n1+7,1, n1+8];
MSresult1 = result(:, index);save(['MSresult1' str], 'MSresult1');
