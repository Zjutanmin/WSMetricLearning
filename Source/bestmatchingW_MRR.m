function [score, xpos, ypos, rpos, margin] = bestmatchingW_MRR(feat, ctr_fea, Map, PCACOEFF, fsize, W, nrotate)
if isa(feat, 'double') && ndims(feat) == 2
    tfeat{1} = feat;
    Map = [1,1];
end
feat = tfeat;


nbase = size(ctr_fea, 1);nbase1 = nbase / nrotate;
if ndims(feat) == 3
    xdim = size(feat, 1) - fsize(1);
    ydim = size(feat, 2) - fsize(2);
else
    tmax = max(Map-1, [], 1);
    xdim = tmax(1);ydim = tmax(2);
end

if ndims(feat) == 3
    feattmp = [];
    Map = zeros((xdim+1)*(ydim+1), 2);
    %%%GetThe date
    index = 0;
    for i = 1:xdim+1
        for j = 1:ydim+1
            Map(index, :) = [i, j];
            tfeat = feat(i:i+fsize(1)-1,j:j+fsize(2)-1,:);
            feattmp = [feattmp; reshape(tfeat(:), [1, size(ctr_fea,2)])];
        end
    end
end

    if ~isempty(PCACOEFF)
        feattmp = cell2mat(feat);feattmp = feattmp';
        feattmp = (feattmp - repmat(PCACOEFF{2}, [size(feattmp,1),1])) * PCACOEFF{1};
    end
    num = size(feattmp, 1);
    b  = Wdistance(feattmp, ctr_fea, nbase, num, W);%%distance
    b = -b; %%socre
    
    b = reshape(b', [nbase1, nrotate, num]);
    
    max_b = max(b,[], 1);
    margin = sum((repmat(max_b, [nbase1, 1]) - b)) / (nbase1-1);
%     tic
%     margin = max_b * (1 + 1/(nbase1-1)) - sum(b, 1) / (nbase1-1);
%     toc
%     tic
%     margin1 = sum((repmat(max_b, [nbase1, 1]) - b) / (nbase1-1));
%     toc
%     tic
%     margin2 = sum((repmat(max_b, [nbase1, 1]) - b)) / (nbase1-1);
%     toc 
%     for ii = 1:nrotate
%         for jj = 1:num
%             margin1(1, ii,jj) = sum(max(b(:,ii,jj)) - b(:,ii,jj)) / (nbase1 - 1);
%         end
%     end
%     dis = margin1 - margin;max(abs(dis(:)))
    
    [margin, id] = max(margin(:));
    
    
    [rpos, nump] = ind2sub([nrotate, num], id);
    xpos = Map(nump, 1);
    ypos = Map(nump, 2);
    score = -b(:, rpos, nump);