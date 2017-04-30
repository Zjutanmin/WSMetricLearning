name = 'Class-others';
dataset = {'face', 0};Config = 'sphog';name = [name, str];
[str,dataset, featurestr, VSNIPPET, classes, classesstr, classnum, ...
    crangeMLR, crangeSVM, strThresh, ratio, row, col, kkrange, outdim, ntree,CNum, crangeSVM1] = GetSetting({dataset{1}, str});
range = 1;


crangeMLR = [1536, 2048];
cConfig = {'PixelO', 'sphog', 'PixelM', 'sphogM', 'Pixel1', 'sphog1', 'PixelM1', 'sphogM1'};
cDOGfig = {'','', '','', '','', '',''};
cimsize = {[32, 32], [32, 32], [32, 32], [32, 32],[32, 32], [32, 32], [32, 32], [32, 32]};
cnpyra = {0, 0, 0, 0,0, 0, 0, 0};
TS = {'LMNN', 'WSML', 'WSMTL', 'WSMTL(I)', 'Our'};
if ~exist('RR', 'var')
    RR = 1;
end
TS = [TS(1),{'gbLMNN', 'LSVM', 'KSVM'}, TS(2:end)];

if ~exist('iirange', 'var')
    iirange = [1:length(TS)];
end

NT = length(TS);
Ntrain = [0.3, 0.4, 0.5, 0.6, 0.7];
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
if ~exist('TBest', 'var')
    TBest = 0;
end


if ~exist('isdegree', 'var')
    isdegree = 0;
end

if isdegree
    cstr = {{ '_PIE68', '_PIE65', '_PIE69'},...
        { '_PIE78', '_PIE75', '_PIE79'}};
    ctitle = {'Occlusion', 'Corruption'};
    Jindex = [2, 2];
    if Numtrain == 30
    cstr = {{ '_PIE411', '_PIE118',  '_PIE412',  '_PIE115',  '_PIE413',  '_PIE119'},...
    { '_PIE218',  '_PIE215',  '_PIE219'},...
    { '_PIE513',  '_PIE514',  '_PIE515', '_PIE516',  '_PIE517',  '_PIE518'}};
ctitle = {'Occlusion', 'Corruption', 'Corruption'};Jindex = [4, 2, 5];
SSRatio = {[0.3 0.4 0.5 0.6 0.7 0.8], [0.3 0.4 0.5 0.6 0.7 0.8],...
    [0.3 0.4 0.5 0.6 0.7 0.8]};
xtitlestr = {'Percent occluded', 'Percent corrupted', 'Percent corrupted'};
    end
    if newd == -1
    cnewd = { '_PIE',  '_PIE',  '_PIE'};
    else
    cnewd = { '_PIE65',  '_PIE75',  '_PIE85'};
    end
    Ntrain = [1, 2, 3];
else
    cstr = {{ '_PIE61',  '_PIE62',  '_PIE63',  '_PIE64',  '_PIE65'},...
        { '_PIE71',  '_PIE72',  '_PIE73',  '_PIE74',  '_PIE75'}};
    ctitle = {'Occlusion', 'Corruption'};Jindex = [3,3];
    if Numtrain == 30
    cstr = {{ '_PIE113',  '_PIE114',  '_PIE115',  '_PIE116',  '_PIE117'},...
    { '_PIE214',  '_PIE215',  '_PIE216'},...
    { '_PIE615',  '_PIE616',  '_PIE517',  '_PIE618',  '_PIE619'}};
ctitle = {'Occlusion', 'Corruption', 'Corruption'};Jindex = [3,2,3];
    end
    if newd == -1
    cnewd = { '_PIE',  '_PIE',  '_PIE'};
    else
    cnewd = { '_PIE6',  '_PIE7',  '_PIE8'};
    end
end

addpath(genpath(fullfile(PATH_F,'Tool')))
sstr = '';
if TBest
    sstr = '_N';
end

MMulti = [0];
PCAM ={{0.95, 'LDA', 1, 1}};
cd(PATH_F)
close all;
orgstr = str;
PCAStr = 'PCA0.95NF';
if ~exist('Vout', 'var')
    Vout = 0;
end
PCAStr1 =  PCAStr;
if Vout
    PCAStr1 =  [PCAStr1, 'L'];
end

if ~exist('featnorm', 'var')
    featnorm = 1;indindex = 1;indindex = 1;
end

NP = length(PCAStr);



SStr = '';
if exist('VirTest', 'var') && VirTest
    SStr = num2str(VirTest);
end
% SStr = [SStr, PCAStr(NP+1:end)];
PCAStr=[PCAStr, SStr];PCAStr1=[PCAStr1, SStr];
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
    loc = {1, 'Best'};
else
    loc = 'Best';
end


strsuffix  = '';

if featnorm
    strsuffix =  [strsuffix, 'FN'];
end
if indindex
    strsuffix =  [strsuffix, 'M'];
end
if ~exist('PerC', 'var')
    PerC = 0;
end
if PerC
    strsuffix =  [strsuffix, 'C'];
end
for i = 1:length(Ntrain)
    tmp = num2str(Ntrain(i));
    XTitlestr1{i} = ['R', tmp(2:end)];
end
        

figure(1);
RRV = RR(end:-1:1);
if length(RR) > 1
for i = 1:length(cstr)
    cstr{i} = cstr{i}(Jindex(i));
end
end
if ~exist('Srange', 'var')
    Srange = [1:length(cstr)];    
end
cstr = cstr(Srange);ctitle = ctitle(Srange);
try
    SSRatio = SSRatio(Srange);xtitlestr = xtitlestr(Srange);
end

row = length(Srange);col = 1;
if length(RR) ~= 1
    row = length(cstr{1});col = 1;
end

for kk = 1:length(cstr)
    if length(RR) ~= 1
        close all
        figure(1);
    end
    TrainFun1 = TrainFun;Ntrain1 = Ntrain;
for i = 1:length(range)
    MRes = zeros([NT*length(RR), length(cstr{kk}), length(MMulti)]);
    for j = 1:length(cstr{kk})
        if Vout && kk == 3
            str = [cstr{kk}{j}, PCAStr1];
        else
            str = [cstr{kk}{j}, PCAStr];
        end
        if Ninit == 1 && kk ~= 2
            str =  [str, 'TN'];
        end
        if Ninit == 11 && kk ~= 2
            str =  [str, 'TNN'];
        end
        if Ninit == 21 && kk ~= 2
            str =  [str, 'TN2'];
        end
        str =  [str, strsuffix];
        if exist('newd', 'var') && newd
            str =  [str, cnewd{kk}];
        end
        if length(RR)~=1
            for rr = RR
                tmp = num2str(rr);
                str = [str, tmp(2:end)];
            end
        end
        

        
    try
% % % %         if strcmp(func2str(TrainFun), 'GetRecogRate_31')
% % % %             load(['resultBTmpNNTemp1', sstr, str, '.mat'], 'resultBTmp');
% % % %             save([dir 'Result\resultBTmpNNTemp1', sstr, str, '.mat'], 'resultBTmp');
% % % %         end
% % % %         if strcmp(func2str(TrainFun), 'GetRecogRate_3')
% % % %             load(['resultBTmpNNTemp', sstr, str, '.mat'], 'resultBTmp');
% % % %             save([dir 'Result\resultBTmpNNTemp', sstr, str, '.mat'], 'resultBTmp');
% % % %         end
        cdir = fullfile('figure\WSMTL\', cstr{kk}{j});cdir = [cdir, '\'];

        if strcmp(func2str(TrainFun), 'GetRecogRate_31')
            load([cdir 'Result\resultBTmpNNTemp1', sstr, str, '.mat'], 'resultBTmp');
        end
        if strcmp(func2str(TrainFun), 'GetRecogRate_3')
            load([cdir 'Result\resultBTmpNNTemp', sstr, str, '.mat'], 'resultBTmp');
        end
        
        res1 =  reshape((cell2mat(resultBTmp)), [], length(RR));
        if size(res1, 1) ~= NT
            RRD = res1(5:end,:);
            if length(RR) > 1
                disp = RRD(:, end) - RRD(:, 1);
            else
                disp = RRD;
            end
            disp = reshape(disp, 4, []);
            [IIind,JJind] = ind2sub(size(disp), (find(disp<=0)));
            JJind = setdiff([1:size(disp, 2)], JJind);
            disp = disp([1, 4], JJind);
            if length(RR) > 1
                [~, ord] =min(mean(disp, 1));
            else
                [~, ord] =max(sum(disp));
            end
            JJind = JJind(ord);
            
            disp = res1(end-3:end, end);
            
            res1 =  res1([1:4, 4+(JJind-1)*4+1:4+JJind*4],:);
            
            if nnz(find(res1(end-3:end, end))) < 4
                res1(end-3:end, end) = disp;
            end
        end
        res1 = res1(:);
    catch
        res1 =  zeros( [NT*length(RR), 1]);
    end
    RE1 = [res1];
    for mm = 1:length(MMulti)
        Res1 = RE1(:,mm);
        try
            MRes(:, j, mm) = Res1;
        catch
            MRes(:, j, mm) = zeros( [NT*length(RR), 1]);
        end
    end
    end
%     MRes   
    for mm = 1:length(MMulti)
        
        if length(RR) ~= 1
            strs = [orgstr cConfig{range(1)}, 'MV', num2str(MMulti(mm)), sstr, PCAStr(NP+1:end), ctitle{kk}];
        else
            strs = [orgstr cConfig{range(1)}, 'MV', num2str(MMulti(mm)), sstr, PCAStr(NP+1:end)];
        end
        if NT == 2
            strs = [strs, num2str(NT)];
        end
        if Vout
            strs = [strs, 'L'];
        end
        strs =  [strs, strsuffix];
        if exist('newd', 'var') && newd
            strs =  [strs, 'N'];
        end
        if isdegree
            strs =  [strs, 'D'];
        end
        if Numtrain~=70
            strs =  [strs, num2str(Numtrain)];
        end
        if PerC
            strs =  [strs, 'C'];
        end
        for kkt = 1:length(Srange)
            strs =  [strs, num2str(Srange(kkt))];
        end
        if length(RR) == 1
            issave = 0;TTS = {};
            if kk == length(cstr)
                issave = 1;TTS = TS;
            end
            if ~isempty(TTS)
                    TTS = TTS(iirange);
            end
            subplot(col, row, kk);
            if length(Srange) > 1
                title(ctitle{kk})
            end
            TTmp = (MRes(:, :, mm))';
            imin = min(TTmp(find(TTmp)));imax = max(TTmp(find(TTmp)));
            TTmp(find(~TTmp)) = imin - 0.5*(imax - imin);
            tNtrain = Ntrain;
            if isdegree
                tNtrain = [1:size(TTmp, 1)];
            end
            imin = min(min(TTmp(:, iirange)));imax = max(max(TTmp(:, iirange)));
            imargin =(imax-imin);
            imin = imin - imargin*0.001;
            imax = imax + imargin*0.001;
            
            if isdegree
                jmargin = max(SSRatio{kk}) - min(SSRatio{kk});
                jmin = min(SSRatio{kk}) - jmargin*0.001;
                jmax = max(SSRatio{kk}) + jmargin*0.001;
                plotFigC(SSRatio{kk}, TTmp(:, iirange), TTS, {['Temp_KMEAN', strs, SStr], 1, issave}, xtitlestr{kk}, ...
                'Accuracy (%)', 0, dir, {1, loc}, 0, 1, 0, 0, [1, 1], 0, [jmin jmax imin imax]); 
            else
                jmargin = max(tNtrain) - min(tNtrain);
                jmin = min(tNtrain) - jmargin*0.001;
                jmax = max(tNtrain) + jmargin*0.001;
                plotFigC(tNtrain, TTmp(:, iirange), TTS, {['Temp_KMEAN', strs, SStr], 1, issave}, 'Ratio of occluded samples', ...
                'Accuracy (%)', 0, dir, {1, loc}, 0, 1, 0, 0, [1, 1], 0, [jmin jmax imin imax]); 
            end
            
        else
            
            MMR = (MRes(:, :, mm))';
            for rr = 1:length(cstr{1})
                issave = 0;TTS = {};
                if rr == length(cstr{1})
                    issave = 1;TTS = TS;
                end
                if ~isempty(TTS)
                    TTS = TTS(iirange);
                end
                subplot(col, row, rr);
                try
                Res = (reshape(MMR(rr,:), NT, []))';
                
                RRES = Res(:, iirange);
                RRES = RRES(end:-1:1, :);
                TTmp = RRES;
                if nnz(TTmp)
                    
                imin = min(TTmp(find(TTmp)));imax = max(TTmp(find(TTmp)));
                TTmp(find(~TTmp)) = imin - 0.5*(imax - imin);
                
                axisF = [min(TTmp(:)), max(TTmp(:))];
                
                imargin =axisF(2) - axisF(1);
                imin = axisF(1) - imargin*0.001;
                imax = axisF(2) + imargin*0.001;
                jmargin = max(RRV) - min(RRV);
                jmin = min(RRV) - jmargin*0.001;
                jmax = max(RRV) + jmargin*0.001;
                plotFigC(RRV, TTmp, TTS, {['Temp_KMEAN', strs, SStr], 1, issave}, 'Balanced ratio', ...
                    'Accuracy (%)', 1, dir, {1, loc}, 0, 1, 0, 0, [1, 1], 0, [jmin jmax imin imax]); 
                end
                end

            end
        
        end
    end
    TrainFun = TrainFun1;Ntrain = Ntrain1;
end

end
close all;