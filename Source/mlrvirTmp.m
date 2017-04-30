dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others';
dataset = {'face', 0};Config = 'sphog';name = [name, str];
% crangeMLR = [32, 128, 512, 1024, 1536, 2048, 10240 20480 40960,51200, 61440, 81920, 102400];



[str,dataset, featurestr, VSNIPPET, classes, classesstr, classnum, ...
    crangeMLR, crangeSVM, strThresh, ratio, row, col, kkrange, outdim, ntree,CNum, crangeSVM1] = GetSetting({dataset{1}, str});
classes = classes(1:end-1);
classesstr = classesstr(1:end-1);
classnum = classnum(1:end-1);


if ~isempty(crangeMLR)
crangeMLR = [512, 1024, 1536, 2048, 10240 20480];
if strcmp(TrainFun, @GetRecogRate_31)
    crangeMLR = [1024, 1536, 2048, 4096];
else
    crangeMLR = [10240];
%     crangeMLR = [1536, 2048];
end
end

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
if ~exist('RR', 'var')
    RR = 1;
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

Wfea = {22404, 22404, 22410, 22410, 22404, 22404, 22410, 22410, 22403, 22403, 22403};
WNorm = {'max2', 'max2', 'max2', 'max2', 'min2', 'min2', 'max4', 'max8', 'max8', 'max4', 'max8'};
Norm = {[1,1], [1,0], [1,1], [1,0], [1,1], [1,0], [1,1], [1,1], [1,1], [1,1], [1,1]};
KFea = {10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10};
weightN = {0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0};


lamda = [0.01:0.02:0.1, 0.2:0.05:0.4,  0.5:0.05:1];
dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
dir = fullfile(dir,str);
if ~exist(dir)
    mkdir(dir)
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

ind = [3];
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


% % % for ct = range
% % %     Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct};   imsize = cimsize{ct};
% % %     for int = 1:length(Ntrain)
% % %         ntr = Ntrain(int);
% % %         for mm = 1:length(MMulti)
% % %         i = 0;resultt = [];
% % %         for tt = 1:length(classes);
% % %         i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'KNN', {'1', classes{tt}}, {}, 1, 0, {RRatio, [], imsize}, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20, 0, 1, {1}, 0, 0, 11, 1);
% % %         i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'INNC', {'1', classes{tt}}, 0.05, 1, 0, {RRatio, [], imsize}, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20, 0, 1, {1}, 0, 0, 11, 1);
% % %         end 
% % %         resultB1{mm, ct, int} = resultt;
% % %         end
% % %     end
% % % end


TempNorm = [2];
PCAM =0;
% % lamda = [0.05];
cd 'D:\MinTan\project\Signdetect\SignClassify';
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

if ~exist('Ninit', 'var')
    Ninit = 0;
end

if ~exist('featnorm', 'var')
    featnorm = 0;
end
if ~exist('indindex', 'var')
indindex = 0;
end

winit1 = 0;winit2 = 1;winit = {1, Ninit};
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

        
        
        resultt = [];i = 0;
        crange = [0.1250, 2, 32, 512];
        pcarange = 0.95;winit1 = 0;winit2 = 1;winit = {1, Ninit};
        resultt = [];i = 0;
        
        kkrange = [4]; 
        outdim = [50, 100, 0];
        outdim = [50, 100];
        outdim = [50];
%         if length(str) > 4 && strcmp(str(1:5), '_PIE5') && Vout
%             outdim = [50, 100];
%         end
        try
            ntree = ntree(1);
        end
        
        % ntree = [100:100:300];
        if ~isempty(outdim) && outdim(1) > 0
            for dim = outdim
                for kk = kkrange
         for nt = ntree
         for jj = pcarange
             for tt = 1:length(classes); 
                 try
                     i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'lmnn', {'1', classes{tt}}, [kk, dim, 80, 1, 0.5, 0], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,1,1,featnorm);
                     i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[temp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, str, Config,{'sift'},'lmnn', {'1', classes{tt}}, [kk, dim, 1000, 1, 0.5, 0], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,1,1,featnorm);
                 catch
                     cd 'D:\MinTan\project\Signdetect\SignClassify';resultt(end+1:end+2) = 0; ranktime(end+1:end+2) = 0; 
                 end
             end
         end
         end
                end    
            end
        else
            outdim = -outdim;
        end
        try
            resultt = (reshape(resultt, [length(classes), 2*length(outdim) * length(kkrange) * length(ntree)]))';
            [resultt, Vbaset] = max(resultt);
            resultN(:,end+1) = resultt(:);CbestVV(:,end+1) = Vbaset;
        catch
            resultN = [resultN, repmat([0], length(classes), 1)];CbestVV  = [CbestVV, repmat([0], length(classes), 1)];
        end
        

        crange = crangeSVM;
        pcarange = 0.95; Ntype = 1;N = (0+Ntype);
        i = 0; resultt = [];ranktime= [];
        for jj = pcarange
            for ii = crange
                for tt = 1:length(classes);
                    i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'MultiSVM', {'1', classes{tt}}, [ii,1,0], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,1,1,featnorm);
                end
            end
        end
        try
            resultt = reshape(resultt, [N,  length(classes), length(crange)]);
            [resultt, Vbaset] = max(resultt, [], 3);
            CbestV = (crange(Vbaset))';
            resultN = [resultN, resultt'];CbestVV  = [CbestVV, CbestV];
        catch
            resultN = [resultN, repmat([0], length(classes), 1)];CbestVV  = [CbestVV, repmat([0], length(classes), 1)];
        end
        crange = crangeSVM1;
        i = 0; resultt = [];ranktime= [];
        for jj = pcarange
            for ii = crange
                for tt = 1:length(classes);
                    i = i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[temp, resultt(i), ranktime(i), ] = TrainFun(dataset, str, Config,{'sift'},'MultiSVM', {'1', classes{tt}}, [ii,1,2], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,Voting,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,1,1,featnorm);
                end
            end
        end
        try
            resultt = reshape(resultt, [N,  length(classes), length(crange)]);
            [resultt, Vbaset] = max(resultt, [], 3);
            CbestV = (crange(Vbaset))';
            resultN = [resultN, resultt'];CbestVV  = [CbestVV, CbestV];
        catch
            resultN = [resultN, repmat([0], length(classes), 1)];CbestVV  = [CbestVV, repmat([0], length(classes), 1)];
        end
        
        
        
% % % % % % % %         %%%MLR-A
% % % % % % % %         krange = [1];i = 0;resultt = [];
% % % % % % % %         LOSS = {{[2, 3, 1, 100, 1, 10, 10, 1, 10, 0, 0, 0, 1, 1000, 1], [0.000001 1], [1], [0.05], [1]},...
% % % % % % % %                 {[2, 3, 1, 100, 1, 10, 10, 1, 100, 6, 0, 0, 1, 1000, 1], [0.000001 1], [1], [0.05], [1]}};
% % % % % % % %         LOSSPRE = {{[2, 3, 1, 100, 1, 10, 10, 1, 10, 0, 0, 0, 1], [0.000001 1], [1], [0.05], [1]},...
% % % % % % % %                 {[2, 3, 1, 100, 1, 10, 10, 1, 100, 6, 0, 0, 1], [0.000001 1], [1], [0.05], [1]}};
% % % % % % % %         HLOSS = {'MRR', 'HINGE'};
% % % % % % % % %         LOSSPRE{i2}{4} = 0.05;
% % % % % % % %         for mm = 1:length(multiview)
% % % % % % % %         i = 0;clear 'resultt';clear 'ranktime';pcarange = 0.95;
% % % % % % % %         crange = crangeMLR;
% % % % % % % %         i = 0;resultt = [];
% % % % % % % %         Ntype = 0;
% % % % % % % %         pcarange = 0.95;winit = {1, Ninit}
% % % % % % % %         Nnum = 1;
% % % % % % % %         N = (Nnum+Ntype);jj = pcarange;
% % % % % % % %         resultt = [];
% % % % % % % %         for tt = 1:length(classes);
% % % % % % % %             ind = ParaB{kkki, ct}{1}(tt);
% % % % % % % %             for kk = krange
% % % % % % % %             for ii = crange
% % % % % % % %                 for kkt = 1:length(HLOSS)
% % % % % % % %                     for i2 = 1:length(LOSS)
% % % % % % % %                         [~, ~, ~, ~, modelresult] = TrainFun(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, 'MRR', 1, 1, 0, 1, 3, 0, 0, 1}, [kk]}, LOSSPRE{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,1);
% % % % % % % %                         i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = TrainFun(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, 0, 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}},1,1,0,1);
% % % % % % % %                     end
% % % % % % % %                 end
% % % % % % % %             end
% % % % % % % %             end
% % % % % % % %         end

        %%%MLR-A
        krange = [1];i = 0;resultt = [];
        
        LOSS = {{[2, 3, 1, 100, 1, 10, 10, 1, 10, 0, 0, 0, 1, 1000, 1], [0.000001 1], [1], [0.05], [1]},...
            {[2, 3, 1, 100, 1, 10, 10, 1, 5, 0, 0, 0, 1, 100, 1], [0.000001 1], [1], [0.05], [1]},...
            {[2, 3, 1, 100, 1, 10, 10, 1, 3, 0, 0, 0, 1, 100, 1], [0.000001 1], [1], [0.05], [1]},...
            {[2, 3, 1, 100, 1, 10, 10, 1, 3, 2, 0, 0, 1, 100, 1], [0.000001 1], [1], [0.05], [1]},...
            {[2, 3, 0, 100, 1, 10, 10, 1, 3, 2, 0, 0, 1, 100, 1], [0.000001 1], [1], [0.05], [1]},...
{[2, 3, 20, 100, 1, 10, 10, 1, 3, 2, 0, 0, 20, 100, 1], [0.000001 1], [1], [0.05], [1]}};
        LOSSPRE = {{[2, 3, 1, 100, 1, 10, 10, 1, 10, 0, 0, 0, 1], [0.000001 1], [1], [0.05], [1]},...
            {[2, 3, 1, 100, 1, 10, 10, 1, 5, 0, 0, 0, 1, 100], [0.000001 1], [1], [0.05], [1]},...
            {[2, 3, 1, 100, 1, 10, 10, 1, 3, 0, 0, 0, 1, 100], [0.000001 1], [1], [0.05], [1]},...
            {[2, 3, 1, 100, 1, 10, 10, 1, 3, 2, 0, 0, 1, 100], [0.000001 1], [1], [0.05], [1]},...
            {[2, 3, 0, 100, 1, 10, 10, 1, 3, 2, 0, 0, 1, 100], [0.000001 1], [1], [0.05], [1]},...
{[2, 3, 20, 100, 1, 10, 10, 1, 3, 2, 0, 0, 20, 100], [0.000001 1], [1], [0.05], [1]}};
         
             
     
     HLOSS = {'MRR'};
%         LOSSPRE{i2}{4} = 0.05;
        for mm = 1:length(multiview)
        i = 0;clear 'resultt';clear 'ranktime';pcarange = 0.95;
        crange = crangeMLR;
        i = 0;resultt = [];
        Ntype = 0;
        pcarange = 0.95;winit1 = 0;winit2 = 1;winit = {1, Ninit};
        Nnum = 1;
        N = (Nnum+Ntype);jj = pcarange;
        resultt = [];
        for tt = 1:length(classes)
            for kk = krange
            for ii = crange
                for kkt = 1:length(HLOSS)
                    for i2 = 1:length(LOSS)
                        if indindex && i2 == length(LOSS)  
                            indd = [length(Wfea)-2,length(Wfea)-1,length(Wfea)];   
                        else
                            indd = [ParaB{kkki, ct}{1}(tt)];
                        end
                        for ind = indd
                        if i2 < length(LOSS) - 3
                            i =i + 1;resultt(i) = 0; ranktime(i) = 0;
                            i =i + 1;resultt(i) = 0; ranktime(i) = 0;
                            i =i + 1;resultt(i) = 0; ranktime(i) = 0;
% %                             [~, ~, ~, ~, modelresult] = GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, 'MRR', 1, 1, 0, 1, 3, 0, 0, 1}, [kk]}, LOSSPRE{i2}], 1, 0, {{VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20,0,[1], {1},1,0,0,1);
% %                             i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, 0, 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {{VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}},1,1,0,1);
                        else
                            TrainFun1 = TrainFun;                   
                            if indindex
                                if i2 ~= length(LOSS)   
                                    TrainFun1 = @GetRecogRate_31; 
                                end
                            end
                            
%                             if strcmp(str(1:5), '_PIE7')
%                                 if i2 == length(LOSS)
%                                 TrainFun1 = @GetRecogRate_31;
%                                 end
%                             end
%                             if ~strcmp(str(1:5), '_PIE7')
%                                 if i2 == length(LOSS)-1
%                                 TrainFun1 = @GetRecogRate_31;
%                                 end
%                             end
                            i =i + 1;cd 'D:\MinTan\project\Signdetect\SignClassify';[~, resultt(i), ~, ~, modelresult] =  GetRecogRate_31(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, 'MRR', 1, 1, 0, 1, 3, 0, 0, 1}, [kk]}, LOSSPRE{i2}], 1, 0, {{VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20,winit1,[1], {1},1,0,0,1,1,featnorm);
                            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, 0, 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {{VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit2,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}, weightN{ind}},1,1,0,1,1,featnorm);
                            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, 0, 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {{VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,5,1,0,1], {-4,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}, weightN{ind}},1,1,0,1,1,featnorm);
                        end
                    end
                end
            end
            end
            end
        end
        if ~isempty(crangeMLR)
            
            resultN = [resultN, max(resultt(1:3:end))];
            resultt1 = resultt;
        
            resultt = resultt1(2:3:end);
            [~, ord] = max(resultt);[i2, kkt, i3, i4, i5] = ind2sub([length(LOSS), length(HLOSS), length(crange), length(krange), length(indd)], ord);
            kk = krange(i4);ii = crange(i3);ind = indd(i5);
            resultt = []; i = 0;
        
            cd 'D:\MinTan\project\Signdetect\SignClassify';[~, ~, ~, ~, modelresult] = TrainFun(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, 'MRR', 1, 1, 0, 1, 3, 0, 0, 1}, [kk]}, LOSSPRE{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20,winit1,[1], {1},1,0,0,1,1,featnorm);
            for lam = lamda
                LOSS{i2}{4} = lam;
                i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = TrainFun(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, 0, 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit2,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}},1,1,0,1,1,featnorm);
            end
            resultN = [resultN, max(resultt)];
            LOSS{i2}{4} = 0.05;
            
            
            resultt = resultt1(3:3:end);
            [~, ord] = max(resultt);[i2, kkt, i3, i4, i5] = ind2sub([length(LOSS), length(HLOSS), length(crange), length(krange), length(indd)], ord);
            kk = krange(i4);ii = crange(i3);ind = indd(i5);
            resultt = []; i = 0;
        
            cd 'D:\MinTan\project\Signdetect\SignClassify';[~, ~, ~, ~, modelresult] = TrainFun(dataset, str, Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, 'MRR', 1, 1, 0, 1, 3, 0, 0, 1}, [kk]}, LOSSPRE{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,kkk,0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20,winit1,[1], {1},1,0,0,1,1,featnorm);
            for lam = lamda
                LOSS{i2}{4} = lam;
                i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = TrainFun(dataset, [str, {[-1]}, {[]}, {modelresult}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, 0, 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {RRatio, {VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,5,1,0,1], {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}},1,1,0,1,1,featnorm);
            end
            resultN = [resultN, max(resultt)];
            LOSS{i2}{4} = 0.05;
        end
        %%%WSMLR_0*-A-T
        end
    end
        resultBTmp{kkki, ct, int, ikk} = resultN;
    end
    end
end



resultB1 = resultB1(:, range, :);
resultBTmp = resultBTmp(:, range, :);
cd 'D:\MinTan\project\Signdetect\SignClassify';
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


if strcmp(func2str(TrainFun), 'GetRecogRate_31') || strcmp(func2str(TrainFun), 'GetRecogRate_33')
    save(['resultBTmpNNTemp1', str, '.mat'], 'resultBTmp');
end
if strcmp(func2str(TrainFun), 'GetRecogRate_3')
    save(['resultBTmpNNTemp', str, '.mat'], 'resultBTmp');
end
% % % % % % % % % % % % % addpath(genpath('D:\MinTan\project\Signdetect\SignClassify\Tool'))
% % % % % % % % % % % % % cd 'D:\MinTan\project\Signdetect\SignClassify';
% % % % % % % % % % % % % TS = {'MLR-T', 'MLR*-T', 'Our(0)-D', 'Our-D' 'Our(0)-C', 'Our-C'};
% % % % % % % % % % % % % TS1 = {'Template', 'Sample'};
% % % % % % % % % % % % % load(['resultBTmpNN', str, '.mat'], 'resultBTmp');
% % % % % % % % % % % % % resultBTmp1 = resultBTmp;
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
% % % 
% % % TS = {'NN', 'INNC', 'Our(0)-D', 'Our(0)-C'};
% % % for mm = 1:length(MMulti)
% % %     strs = [str cConfig{range(1)}, 'MV', num2str(MMulti(mm))];
% % %     plotFigC(Ntrain, (MRes(:, :, mm))', TS, ['Temp_KMEAN', strs], 'Method', ...
% % %         'Per-class accuracy (%)', 0, dir, {1, loc}, 1, 1, 0, 0, [1, 1], 0);
% % % end