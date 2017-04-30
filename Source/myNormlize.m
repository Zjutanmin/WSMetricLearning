function TestData = myNormlize(TestData, Normfea, tnorm)
if nargin < 3
    tnorm = 1;
end
if iscell(Normfea)
    W = Normfea{2};
    if ~isempty(W)
        [vecs,vals] = eig(0.5 * (W + W'));
        L = real(abs(vals)).^0.5 * vecs'; 
        TestData = NormUnderM(TestData, L);
    end
else
    if (Normfea)
        TestData = L2normMatrix(TestData, tnorm);
    end
end