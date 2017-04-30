function [rscore, rxpos, rypos, rrpos] = bestmatching(aindex, ...
    feat, ctr_fea, fsize, PCACOEFF)
if nargin < 5
    PCACOEFF = {};
end
    
for l = 1:length(ctr_fea)  %%%rotation
    ctr_fea{l} = ctr_fea{l}(aindex);
end

score = zeros(length(ctr_fea), length(ctr_fea{1}));
xpos = zeros(length(ctr_fea), length(ctr_fea{1}));
ypos = zeros(length(ctr_fea), length(ctr_fea{1}));

% imax = -inf;

if isempty(PCACOEFF)
    for l = 1:length(ctr_fea)  %%%rotation
        r = fdist(feat, ctr_fea{l}, 1, length(ctr_fea{l}));
        rscore = cell2mat(r);
        if numel(r{1}) == 1
            score(l,:) = rscore;
            xpos(l,:) = 1;
            ypos(l,:) = 1;
        else
            [rx, xpostmp] = min(rscore);
            rx = reshape(rx(:), [size(r{1}, 2), length(ctr_fea{l})]);
            [score(l,:), ypos(l,:)] = min(rx);
            index = ypos(l,:)  + [0:size(rx, 1):size(rx, 1)*(size(rx, 2) - 1)];
            xpos(l,:) = xpostmp(index);
        end
    end
else
    xdim = size(feat, 1) - fsize(1);
    ydim = size(feat, 2) - fsize(2);
    X = [];
    Map = zeros((xdim+1)*(ydim+1), 2);
    %%%GetThe date
    index = 0;
    for i = 1:xdim+1
        for j = 1:ydim+1
            index = index+1;
            Map(index, :) = [i, j];
            tfeat = feat(i:i+fsize(1)-1,j:j+fsize(2)-1,:);
            X = [X; reshape(tfeat(:), [1, numel(tfeat)])];
        end      
    end
    if ~isempty(PCACOEFF)
        X = (X - repmat(PCACOEFF{2}, [size(X,1),1])) * PCACOEFF{1};
    end
    
    for l = 1:length(ctr_fea)  %%%rotation
        B = reshape(cell2mat(ctr_fea{l}), [length(ctr_fea{l}), size(PCACOEFF{1}, 2)]);
        nframe=size(X,1);
        nbase=size(B,1);
        XX = sum(X.*X, 2);
        BB = sum(B.*B, 2);
        r  = repmat(XX, 1, nbase)-2*X*B'+repmat(BB', nframe, 1);
        [score(l,:), id] = min(r,[], 1);
        xpos(l,:) = Map(id, 1);
        ypos(l,:) = Map(id, 2);
    end
end

if length(ctr_fea) > 1
    [rscore, ord] = min(score);
    x = ord(:);y = [1:length(rscore)];
    index = sub2ind(size(score), x, y(:));
    rxpos = reshape(xpos(index), size(rscore));
    rypos = reshape(ypos(index), size(rscore));
    rrpos = ord;
else
    rscore = score;
    rxpos = xpos;
    rypos = ypos;
    rrpos = ones(size(rypos)); 
end
% rxpos1 = zeros(size(rxpos));
% rypos1 = zeros(size(rypos));
% for i = 1:length(rxpos1)
% rxpos1(i) = xpos(ord(i), i);
% rypos1(i) = ypos(ord(i), i);
% end
% imax = max(imax, max(abs(rxpos - rxpos1)));
% imax = max(imax, max(abs(rypos - rypos1)));
% 
% imax



function dist = mdist(feat1, feat2)
dsize = size(feat1) - size(feat2) + 1;
dist = zeros([dsize(1), dsize(2)]);
tsize = size(feat2);
for i = 1:dsize(1)
    for j = 1:dsize(2)
        tmpfeat = feat1(i:i+tsize(1)-1, j:j+tsize(2)-1, :);
        dist(i,j) = sum((tmpfeat(:) - feat2(:)).^2);
    end
end