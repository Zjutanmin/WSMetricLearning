function X1 = changeOrd(X, numSign)
if nargin < 2
    numSign = ones(1, length(X));
end

X1 = cell2mat(X);        
X1 = X1';
X1 = mat2cell(X1, size(X1, 1), numSign);