function fea = normlized(fea, NormFea, tnorm)
if ~NormFea
    return;
end
fea = L2normMatrix(fea, tnorm);