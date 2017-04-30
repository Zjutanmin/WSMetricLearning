function [C, voted] = GetRerank(C, distance, nclass, ts_idx, method, Rdistance, ...
    ts_imname, tr_imname, tr_size, ts_size)
tr_size = prod(tr_size, 2);%%%pixel-wise size
ts_size = prod(ts_size, 2);
if nargin < 5
    method = 1;
    Rdistance = 0.5;
    ts_imname = [];
end
knn = size(C, 2);
tt = unique(ts_idx);

voted = zeros(length(ts_size), knn);

for i = 1:length(tt)
    index = find(ts_idx == tt(i));  %%%find the fold's index
    
%     figure;
%     
%     col = ceil(sqrt(length(index)));
%     for jj = 1:length(index)
%         ts_imname{index(jj)}
%         im = imread(ts_imname{index(jj)});
%         subplot(col, col, jj);
%         imshow(uint8(im));
%     end
%     title('samples in this folder\n');    
%     length(index)
%     pause
%     
%     close all
    
    tmpvoted = zeros(length(index), knn);
    C_i = C(index, :);
    distance_i = distance(index, :);
    switch method
        case 1
            Tresult = C_i(:);
            xx = hist(Tresult, [1:1:nclass]);
            [xx, ord] = sort(xx, 'descend');
            
            uTresult = ord(1:knn);
            tmpvoted(:) = 1;
            
            C_i = repmat(uTresult, [length(index), 1]);
        case 2
            Tresult = C_i(:);
            Conf = distance_i(:);
            thresh = min(Conf) + (max(Conf) - min(Conf)) * Rdistance;
            ind = find(Conf < thresh);
            
            Tresult = Tresult(ind);
            tmpvoted(ind) = 1;
            xx = hist(Tresult, [1:1:nclass]);
            [xx, ord] = sort(xx, 'descend');
            
            uTresult = ord(1:knn);
            
            C_i = repmat(uTresult, [length(index), 1]);
        
        case 3
            curr_tr_size = tr_size(C_i);%%%size of templete
            curr_ts_size = ts_size(index);%%%size of templete
            
            curr_ts_size = repmat(curr_ts_size, [1, knn]);
            ind = find(curr_ts_size >= curr_tr_size * Rdistance);
    
            Tresult = C_i(ind);
            tmpvoted(ind) = 1;
            
            xx = hist(Tresult, [1:1:nclass]);
            [xx, ord] = sort(xx, 'descend');
            
            uTresult = -1 * ones(1, knn);
            
            if length(ord) < knn
                uTresult(1:length(ord)) = ord(1:end);
            else
                uTresult = ord(1:knn);
            end
            
            C_i = repmat(uTresult, [length(index), 1]);
            
    end
    C(index, :) = C_i;
    voted(index, :) = tmpvoted; 

% 
% %     col = ceil(sqrt(length(uTresult)));
% %     for jj = 1:length(index)
% %         im = imread(ts_imname{uTresult(jj)});
% %         subplot(col, col, jj);
% %         imshow(uint8(im));
% %     end
% %     title('Targe class\n');
% %     
% %     pause;


end