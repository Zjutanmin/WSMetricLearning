function dataY1 = iscell2mat(dataY1, NeedOne)
if NeedOne
    dataY1 = cell2mat(dataY1(:, 1));
end