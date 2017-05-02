function XLatent = getLatent1(numSign, numSignS1, X, h)
if nargin < 3
    h = ones(size(numSign));
end
base = cumsum(numSign);base = [0, base];
XLatent = cell2mat(X);
XLatent = XLatent(:,base(1:end-1) + h);