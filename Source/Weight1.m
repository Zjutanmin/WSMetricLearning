
function tmp = Weight1(prob, A, fsize)
tmp = zeros(fsize);
[Aunique, b,c] = unique(A);
for jj = 1:length(Aunique)
    idx = find(c == Aunique(jj));
    tmp(Aunique(jj)) = length(idx);
end