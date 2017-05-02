name = 'Class-others';
dataset = 'TSR';str = '_GTSRB';Config = 'sphog';name = [name, str];
crangeMLR = [32, 128, 512, 1024, 1536, 2048, 10240 20480 40960,51200, 61440, 81920, 102400];
crangeMLR1 = union([6144, 10240: 2048: 18432,  25600:5120:35840], [10240: 20480:  102400]);
crangeMLR = union(crangeMLR1, crangeMLR);

crangeSVM = [0.0157, 0.0313, 0.0625, 0.1250, 2, 32, 512];
cConfig = {'Pixel', 'sphog', 'PixelM', 'sphogM', 'Pixel1', 'sphog1', 'PixelM1', 'sphogM1', 'HOG_02'};
cDOGfig = {'','', '','', '','', '','',''};
cimsize = {[28, 28], [28, 28], [28, 28], [28, 28],[28, 28], [28, 28], [28, 28], [28, 28], [40, 40]};
cnpyra = {0, 0, 0, 0,0, 0, 0, 0, 0};

classes = {'0'};classesstr = {'43'};classnum = [43];winit = 1;
PCAM ={{0.95, 'LDA', 1, 1}};
range = [2 9];
multiview = [0 0.5];  %%%norlization
MMulti = [0];


Wfea = {22404, 22410, 22404, 22404, 22410, 22410, 22404};
WNorm = {'max2', 'max2', 'min2', 'max4', 'max4', 'max', 'max'};
Norm = {[1,1], [1,1], [1,1], [1,1], [1,1], [1,1], [1,1]};
KFea = {10, 10, 10, 10, 10, 10, 8};
lamda = [0.01:0.02:0.1, 0.2:0.05:0.4,  0.5:0.05:1];

MID = 1;
BaseP = [0.9747 0.9767];
clear 'resultB1';clear 'resultB';


cd(PATH_F)
addpath('Tool')
TS = {'NN', 'INNC', 'NN-A', 'INNC-A', 'MLR', 'MLR_A', 'WSMLR-D' , 'WSMLR-D-A' , 'WSMLR*-D' , 'WSMLR*-D-A',...
    'WSMLR-C' , 'WSMLR-C-A' , 'WSMLR*-C' , 'WSMLR*-C-A'};
dir = 'figure/WSMLR/';
dir = fullfile(dir,str);
if ~exist(dir)
    mkdir(dir)
end
if ~exist(fullfile(dir, 'Result'))
    mkdir(fullfile(dir, 'Result'))
end
dir = [dir, '/'];

try
    load(fullfile([dir, 'Result/re_Best.mat']), 'resultBest', 'resultB', 'ranktimeB')
catch
    resultB = cell(length(MMulti), length(cDOGfig));
    ranktimeB = cell(length(MMulti), length(cDOGfig));
    resultBest = cell(length(MMulti), length(cDOGfig));
    for ct = range
    Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct};
    kkki = 0;
    for kkk = MMulti
        CbestVV = [];indexV = [];lambdaV = [];
        kkki = kkki + 1;
        i = 0;clear 'resultt';pcarange = 0.95;
        crange = crangeMLR;N = 10;resultt = [];ranktime = [];
        for jj = pcarange
            for ii = crange
                for tt = 1:length(classes);
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20,0,[1], {1},1,0,0,1);
                end
            end
        end
        [resultN, idd] = max(resultt);
        CbestVV = [CbestVV, crange(idd)];indexV = [indexV, 1];lambdaV = [lambdaV, 1];
        i = 0;resultt = [];ranktime = [];
        for jj = pcarange
            for ii = crange(idd)
                for tt = 1:length(classes);
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20,0,[1], {1},1,0,1,1);
                end
            end
        end
        [~, idd] = max(resultt);
        resultN = [resultN,  max(resultt)];
        CbestVV = [CbestVV, crange(idd)];indexV = [indexV, 1];lambdaV = [lambdaV, 1];
        
        for mm = 1:length(multiview)
        i = 0;clear 'resultt';pcarange = 0.95;
        crange = crangeMLR;
        resultt = [];ranktime = [];
        for jj = pcarange
            for ii = crange
                for tt = 1:length(classes); 
%                     i =i + 7;
%                     resultt = [resultt, rand([1, 7])];ranktime = [ranktime, rand([1, 7])];
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],22410,10, 'Reciprocal',0,1,1, 'NA', 'max2',1,1},1,1,0,1);
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'min2',1,1},1,1,0,1);

                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,10, 'Reciprocal',0,1,1, 'NA', 'max4',1,1},1,1,0,1);
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],22410,10, 'Reciprocal',0,1,1, 'NA', 'max4',1,1},1,1,0,1);
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],22410,10, 'Reciprocal',0,1,1, 'NA', 'max',1,1},1,1,0,1);
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],22404,8, 'Reciprocal',0,1,1, 'NA', 'max',1,1},1,1,0,1);
                 end
            end
        end
        result = reshape(resultt, 7, []);
        [result, index] = max(result, [], 1);
        
        
        result = (reshape(result, [], length(classes)*length(crange)))';
        result= reshape(result, [length(classes), length(crange), size(result, 2)]);
        [result,Cbest] = max(result, [], 2);
        
        
        result = reshape(result, [size(result, 1), size(result, 3)]);
        Cbest = reshape(Cbest, [size(Cbest, 1), size(Cbest, 3)]);
        [result, idx] = max(result);
        Cbest = Cbest(idx);
        index = index(Cbest);
        resultN = [resultN, result];
        fprintf('The Best choise of C under with differnt class and method\n')
        CbestVV = [CbestVV, crange(Cbest)];indexV = [indexV, index];lambdaV = [lambdaV, 1];
        
        
        i = 0;resultt = [];
        Ntype = 0;
        pcarange = 0.95;winit= 1;
        Nnum = 1;
        N = (Nnum+Ntype);jj = pcarange;resultt = [];
        for tt = 1:length(classes);
            ind = index(tt);
            for ii =crange(Cbest)
                i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}},1,1,1,1);
            end
        end  
        [~, idd] = max(resultt);
        resultN = [resultN, max(resultt)];ranktimeB = [ranktimeB, ranktime(idd)];
        CbestVV = [CbestVV, crange(Cbest)];indexV = [indexV, index];lambdaV = [lambdaV, 1];
        
        i = 0;resultt = [];
        Ntype = 0;
        pcarange = 0.95;winit= 1;
        Nnum = 1;
        N = (Nnum+Ntype);jj = pcarange;resultt = [];
        for tt = 1:length(classes);
            ind = index(tt);
            for lam = lamda
            for ii = crange(Cbest)
                i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [lam]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}},1,1,0,1);
                i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [lam]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}},1,1,1,1);
            end
            end
        end  
        [resultt, lambda] = (max(reshape(resultt, 2, []), [], 2));
        resultt = resultt'; lambda =  lamda(lambda);
        resultN = [resultN, (resultt)];      
        
        CbestVV = [CbestVV, crange(Cbest), crange(Cbest)];
        indexV = [indexV, index, index];lambdaV = [lambdaV, lambda];
        
        end
        resultB{kkki, ct} = resultN;
        resultBest{kkki, ct} = {CbestVV, indexV, lambdaV};
        
    end
    end
    resultB = resultB(:, range);
    ranktimeB = ranktimeB(:, range);
    resultBest = resultBest(:, range);
    save(fullfile([dir, 'Result/re_Best.mat']), 'resultBest', 'resultB', 'ranktimeB')
end
% rresultB = resultB;rresultB1 = resultB1;


resultB = cell(length(MMulti), length(cDOGfig));
ranktimeB = cell(length(MMulti), length(cDOGfig));
resultB1 = cell(length(MMulti), length(cDOGfig));
ranktimeB1 = cell(length(MMulti), length(cDOGfig));
for ct = range
    Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct};   imsize = cimsize{ct};
    for mm = 1:length(MMulti)
        i = 0;resultt = [];ranktime = [];
        for tt = 1:length(classes);
        i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'KNN', {'1', classes{tt}}, {}, 1, 0, imsize, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20, 0, 1, {1}, 0, 0, 0, 1);
        i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'INNC', {'1', classes{tt}}, 0.05, 1, 0, imsize, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20, 0, 1, {1}, 0, 0, 0, 1);
        i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'KNN', {'1', classes{tt}}, {}, 1, 0, imsize, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20, 0, 1, {1}, 0, 0, 11, 1);
        i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'INNC', {'1', classes{tt}}, 0.05, 1, 0, imsize, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20, 0, 1, {1}, 0, 0, 11, 1);
        end 
        resultB1{mm, ct} = resultt;ranktimeB1{mm, ct} = ranktime;
    end
end
ikkk = 0;
for ct = range
    ikkk = ikkk + 1;
    Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct};
    kkki = 0;
    for kkk = MMulti
        kkki = kkki + 1;
        Cpara = resultBest{kkki, ikkk};
        CbestVV = Cpara{1};indexV = Cpara{2};lambdaV = Cpara{3};
        i = 0;clear 'resultt';pcarange = 0.95;
        crange = crangeMLR;N = 10;resultt = [];ranktime = [];
        jj = pcarange;ii = CbestVV(1);tt = 1;
        
%         i =i + 1;resultt = [resultt, rand([1, 1])];ranktime = [ranktime, rand([1, 1])];
                   
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20,0,[1], {1},1,0,0,1);
        resultN = resultt;ranktimeN = ranktime;
        
        i = 0;resultt = [];ranktime = [];
%         i =i + 1;resultt = [resultt, rand([1, 1])];ranktime = [ranktime, rand([1, 1])];
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20,0,[1], {1},1,0,1,1);
        resultN = [resultN, resultt];ranktimeN = [ranktimeN, ranktime];
        
        for mm = 1:length(multiview)
        
            clear 'resultt';
        crange = crangeMLR;
        i = 0;resultt = [];ranktime = [];
        
        tt = 1;ind = indexV(length(ranktimeN)+1);ii = CbestVV(tt, length(ranktimeN)+1);
%         i =i + 1;resultt = [resultt, rand([1, 1])];ranktime = [ranktime, rand([1, 1])];
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}},1,1,0,1);
        resultN = [resultN, resultt];ranktimeN = [ranktimeN, ranktime];
        
        i = 0;resultt = [];ranktime = [];
        tt = 1;ind = indexV(length(ranktimeN)+1);ii = CbestVV(tt, length(ranktimeN)+1);
%         i =i + 1;resultt = [resultt, rand([1, 1])];ranktime = [ranktime, rand([1, 1])];
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}},1,1,1,1);
        resultN = [resultN, resultt];ranktimeN = [ranktimeN, ranktime];
        
        i = 0;resultt = [];ranktime = [];
        Ntype = 0;
        pcarange = 0.95;winit= 1;
        Nnum = 1;
        N = (Nnum+Ntype);jj = pcarange;
        
        lam = lambdaV(length(ranktimeN)+1);ind = indexV(length(ranktimeN)+1);ii = CbestVV(tt, length(ranktimeN)+1);
%         i =i + 1;resultt = [resultt, rand([1, 1])];ranktime = [ranktime, rand([1, 1])];
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [lam]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}},1,1,0,1);
        lam = lambdaV(length(ranktimeN)+2);
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [lam]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}},1,1,1,1);
 
        
        resultN = [resultN, (resultt)];      
        ranktimeN = [ranktimeN, ranktime];
        
        
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

TS = {'1-NN', 'INNC', 'MLR', 'WSMLR*-D','WSMLR*-C'};
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
            'Per-image accuracy (%)', 0, dir, loc, 1, 0,0,0, [1,1],1, [-1 -1 82 -1]);
        %%%%plot recognition accuracy
    end
end

% % uiopen('D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_GTSRB\Class_method_A_GTSRBHOG_02MV0.fig',1)
% % set(gca, 'OuterPosition', [0.1 0.1 0.9 0.9])
% % print(gcf, '-djpeg', '-r0', [ 'D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_GTSRB\Class_method_A_GTSRBHOG_02MV0.jpg']);
% % saveas(gca,['D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_GTSRB\Class_method_A_GTSRBHOG_02MV0.fig']);
% % print(gcf, '-depsc2','-r0', [ 'D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_GTSRB\Class_method_A_GTSRBHOG_02MV0.eps']);
% % 
% % uiopen('D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_GTSRB\Class_method_A_GTSRBsphogMV0.fig',1)
% % set(gca, 'OuterPosition', [0.1 0.1 0.9 0.9])
% % print(gcf, '-djpeg', '-r0', [ 'D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_GTSRB\Class_method_A_GTSRBsphogMV0.jpg']);
% % saveas(gca,['D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_GTSRB\Class_method_A_GTSRBsphogMV0.fig']);
% % print(gcf, '-depsc2','-r0', [ 'D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_GTSRB\Class_method_A_GTSRBsphogMV0.eps']);

% % uiopen('D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_BTSRB\Class_method_A_BTSRBsphogMV0.fig',1)
% % set(gca, 'OuterPosition', [0.1 0.1 0.9 0.9])
% % print(gcf, '-djpeg', '-r0', [ 'D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_BTSRB\Class_method_A_BTSRBsphogMV0.jpg']);
% % saveas(gca,['D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_BTSRB\Class_method_A_BTSRBsphogMV0.fig']);
% % print(gcf, '-depsc2','-r0', [ 'D:\Tanmin\Study\CVPR\cvpr\cvpr14\latex\fig\_BTSRB\Class_method_A_BTSRBsphogMV0.eps']);
