name = 'Class-others';
dataset = 'TSR';str = '_BTSRB';Config = 'sphog';name = [name, str];
crangeMLR = [2048, 10240 20480, 32, 128, 512, 1024, 1536,  40960,51200, 61440, 81920, 102400];

% crangeMLR = crangeMLR(1:2:end);

crangeSVM = [0.0157, 0.0313, 0.0625, 0.1250, 2, 32, 512];
cConfig = {'Pixel', 'sphog', 'PixelM', 'sphogM', 'Pixel1', 'sphog1', 'PixelM1', 'sphogM1'};

cimsize = {[28, 28], [28, 28], [28, 28], [28, 28],[28, 28], [28, 28], [28, 28], [28, 28]};


classes = {'0'};classesstr = {'62'};classnum = [62];winit = 1;
PCAM ={{0.95, 'LDA', 1, 1}};
range = 2;
multiview = [0 0.5 3];  %%%norlization
%MMulti = [0 3];
MMulti = [0];
MID = 1;
BaseP = [0.9747 0.9767];
clear 'resultB1';clear 'resultB';

stitle = {{-1, []}, {0.3, 0}, {0.4, 0}, {0.5, 0}, {0.8, 0},...
    {3, 0}, {4, 0}, {5, 0}, {8, 0}};

% dis = resultB1{MID, range}(3:4) - BaseP
Wfea = {22404, 22404, 22410, 22410, 22404, 22404, 22404};
Kfea = {10, 10, 10, 10, 10, 10, 8};
WNorm = {'max2', 'max2', 'max2', 'max2', 'min2', 'min2', 'max'};
Norm = {[1,1], [1,0], [1,1], [1,0], [1,1], [1,0], [1,1]};

lamda = [0.01:0.02:0.1, 0.2:0.05:0.4,  0.5:0.05:1];


TS = {'1-NN', 'INNC', 'NN-A', 'INNC-A', 'MLR', 'MLR_A', 'WSMLR-D' , 'WSMLR-D-A' , 'WSMLR*-D' , 'WSMLR*-D-A',...
    'WSMLR-C' , 'WSMLR-C-A' , 'WSMLR*-C' , 'WSMLR*-C-A','WSMLR' , 'WSMLR-A' , 'WSMLR*' , 'WSMLR*-A'};
cd(PATH_F)
addpath(fullfile(PATH_F, 'Tool'))
dir = 'figure/WSMLR/';
dir = fullfile(dir,str);
if ~exist(dir)
    mkdir(dir)
end
if ~exist(fullfile(dir, 'Result'))
    mkdir(fullfile(dir, 'Result'))
end
dir = [dir, '/'];


load(fullfile([dir, 'Result/re_Best.mat']), 'resultBest', 'resultB', 'ranktimeB')

resultB1 = cell(length(MMulti), 1);
ranktimeB1 = cell(length(MMulti), 1);
resultB = cell(length(MMulti), 1);
ranktimeB = cell(length(MMulti), 1);
for ct = range
    Config = cConfig{ct};   imsize = cimsize{ct};
    for mm = 1:length(MMulti)
        i = 0;resultt = [];ranktime = [];
        for tt = 1:length(classes);
        i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate(dataset, str, Config,'KNN', {'1',classes{tt}},{},imsize, 1,MMulti(mm),2,1,PCAM, 0, [1], {1}, 0, 0, 0, 1);
        i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate(dataset, str, Config,'INNC',{'1',classes{tt}}, 0.05,imsize, 1,MMulti(mm),2,1,PCAM, 0, [1], {1}, 0, 0, 0, 1);
        i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate(dataset, str, Config,'KNN', {'1',classes{tt}},{},imsize, 1,MMulti(mm),2,1,PCAM, 0, [1], {1}, 0, 0, 11, 1);
        i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate(dataset, str, Config,'INNC',{'1',classes{tt}}, 0.05,imsize, 1,MMulti(mm),2,1,PCAM, 0, [1], {1}, 0, 0, 11, 1);
        end 
        resultB1{mm, ct} = resultt;ranktimeB1{mm, ct} = ranktime;
    end
end
ikkk = 0;
for ct = range
    ikkk = ikkk+ 1;
    Config = cConfig{ct};
    kkki = 0;
    for kkk = MMulti
        kkki = kkki + 1;
        Cpara = resultBest{kkki, ikkk};
        CbestVV = Cpara{1};indexV = Cpara{2};lambdaV = Cpara{3};ThV = Cpara{4};
        i = 0;clear 'resultt';clear 'ranktime';pcarange = 0.95;
        crange = crangeMLR;N = 10;
        resultt = [];ranktime = [];
        jj = pcarange;ii = CbestVV(1);
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate(dataset, str, Config,'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, [40, 40], 1,kkk,2,1,PCAM,0,[1],{1},1,0,0,1);
        resultN = resultt;ranktimeN  = ranktime;
        
        i = 0;resultt = [];ranktime = [];
        jj = pcarange;ii = CbestVV(1);tt = 1;
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate(dataset, str, Config,'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, [40, 40], 1,kkk,2,1,PCAM,0,[1],{1},1,0,1,1);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        
        for mm = 1:length(multiview)
        crange = crangeMLR;
        
        i = 0;resultt = [];ranktime = [];
        ii = CbestVV(tt, length(ranktimeN)+1);tt = 1;
        jjj = ThV(length(ranktimeN)+1);ind = indexV(length(ranktimeN)+1);
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate(dataset, str, Config,'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, [40, 40], 1,{multiview(mm), kkk},4,1,PCAM,winit,[1,5,1,0,1],[stitle{jjj},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,0,1);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        i = 0;resultt = [];ranktime = [];
        ii = CbestVV(tt, length(ranktimeN)+1);tt = 1;
        jjj = ThV(length(ranktimeN)+1);ind = indexV(length(ranktimeN)+1);
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate(dataset, str, Config,'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, [40, 40], 1,{multiview(mm), kkk},4,1,PCAM,winit,[1,5,1,0,1],[stitle{jjj},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,1,1);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        
        i = 0;resultt = [];ranktime = [];
        ii = CbestVV(tt, length(ranktimeN)+1);tt = 1;
        jjj = ThV(length(ranktimeN)+1);ind = indexV(length(ranktimeN)+1);lam = lambdaV(length(ranktimeN)+1);
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate(dataset, str, Config,'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [lam]}, [40, 40], 1,{multiview(mm), kkk},4,1,PCAM,winit,[1,5,1,0,1],[stitle{jjj},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,0,1);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        i = 0;resultt = [];ranktime = [];
        ii = CbestVV(tt, length(ranktimeN)+1);tt = 1;
        jjj = ThV(length(ranktimeN)+1);ind = indexV(length(ranktimeN)+1);lam = lambdaV(length(ranktimeN)+1);
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate(dataset, str, Config,'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [lam]}, [40, 40], 1,{multiview(mm), kkk},4,1,PCAM,winit,[1,5,1,0,1],[stitle{jjj},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,1,1);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        
       
        end
        resultB{kkki, ct} = resultN;
        ranktimeB{kkki, ct} = ranktimeN;
        
    end
end
resultB1 = resultB1(:, range);
resultB = resultB(:, range);
ranktimeB = ranktimeB(:, range);
ranktimeB1 = ranktimeB1(:, range);


save(fullfile([dir, 'Result/re_A.mat']), ...
    'resultB1', 'resultB', 'ranktimeB1', 'ranktimeB', 'resultBest')

if length(range) == 2
    loc = {1, 'SouthEast'};
else
    loc = 'SouthEast';
end
TS = {'1-NN', 'INNC', 'MLR' 'WSMLR*-D' 'WSMLR*-C','WSMLR*'};
TS1 = {'Template', 'Sample'};

disp('The 1th and 2th row are the results of search within templates and samples:\n')
disp('The compared methods are:\n')
disp(cell2mat(cellfun(@(x) [x,',  '], TS, 'UniformOutput', 0)))
    
for i = 1:length(range)
    res =  cell2mat(resultB(:, i));
    tmp = [res([1, 5:4:end]);res([2, 6:4:end])];
    res = [res(1), (tmp(:))'];
    RE = [cell2mat(resultB1(:, i)),res ];
    
    res =  cell2mat(ranktimeB(:, i));
    tmp = [res([1, 5:4:end]);res([2, 6:4:end])];
    res = [res(1), (tmp(:))'];
    RE1 = [cell2mat(ranktimeB1(:, i)),res ];
    
    for mm = 1:length(MMulti)
        strs = [str cConfig{range(i)}, 'MV', num2str(MMulti(mm))];
        Res = RE(mm,:);
        Res = [(reshape(Res(1:4), 2, 2))', (reshape(Res(6:end), 2, []))];
        
        disp(['recognition accuracy per image using ' ...
            cConfig{range(i)} ' feature for different methods:\n']);
        disp(savedot(Res, 2)) %%%%print recognition time per image
        
        Res1 = RE1(mm,:);
        Res1 = [(reshape(Res1(1:4), 2, 2))', (reshape(Res1(6:end), 2, []))];
        
        disp(['recognition time per image using ' ...
            cConfig{range(i)} ' feature for different methods:\n']);
        disp(Res1 * 1e3) %%%%print recognition time per image
        
        plotFigC({classnum, TS}, Res, TS1, ['Class_method_A', strs], 'Method', ...
            'Per-image accuracy (%)', 0, dir, loc, 1, 0,0,0, [1,1],1);
    end
end