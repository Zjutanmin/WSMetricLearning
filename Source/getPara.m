function [knn_size, outdim, max_iter, quiet,  mu, validation...
    earlystopping, ntrees] = getPara(cpara, dimsize)
if isempty(cpara)
    knn_size = 4;
else
    knn_size = cpara(1);
end
if length(cpara) < 2
    outdim = 3;
else
    outdim = cpara(2);
    if outdim  == 0
        outdim = dimsize(2);
    end 
end
if length(cpara) < 3
    max_iter = 1000;
else
    max_iter = cpara(3);    
end
if length(cpara) < 4
    quiet = 1;
else
    quiet = cpara(4);    
end
if length(cpara) < 5
    mu = 0.5;
else
    mu = cpara(5);    
end
if length(cpara) < 6
    validation = 0.2;
else
    validation = cpara(6);    
end
if length(cpara) < 7
    ntrees = 200;
else
    ntrees = cpara(7);    
end
if length(cpara) < 8
    earlystopping = 25;
else
    earlystopping = cpara(8);    
end