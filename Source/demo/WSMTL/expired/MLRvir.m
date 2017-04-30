name = 'Class-others';
dataset = {'face', 0};Config = 'sphog';name = [name, str];
% crangeMLR = [32, 128, 512, 1024, 1536, 2048, 10240 20480 40960,51200, 61440, 81920, 102400];
global PATH_F;
cd ..;
cd ..;
GetGlobalSetting;
cd(fullfile(PATH_F, 'demo/WSMTL'))

[str,dataset, featurestr, VSNIPPET, classes, classesstr, classnum, ...
    crangeMLR, crangeSVM, strThresh, ratio, row, col, kkrange, outdim, ntree,CNum, crangeSVM1] = GetSetting({dataset{1}, str});
classes = classes(1:end-1);
classesstr = classesstr(1:end-1);
classnum = classnum(1:end-1);

if ~exist('RR', 'var')
    RR = 1;
end


if ~isempty(crangeMLR)
crangeMLR = [512, 1024, 1536, 2048, 10240 20480];
if strcmp(func2str(TrainFun), 'GetRecogRate_31') || strcmp(func2str(TrainFun), 'GetRecogRate_33')
    if length(RR) == 1 && RR(1) == 1
        crangeMLR = 10240;
    else
        crangeMLR = [10240 12800 20480 17920 15360];
%         crangeMLR = [20480 17920 15360 12800 10240 7680 5120];
    end
else
    if length(RR) == 1 && RR(1) == 1
        crangeMLR = 10240;
    else
        crangeMLR = [10240 12800 20480 17920 15360];
%         crangeMLR = [20480 17920 15360 12800 10240 7680 5120];
    end
end
end
if ~exist('rangeI', 'var')
   rangeI = [1:length(crangeMLR)]; 
end
crangeMLR  = crangeMLR(rangeI);
% crangeMLR = crangeMLR(1:2:end);
if ~exist('TrainFun', 'var')
    TrainFun = @GetRecogRate_3;
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

Wfea = {22404, 22404, 22410, 22410, 22404, 22404, 22410, 22410, 22403, 2403, 22403};
WNorm = {'max2', 'max2', 'max2', 'max2', 'min2', 'min2', 'max4', 'max8', 'max4', 'max4', 'Omax4'};
Norm = {[1,1], [1,0], [1,1], [1,0], [1,1], [1,0], [1,1], [1,1], [1,1], [1,1], [1,1]};
KFea = {10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10};
weightN = {0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1};


lamda = [0.01:0.02:0.1, 0.2:0.05:0.4,  0.5:0.05:1];
dir = 'figure/WSMTL/';
dir = fullfile(dir,str);
if ~exist(dir)
    mkdir(dir)
end
if ~exist(fullfile(dir, 'Result'))
    mkdir(fullfile(dir, 'Result'))
end
        
dir = [dir, '/'];
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

resultB1 = cell(length(multiview), length(cDOGfig), length(Ntrain));
for ct = range
    kkki = 0;
    for kkk = MMulti
        kkki = kkki + 1;ParaB{kkki, ct}{1}(1)  = 3;
    end
end
PCAM ={{0.95, 'LDA', 1, 1}};

if ~isempty(crangeSVM)
    if length(RR) == 1
    crangeSVM = [];
    crangeSVM1 = [];
    else
%     crangeSVM = crangeSVM(1:2:end);
%     crangeSVM1 = crangeSVM1(1:2:end);
    end
end
if ~exist('isDel', 'var')
    isDel = 0;
end
if ~exist('RatioC', 'var')
    RatioC = 0;
end
if ~exist('NewFea', 'var')
    NewFea = 0;
end


% % % for ct = range
% % %     Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct};   imsize = cimsize{ct};
% % %     for int = 1:length(Ntrain)
% % %         ntr = Ntrain(int);
% % %         for mm = 1:length(MMulti)
% % %         i = 0;resultt = [];
% % %         for tt = 1:length(classes);
% % %         i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'KNN', {'1', classes{tt}}, {}, 1, 0, {RRatio, [], imsize}, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20, 0, 1, {1}, 0, 0, 11, 1);
% % %         i = i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'INNC', {'1', classes{tt}}, 0.05, 1, 0, {RRatio, [], imsize}, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20, 0, 1, {1}, 0, 0, 11, 1);
% % %         end 
% % %         resultB1{mm, ct, int} = resultt;
% % %         end
% % %     end
% % % end


TempNorm = [2];
PCAM =0;
% % lamda = [0.05];
cd(PATH_F);
% if length(RR) == 1
    multiview = 0;
% end
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

if ~exist('Ninit', 'var')
    Ninit = 0;
end

if ~exist('featnorm', 'var')
    featnorm = 0;
end
if ~exist('indindex', 'var')
indindex = 0;
end
if ~exist('ismult', 'var')
    ismult= 0;
end
winit1 = 0;winit2 = 1;winit = {1, Ninit};

ostr= str;
if Vout
    PCAStr = [PCAStr, 'L'];
end
if Ninit == 1
    PCAStr = [PCAStr, 'TN'];
end
if Ninit == 11
    PCAStr = [PCAStr, 'TNN'];
end

if featnorm
    PCAStr = [PCAStr, 'FN'];
end
if indindex
    PCAStr = [PCAStr, 'M'];
end
if PerC
    PCAStr = [PCAStr, 'C'];
end
if exist('newd', 'var') && ~isempty(newd)
    PCAStr =  [PCAStr, newd];
end
str = [str, PCAStr];
if VirTest
    str=[str, num2str(VirTest)];
end

if length(RR)~=1 
    for i = 1:length(RR)
        tmp = num2str(RR(i));
        str = [str, tmp(2:end)];
    end
end
if strcmp(func2str(TrainFun), 'GetRecogRate_31') || strcmp(func2str(TrainFun), 'GetRecogRate_33') || strcmp(func2str(TrainFun), 'GetRecogRate_33')
    str = ['Temp1', str];
end
if strcmp(func2str(TrainFun), 'GetRecogRate_3')
    str = ['Temp', str];
end
ostr1 = str;
str = ostr;


try
    load([dir 'Result/resultBTmpNN', ostr1, '_Best.mat'], 'resultBest', ...
        'resultBTmp');
catch   

    for ct = range
    Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct}; imsize = cimsize{ct};
    for int = 1:length(Ntrain)
        ntr = Ntrain(int);
        ikk = 0;
        for RRatio = RR
            ikk = ikk + 1;
    kkki = 0;
    for kkk = MMulti
        kkki = kkki + 1;resultN = [];CbestVV = [];
        clear 'resultt';clear 'ranktime';pcarange = 0.95;

        
        pcarange = 0.95;winit1 = 0;winit2 = 1;winit = {1, Ninit};
        resultt = [];i = 0;
        
        kkrange = [4]; 
        outdim = [50];
        cntree = [30, 100:100:300];
        try
            ntree = cntree(1);
        end
        ranktime = [];
        % ntree = [100:100:300];
        if ~isempty(outdim) && outdim(1) > 0
            for dim = outdim
                for kk = kkrange
         for nt = ntree
         for jj = pcarange
             for tt = 1:length(classes); 
              
                     i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'lmnn', {'1', classes{tt}}, [kk, dim, 80, 1, 0.5, 0], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,Apcompute,1,featnorm);
                     i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'lmnn', {'1', classes{tt}}, [kk, dim, 200, 1, 0.5, 0], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,Apcompute,1,featnorm);
                     i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'lmnn', {'1', classes{tt}}, [kk, dim, 500, 1, 0.5, 0], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,Apcompute,1,featnorm);
                     i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'lmnn', {'1', classes{tt}}, [kk, dim, 1000, 1, 0.5, 0], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,Apcompute,1,featnorm);
                 
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
        try
            ntree = cntree;
        end
        ranktime = [];
        % ntree = [100:100:300];
        for dim = outdim
                for kk = kkrange
         for nt = ntree
         for jj = pcarange
             for tt = 1:length(classes); 
                 try
                     i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'gblmnn', {'1', classes{tt}}, [kk, dim, 500, 1, 0.5, 0, nt], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,Apcompute,1,featnorm);
                 catch
                     cd(PATH_F);resultt(end+1) = 0; ranktime(end+1) = 0; 
                 end
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
%         crange = crangeSVM1;
        crange = crangeSVM;
        pcarange = 0.95; Ntype = 1;N = (0+Ntype);
        i = 0; resultt = [];ranktime= [];
        for jj = pcarange
            for ii = crange
                for tt = 1:length(classes);
                    i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'MultiSVM', {'1', classes{tt}}, [ii,1,0], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,Apcompute,1,featnorm);
                end
            end
        end
            resultt = reshape(resultt, [N,  length(classes), length(crange)]);
            [resultt, Vbaset] = max(resultt, [], 3);
            CbestV = (crange(Vbaset))';
            resultN = [resultN, resultt'];CbestVV  = [CbestVV, CbestV];
        
        crange = [];
        i = 0; resultt = [];ranktime= [];
        for jj = pcarange
            for ii = crange
                for tt = 1:length(classes);
                    i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'MultiSVM', {'1', classes{tt}}, [ii,1,2], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,Apcompute,1,featnorm);
                end
            end
        end
            resultN = [resultN, repmat([0], length(classes), 1)];CbestVV  = [CbestVV, repmat([0], length(classes), 1)];
        
       
        %%%MLR-A
        krange = [1];i = 0;resultt = [];
        HLOSS = {'MRR'};
     
        Find = [ind, length(KFea) - 2, length(KFea) - 2];
        Ratio_1 = [-4, -5, -4];
        MLRBalance = [0, 1, 1];
        RC = [0, 0, 0];
        if RatioC
            Find = [ind, length(KFea) - 2, length(KFea) - 2, ...
                length(KFea) - 2, length(KFea) - 2];
            Ratio_1 = [-4, -5, -4, -4, -4];
            MLRBalance = [0, 1, 1, 1, 1];
            multiview = [0, 0.5, 0, 0.5, 0.5];
            RC = [0, 0, 0, 0, 1];
            if NewFea
                Find = [ind, length(KFea) - 2, length(KFea) - 2, ...
                    length(KFea) - 2, length(KFea) - 2, length(KFea)];
                Ratio_1 = [-4, -5, -4, -4, -4, -4];
                MLRBalance = [0, 1, 1, 1, 1, 1];
                multiview = [0, 0.5, 0, 0.5, 0.5, 0.5];
                RC = [0, 0, 0, 0, 1, 0];
            end
        else   
        if ismult
            Find = [ind, length(KFea) - 2, length(KFea) - 2, length(KFea) - 2];
            Ratio_1 = [-4, -5, -4, -4];
            MLRBalance = [0, 1, 1, 1];
            multiview = [0, 0.5, 0, 0.5];
            RC = [0, 0, 0, 0];
        else
            multiview = [0, 0.5, 0];
        end
        end
        
        %%%new feature 03, new method:delete+normlize+BY class
        for mm = 1:length(multiview)
        i = 0;clear 'resultt';clear 'ranktime';pcarange = 0.95;
        crange = crangeMLR;
        i = 0;resultt = [];
        Ntype = 0;
        pcarange = 0.95;winit1 = 0;winit2 = 1;winit = {1, Ninit};
        Nnum = 1;
        N = (Nnum+Ntype);jj = pcarange;
        resultt = [];
        i2 = 1;
        
        
        TrainFun1 = TrainFun; 
        if RatioC
            if mm < length(multiview)
            TrainFun1 = @GetRecogRate_31;
            end
        else
        if isDel
            if mm ~= 2
            TrainFun1 = @GetRecogRate_31;
            end
        else
            if mm < length(multiview)
            TrainFun1 = @GetRecogRate_31;
            else
            
            end
        end
        
        end
        if RRatio == 1 && RatioC && mm == 5
            TrainFun1 = @GetRecogRate_31;
        end
        if strcmp(func2str(TrainFun1), 'GetRecogRate_31') && mm ~= 4 && mm ~= 5
            crange = [10240];
        end
        for tt = 1:length(classes)
            for kk = krange
            for ii = crange
                for kkt = 1:length(HLOSS)
                    %%ewighted metirc
                    LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 3, 2, 0, 0, 200, 100, 1], [0.000001 1], [1]};
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {''}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{{ii, RC(mm)}, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,1,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
                    % weighted Metric+ template
                    LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 1, 2, 0, 0, -100.12, 302, 1], [0.0001 1], [1]};
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {{'', modelresult}}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{{ii, RC(mm)}, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,1,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
                    % weighted Metric+ template+iterative template
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{{ii, RC(mm)}, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,3,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
                    % weighted Metric+ template+iterative M+template
                    LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 1, 2, 0, 0, -100.12, 302], [0.0001 1], [1]};
                    i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{{ii, RC(mm)}, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [kk]}, LOSS{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,3,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
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
        %%%WSMLR_0*-A-T
        end
        resultBTmp{kkki, ct, int, ikk} = resultN;
        resultBest{kkki, ct, int, ikk} = CbestVV;
    end
        
    end
    end
    resultBTmp = resultBTmp(:, range, :, :);
    resultBest = resultBest(:, range, :, :);
    save([dir 'Result/resultBTmpNN', ostr1, '_Best.mat'], 'resultBest', ...
        'resultBTmp');
end


ikkk = 0;
for ct = range
    ikkk = ikkk + 1;
    Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct}; imsize = cimsize{ct};
    for int = 1:length(Ntrain)
        ntr = Ntrain(int);
        ikk = 0;
        for RRatio = RR
            ikk = ikk + 1;
    kkki = 0;
    for kkk = MMulti
        kkki = kkki + 1;resultN = [];ranktimeN = [];
        clear 'resultt';clear 'ranktime';pcarange = 0.95;
        CbestVV = resultBest{kkki, ikkk, int, ikk};
        pcarange = 0.95;winit1 = 0;winit2 = 1;winit = {1, Ninit};
        resultt = [];i = 0;
        
        kkrange = [4]; 
        outdim = [50];
        cntree = [30, 100:100:300];
       
        
        NP = [80, 200, 500, 1000];ntree = cntree(1);
        [i1,i2,i3,i4, i5] = ind2sub([length(NP), length(pcarange), length(ntree), length(kkrange), length(outdim)],...
            CbestVV(length(ranktimeN)+1));
        dim = outdim(i5); kk = kkrange(i4);nt = ntree(i3);jj = pcarange(i2);np = NP(i1);
        resultt = [];ranktime = [];i = 0;i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'lmnn', {'1', classes{tt}}, [kk, dim, np, 1, 0.5, 0], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,Apcompute,1,featnorm);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];

        NP = [500];ntree = cntree;
        [i1,i2,i3,i4, i5] = ind2sub([length(NP), length(pcarange), length(ntree), length(kkrange), length(outdim)],...
            CbestVV(length(ranktimeN)+1));
        tt = 1;dim = outdim(i5); kk = kkrange(i4);nt = ntree(i3);jj = pcarange(i2);np = NP(i1);
        resultt = [];ranktime = [];i = 0;i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'gblmnn', {'1', classes{tt}}, [kk, dim, 500, 1, 0.5, 0, nt], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,Apcompute,1,featnorm);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        tt = 1;ii = CbestVV(length(ranktimeN)+1); jj = pcarange(1);
        resultt = [];ranktime = [];i = 0; i = i + 1;clc;close all; clc;cd(PATH_F);[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'MultiSVM', {'1', classes{tt}}, [ii,1,0], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,Apcompute,1,featnorm);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];

        resultN = [resultN, 0];ranktimeN  = [ranktimeN, 0];
        %%%MLR-A
        krange = [1];i = 0;resultt = [];
        HLOSS = {'MRR'};
     
        Find = [ind, length(KFea) - 2, length(KFea) - 2];
        Ratio_1 = [-4, -5, -4];
        MLRBalance = [0, 1, 1];
        RC = [0, 0, 0];
        if RatioC
            Find = [ind, length(KFea) - 2, length(KFea) - 2, ...
                length(KFea) - 2, length(KFea) - 2];
            Ratio_1 = [-4, -5, -4, -4, -4];
            MLRBalance = [0, 1, 1, 1, 1];
            multiview = [0, 0.5, 0, 0.5, 0.5];
            RC = [0, 0, 0, 0, 1];
            if NewFea
                Find = [ind, length(KFea) - 2, length(KFea) - 2, ...
                    length(KFea) - 2, length(KFea) - 2, length(KFea)];
                Ratio_1 = [-4, -5, -4, -4, -4, -4];
                MLRBalance = [0, 1, 1, 1, 1, 1];
                multiview = [0, 0.5, 0, 0.5, 0.5, 0.5];
                RC = [0, 0, 0, 0, 1, 0];
            end
        else   
        if ismult
            Find = [ind, length(KFea) - 2, length(KFea) - 2, length(KFea) - 2];
            Ratio_1 = [-4, -5, -4, -4];
            MLRBalance = [0, 1, 1, 1];
            multiview = [0, 0.5, 0, 0.5];
            RC = [0, 0, 0, 0];
        else
            multiview = [0, 0.5, 0];
        end
        end
        
        %%%new feature 03, new method:delete+normlize+BY class
        for mm = 1:length(multiview)
        i = 0;clear 'resultt';clear 'ranktime';pcarange = 0.95;
        crange = crangeMLR;
        i = 0;resultt = [];
        Ntype = 0;
        pcarange = 0.95;winit1 = 0;winit2 = 1;winit = {1, Ninit};
        Nnum = 1;
        N = (Nnum+Ntype);jj = pcarange;
        resultt = [];
        i2 = 1;
        
        
        TrainFun1 = TrainFun; 
        if RatioC
            if mm < length(multiview)
            TrainFun1 = @GetRecogRate_31;
            end
        else
        if isDel
            if mm ~= 2
            TrainFun1 = @GetRecogRate_31;
            end
        else
            if mm < length(multiview)
            TrainFun1 = @GetRecogRate_31;
            else
            
            end
        end
        
        end
        if RRatio == 1 && RatioC && mm == 5
            TrainFun1 = @GetRecogRate_31;
        end
        if strcmp(func2str(TrainFun1), 'GetRecogRate_31') && mm ~= 4 && mm ~= 5
            crange = [10240];
        end
        [i1,i22,i3] = ind2sub([length(HLOSS), length(crange), length(krange)],...
            CbestVV(length(ranktimeN)+1));
        tt = 1;kkt = i1;ii = crange(i22); kk = krange(i3);
                    LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 3, 2, 0, 0, 200, 100, 1], [0.000001 1], [1]};
        resultt = [];ranktime = [];i = 0;i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {''}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{{ii, RC(mm)}, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,1,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
        resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        [i1,i22,i3] = ind2sub([length(HLOSS), length(crange), length(krange)],...
            CbestVV(length(ranktimeN)+1));
        tt = 1;kkt = i1;ii = crange(i22); kk = krange(i3);
        LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 1, 2, 0, 0, -100.12, 302, 1], [0.0001 1], [1]};
        resultt = [];ranktime = [];i = 0;i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {{'', modelresult}}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{{ii, RC(mm)}, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,1,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
                    resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        [i1,i22,i3] = ind2sub([length(HLOSS), length(crange), length(krange)],...
            CbestVV(length(ranktimeN)+1));
        tt = 1;kkt = i1;ii = crange(i22); kk = krange(i3);
        LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 1, 2, 0, 0, -100.12, 302, 1], [0.0001 1], [1]};
        resultt = [];ranktime = [];i = 0;i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{{ii, RC(mm)}, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,3,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
                    resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
      
     
    [i1,i22,i3] = ind2sub([length(HLOSS), length(crange), length(krange)],...
            CbestVV(length(ranktimeN)+1));

        tt = 1;kkt = i1;ii = crange(i22); kk = krange(i3);
        LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 1, 2, 0, 0, -100.12, 302], [0.0001 1], [1]};
        resultt = [];ranktime = [];i = 0;i =i + 1;clc;close all; clc;cd(PATH_F);[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{{ii, RC(mm)}, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [kk]}, LOSS{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,3,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
                resultN = [resultN, resultt];ranktimeN  = [ranktimeN, ranktime];
        
        %%%WSMLR_0*-A-T
        end
        resultBTmp{kkki, ct, int, ikk} = resultN;
    end
        
        end
    end
end
resultBTmp = resultBTmp(:, range, :, :);

% % % resultB1 = resultB1(:, range, :, :);
% % % resultBTmp = resultBTmp(:, range, :, :);
cd(PATH_F);

save([dir 'Result/resultBTmpNN', ostr1, '.mat'], 'resultBTmp');