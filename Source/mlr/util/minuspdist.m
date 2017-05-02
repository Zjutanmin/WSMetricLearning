function C = minuspdist(A, B)
[m,n] = size(A);
numpos = m;
numneg = size(B,1);
A = repmat(A, [size(B, 1), 1]);
B = reshape(repmat(reshape(B(:), [1, numel(B)]), [m, 1]),  size(A));
C = sum(A - B) / (numneg * numpos);