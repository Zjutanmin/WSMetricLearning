function XLatent = getLatent(cellbase, X, h)
XLatent = cell2mat(X);
XLatent = XLatent(:,cell2mat(cellbase) + cell2mat(h));