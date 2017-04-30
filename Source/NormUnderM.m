function dataX1 = NormUnderM(dataX1, L)
X = L2normMatrix(dataX1*L');
dataX1 = X*inv(L');