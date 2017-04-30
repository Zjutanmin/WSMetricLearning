function W = WbyEntropy(distance, Enorm)
if nargin < 2
    Enorm = 0;
end
[m,n] = size(distance);
if Enorm
    distance = bsxfun(@times, distance, 1./sum(distance, 2));
end
distance(find(distance == 0)) = 1e-5;
W = sum(-distance.*log(distance), 2);
Nmax = log(n);
Nmin = 0;
W = 1 - (W - Nmin) / Nmax;