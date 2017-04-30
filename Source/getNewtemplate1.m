function [dataX, dataY, inum, setting, Label, dataXX] = getNewtemplate1(idx1, idx2,  dataX, dataY,...
    ts_label,  setting,  SW)   
% addpath('ksvdbox');addpath('ompbox')
if ~isfield(setting, 'Nfixed')
setting.Nfixed  = 0;
end
dataXX = [];
if setting.MeanT && ~setting.AllTemp
    index = [idx1:idx2];
    dataT = [];
    if setting.TemplateINNC
        dataT = dataX(1:idx1 - 1, :);
    end
    dataX = dataX(index, :);
    SW =SW(:);
    [a,~,c] = unique(ts_label);
    dataX1 = [];dataY1 = []; 
    inum = 0;
    if setting.TemplateINNC
         [setting, dataY, Label, dataX1, inum, dataXX] = GetTempINNC(setting, ...
             dataX, dataY, ts_label, SW, setting.TemplateINNC, idx1, dataT);
    else
        clear 'dataY';
        dataY = cell(length(ts_label), 1);dataY1 = cell(length(ts_label), 1);
        for ii = 1:length(a)
            idx = find(c == ii);
            SWW = SW(idx);SWW = SWW / sum(SWW) * length(SWW);
            if setting.MeanNum == 1
                Data = bsxfun(@times, (dataX(idx, :))', SWW');
                xmeans = mean(Data, 2);
            else
                [xmeans, label] = Wkmeans_W(dataX(idx, :), setting.MeanNum, SWW);
            end
            len = size(xmeans, 2);
            Label(inum + 1: inum + len) = a(ii);
            dataY(idx) = mat2cell(repmat([inum + 1: inum + len],...
                [length(idx), 1]), ones(length(idx), 1), len);
            dataX1 = [dataX1; xmeans'];
            inum = inum + size(xmeans, 2);
        end
        for ii = 1:length(a)
            idx = find(c == ii);
            len = inum - length(dataY{idx(1), :});
            dataY1(idx) = mat2cell(repmat(setdiff([1:inum], dataY{idx(1), :}), ...
                [length(idx), 1]), ones(length(idx), 1), len);
        end
        if setting.TemplateNorm
            dataX1 = L2normMatrix(dataX1);
        end
        dataY = [cell(inum, 2); [dataY, dataY1]]; 
        setting.Label = Label;
    end
    dataX = [dataX1; dataX]; 
else
    inum = idx1 - 1;
end


function [setting, dataY, Label, dataX1, inum, gamma] = GetTempINNC(setting, ...
    dataX, dataY, ts_label, SW, TemplateINNC, idx1, dataT)
MultKSVD = 0;
Label = setting.Label;
inum = size(dataT, 1);
switch TemplateINNC
    case 1
        setting.MetricL2 = 1;
        setting.TemplateINNC = 0;
        if ~setting.INITINNC
            [A, dataY, inum, ~, Label] = getNewtemplate(1, size(dataX, 1),  dataX, dataY,...
                ts_label,  setting,  SW);
            setting.INITINNC = 1;
            dataT = A(1:inum, :);
            setting.Label = Label;
        end
        setting.TemplateINNC = 1;
        SWW = SW;SWW = SWW / sum(SWW) * length(SWW);
        if setting.GammaS
            Ymatched = GetMatched(dataY(:, 1), inum+1:size(dataY, 1), inum);
        else
            Ymatched = [];
        end
        if setting.Nfixed
            fixedcode = 0;CodeINN  = [];
            if setting.GammaS
                MultKSVD = 1;
            end
        else
            CodeINN  = INNCode(dataT, [1:size(dataT, 1)]', dataX,  ...
                setting.lambda_INNC, setting.K_INNC, setting.blocksize_INNC, ...
                setting.verbose_INNC, setting.beta_INNC, Ymatched);
            fixedcode = 1;CodeINN = (bsxfun(@times, CodeINN, sqrt(SWW)))';
        end
        params.fixedcode = fixedcode;
        setting.K_dic = size(dataT, 1);
        params.initdict = dataT';
    case 2
        SWW = SW;SWW = SWW / sum(SWW) * length(SWW);
        CodeINN = [];
        fixedcode = 0;
        dataX = [dataT;dataX];
        SWW = [ones(inum, 1);SWW];
        D = Wkmeans_W(dataX, setting.K_dic, SWW);
        if setting.TemplateNorm
            D = L2normMatrix(D);
        end
        params.fixedcode = fixedcode;
        params.initdict = D;
end  
params.W = CodeINN;
params.data = bsxfun(@times, dataX', sqrt(SWW)'); %????

params.SCode.Code =  [];
if ~params.fixedcode
    params.lamda = setting.lamda_dic;%????
    params.method_dic = 'L0';%????
    params.iternum = setting.iternum;%????
end
params.memusage = 'high';
params.SCode.Code = [];

if MultKSVD
    [a, ~, c] = unique(ts_label);
    data1 = params.data;
    D = (params.initdict);
    gamma = zeros([setting.K_dic, size(data1, 2)]);
    for tt = 1:length(a)
        idt = find(c==tt);
drange = dataY{inum+idt(1),1};
        K_dic = length(drange);
        params.Tdata = K_dic/10; %???L0norm
        params.dictsize = K_dic;%????
        params.data = data1(:, idt);
        params.initdict = D(:, drange);
        [D(:, drange), temp] = ksvd(params,'');%D????gamma??X???coding???
row = repmat(drange(:), [1, length(idt)]);
idt = idt(:);
col = repmat(idt', [length(drange), 1]);
idt = sub2ind(size(gamma), row(:), col(:));
gamma(idt) = temp(:); clear 'temp';
    end
    clear 'data1'
else
    params.Tdata = setting.K_dic/10; %???L0norm
    params.dictsize = setting.K_dic;%????
    [D, gamma, err] = ksvd(params,'');%D????gamma??X???coding???
end
if TemplateINNC == 1
    dataX1 = D';
else
    setting.Dic = D;
    gamma = (double(gamma))';
    dataX1 = dataT;
    setting.codebook = 1;
    setting.Fbook = fullfile(setting.Modelresult,['Cbook-', setting.Mstr]);
    save(fullfile(setting.Modelresult,['Cbook-', setting.Mstr]), 'D');
end