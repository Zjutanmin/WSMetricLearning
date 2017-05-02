function [gamma, fobj, XDic] = DLITER(Margins, C, KmeanLAMDA, X, XX, XDic, Y, npos, nfac, k,...
    Ymatched, W, SW, Ycons, Yloss, PsiClock, TempID, TemplateNorm, UpSolver, cpara, innerfea)
params.initdict = XDic;
params.data = bsxfun(@times, XX', sqrt(SW)'); %????
params.Tdata = cpara{1}/10; %???L0norm
params.Tdata_dic = cpara{1}/10; %???L0norm 
params.dictsize = cpara{1};%????
params.fixedcode = 0;
params.lamda = cpara{2};
params.method_dic = cpara{4};

params.iternum = cpara{3};%????                  
params.memusage = 'high';
C = C / KmeanLAMDA;
nTemp = length(TempID);
nneg = nTemp - npos;
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

params.SCode.fun = @distanceP;

% params.SCode.Q00 = cell2mat(Yloss);

params.SCode.Q0 = Margins;
Cov = cell2mat(cellfun(@sum, mat2cell(Ylabel, n*ones(1, ncons), nTemp), ...
    'UniformOutput', false));
params.SCode.Q1 = 2 * Cov;
params.SCode.iter_dic = cpara{7};
params.SCode.P1 = Ylabel;
params.SCode.nTemp = nTemp;
params.SCode.lamda_dic = cpara{2} * sqrt(SW)';
params.SCode.C = C;
params.SCode.W = W;
params.SCode.ncons = ncons;
params.SCode.mult_dic = cpara{6}; 
if length(cpara) > 7 && cpara{8}
    Q0 = reshape(cell2mat(Yloss), [], ncons);
    NF = n / cpara{10};
    params.SCode.Code = bsxfun(@times, X, sqrt(SW')); %????

    params1 = params;
    for tt = 1:cpara{9}
        idx= randperm(n);
        idx1 = idx(1:cpara{10});
        idx =[1:nTemp, nTemp+idx1];

        params1.initdict = XDic;
        params1.data = params.data(:, idx);
        params1.SCode.Q0 = sum(Q0(idx1,:), 1);
        params1.SCode.Q1 = params.SCode.Q1*NF;
        idx1 = bsxfun(@plus, repmat(idx1, ncons, 1), [0:n:(n-1)*ncons]');
        idx1 = idx1';
        params1.SCode.P1 = params.SCode.P1(idx1(:),:)*NF;
        params1.SCode.Code = params.SCode.Code(:, idx);
        params1.SCode.lamda_dic = params.SCode.lamda_dic(idx);

        [XDic, gamma, err] = ksvd(params1,'');%D????gamma??X???coding???

        params.XDic = XDic;
        params.SCode.Code = ksvd_omp(params, '');
        max(abs(params.SCode.Code(:)))
    end
    gamma = params.SCode.Code;
else
    params.SCode.Code = bsxfun(@times, X, sqrt(SW')); %????
    [XDic, gamma, err] = ksvd(params,'');%D????gamma??X???coding???
end
gamma = bsxfun(@times, gamma, 1./sqrt(SW)'); %????
gamma = full(gamma);
try
    save(cpara{5}, 'D');
end
fobj = err(end);