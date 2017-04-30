function [IDX2, curr_distance2] = Multi2SigIDX(IDX, setting, curr_distance)
IDX2 = IDX;
curr_distance2 = curr_distance;ntr_fea = length(setting.labelmap);
if setting.MeanT && size(IDX, 2)~=ntr_fea
    booldis = 1;
    if nargout == 1
        booldis = 0;
    end
    nn = size(IDX, 1);
    
%     tic;
%     IDX1 = zeros(nn, ntr_fea);curr_distance1 = zeros(nn, ntr_fea);
%     for tt = 1:nn    
%         [a,rb] = unique(setting.Label(IDX(tt,:)), 'stable');
%         IDX1(tt,:) = reshape(a, [1, length(a)]);
%         if booldis
%             curr_distance1(tt,:) = curr_distance(tt,rb);
%         end
%     end
%     toc;
%     
%     tic;    
    [IDX2, B] = cellfun(@(x) unique(x, 'stable'), mat2cell(setting.Label(IDX), ...
        ones(nn, 1), size(IDX, 2)), 'UniformOutput', false);
    IDX2 = cell2mat(IDX2);
    Btemp = cell2mat(B);Atemp = repmat([1:nn], ntr_fea, 1);
    idx = sub2ind(size(curr_distance), Atemp(:), Btemp(:));
    if booldis
        curr_distance2 = (reshape(curr_distance(idx), ntr_fea, nn))';
    end
%     toc;
%     
%     dis = curr_distance2 - curr_distance1; max((abs(dis(:))))
%     dis = IDX2 -IDX1; max((abs(dis(:))))
end