function Gamma = ksvd_omp1(params,varargin)
params.iternum = 1;
params.fixedcode = 0;
params.fixedDic = 1;
[~, Gamma] = ksvd1(params,varargin{1});
