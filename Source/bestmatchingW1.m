function [score, xpos, ypos, rpos] = bestmatchingW1(feat, ctr_fea, Map, PCACOEFF, fsize, W, nrotate)
                    
nbase = size(ctr_fea, 1);nbase1 = nbase / nrotate;
if ndims(feat) == 3
    xdim = size(feat, 1) - fsize(1);
    ydim = size(feat, 2) - fsize(2);
else
    tmax = max(Map-1, [], 1);
    xdim = tmax(1);ydim = tmax(2);
end

r =zeros([xdim+1, (ydim+1)*nbase / nrotate]);
rrpos = cell(xdim+1, ydim+1);

if ndims(feat) == 3
    for i = 1:xdim+1
    for j = 1:ydim+1
        feattmp = feat(i:i+fsize(1)-1,j:j+fsize(2)-1,:);
        feattmp = feattmp(:);
        if ~isempty(PCACOEFF)
            feattmp = (feattmp' - PCACOEFF{2}) * PCACOEFF{1};
            b  = Wdistance(feattmp, ctr_fea, nbase, 1, W);%%distance
        else
            b  = Wdistance(feattmp', ctr_fea, nbase, 1, W);%%distance
        end
        b = reshape(b, [nrotate, nbase1]);
        [b, rrpos{i,j}] = min(b, [], 1);
        r(i,j:ydim+1:end) = b;
    end
    end
else
    if ~isempty(PCACOEFF)
        feattmp = cell2mat(feat);feattmp = feattmp';
        feattmp = (feattmp - repmat(PCACOEFF{2}, [size(feattmp,1),1])) * PCACOEFF{1};
    end
    for ii = 1:size(feattmp, 1)
        i = Map(ii,1);j = Map(ii,2);
        b = Wdistance(feattmp(ii,:), ctr_fea, nbase, 1, W);%%distance
        b = reshape(b, [nrotate, nbase1]);
        [b, rrpos{i,j}] = min(b, [], 1);
        r(i,j:ydim+1:end) = b;
    end
end

rscore = r;%%%%distance
if xdim == 0
    score = rscore;
    xpos = ones(size(score));
    ypos = ones(size(score));
else
    [rx, xpostmp] = min(rscore);
    rx = reshape(rx(:), [ydim+1, nbase1]);
    [score, ypos] = min(rx);
    index = ypos  + [0:size(rx, 1):size(rx, 1)*(size(rx, 2) - 1)];
    xpos = xpostmp(index);
end
rpos = zeros(size(xpos));
for i = 1:length(xpos)
    rpos(i) = rrpos{xpos(i),ypos(i)}(i);
end