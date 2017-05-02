function D = distanceFull(W, X, innerfea)
if innerfea
    D = -X' * W * X;
else
    D = PsdToEdm(X' * W * X);
end
end
