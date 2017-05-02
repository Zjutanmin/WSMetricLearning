function THsocre = WeightedScore(classify, Score, svote, cmethod, softK)
%%%%score distance
Hscore = Score;
[m,n] = size(Hscore);

[dummy, idx] = sort(Hscore, 2, 'ascend');
Activeindex = idx(:, 1:softK);

Aindex = (Activeindex-1)*size(Activeindex, 1) + ...
    repmat([1:size(Activeindex,1)]', [1, size(Activeindex, 2)]);
THsocre = -Inf(size(Hscore));

% Hscore1 = Hscore;
THsocre(Aindex) = GetWeighted(classify, Hscore(Aindex), svote, cmethod);
% nnz(Hscore1 - Hscore)

function weight = GetWeighted(classify, Hscore, svote, cmethod)
% Hscore = Hscore;
% return;
if strcmp(svote, 'Norm')
    weight = -Hscore;
%     weight = Normlizeweight(weight);
    return;
end
[m,n] = size(Hscore);
                
switch cmethod
    case 1
        switch svote
            case 'Guassion'
                sigma = -min(Hscore(:)) / log(0.99);
                if strcmp(classify, 'MultiSVM')
                    sigma = 1;
                end
                weight = exp( -Hscore ./ sigma);            
%                 [max(weight, [], 2), min(weight, [], 2)]
%                 [ max(weight(:)), min(weight(:))]
                
            case 'linear'
        
                Hscore = -Hscore;
                
                tmin = min(Hscore(:));
                tmax = max(Hscore(:));
                margin = tmax - tmin;
        
                weight = (Hscore - tmin) ./ margin;
                
%                 [max(weight, [], 2), min(weight, [], 2)]
%                 [ max(weight(:)), min(weight(:))]
            
            case 'Reciprocal'
                norm = sum(sum(1./ Hscore));
                weight = (1 ./ Hscore) ./ norm;
%                 sum(weight, 2)
%                 sum(weight(:))
        end
        
    case 0
        switch svote
            case 'Guassion'
                sigma = -min(sqrt(Hscore), [], 2) / log(0.99);
                if strcmp(classify, 'MultiSVM')
                    sigma = ones([m, 1]);
                end
                weight = exp( -sqrt(Hscore) ./ repmat(sigma, [1, n]));
                
                weight(find(abs(sigma) == Inf),:) = 0;
                
%                 [max(weight, [], 2), min(weight, [], 2)]
            case 'linear'
        
                Hscore = -Hscore;
                
                tmin = min(Hscore, [], 2);
                tmax = max(Hscore, [], 2);
                margin = tmax - tmin;
        
                weight = (Hscore - repmat(tmin, [1, n])) ./ repmat(margin, [1, n]);
%                 [max(weight, [], 2), min(weight, [], 2)]
            
            case 'Reciprocal'
                ss = sum(Hscore, 2);
                idx = find(ss <= 0);
                Hscore(idx,:) = bsxfun(@minus, Hscore(idx,:), ss(idx)-1e-5);
                
                tt = 1./ Hscore;
                norm = sum(tt, 2);
                weight = (1 ./ Hscore) ./ repmat(norm, [1, n]);
                
                weight(find(norm == 0),:) = 0;
%                 [max(weight, [], 2), min(weight, [], 2)]
%                 sum(weight, 2)
        end
end
if size(weight,2) == 1
    return;
end

tmin = min(Hscore, [], 2);
tmax = max(Hscore, [], 2);
margin = tmax - tmin;
id = union(find(margin < 1e-4), find(sum(abs(Hscore), 2) < 1e-4));
weight(id,:) = 0;
weight(setdiff([1:m], id),:) = Normlizeweight(weight(setdiff([1:m], id),:));

% weight(1,:)
% weight ./ repmat(sum(weight,2), [1, n]);


function weight = Normlizeweight(weight)
if size(weight,2) == 1
    return;
end
[m,n] = size(weight);
tmin = min(weight, [], 2);
tmax = max(weight, [], 2);
margin = tmax - tmin;
weight = weight ./ repmat(sum(weight,2), [1, n]);
id = union(find(margin < 1e-4), find(sum(abs(weight), 2) < 1e-4));
weight(id,:) = 0;