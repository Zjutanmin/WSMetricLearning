name = 'Class-others';
dataset = {'face', 0};Config = 'sphog';name = [name, str];
% crangeMLR = [32, 128, 512, 1024, 1536, 2048, 10240 20480 40960,51200, 61440, 81920, 102400];
if ~exist('VirTest', 'var')
    VirTest = 0;
end


[str,dataset, featurestr, VSNIPPET, classes, classesstr, classnum, ...
    crangeMLR, crangeSVM, strThresh, ratio, row, col, kkrange, outdim, ntree,CNum, crangeSVM1] = GetSetting({dataset{1}, str});
classes = classes(1:end-1);
classesstr = classesstr(1:end-1);
classnum = classnum(1:end-1);



if ~isempty(crangeMLR)
crangeMLR = [512, 1024, 1536, 2048, 10240 20480];
if strcmp(func2str(TrainFun), 'GetRecogRate_31') || strcmp(func2str(TrainFun), 'GetRecogRate_33')
%     crangeMLR = [1024, 1536, 2048, 4096, 10240];
    crangeMLR = [10240];
else
    crangeMLR = [10240];
%     crangeMLR = [1536, 2048];
end
end

% crangeMLR = crangeMLR(1:2:end);
if ~exist('TrainFun', 'var')
    TrainFun = @GetRecogRate;
end
if exist('Cbest', 'var')
    if Cbest == 0.5
        crangeMLR = crangeMLR(2:2:end-1);
    else if Cbest == -0.5
            crangeMLR = crangeMLR(3:2:end-1);
        end
    end
end

cConfig = {'PixelO', 'sphog', 'PixelM', 'sphogM', 'Pixel1', 'sphog1', 'PixelM1', 'sphogM1'};
cDOGfig = {'','', '','', '','', '',''};
cimsize = {[32, 32], [32, 32], [32, 32], [32, 32],[32, 32], [32, 32], [32, 32], [32, 32]};
cnpyra = {0, 0, 0, 0,0, 0, 0, 0};

classes = {'0'};classesstr = {'10'};classnum = [10];
PCAM ={{0.95, 'LDA', 0, 0.01}};PCAStr = 'LDA0.01NF';
PCAM = 0.95;PCAStr = 'PCA0.95NF';
range = 1;
multiview = [0 0.5];  %%%norlization
MMulti = [0 3];
MMulti = [0];
MID = 1;
BaseP = [0.9747 0.9767];

Wfea = {22404, 22404, 22410, 22410, 22404, 22404, 22410, 22410, 22403, 2403, 2403};
WNorm = {'max2', 'max2', 'max2', 'max2', 'min2', 'min2', 'max4', 'max8', 'max4', 'max4', 'max8'};
Norm = {[1,1], [1,0], [1,1], [1,0], [1,1], [1,0], [1,1], [1,1], [1,1], [1,1], [1,1]};
KFea = {10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10};
weightN = {0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1};

lamda = [0.01:0.02:0.1, 0.2:0.05:0.4,  0.5:0.05:1];
cd(PATH_F);
dir = 'figure\WSMTL\';
dir = fullfile(dir,str);
if ~exist(dir)
    mkdir(dir)
end
if ~exist(fullfile(dir, 'Result'))
    mkdir(fullfile(dir, 'Result'))
end
dir = [dir, '\'];
if length(range) == 2
    loc = {1, 'SouthEast'};
else
    loc = 'SouthEast';
end
clear 'resultB1';clear 'resultB';

lamda = [0.05:0.05:0.15];krange = [1, 3, 10, 20];
lamda = [0.01:0.02:0.1, 0.2:0.05:0.55];
Ntrain = [10 30 70 110 150];
tt = 1;

if ~exist('ind', 'var')
    ind = [3];
end
Ntrain = Ntrain(ind);

for ct = range
    kkki = 0;
    for kkk = MMulti
        kkki = kkki + 1;ParaB{kkki, ct}{1}(1)  = 3;
    end
end
PCAM ={{0.95, 'LDA', 1, 1}};



TempNorm = [2];
PCAM =0;

if strcmp(str, '_BTSRB') || strcmp(str, '_GTSRB')
    PCAM ={{0.95, 'LDA', 1, 1}};range = 2;
    dataset = 'TSR';Config = 'sphog';
    crangeMLR = [1024:256:2048, 10240];
    cimsize = {[28, 28], [28, 28], [28, 28], [28, 28],[28, 28], [28, 28], [28, 28], [28, 28]};
end
if strcmp(str, '_YaleBE')
    crangeMLR = [512, 1024, 1536, 2048, 10240 20480];
    PCAMT =[188  378  736  799  911 989];Ntrain = [5 10 20 30 40 50];
end
if strcmp(str, '_PIE')
    Ntrain =[10    30    70   110   150];
    PCAM = 0.95;
end

% % lamda = [0.05];

multiview = 0;
if ~exist('Vout', 'var')
    Vout = 0;
end
newdata = '_PIE';
if exist('newd', 'var') 
    if ~isempty(newd)
        newdata = newd;
    else
        newdata = str;
    end
end

if ~exist('PerC', 'var')
    PerC = 0;
end
if PerC
    Apcompute = 0;
else
    Apcompute = 1;
end

if ~exist('featnorm', 'var')
    featnorm = 0;
end
if ~exist('indindex', 'var')
indindex = 0;
end



multiview = [0, 0.5];
ostr = str;
if Vout
    PCAStr = [PCAStr, 'L'];
end
strsuffix  = '';
if Ninit == 1
    strsuffix =  [strsuffix, 'TN'];
end
if Ninit == 11
    strsuffix =  [strsuffix, 'TNN'];
end
if Ninit == 21
    strsuffix =  [strsuffix, 'TN2'];
end
if featnorm
    strsuffix =  [strsuffix, 'FN'];
end
if indindex
    strsuffix =  [strsuffix, 'M'];
end
if PerC
    strsuffix = [strsuffix, 'C'];
end
PCAStr = [PCAStr, strsuffix];
if exist('newd', 'var') && ~isempty(newd)
    PCAStr =  [PCAStr, newd];
end
str = [str, PCAStr];
if VirTest
    str=[str, num2str(VirTest)];
end
if strcmp(func2str(TrainFun), 'GetRecogRate1') || strcmp(func2str(TrainFun), 'GetRecogRate_33') || strcmp(func2str(TrainFun), 'GetRecogRate_33')
    str = ['Temp1_N', str];
end
if strcmp(func2str(TrainFun), 'GetRecogRate')
    str = ['Temp_N', str];
end
ostr1 = str;
str = ostr;
try
    load([dir 'Result\resultBTmpNN', ostr1, '_Best.mat'], 'resultBest', ...
        'resultBTmp');
catch

    for ct = range
    Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct}; imsize = cimsize{ct};
    for int = 1:length(Ntrain)
        ntr = Ntrain(int);
        if strcmp(str, '_BTSRB') || strcmp(str, '_GTSRB')
            nntrain = 1;
        else
            if strcmp(str, '_YaleBE')
                nntrain = {-50, ntr};PCAM = PCAMT(int);
            else
                nntrain = {-10, ntr};
            end
        end
        kkki = 0;
    for kkk = MMulti
        kkki = kkki + 1;resultN = [];CbestVV = [];
        clear 'resultt';clear 'ranktime';
        pcarange = 0.95;winit1 = 0;winit2 = 1;winit = {1, Ninit};
        resultt = [];i = 0;ranktime = [];
        
        kkrange = [4]; outdim = [50];
        if length(str) > 4 && strcmp(str(1:5), '_PIE5') && Vout
            outdim = [50, 100];
        end
        cntree = [30, 100:100:300];
        ntree = cntree(1);
        if ~isempty(outdim) && outdim(1) > 0
            for dim = outdim
                for kk = kkrange
         for nt = ntree
         for jj = pcarange
             for tt = 1:length(classes); 
                 try
                     i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = GetRecogRate1(dataset, str, Config,'lmnn', {'1', classes{tt}}, [kk, dim, 80, 1, 0.5, 0], {{VirTest, newdata}, imsize},  1,kkk,Voting,nntrain,PCAM,0, [1],{1},1,0,0,Apcompute,1,featnorm);
                     i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = GetRecogRate1(dataset, str, Config,'lmnn', {'1', classes{tt}}, [kk, dim, 200, 1, 0.5, 0], {{VirTest, newdata}, imsize},  1,kkk,Voting,nntrain,PCAM,0, [1],{1},1,0,0,Apcompute,1,featnorm);
                     i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,'lmnn', {'1', classes{tt}}, [kk, dim, 500, 1, 0.5, 0], {{VirTest, newdata}, imsize},  1,kkk,Voting,nntrain,PCAM,0, [1],{1},1,0,0,Apcompute,1,featnorm);
                     i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = GetRecogRate1(dataset, str, Config,'lmnn', {'1', classes{tt}}, [kk, dim, 1000, 1, 0.5, 0], {{VirTest, newdata}, imsize},  1,kkk,Voting,nntrain,PCAM,0, [1],{1},1,0,0,Apcompute,1,featnorm);
                 catch
                     cd(PATH_F);resultt(end+1:end+4) = 0; ranktime(end+1:end+4) = 0; 
                 end
             end
         end
         end
                end   
            end
        else
            outdim = -outdim;
        end
        resultt = (reshape(resultt, [length(classes), 4*length(outdim) * length(kkrange) * length(ntree)]))';
        [resultt, Vbaset] = max(resultt);
        resultN(:,end+1) = resultt(:);CbestVV(:,end+1) = Vbaset;

        resultt = [];i = 0;ranktime = [];
        ntree = cntree;
        for dim = outdim
                for kk = kkrange
         for nt = ntree
         for jj = pcarange
             for tt = 1:length(classes); 
                 try
                     i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,'gblmnn', {'1', classes{tt}}, [kk, dim, 500, 1, 0.5, 0, nt], {{VirTest, newdata}, imsize},  1,kkk,Voting,nntrain,PCAM,0, [1],{1},1,0,0,Apcompute,1,featnorm);
                 catch
                     cd(PATH_F);resultt(end+1) = 0; ranktime(end+1) = 0; 
                 end
             end
         end
                end    
                end
        end
        resultt = (reshape(resultt, [length(classes), length(outdim) * length(kkrange) * length(ntree)]))';
        [resultt, Vbaset] = max(resultt);
        resultN(:,end+1) = resultt(:);CbestVV(:,end+1) = Vbaset;

        
        if ~isempty(crangeSVM)
%             crangeSVM = [10, 16];
            crangeSVM = [crangeSVM(1:4), 10];
        end
        crange = crangeSVM;
        pcarange = 0.95; Ntype = 1;N = (0+Ntype);
        i = 0; resultt = [];ranktime= [];
        for jj = pcarange
            for ii = crange
                for tt = 1:length(classes);
                    i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,'MultiSVM', {'1', classes{tt}}, [ii,1,0], {{VirTest, newdata}, imsize},  1,kkk,Voting,nntrain,PCAM,0, [1],{1},1,0,0,Apcompute,1,featnorm);
                end
            end
        end
        resultt = reshape(resultt, [N,  length(classes), length(crange)]);
        [resultt, Vbaset] = max(resultt, [], 3);
        CbestV = (crange(Vbaset))';
        resultN = [resultN, resultt'];CbestVV  = [CbestVV, CbestV];

        
        crange = crangeSVM1;
        crange = [];
        i = 0; resultt = [];ranktime= [];
        for jj = pcarange
            for ii = crange
                for tt = 1:length(classes);
                    i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,'MultiSVM', {'1', classes{tt}}, [ii,1,2], {{VirTest, newdata}, imsize},  1,kkk,Voting,nntrain,PCAM,0, [1],{1},1,0,0,Apcompute,1,featnorm);
                end
            end
        end
        resultN = [resultN, 0];CbestVV  = [CbestVV, 0];

        
        %%MLR-A
        krange = [1];i = 0;
        HLOSS = {'MRR'};
     
        Find = [ind, length(KFea) - 2, length(KFea) - 2];
        Ratio_1 = [-4, -5, -4];
        MLRBalance = [0, 1, 1];
        multiview = [0, 0.5, 0];
        %%new feature 03, new method:delete+normlize+BY class
        
        for mm = 1:length(multiview)
        clear 'resultt';clear 'ranktime';pcarange = 0.95;
        crange = crangeMLR;
        i = 0;
        Ntype = 0;
        pcarange = 0.95;winit1 = 0;winit2 = 1;winit = {1, Ninit};
        Nnum = 1;
        N = (Nnum+Ntype);jj = pcarange;
        resultt = [];ranktime = [];
        i2 = 1;
        
        TrainFun1 = TrainFun; 
        if mm < length(multiview)
            TrainFun1 = @GetRecogRate1;
        end
        
        for tt = 1:length(classes)
            for kk = krange
            for ii = crange
                for kkt = 1:length(HLOSS)
                    %ewighted metirc
                    LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 3, 2, 0, 0, 200, 100, 1], [0.000001 1], [1]};
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {''}, [1]], Config,'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], {{VirTest, newdata}, imsize},  1,{multiview(mm), kkk},4,nntrain,PCAM,winit,[1,1,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
%                     weighted Metric+ template
                    LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 1, 2, 0, 0, -100.12, 302, 1], [0.0001 1], [1]};
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {{'', modelresult}}, [1]], Config,'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], {{VirTest, newdata}, imsize},  1,{multiview(mm), kkk},4,nntrain,PCAM,winit,[1,1,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
%                     weighted Metric+ template+iterative template
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], {{VirTest, newdata}, imsize},  1,{multiview(mm), kkk},4,nntrain,PCAM,winit,[1,3,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
%                     weighted Metric+ template+iterative M+template
                    LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 1, 2, 0, 0, -100.12, 302], [0.0001 1], [1]};
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [kk]}, LOSS{i2}], {{VirTest, newdata}, imsize},  1,{multiview(mm), kkk},4,nntrain,PCAM,winit,[1,3,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
                end
            end
            end
        end
        if ~isempty(crangeMLR)
            [rr,iind] = max(resultt(1:4:end));resultN = [resultN, rr];CbestVV  = [CbestVV, iind];
            [rr,iind] = max(resultt(2:4:end));resultN = [resultN, rr];CbestVV  = [CbestVV, iind];
            [rr,iind] = max(resultt(3:4:end));resultN = [resultN, rr];CbestVV  = [CbestVV, iind];
            [rr,iind] = max(resultt(4:4:end));resultN = [resultN, rr];CbestVV  = [CbestVV, iind];
        end
        %%WSMLR_0*-A-T
        end
    end
        resultBTmp{kkki, ct, int} = resultN;
        resultBest{kkki, ct, int} = CbestVV;
    end
    end
    
    resultBTmp = resultBTmp(:, range, :);
    resultBest = resultBest(:, range, :);
    save([dir 'Result\resultBTmpNN', ostr1, '_Best.mat'], 'resultBest', ...
        'resultBTmp');
end


ikkk = 0;
for ct = range
    ikkk = ikkk + 1;
    Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct}; imsize = cimsize{ct};
    for int = 1:length(Ntrain)
        ntr = Ntrain(int);
        if strcmp(str, '_BTSRB') || strcmp(str, '_GTSRB')
            nntrain = 1;
        else
            if strcmp(str, '_YaleBE')
                nntrain = {-50, ntr};PCAM = PCAMT(int);
            else
                nntrain = {-10, ntr};
            end
        end
        kkki = 0;
    for kkk = MMulti
        kkki = kkki + 1;resultN = [];ranktimeN = [];
        CbestVV = resultBest{kkki, ikkk, int};
        clear 'resultt';clear 'ranktime';
        pcarange = 0.95;winit1 = 0;winit2 = 1;winit = {1, Ninit};
        
        
        kkrange = [4]; outdim = [50];
        if length(str) > 4 && strcmp(str(1:5), '_PIE5') && Vout
            outdim = [50, 100];
        end
        cntree = [30, 100:100:300];
        NP = [80, 200, 500, 1000];ntree = cntree(1);
        [i1,i2,i3,i4, i5] = ind2sub([length(NP), length(pcarange), length(ntree), length(kkrange), length(outdim)],...
            CbestVV(length(ranktimeN)+1));
        dim = outdim(i5); kk = kkrange(i4);nt = ntree(i3);jj = pcarange(i2);np = NP(i1);
        resultt = [];ranktime = [];i = 0;i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,'lmnn', {'1', classes{tt}}, [kk, dim, np, 1, 0.5, 0], {{VirTest, newdata}, imsize},  1,kkk,Voting,nntrain,PCAM,0, [1],{1},1,0,0,Apcompute,1,featnorm);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];

        NP = [500];ntree = cntree;
        [i1,i2,i3,i4, i5] = ind2sub([length(NP), length(pcarange), length(ntree), length(kkrange), length(outdim)],...
            CbestVV(length(ranktimeN)+1));
        tt = 1;dim = outdim(i5); kk = kkrange(i4);nt = ntree(i3);jj = pcarange(i2);np = NP(i1);
        resultt = [];ranktime = [];i = 0;i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,'gblmnn', {'1', classes{tt}}, [kk, dim, np, 1, 0.5, 0, nt], {{VirTest, newdata}, imsize},  1,kkk,Voting,nntrain,PCAM,0, [1],{1},1,0,0,Apcompute,1,featnorm);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];


        tt = 1;ii = CbestVV(length(ranktimeN)+1); jj = pcarange(1);
        resultt = [];ranktime = [];i = 0;i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,'MultiSVM', {'1', classes{tt}}, [ii,1,0], {{VirTest, newdata}, imsize},  1,kkk,Voting,nntrain,PCAM,0, [1],{1},1,0,0,Apcompute,1,featnorm);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];

        resultN = [resultN, 0];ranktimeN  = [ranktimeN, 0];
        
        %%MLR-A
        krange = [1];i = 0;
        HLOSS = {'MRR'};
        Find = [ind, length(KFea) - 2, length(KFea) - 2];
        Ratio_1 = [-4, -5, -4];
        MLRBalance = [0, 1, 1];
        multiview = [0, 0.5, 0];
        %%new feature 03, new method:delete+normlize+BY class
        
        for mm = 1:length(multiview)
        i = 0;clear 'resultt';clear 'ranktime';pcarange = 0.95;
        crange = crangeMLR;
        Ntype = 0;
        pcarange = 0.95;winit1 = 0;winit2 = 1;winit = {1, Ninit};
        Nnum = 1;
        N = (Nnum+Ntype);jj = pcarange;
        
        TrainFun1 = TrainFun; 
        if mm < length(multiview)
            TrainFun1 = @GetRecogRate1;
        end
        i2 = 1;
        [i1,i22,i3] = ind2sub([length(HLOSS), length(crange), length(krange)],...
            CbestVV(length(ranktimeN)+1));
        tt = 1;kkt = i1;ii = crange(i22); kk = krange(i3);
        LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 3, 2, 0, 0, 200, 100, 1], [0.000001 1], [1]};
        resultt = [];ranktime = [];i = 0;i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {''}, [1]], Config,'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], {{VirTest, newdata}, imsize},  1,{multiview(mm), kkk},4,nntrain,PCAM,winit, [1,1,1,0,1],{Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        [i1,i22,i3] = ind2sub([length(HLOSS), length(crange), length(krange)],...
            CbestVV(length(ranktimeN)+1));
        tt = 1;kkt = i1;ii = crange(i22); kk = krange(i3);
        LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 1, 2, 0, 0, -100.12, 302, 1], [0.0001 1], [1]};
        resultt = [];ranktime = [];i = 0;i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {{'', modelresult}}, [1]], Config,'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], {{VirTest, newdata}, imsize},  1,{multiview(mm), kkk},4,nntrain,PCAM,winit, [1,1,1,0,1],{Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        [i1,i22,i3] = ind2sub([length(HLOSS), length(crange), length(krange)],...
            CbestVV(length(ranktimeN)+1));
        tt = 1;kkt = i1;ii = crange(i22); kk = krange(i3);
        LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 1, 2, 0, 0, -100.12, 302, 1], [0.0001 1], [1]};
        resultt = [];ranktime = [];i = 0;i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], {{VirTest, newdata}, imsize},  1,{multiview(mm), kkk},4,nntrain,PCAM,winit, [1,3,1,0,1],{Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        
        [i1,i22,i3] = ind2sub([length(HLOSS), length(crange), length(krange)],...
            CbestVV(length(ranktimeN)+1));
        tt = 1;kkt = i1;ii = crange(i22); kk = krange(i3);
        LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 1, 2, 0, 0, -100.12, 302], [0.0001 1], [1]};
        resultt = [];ranktime = [];i = 0;i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [kk]}, LOSS{i2}], {{VirTest, newdata}, imsize},  1,{multiview(mm), kkk},4,nntrain,PCAM,winit, [1,3,1,0,1],{Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
    end
        resultBTmp{kkki, ct, int} = resultN;
    end
    end
end

resultBTmp = resultBTmp(:, range, :);
cd(PATH_F);
save([dir 'Result\resultBTmpNN', ostr1, '.mat'], 'resultBTmp');

% % resultB1 = cell(length(multiview), length(cDOGfig), length(Ntrain));
% % for ct = range
% %     Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct};   imsize = cimsize{ct};
% %     for int = 1:length(Ntrain)
% %         ntr = Ntrain(int);
% %         for mm = 1:length(MMulti)
% %         i = 0;resultt = [];
% %         for tt = 1:length(classes);
%         i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, str, Config,'KNN', {'1', classes{tt}}, {}, {{VirTest, '_PIE'}, imsize},  1,MMulti(mm),2,nntrain,PCAM, 0, 1, {1}, 0, 0, 11, 1);
%         i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, str, Config,'INNC', {'1', classes{tt}}, 0.05, {{VirTest, '_PIE'}, imsize},  1,MMulti(mm),2,nntrain,PCAM, 0, 1, {1}, 0, 0, 11, 1);
%         end 
%         resultB1{mm, ct, int} = resultt;
%         end
%     end
% end
% resultB1 = resultB1(:, range, :);
% 
% clear 'MRes'
% for i = 1:length(range)
% for int = 1:length(Ntrain)
% RE = [cell2mat(resultB1(:, i, int))];
% % RE = repmat(RE, 2, 1);RE = RE(:);
% res1 =  cell2mat(resultBTmp(:, i, int));
% RE1 = [res1 ];
% for mm = 1:length(MMulti)
% Res1 = RE1(mm,:);Res1 = Res1(1:2:end);
% MRes(:, int, mm) = [RE; Res1(:)];
% end
% end
% end