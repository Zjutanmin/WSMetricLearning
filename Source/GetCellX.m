function dataX = GetCellX(datastr, CIndex)
BatchRound = size(CIndex, 1);
dataX = cell(CIndex(end, 2), 1);
for R = 1:BatchRound
    index = [CIndex(R, 1):CIndex(R, 2)];
    load(fullfile(datastr,[num2str(R) '.mat']), 'Xcell'); 
    dataX(index) = Xcell;
end