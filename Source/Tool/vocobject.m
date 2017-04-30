function result = vocobject(year, range, C, confile, yita0, thresh,...
    evaltype, imgsave)
addpath(genpath('D:\Tanmin\LSVM\lsvm4'));
if nargin < 1
    year = '2007';
end
if nargin < 3
    C = 0.125;
end
if nargin < 4
    confile = 'cHoG_1';
end
if nargin < 5
    yita0 = 1e-4;
end
if nargin < 6
    thresh = 1;
end
if nargin < 7
    evaltype = 0;
end
if nargin < 8
    imgsave = false;
end

database = 'voc';
cls = {'aeroplane','bicycle','bird','boat','bottle','bus','car','cat',...
    'chair','cow','diningtable','dog','horse','motorbike','person',...
    'pottedplant','sheep','sofa','train','tvmonitor'};
cseq=voc_getoptimalC(database);

cls = cls(range);
cseq = cseq(range);
% 
% cd 'D:\Tanmin\LSVM\lsvm4';
% dir = 'D:\Tanmin\LSVM\lsvm4\cache\voc2007\L2\';
% for i = 1:length(cls)
%     fname = [dir cls{i} '_final'];
%     load([fname '.mat'], 'model');
%     mulvisualizemodel1(model,1:2:length(model.rules{model.start}),...
%       [fname],[fname]);
% end
% t = 1;

getorgsetting;
for i = 1:length(cls)
    C = cseq(i);
    result{i} = trainL1(database, cls{i},confile,year,setting,...
        C, yita0, thresh, evaltype, imgsave);
end

function result = trainL1(database, cls,confile, year,setting,...
    C, yita0, thresh, evaltype, imgsave)
load(['D:\Tanmin\LSVM\VOC' year '\' cls '_final']);
n = length(model.rules{model.start})/2;
n = 1;
if strcmp(confile, 'cHoG_1')
    try
        result(1,:) = L2result(model, year, cls, n, setting, database, imgsave);
    catch
        result(1,:) = ObjDet_svm(database,cls,confile,0,n,1,...
            'kmeans','x2',1,0,0.002,1,thresh,evaltype,[20,0.1],0,0.0001,...
            0.8,0,1e-3,-1,100,imgsave);
    end
else
    result(1,:) = ObjDet_svm(database,cls,confile,0,n,1,...
            'kmeans','x2',1,0,0.002,1,thresh,evaltype,[20,0.1],0,0.0001,...
            0.8,0,1e-3,-1,100,imgsave);
end     
% result(2,:) = ObjDet_svm(database,cls,confile,0,n,1,...
%     'kmeans','x2',1,62,C,1,thresh,evaltype,[20,0.1],5,yita0,...
%     0.8,101,1e-3,-1,100,imgsave);


function result = L2result(model, year, cls, n, setting, database, imgsave)    
%%%get orginal model
notecache = ['voc' year '\' cls '\lsvm\' num2str(n), ...
    '_1_1_05_chog1S16f0s0C0.002(0)la1th1e0_0m20_0.1P0_0.0001_0.8tp0(0.001)_t(-1,100)_F'];
[cachedir,tmpdir] = globals(notecache);
try
    load([cachedir cls '_final']);
catch
    result(1,:) = ObjDet_svm(database,cls,confile,0,n,1,...
            'kmeans','x2',1,0,0.002,1,thresh,evaltype,[20,0.1],0,0.0001,...
            0.8,0,1e-3,-1,100,imgsave);
end
model.setting = setting;
model.cache = cachedir;
model = modeltranform(model);
model = model_index(model);save([cachedir cls '_final'],'model');
mulvisualizemodel(model,1:2:length(model.rules{model.start}),...
    [cachedir  cls '_final'],[cls '_final']);
model.thresh = min(-1.1, model.thresh);
th = tic();
boxes1 = pascal_test_fast(database,notecache,cls, model, 'test',year);
ttest = toc(th);
ttest = ttest / length(boxes1);
save([cachedir 'ttest'], 'ttest');
%evaluate models by detections
ap1 = pascal_eval(database,notecache,cls, boxes1, 'test',year);
%%detect by rescore
[ap1, ap2] = bboxpred_rescore(database,notecache,cls, 'test',year,...
    'default', year);
rate = sparserate(model);

times_toc = zeros(1,4);
result = [times_toc,ttest,rate, ap1, ap2];

if exist(tmpdir)
    try
        rmdir(tmpdir,'s');
    catch
    end
end