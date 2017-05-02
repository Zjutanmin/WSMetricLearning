function [XDic, Feat_GD, fobj] = mykmeans(Margins, C, KmeanLAMDA, X, XX, Y, npos, nfac, k,...
    Ymatched, W, SW, Ycons, Yloss, PsiClock, TempID, TemplateNorm, UpSolver, cpara, innerfea, cparaINNC, ITERkmean)
% cparaINNC = 0;
% cparaINNC= 1;
% cparaINNC = 0;cparaINNC = [0.0500,62.0000,-1.0000,0,0.9500, cparaINNC];
% cparaINNC = 1;cparaINNC = [0.0500,62.0000,-1.0000,0,0.9500, cparaINNC];
% SCode.iter_dic = 10;

fobj = 0;
mk = k;
GammaS = cparaINNC(end-2);
KmeanE = cparaINNC(end-1);
Tnorm = cparaINNC(end);
cparaINNC = cparaINNC(1:end-3);
C = C / KmeanLAMDA;
nTemp = length(TempID);
nneg = nTemp - npos;
X = [X, XX];
n = size(X,2)- nTemp;
ncons = length(Ycons);

YlabelT = (bsxfun(@times, ones([n ,nTemp]), -npos));
[aind,~] =ind2sub(size(YlabelT), Ymatched);
YlabelT(Ymatched) = nneg(aind);
Ylabel = double((cell2mat(Ycons)));
Ylabel = bsxfun(@times, (repmat(YlabelT, [ncons, 1]) - Ylabel) / 2, repmat((1./nfac)/n, ncons, 1));
if innerfea
    Ylabel = Ylabel / 2;
end
Ylabel = bsxfun(@times, Ylabel, repmat((SW), [ncons, 1])); %????
SCode.iter_dic = cpara{7};
SCode.fun = @distanceP;

SCode.Q0 = Margins;
Cov = cell2mat(cellfun(@sum, mat2cell(Ylabel, n*ones(1, ncons), nTemp), ...
    'UniformOutput', false));
SCode.Q1 = 2 * Cov;
SCode.P1 = Ylabel;
SCode.nTemp = nTemp;
SCode.C = C;
SCode.C1 = 1 / KmeanLAMDA;
SCode.W = W;
SCode.ncons = ncons;
SCode.mult_dic = cpara{6}; 
maxiter = cpara{3};
iter = 0;
YesU = 1;

XDic1 = X(:, 1:nTemp);
tr_label = [1:nTemp];

if ~isempty(cparaINNC) || ITERkmean(3)
    if ITERkmean(3)
        KmeanE = 1;
    end
    L = eye(size(X, 1));
    WData = L*X(:, 1+nTemp:end);
end;

% % % if ~isempty(cparaINNC)
% % %     if KmeanE
% % %          L = eye(size(X, 1));
% % %     else
% % %         [vecs,vals] = eig(0.5 * (SCode.W + SCode.W'));
% % %         L = real(abs(vals)).^0.5 * vecs';
% % %     end
% % %     WData = L*X(:, 1+nTemp:end);
% % % end;
XDic = X(:, 1:nTemp);
% % % GammaS = 1;
if GammaS
    Ymatched = GetMatched(Y, 1:length(Y), nTemp);
    
    YmatchedN = int8(zeros(n, nTemp));
    YmatchedN(Ymatched) = 1;
else
    Ymatched = [];YmatchedN = [];
end


% label = 0;
last = 0;label = Inf;
if ~KmeanE
    MW = W;
else
    MW = eye(size(W));
end
fixedcode = 1;setting.Nfixed = 0;setting.AllTemp = 0;setting.TemplateINNC = 0;
setting.Label = repmat([1: nTemp/k], k, 1);setting.Label = setting.Label(:);
setting.MeanT = 1;setting.MeanNum = k;
setting.Svlfeat = 1;setting.innerkmean = 0;
dataX = (X(:, 1+nTemp:end))';
if k == 1 && GammaS
    maxiter = 1;
end
ts_label = cell2mat(Y);ts_label =ceil(ts_label(:, 1)/k);
while iter < maxiter && (any(label(:) ~= last(:)) || YesU)
last = label;
%     tic
    if KmeanLAMDA
        if ~isempty(cparaINNC)
            [GG, label]  = INNCode((L*XDic)', tr_label, WData', cellfun(@max, Y, 'UniformOutput', true), ...
                cparaINNC(1), cparaINNC(2), cparaINNC(3), cparaINNC(4), ...
                cparaINNC(5), Ymatched, innerfea);
            GG = GG';
        else
            if ~KmeanE
                D  = Wdistance(X(:, 1+nTemp:end)', XDic', size(XDic, 2), n, W, innerfea);
            else
                if innerfea
                    D  = -X(:, 1+nTemp:end)'*XDic;
                else
                    XX = sum((X(:, 1+nTemp:end)').*(X(:, 1+nTemp:end)'), 2);
                    BB = sum((XDic').*(XDic'), 2);
                    D  = repmat(XX, 1, nTemp)-2*X(:, 1+nTemp:end)'*XDic+...
                        repmat(BB', n, 1);
                end
            end
            D = -D';
            D(find(~YmatchedN')) = -Inf;
            [~,label] = max(D,[],1); % assign samples to the nearest centers
            GG = zeros([nTemp, n]);idx = sub2ind([nTemp, n], label, [1:n]);
            GG(idx) = 1;
        end
    end
%     toc
%     tic
    SCode.Code = bsxfun(@times, GG, sqrt(SW')); %????
    if ITERkmean(4)
%         XDic11 = GetINITSVD();
        CodeINN  = SCode.Code;params.fixedcode = fixedcode;
        [A, ~, inum] = getNewtemplate(1, size(dataX, 1),  dataX, cell2mat(Y),...
            ts_label,  setting,  SW);
        dataT = A(1:inum, :);
        setting.K_dic = size(dataT, 1);
        params.initdict = dataT';
        params.W = CodeINN;
        params.data = bsxfun(@times, dataX', sqrt(SW)'); %????
        params.memusage = 'high'; params.SCode.Code = [];params.Tdata = setting.K_dic/10; %???L0norm
        params.dictsize = setting.K_dic;%????
        XDic1 = ksvd(params,'');%D????gamma??X???coding???
    end
[XDic, Feat_GD] = getDic(XDic1, X(:, 1+nTemp:end), SCode, SW, Tnorm, ~isempty(cparaINNC), ITERkmean, MW);
    XDic = full(XDic);%D????gamma??X???coding???
    YesU = 1; 
    if norm(XDic1 - XDic, 1) / norm(XDic1, 1) < 1e-3;
        YesU = 0;
    end
    XDic1 = XDic;
    iter = iter + 1;
%     toc
end
XDic = XDic1;
try
    save(cpara{5}, 'D');
end



function [D, Feat_GD] = getDic(D, data, SCode, SW, Tnorm, GetINNC, ITERkmean, MW)

% [XDic, Feat_GD] = getDic(XDic1, X(:, 1+nTemp:end), SCode, SW, Tnorm, ~isempty(cparaINNC), ITERkmean, MW);

FeatUpkmean  = ITERkmean(1);
Feat_GD = zeros(size(MW));
GetINNCBOOL = ITERkmean(3);
ITERkmean  = ITERkmean(2);

Gamma = SCode.Code;
NP = size(Gamma, 2);
dcc = - 2 * bsxfun(@times, data, sqrt(SW'))  * Gamma';
OBJ = Inf;

if ~GetINNC && ~ITERkmean
    SCode.iter_dic = 1;
end
% SCode.W = MW;
  
for i = 1:SCode.iter_dic
%     tic;
    P1 = SCode.P1*D'*SCode.W;
    Q1 = SCode.Q0;
    Q1  = Q1(:);
    TT = sum(-4*P1 .* repmat(data', SCode.ncons, 1), 2);
    TT = bsxfun(@plus, Q1', sum((reshape(TT, [], SCode.ncons)), 1));
    [a,idx] = max([TT, 0], [], 2);
    
    Range = [(idx-1)*NP+1:idx*NP];      
    Temp = [SCode.P1; zeros([NP,SCode.nTemp])];
    DT = -4*(data*Temp(Range, :))' * SCode.W;
    
    if GetINNC || GetINNCBOOL
% % %         OBJ1 = [1 /NP * (sum(sum((bsxfun(@times, data, sqrt(SW')) - ...
% % %             D*Gamma).^2))) + SCode.C * a, SCode.C1 * trace(SCode.W)]
        OBJ1 = 1 /NP * (sum(sum((bsxfun(@times, data, sqrt(SW')) - ...
            D*Gamma).^2))) + SCode.C * a;
        dc1 = 1 /NP * (dcc + 2 * (D * Gamma) * Gamma');
        dc2 = SCode.C * [DT'];
        dC =  dc1 + dc2;
        D  = D  - SCode.mult_dic * 1 / sqrt(i) * dC;
        if Tnorm == 1
            D = (L2normMatrix(D'))';
        end
    else
% % %         OBJ1 = [-ITERkmean* 1 /NP * sum(diag((bsxfun(@times, data, sqrt(SW')))'*...
% % %             MW*(D*Gamma))), SCode.C * a, SCode.C1 * trace(SCode.W)]
        
% % % %         if OBJ1 < 0
% % % %         tt = 1;
% % % %         end
        OBJ1 = -ITERkmean* 1 /NP * sum(diag((bsxfun(@times, data, sqrt(SW')))'*...
            MW*(D*Gamma)))+SCode.C * a;
% % %         x12 = 0;
% % %         data1 = bsxfun(@times, data, sqrt(SW'));
% % %         for t = 1:size(Gamma, 2)
% % %             x12 = x12 + (data1(:,t))'*SCode.W*(D*Gamma(:,t));
% % %         end
        dc1 = 1 /NP * (MW*dcc/2);
        dc2 = SCode.C * [DT'];
        dC =  (ITERkmean* dc1 + dc2);
        if ITERkmean
            D  = D  - SCode.mult_dic * 1 / sqrt(i) * dC;
            D = (L2normMatrix(D'))';
        else
            dC =  -dC;
            D = (L2normMatrix(dC'))';
        end
    end
    
    if abs(OBJ1 - OBJ) / abs(OBJ) < 1e-3
        break;
    end
    LL(i) = OBJ1;
    OBJ = OBJ1;
%     toc;
end
if Tnorm == 2 
    D = (L2normMatrix(D'))';
end
if FeatUpkmean
    Feat_GD = ITERkmean* 1 /(NP*SCode.C) * (((bsxfun(@times, data, sqrt(SW')))*...
        (D*Gamma)'));
end


t = 1;