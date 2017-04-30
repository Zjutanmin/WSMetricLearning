function dPsi = cpGradientFull(X, S, batchSize, NT)
if nargin < 4
    dPsi    = X * S * X' / batchSize;
else
    dPsi    = X(:, NT+1:end) * S(NT+1:end, 1:NT) * (X(:, 1:NT))' / batchSize;
end
end
