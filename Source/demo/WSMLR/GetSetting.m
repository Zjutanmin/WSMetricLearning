function [str, dataset, featurestr, VSNIPPET, classes, classesstr, classnum, ...
    crangeMLR, crangeSVM, strThresh, ratio, row, col, kkrange, outdim, ntree, CNum, crangeSVM1] ...
    = GetSetting(str, MRR)
addpath('K:/Tanmin/project/Signdetect/SignClassify')
kkrange = [4 10]; 
outdim = [20, 50, 100, 0];
ntree = [50:50:200, 300];
isVSNIPPE = 0;
CNum = [];

MSVMrange = 0;LoutDIM = 0;
if iscell(str)
    CR = str{1};
    if length(str) > 2
        isVSNIPPE = str{2};
    end
    if length(str) > 3
        CNum = str{3};
    end
    if length(str) > 4
        MSVMrange = str{4};
    end
    if length(str) > 5
        LoutDIM = str{4};
    end
    str = str{end};
else
    CR = 0;
end
if LoutDIM
    outdim = [20, 50, 100];
end
if nargin < 2
    MRR = 0;
end
CRT = floor(CR / 10);
CR = mod(CR,  10);

% crangeMLR = [0.1250, 0.5, 2, 32, 512, 1024, 1536, 2048];
crangeMLR = [128, 2, 32, 512, 1024, 1536, 2048];

% crangeMLR = [8 16, 48, 64, 96, 112, 144, 160, 192, 256, 320];


crangeSVM = [0.0157, 0.0313, 0.0625, 0.1250, 2, 32, 512, 1024];
crangeSVM1 = crangeSVM;
if MSVMrange
    crangeSVM = [0.0625, 0.1250, 2, 32];
    crangeSVM1 = [0.1250, 2, 32, 512, 1024];
end

HN1 = floor(length(crangeMLR) / 2);
HN2 = floor(length(crangeSVM) / 2);
HN3 = floor(length(crangeSVM1) / 2);
% HN4 = floor(length(outdim) / 2);
HN4 = floor(length(ntree) / 2);
switch CR
    case 0  
    case 1
        crangeMLR = crangeMLR(1:HN1);
        crangeSVM = crangeSVM(1:HN2);
        crangeSVM1 = crangeSVM1(1:HN3);
        ntree = ntree(1:HN4);
    case 2
        crangeMLR = crangeMLR(HN1+1:end);
        crangeSVM = crangeSVM(HN2+1:end);
        crangeSVM1 = crangeSVM1(HN3+1:end);
        ntree = ntree(HN4+1:end);
end

switch CRT
    case 0
    case 1
        crangeMLR = [];
        crangeSVM = [];crangeSVM1 = [];
%         crangeMLR = crangeMLR(2:end);
%         crangeSVM = crangeSVM(2:end);
%         kkrange = kkrange(1);
%         outdim = outdim(1);
%         ntree = ntree(1);
    case 2
        kkrange = [];
        outdim = [];
        ntree = [];
        crangeMLR = [];
%         crangeMLR = crangeMLR(1);
%         crangeSVM = crangeSVM(1);
%         kkrange = kkrange(2:end);
%         outdim = outdim(2:end);
%         ntree = ntree(2:end);
    case 3
        kkrange = [];
        outdim = [];
        ntree = [];
        crangeSVM = [];crangeSVM1 = [];

    case 4
        crangeMLR = [];
        crangeSVM = [];crangeSVM1 = [];
        outdim = -outdim;
end

dataset = 'Sign';featurestr = 'cHoG_1_color24_0';
Mlen = getmeanlen(dataset, str);

VSNIPPEstr = '';
if isVSNIPPE
    VSNIPPET{1} = unique(round(Mlen*[0.3 0.4 0.5 0.8]));
    if MRR
    VSNIPPET{1} = union(setdiff(VSNIPPET{1}, 1), 5);
    else
        VSNIPPET{1} = (setdiff(VSNIPPET{1}, 1));
    end
%     VSNIPPET{1} = (setdiff(VSNIPPET{1}, 1));
    for i = 1:length(VSNIPPET{1})
        VSNIPPEstr = [VSNIPPEstr, '_' num2str(VSNIPPET{1}(i))];
    end
else
    VSNIPPET{1} = [3 4 5 8];
end
VSNIPPET{2}= {};
for i = 1:length(VSNIPPET{1})
    VSNIPPET{2}{i} = num2str(VSNIPPET{1}(i));
end
VSNIPPET{3} = VSNIPPEstr;
if LoutDIM
    VSNIPPET{3} = [VSNIPPET{3}, '_O'];
end

switch str
    case '_NewT5'
        classes = {'-3.13', '-3.20', '-3.26', '-3.33', '-3.39', '-3.46', '0'};
        classesstr = {'13', '20', '26', '33', '39', '46', '52'};
        classnum = [13, 20, 26, 33, 39, 46, 52];
        thresh = -1;
        ratio = [0.0625, 0.0884,  0.125, 0.1768,  0.25, 0.3536, 0.5];
        row = 13; col= 4;
        result = STA(str);
    case '_NewT7-20-4-T2D'
        classes = {'-3.21', '-3.31', '-3.41', '-3.51', '-3.61', '-3.71', '-3.81', '-3.91', '0'};
        classesstr = {'21', '31', '41', '51', '61', '71', '81', '91', '101'};
        classnum = [21,31,41,51,61,71,81,91,101];
        thresh = -1;
        ratio = [0.125    0.25    0.375  0.5    0.625    0.75];
        row = 21; col= 5;
    case '_NewT11_N_M_1_80_20'
        classes = {'-3.12', '-3.27', '-3.42', '-3.57', '-3.72', '-3.87', '-3.102', '-3.117', '0'};
        classesstr = {'12', '27', '42', '57', '72', '87', '102', '117', '132'};
        classnum = [12, 27, 42, 57, 72, 87, 102, 117, 132];
        thresh = 20;
        ratio = [0.1    0.2    0.3  0.4    0.5    0.6  0.7  0.8];
        row = 22; col= 6;
    case '_NewT11_A_M_1_80_20'
        classes = {'-3.20', '-3.30', '-3.40', '-3.50', '-3.60', '-3.70', '-3.80', '0'};
        classesstr = {'20', '30', '40', '50', '60', '70', '80', '90'};
        classnum = [20,30,40,50,60,70,80,91];
        thresh = 20;
        ratio = [0.1    0.2    0.3  0.4    0.5    0.6  0.7  0.8];
        row = 18; col= 5;
    case '_NewT11_A_N_M_1_80_20'
        classes = {'-3.21', '-3.31', '-3.41', '-3.51', '-3.61', '-3.71', '-3.81', '-3.91', '-3.101', '0'};
        classesstr = {'21', '31', '41', '51', '61', '71', '81', '91', '101', '111'};
        classnum = [21,31,41,51,61,71,81,91,101,111];
        thresh = 20;
        ratio = [0.1    0.2    0.3  0.4    0.5    0.6  0.7  0.8];
        row = 37; col= 3;
    case '_NewT11_A_N_M_1_40_20'
        classes = {'-3.21', '-3.31', '-3.41', '-3.51', '-3.61', '-3.71', '-3.81', '-3.91', '-3.101', '0'};
        classesstr = {'21', '31', '41', '51', '61', '71', '81', '91', '101', '111'};
        classnum = [21,31,41,51,61,71,81,91,101,111];
        thresh = 20;
        ratio = [0.1    0.2    0.3  0.4    0.5    0.6  0.7  0.8];
        row = 37; col= 3;
    case '_NewT11_N_M_1_80_20_R'
        classes = {'-3.22', '-3.32', '-3.42', '-3.52', '-3.62', '-3.72', '-3.82', '-3.92', '-3.102', '0'};
        classesstr = {'22', '32', '42', '52', '62', '72', '82', '92', '102', '112'};
        classnum = [22,32,42,52,62,72,82,92,102,112];
        thresh = 20;
        ratio = [0.1    0.2    0.3  0.4    0.5    0.6  0.7  0.8];
        row = 28; col= 4;
        if MRR
            ratio = [0.01 0.05  0.051  0.1    0.2    0.3  0.4    0.5    0.6];
        end
    case '_NewT11_N_M_1_80_20_R2'
        classes = {'-3.22', '-3.32', '-3.42', '-3.52', '-3.62', '-3.72', '-3.82', '-3.92', '-3.102', '0'};
        classesstr = {'22', '32', '42', '52', '62', '72', '82', '92', '102', '112'};
        classnum = [22,32,42,52,62,72,82,92,102,112];
        thresh = 20;
        ratio = [0.1    0.2    0.3  0.4    0.5    0.6  0.7  0.8];
        row = 28; col= 4;
        if MRR
            ratio = [0.01 0.05  0.051  0.1    0.2    0.3  0.4    0.5    0.6];
        end
    case '_NewT11_N_M_1_100_20_R'
        classes = {'-3.22', '-3.32', '-3.42', '-3.52', '-3.62', '-3.72', '-3.82', '-3.92', '-3.102', '0'};
        classesstr = {'22', '32', '42', '52', '62', '72', '82', '92', '102', '112'};
        classnum = [22,32,42,52,62,72,82,92,102,112];
        thresh = 20;
        ratio = [0.1    0.2    0.3  0.4    0.5    0.6  0.7  0.8];
        row = 28; col= 4;
    case '_NewT11_N_M_1_100_20_R1'
        classes = {'-3.21', '-3.31', '-3.41', '-3.51', '-3.61', '-3.71', '-3.81', '-3.91', '0'};
        classesstr = {'21', '31', '41', '51', '61', '71', '81', '91', '101'};
        classnum = [21,31,41,51,61,71,81,91,101];
        thresh = 20;
        ratio = [0.1    0.2    0.3  0.4    0.5    0.6  0.7  0.8];
        row = 21; col= 5;
    case '_NewT11_N_M_1_80_20_R1'
        classes = {'-3.21', '-3.31', '-3.41', '-3.51', '-3.61', '-3.71', '-3.81', '-3.91', '0'};
        classesstr = {'21', '31', '41', '51', '61', '71', '81', '91', '101'};
        classnum = [21,31,41,51,61,71,81,91,101];
        thresh = 20;
        ratio = [0.1    0.2    0.3  0.4    0.5    0.6  0.7  0.8];
        row = 21; col= 5;
end
if thresh ~= -1
    strThresh = {str, thresh};
else
    strThresh = str;
end


function Mlen = getmeanlen(database, sstr)
sstr = [database, sstr];
load(['K:/Tanmin/project/Signdetect/SignClassify/TrainInfo/image_' sstr '_1_Floderinfo.mat'])
[aa,bb,cc] = unique(ts_fold_idx);
Len = [];
for i = 1:length(aa)
    Len(i) = length(find(cc == i));
end
Mlen = mean(Len);