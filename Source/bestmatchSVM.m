function [score, xpos, ypos, rpos] = bestmatchSVM(aindex, ...
    feat, label, model, modelW, Psvmtrain, fsize)
if Psvmtrain
    [score, xpos, ypos, rpos] = matchlibsvm(aindex, ...
        feat, label, model, modelW, fsize);
    return;
end

if ~isempty(modelW)
    r1 = fconv(feat, modelW, 1, length(modelW));
end
r = cell2mat(r1);

%%%debug
feat1 = feat(:);
if length(feat1) == size(model.w,2)
    [C,a,b] = predict(label, sparse(feat1'), model);
    
    dis = r - b; 
    if max(abs(dis)) > 1e-4
        sprintf('Eroor\n')
        pause
    end
    
    if length(find(r == max(r))) == 1
        [a,idx] = max(b, [], 2);
        if nnz(C - idx)
            sprintf('Eroor\n')
            pause
        end
    end
end
%%%

rscore = -r;%%%%distance
if numel(r1{1}) == 1
    score = rscore;
    xpos = ones(size(score));
    ypos = ones(size(score));
else
    [rx, xpostmp] = min(rscore);
    rx = reshape(rx(:), [size(r1{1}, 2), length(modelW)]);
    [score, ypos] = min(rx);
    index = ypos  + [0:size(rx, 1):size(rx, 1)*(size(rx, 2) - 1)];
    xpos = xpostmp(index);
end
rpos = ones(size(xpos));