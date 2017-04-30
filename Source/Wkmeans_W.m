function [dataT, label] = Wkmeans_W(dataX, K, SWW, Svlfeat, INNERMean)
if nargin < 4
    Svlfeat = 0;
end
if nargin < 5
    INNERMean = 0;
end
if Svlfeat
%     [dataT, label] = myvlkmeans(dataX', K, SWW);
%     [label, dataT] = litekmeans(dataX', K);
%     sum(dataT.^2, 1)
    [label, dataT] = litekmeans1(dataX', K, SWW, INNERMean);
%     sum(dataT.^2, 1)
%     [dataT, label] = Wkmeans_W(dataX, K, SWW, 0);
%     sum(dataT.^2, 1)
%     [dataT, label] = Wkmeans_W(dataX, K, ones(size(SWW)), 0);
%     sum(dataT.^2, 1)
%     t = 1;
else
    dataX = bsxfun(@times, dataX, sqrt(SWW));
    [dataT, label] = vl_kmeans(dataX', K);
    % [label, dataT] = kmeans(dataX, K);dataT = dataT';
    n = size(dataX, 1);
    E = sparse(1:n,double(label),1,n,K); 
    SW = sqrt(1./SWW)'*(E*spdiags(1,0,1,1));
    SW1 = ones(size(SWW))'*(E*spdiags(1,0,1,1));
    dataT = bsxfun(@times, dataT, SW1./SW);
end
