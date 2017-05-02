function D = distanceFull_ORG(W, X)

    D = PsdToEdm(X' * W * X);
end