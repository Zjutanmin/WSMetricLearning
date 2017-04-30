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

if ~exist('Lambda', 'var')
    Lambda = 0.0001;
end

Wfea = {22404, 22404, 22410, 22410, 22404, 22404, 22410, 22410, 22403, 2403, 2403};
WNorm = {'max2', 'max2', 'max2', 'max2', 'min2', 'min2', 'max4', 'max8', 'max4', 'max4', 'max8'};
Norm = {[1,1], [1,0], [1,1], [1,0], [1,1], [1,0], [1,1], [1,1], [1,1], [1,1], [1,1]};
KFea = {10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10};
weightN = {0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1};

lamda = [0.01:0.02:0.1, 0.2:0.05:0.4,  0.5:0.05:1];
cd 'K:\Tanmin\project\Signdetect\SignClassify';
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

resultB1 = cell(length(multiview), length(cDOGfig), length(Ntrain));
for ct = range
    kkki = 0;
    for kkk = MMulti
        kkki = kkki + 1;ParaB{kkki, ct}{1}(1)  = 3;
    end
end
PCAM ={{0.95, 'LDA', 1, 1}};
if ~isempty(crangeSVM)
%     if length(RR) == 1
%     crangeSVM = [];
%     crangeSVM1 = [];
%     else
%     crangeSVM = crangeSVM(1:2:end);
%     crangeSVM1 = crangeSVM1(1:2:end);
%     end
end
KNNrange = [1, 5, 10, 15, 20, 30, 40, 50, 60, 70, 80, 90, 100];
% % % for ct = range
% % %     Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct};   imsize = cimsize{ct};
% % %     for int = 1:length(Ntrain)
% % %         ntr = Ntrain(int);
% % %         for mm = 1:length(MMulti)
% % %         i = 0;resultt = [];
% % %         for tt = 1:length(classes);
% % %         i = i + 1;clc;close all; clc;cd 'K:\Tanmin\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, str, Config,{'sift'},'KNN', {'1', classes{tt}}, {}, 1, 0, {{VirTest, '_PIE'}, imsize}, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20, 0, 1, {1}, 0, 0, 11, 1);
% % %         i = i + 1;clc;close all; clc;cd 'K:\Tanmin\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = TrainFun1(dataset, str, Config,{'sift'},'INNC', {'1', classes{tt}}, 0.05, 1, 0, {{VirTest, '_PIE'}, imsize}, -1, [4,8,16], 100, 1,MMulti(mm),0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20, 0, 1, {1}, 0, 0, 11, 1);
% % %         end 
% % %         resultB1{mm, ct, int} = resultt;
% % %         end
% % %     end
% % % end


TempNorm = [2];
PCAM =0;
% % lamda = [0.05];
cd 'K:\Tanmin\project\Signdetect\SignClassify';
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

for ct = range
    Config = cConfig{ct};DOGfig = cDOGfig{ct};npyra = cnpyra{ct}; imsize = cimsize{ct};
    for int = 1:length(Ntrain)
        ntr = Ntrain(int);
    kkki = 0;
    for kkk = MMulti
        kkki = kkki + 1;resultN = [];CbestVV = [];
        clear 'resultt';clear 'ranktime';pcarange = 0.95;
        
        resultt = [];i = 0;ranktime = [];
        crange = [0.1250, 2, 32, 512];
        pcarange = 0.95;winit1 = 0;winit2 = 1;winit = {1, Ninit};
        resultt = [];i = 0;
           
        %%%MLR-A
        krange = [1];i = 0;resultt = [];
        HLOSS = {'MRR'};
     
        Find = [length(KFea) - 2];
        Ratio_1 = [-4];
        MLRBalance = [1];
        multiview = [ 0];
        %%%new feature 03, new method:delete+normlize+BY class
        
%         for mm = 1:length(multiview)
        for mm = length(multiview)
        
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
        if mm < length(multiview)
            TrainFun1 = @GetRecogRate_31;
        end       
        resultN = [];
        Lambda_best = 0.0001;
        
        
        modelresult = '';
        i = 0; resultt = [];
        for tt = 1:length(classes)
            for kk = krange
            for ii = crange
                for kkt = 1:length(HLOSS)
                    LOSS{i2} = {[2, 3, 20, 100, 1, 10, 10, 1, 1, 2, 0, 0, -100.12, 302, 1], [Lambda_best 1], [1]};
                    i =i + 1;clc;close all; clc;cd 'K:\Tanmin\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {{'', modelresult}}, [1]], Config,{'sift'},'MLR', {'1',classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {{VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,1,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,0,Apcompute,1,featnorm);
                    
                    for KNN = KNNrange
                    %ewighted metirc
                    i =i + 1;clc;close all; clc;cd 'K:\Tanmin\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {{'', modelresult}}, [1]], Config,{'sift'},'MLR', {['-' num2str(KNN)],classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {{VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,1,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,11,Apcompute,1,featnorm);
                    i =i + 1;clc;close all; clc;cd 'K:\Tanmin\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {{'', modelresult}}, [1]], Config,{'sift'},'MLR', {num2str(KNN),classes{tt}}, [{{ii, HLOSS{kkt}, 1, 1, 0, 1, 3, MLRBalance(mm), 0, 1}, [{kk, 1}]}, LOSS{i2}], 1, 0, {{VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,4,[],0,{-10, ntr},PCAM,0,0,20,winit,[1,1,1,0,1], {Ratio_1(mm),[],Wfea{Find(mm)},KFea{Find(mm)}, 'Reciprocal',0,1,1, 'NA', WNorm{Find(mm)},Norm{Find(mm)}, weightN{Find(mm)}},1,1,11,Apcompute,1,featnorm);
                    
                    i =i + 1;clc;close all; clc;cd 'K:\Tanmin\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {{'', modelresult}}, [1]], Config,{'sift'},'KNN', {['-' num2str(KNN)],classes{tt}}, {}, 1, 0,  {{VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20, 0, 1, {1}, 1, 0, 11, Apcompute,1,featnorm);
                    i =i + 1;clc;close all; clc;cd 'K:\Tanmin\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ~, modelresult] = TrainFun1(dataset, [str, {[-1]}, {[]}, {{'', modelresult}}, [1]], Config,{'sift'},'KNN', {num2str(KNN),classes{tt}}, {}, 1, 0,  {{VirTest, newdata}, imsize}, -1, [4,8,16], 100, 1,{multiview(mm), kkk},0,DOGfig,'',0,npyra,0,0.5,0,'',0,2,[],0,{-10, ntr},PCAM,0,0,20, 0, 1, {1}, 1, 0, 11, Apcompute,1,featnorm);
                    
                    end
                end
            end
            end
        end
        
        if ~isempty(crangeMLR)
            NT = 1+4*length(KNNrange);
            resultN = [resultN, max(resultt(1:NT:end))];
            ikk = 1;
            for KNN = KNNrange
                resultN = [resultN, max(resultt(ikk+1:NT:end))];
                resultN = [resultN, max(resultt(ikk+2:NT:end))];
                resultN = [resultN, max(resultt(ikk+3:NT:end))];
                resultN = [resultN, max(resultt(ikk+4:NT:end))];
                ikk = ikk + 4;
            end
        end
        end
    end
        resultBTmp{kkki, ct, int} = resultN;
    end
end


% resultB1 = resultB1(:, range, :);
% resultBTmp = resultBTmp(:, range, :);
cd 'K:\Tanmin\project\Signdetect\SignClassify';
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

if strcmp(func2str(TrainFun), 'GetRecogRate_31') || strcmp(func2str(TrainFun), 'GetRecogRate_33') || strcmp(func2str(TrainFun), 'GetRecogRate_33')
    save([dir 'Result\resultBTmpNNTemp1_N_Lamda', str, '.mat'], 'resultBTmp');
end
if strcmp(func2str(TrainFun), 'GetRecogRate_3')
    save([dir 'Result\resultBTmpNNTemp_N_Lamda', str, '.mat'], 'resultBTmp');
end
close all;
% % % load([dir 'Result\resultBTmpNNTemp_N_Lamda', str, '.mat'], 'resultBTmp');
resultN = resultBTmp{1};
TTmp = resultN(end-(1+4*length(KNNrange))+1:end);



TTmp(4:4:end) = 0; 
TTmp(5:4:end) = 0;
idx = find(TTmp);

i1 = KNNrange(1);i2 = KNNrange(end);m1 = i2 - i1;
i3 = min(TTmp(idx));i4 = max(TTmp(idx));m2 = i4 - i3;
i1 = i1 - m1*0.001;i2 = i2+m1*0.001;
i3 = i3 - m2*0.001;i4 = i4+m2*0.1;
Fbar = TTmp(1);
TTmp = reshape(TTmp(2:end), 4, []);
% % % TTS = {'Sample(W,S)', 'Sample(W,M)', 'Sample(E,S)', 'Sample(E,M)'};
% % % loc = 'Best';
% % % plotFigC(KNNrange, TTmp', TTS, {['Temp_KMEAN_KNN', str], 1, 1}, 'K', ...
% % %     'Accuracy (%)', 0, dir, {1, loc}, 0, 1, 0, 0, [1, 1], 0, [i1, i2, i3, i4]);TTS = {'Sample(W,S)', 'Sample(W,M)', 'Sample(E,S)', 'Sample(E,M)'};

TTS = {'Sample(S)', 'Sample(M)'};TTmp = TTmp(1:2,:);
loc = 'Best';
plotFigC(KNNrange, TTmp', TTS, {['Temp_KMEAN_KNN', str], 1, 1}, 'K', ...
    'Accuracy (%)', 0, dir, {1, loc}, 0, 1, 0, 0, [1, 1], 0, [i1, i2, i3, i4]);

hold on; 
tStyle = GetStyle_zyt(); 
styleID = length(TTS)+1;
plot([min(KNNrange):max(KNNrange)], Fbar,'-.*',...
    'LineWidth', 1, 'MarkerFaceColor', tStyle(styleID).MarkerFaceColor,...
    'Color', tStyle(styleID).scolor);
[sizetitle,sizelengend, sizelabel, sizetick] = getsize(1);
text(i2-40, i4-3, ['Templates:', num2str(savedot(Fbar, 2))], ...
    'fontsize', sizetitle, 'Color', [1 0 0]);
name = ['Temp_KMEAN_KNN', str];
print(gcf, '-djpeg', '-r0', [dir name '.jpg']);
saveas(gca,[dir name '.fig']);
print(gcf, '-depsc2','-r0', [dir name '.eps']);