function [IDX, pb] =GetSVMDis(Psvmtrain, a, b, Label,  nr_class, knn)
if nargin < 6
    knn = nr_class;
end
if nnz(Label - sort(Label))
    fprintf('Label error')
    pause;
    t = 1;
end
if Psvmtrain
    
    Map = repmat([1:nr_class], [nr_class, 1]);Map = Map(2:end,:);
    Map1 = Map(find(tril(Map)));
    
    Map = repmat([2:nr_class], [nr_class-1, 1]);Map = Map';
    Map2 = Map(find(tril(Map)));
    pb= zeros(size(b, 1), nr_class);
    xlabel = b>=0;
    for i = 1:nr_class
        idx =find(Map1 == i);
        pb(:, i) = sum(xlabel(:, idx), 2);
    end
    
    xlabel = b<0;
    for i = 1:nr_class
        idx =find(Map2 == i);
        pb(:, i) = pb(:, i) + sum(xlabel(:, idx), 2);
    end
    
    pb = pb ./ repmat(sum(pb, 2), [1, nr_class]);
else
    pb = b ./ repmat(sum(b, 2), [1, nr_class]);
end
% [xx,yy] = max(pb, [], 2);
% [xx,yy] = max(pb, [], 2);

[pb, IDX] = sort(-pb, 2);
if IDX(:, 1) ~= a
    fprintf('Test error')
    pause;
    t = 1;
end

IDX= IDX(:, 1:knn);
pb= pb(:, 1:knn);