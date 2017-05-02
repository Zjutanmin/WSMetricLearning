function tmp = MaxWeight(prob, A, fsize)
tmp = zeros(fsize);
[Aunique, b,c] = unique(A);
for jj = 1:length(Aunique)
    idx = find(c == jj);
    tmp(Aunique(jj)) = max(prob(idx));
end