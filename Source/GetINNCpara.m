function [lambda, K, blocksize, verbose, beta] = GetINNCpara(cpara)
lambda = 0.25;beta = 0.95;
blocksize = -1; verbose = 0;
try lambda = cpara(1); end
try K = cpara(2); end
try blocksize = cpara(3); end
try verbose = cpara(4); end
try beta = cpara(6); end
if lambda == -1  lambda = 0.25;  end;
if length(cpara) > 1 && cpara(2) ~= -1
    beta = 1 - 1 / (1+lambda).^K;
    K = ceil(-log(1-beta)/log(1+lambda));
%     K = ceil(-log(1-beta)/log(1+lambda));
else
    K = ceil(-log(1-beta)/log(1+lambda));
end