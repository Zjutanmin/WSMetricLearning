function D = distanceFullMKL_Latent(W, X)

    [d, n, m] = size(X);

    D = zeros(n);
    parfor i = 1:m
        D = D + PsdToEdm(X(:,:,i)' * W(:,:,i) * X(:,:,i));
    end
end
