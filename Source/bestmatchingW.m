function [score, xpos, ypos, rpos] = bestmatchingW(feat, ctr_fea, Map, PCACOEFF, fsize, W, nrotate)
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
    index = 0;
    for i = 1:xdim+1
        for j = 1:ydim+1
            Map(index, :) = [i, j];
            tfeat = feat(i:i+fsize(1)-1,j:j+fsize(2)-1,:);
            feattmp = [feattmp; reshape(tfeat(:), [1, size(ctr_fea,2)])];
        end
    end
end
%     num = size(feattmp, 1);
%     b  = Wdistance(feattmp, ctr_fea, nbase, num, W);%%distance
%     b = reshape(b', [nrotate, nbase1, num]);
%     [b, rpos] = min(b, [], 1);b = reshape(b, [nbase1, num]);
%     [score, id] = min(b, [], 2);
%     xpos = Map(id, 1);
%     ypos = Map(id, 2);
% else
    if ~isempty(PCACOEFF)
        feattmp = cell2mat(feat);feattmp = feattmp';
        feattmp = (feattmp - repmat(PCACOEFF{2}, [size(feattmp,1),1])) * PCACOEFF{1};
    end
    num = size(feattmp, 1);
    b  = Wdistance(feattmp, ctr_fea, nbase, num, W);%%distance
    b = reshape(b', [nrotate, nbase1, num]);
    [b, rpos] = min(b, [], 1);b = reshape(b, [nbase1, num]);
    [score, id] = min(b, [], 2);
    xpos = Map(id, 1);
    ypos = Map(id, 2);
    
    index = sub2ind(size(rpos), ones(size(id)), [1:size(rpos,2)]', id);
    rpos = reshape(rpos(index), [1, nbase1]);
% end
xpos = xpos';ypos = ypos';score = score';