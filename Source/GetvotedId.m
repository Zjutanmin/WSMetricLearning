function voted = GetvotedId(nclass, ts_idx, method, ts_imname, tr_imname, ...
    tr_size, ts_size, Rdistance, means, saveempty)
if nargin < 5
    method = 1;
    Rdistance = 0.5;
    ts_imname = [];
    saveempty = 0;
end

knn = 1;
tt = unique(ts_idx);

tr_size = repmat(means, [size(tr_size, 1), 1]);
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
    C_i = ones([length(index), knn]);
    tmpvoted = zeros(length(index), knn);
    switch method
        case 1
            Tresult = C_i(:);
            xx = hist(Tresult, [1:1:nclass]);
            [xx, ord] = sort(xx, 'descend');
            
            uTresult = ord(1:knn);
            tmpvoted(:) = 1;
        case 2
            Tresult = C_i(:);
            Conf = distance_i(:);
            thresh = min(Conf) + (max(Conf) - min(Conf)) * Rdistance;
            ind = find(Conf < thresh);
            tmpvoted(ind) = 1;
        
        case 3
            xtr_size = tr_size(:,1);ytr_size = tr_size(:,2);
            xcurr_tr_size = reshape(xtr_size(C_i), size(C_i));
            ycurr_tr_size = reshape(ytr_size(C_i), size(C_i));%%%size of templete
            
            xts_size = ts_size(:,1);yts_size = ts_size(:,2);  
            
            xcurr_ts_size = repmat(xts_size(index), [1, knn]);
            ycurr_ts_size = repmat(yts_size(index), [1, knn]);
            
            ind1 = find(xcurr_ts_size >= xcurr_tr_size * Rdistance);
            ind2 = find(ycurr_ts_size >= ycurr_tr_size * Rdistance);
            ind = union(ind1, ind2);
            if saveempty && isempty(ind)
                [~, idt] = sort(xcurr_ts_size.*ycurr_ts_size, 'descend');
                N = max(ceil(length(xcurr_ts_size)*Rdistance), 1);
                ind = idt(1:N);
            end
            tmpvoted(ind) = 1;
    end
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