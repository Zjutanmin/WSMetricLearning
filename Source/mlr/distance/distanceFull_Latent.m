function D = distanceFull_Latent(W, X)

    D = PsdToEdm(X' * W * X);
    
    
end
