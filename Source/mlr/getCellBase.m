function cellbase = getCellBase(numSign, numSign1)
base = cumsum(numSign);base = [0, base];base = base(1:end-1);
cellbase = cell(1, length(numSign1));
for i = 1:length(numSign1)
    cellbase{i} = base(i) * ones(1, numSign1(i));
end