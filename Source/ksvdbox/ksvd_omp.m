function Gamma = ksvd_omp(params,varargin)
params.iternum = 1;
params.fixedcode = 0;
params.fixedDic = 1;
[~,Gamma] = ksvd(params,varargin{1});
