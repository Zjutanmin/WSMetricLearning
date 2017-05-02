name = 'Class-others';
dataset = 'TSR';str = '_BTSRB';Config = 'sphog';name = [name, str];
crangeMLR = [2048, 10240 20480, 32, 128, 512, 1024, 1536,  40960,51200, 61440, 81920, 102400];

% crangeMLR = crangeMLR(1:2:end);

crangeSVM = [0.0157, 0.0313, 0.0625, 0.1250, 2, 32, 512];
cConfig = {'Pixel', 'sphog', 'PixelM', 'sphogM', 'Pixel1', 'sphog1', 'PixelM1', 'sphogM1'};
cDOGfig = {'','', '','', '','', '',''};
cimsize = {[28, 28], [28, 28], [28, 28], [28, 28],[28, 28], [28, 28], [28, 28], [28, 28]};
cnpyra = {0, 0, 0, 0,0, 0, 0, 0};

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
        CbestVV = [];indexV = [];lambdaV = [];ThV = [];
        kkki = kkki + 1;
        i = 0;clear 'resultt';clear 'ranktime';pcarange = 0.95;
        crange = crangeMLR;N = 10;
        resultt = [];ranktime = [];
        for jj = pcarange %0.95
            for ii = crange %[2048, 10240 20480, 32, 128, 512, 1024, 1536,  40960,51200, 61440, 81920, 102400]
                for tt = 1:length(classes);
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20,0,[1], {1},1,0,0,1);
                end
            end
        end
        [resultN, idd] = max(resultt);ranktimeN  = ranktime(idd);
        CbestVV = [CbestVV, crange(idd)];ThV = [ThV, 1];indexV = [indexV, 1];lambdaV = [lambdaV, 1];
        
        i = 0;resultt = [];ranktime = [];
        for jj = pcarange
            for ii = crange(idd)
                for tt = 1:length(classes);
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20,0,[1], {1},1,0,1,1);
                end
            end
        end
        [~, idd] = max(resultt);
        resultN = [resultN, max(resultt)];ranktimeN  = [ranktimeN, ranktime(idd)];
        CbestVV = [CbestVV, crange(idd)];ThV = [ThV, 1];indexV = [indexV, 1];lambdaV = [lambdaV, 1];
        
        for mm = 1:length(multiview)
        i = 0;clear 'resultt';clear 'ranktime';pcarange = 0.95;
        crange = crangeMLR;
        resultt = [];ranktime = [];
        for jj = pcarange
            for ii = crange
                for tt = 1:length(classes);
                    for ind = 1:length(Wfea)
                        for jjj = 1:length(stitle)
                            i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], [stitle{jjj},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,0,1);
                        end
                
                    end

                end
            end
        end
        
        result = reshape(resultt, [length(stitle), length(Wfea), length(classes), length(crange)]);
        result = permute(result, [3 1 2 4]);
        ranktime = reshape(ranktime, [length(stitle), length(Wfea), length(classes), length(crange)]);
        ranktime = permute(ranktime, [3 1 2 4]);
        snum = size(result);
        [result, idx] = max(reshape(result, snum(1), []), [], 2);
        [Th, index, Cbest] = ind2sub(snum(2:end), idx);
        resultN = [resultN, result];ranktimeN = [ranktimeN, ranktime(idx)];
        CbestVV = [CbestVV, crange(Cbest)];ThV = [ThV, Th];indexV = [indexV, index];lambdaV = [lambdaV, 1];
        
        fprintf('The Best choise of C under with differnt class and method\n')
        CbestV = crange(Cbest);
        i = 0;resultt = [];
        Ntype = 0;
        pcarange = 0.95;winit= 1;
        Nnum = 1;
        N = (Nnum+Ntype);jj = pcarange;
        resultt = [];ranktime = [];
        for tt = 1:length(classes);
            ind = index(tt);
            for ii = CbestV(tt, 1)
                for jjj = 1:length(stitle)
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], [stitle{ind},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,1,1);
                end
            end
        end  
        [~, idd] = max(resultt);
        resultN = [resultN, max(resultt)];
        ranktimeN = [ranktimeN, ranktime(idd) ];
        CbestVV = [CbestVV, crange(Cbest)];ThV = [ThV, idd];indexV = [indexV, index];lambdaV = [lambdaV, 1];
        
        
        
        i = 0;resultt = [];
        Ntype = 0;
        pcarange = 0.95;winit= 1;
        Nnum = 1;
        N = (Nnum+Ntype);jj = pcarange;
        resultt = [];ranktime = [];
        for tt = 1:length(classes);
            ind = index(tt);
            for lam = lamda
            for ii = CbestV(tt, 1)
                for jjj = 1:length(stitle)
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [lam]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], [stitle{jjj},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,0,1);
                end
            end
            end
        end  
        [~, idd] = max(resultt);
        resultN = [resultN, max(resultt)];
       
        ranktimeN = [ranktimeN, ranktime(idd)];
        [ridd, cidd] = ind2sub([length(stitle), length(lamda)], idd);
        CbestVV = [CbestVV, crange(Cbest)];ThV = [ThV, ridd];indexV = [indexV, index];lambdaV = [lambdaV, lamda(cidd)];
        
        
        
        
        i = 0;resultt = [];ranktime = [];
        Ntype = 0;
        pcarange = 0.95;winit= 1;
        Nnum = 1;
        N = (Nnum+Ntype);jj = pcarange;
        resultt = [];
        for tt = 1:length(classes);
            ind = index(tt);
            for lam = lamda
            for ii = CbestV(tt, 1)
                for jjj = 1:length(stitle)
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [lam]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], [stitle{jjj},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,1,1);
                end
            end
            end
        end  
        
        [~, idd] = max(resultt);
        resultN = [resultN, max(resultt)];
       
        ranktimeN = [ranktimeN, ranktime(idd)];
        [ridd, cidd] = ind2sub([length(stitle), length(lamda)], idd);
        CbestVV = [CbestVV, crange(Cbest)];ThV = [ThV, ridd];indexV = [indexV, index];lambdaV = [lambdaV, lamda(cidd)];
        
       
        end
        resultB{kkki, ct} = resultN;
        resultBest{kkki, ct} = {CbestVV, indexV, lambdaV, ThV};
    end
    end
    resultB = resultB(:, range);
    ranktimeB = ranktimeB(:, range);
    resultBest = resultBest(:, range);
    save(fullfile([dir, 'Result/re_Best.mat']), 'resultBest', 'resultB', 'ranktimeB')
end

% rresultB = resultB;rresultB1 = resultB1;
resultB1 = cell(length(MMulti), length(cDOGfig));
ranktimeB1 = cell(length(MMulti), length(cDOGfig));
resultB = cell(length(MMulti), length(cDOGfig));
ranktimeB = cell(length(MMulti), length(cDOGfig));
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
    ikkk = ikkk+ 1;
    Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct};
    kkki = 0;
    for kkk = MMulti
        kkki = kkki + 1;
        Cpara = resultBest{kkki, ikkk};
        CbestVV = Cpara{1};indexV = Cpara{2};lambdaV = Cpara{3};ThV = Cpara{4};
        i = 0;clear 'resultt';clear 'ranktime';pcarange = 0.95;
        crange = crangeMLR;N = 10;
        resultt = [];ranktime = [];
        jj = pcarange;ii = CbestVV(1);
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20,0,[1], {1},1,0,0,1);
        resultN = resultt;ranktimeN  = ranktime;
        
        i = 0;resultt = [];ranktime = [];
        jj = pcarange;ii = CbestVV(1);tt = 1;
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,1,PCAM,0,0,20,0,[1], {1},1,0,1,1);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        
        for mm = 1:length(multiview)
        crange = crangeMLR;
        
        i = 0;resultt = [];ranktime = [];
        ii = CbestVV(tt, length(ranktimeN)+1);tt = 1;
        jjj = ThV(length(ranktimeN)+1);ind = indexV(length(ranktimeN)+1);
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], [stitle{jjj},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,0,1);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        i = 0;resultt = [];ranktime = [];
        ii = CbestVV(tt, length(ranktimeN)+1);tt = 1;
        jjj = ThV(length(ranktimeN)+1);ind = indexV(length(ranktimeN)+1);
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {ii, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], [stitle{jjj},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,1,1);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        
        i = 0;resultt = [];ranktime = [];
        ii = CbestVV(tt, length(ranktimeN)+1);tt = 1;
        jjj = ThV(length(ranktimeN)+1);ind = indexV(length(ranktimeN)+1);lam = lambdaV(length(ranktimeN)+1);
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [lam]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], [stitle{jjj},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,0,1);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        i = 0;resultt = [];ranktime = [];
        ii = CbestVV(tt, length(ranktimeN)+1);tt = 1;
        jjj = ThV(length(ranktimeN)+1);ind = indexV(length(ranktimeN)+1);lam = lambdaV(length(ranktimeN)+1);
        i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'HINGE', 1, 1, 0, 1, 3}, [-1], [lam]}, 1, 0, [40, 40], -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,1,PCAM,0,0,20,winit,[1,5,1,0,1], [stitle{jjj},Wfea{ind},Kfea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}],1,1,1,1);
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