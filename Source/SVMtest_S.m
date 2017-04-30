function [C, distance] = SVMtest_S(ctr_fea, label,  Psvmtrain, model)
if Psvmtrain
    [C,a,b] = svmpredict(label, sparse(ctr_fea), model); 
else
    [C,a,b] = predict(label, sparse(ctr_fea), model);
end
distance = b;