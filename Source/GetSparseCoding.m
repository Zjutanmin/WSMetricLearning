function dataX = GetSparseCoding(Dic, dataX, lamda, ...
    method_dic, mult_dic, iter_dic, Newcode)
if ~isempty(Dic)
    NK = size(Dic, 2); 
    params.data = dataX'; %????
    params.Tdata = NK/10; %???L0norm 
    params.dictsize = NK;%????
    params.SCode.Code =  [];
    params.lamda = lamda;%????
    if strcmp(method_dic, 'SLEP')
        params.method_dic = 'L1';%????
    else
        params.method_dic = 'L0';%????
    end
    params.iternum = 1;%????
    params.memusage = 'high';
    params.fixedcode = 0;
    params.fixedDic = 1;
    params.initdict = Dic;
    
    params.SCode.lamda_dic = params.lamda;
    params.SCode.mult_dic =mult_dic; 
    params.SCode.iter_dic =iter_dic; 
    params.SCode.C = 0;

    [~, Gamma] = ksvd(params,'');%D????gamma??X???coding???
%     if ~strcmp(method_dic, 'L0') && Newcode
%        params.SCode.Code = Gamma;
%        params.method_dic = method_dic;%????
%        [~, Gamma] = ksvd(params,'');%D????gamma??X???coding???
%     end
    dataX = Gamma';
end