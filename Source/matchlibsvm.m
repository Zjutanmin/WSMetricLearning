function [score, xpos, ypos, rpos] = matchlibsvm(aindex, ...
    feat, label, model, modelW, fsize)
A = model.A;B = model.B;model = rmfield(model, 'A');model = rmfield(model, 'B');
xdim = size(feat, 1) - fsize(1);
ydim = size(feat, 2) - fsize(2);
r =zeros([xdim+1, (ydim+1)*length(model.Label)]);
for i = 1:xdim+1
    for j = 1:ydim+1
%         Prob = zeros(1,length(model.Label));
        feattmp = feat(i:i+fsize(1)-1,j:j+fsize(2)-1,:);
        feattmp = feattmp(:);
        [C,a,b] = svmpredict(label, sparse(feattmp'), model, '-b 1'); 
        
        [tt, ord] = max(b);
        if C~=(ord(1))
            sprintf('Eroor\n')
            pause
        end
        r(i,j:ydim+1:end) = b;
    end
end
% 
% if ~isempty(modelW)
%     r1 = fconv(feat, modelW, 1, length(modelW));
% end
% r = cell2mat(r1);
% 
% %%%debug
% feat1 = feat(:);
% if length(feat1) == size(model.w,2)
%     [C,a,b] = predict(label, sparse(feat1'), model);
%     
%     dis = r - b; 
%     if max(abs(dis)) > 1e-4
%         sprintf('Eroor\n')
%         pause
%     end
%     
%     if length(find(r == max(r))) == 1
%         [a,idx] = max(b, [], 2);
%         if nnz(C - idx)
%             sprintf('Eroor\n')
%             pause
%         end
%     end
% end
%%%

rscore = -r;%%%%distance
if xdim == 0
    score = rscore;
    xpos = ones(size(score));
    ypos = ones(size(score));
else
    [rx, xpostmp] = min(rscore);
    rx = reshape(rx(:), [ydim+1, length(model.Label)]);
    [score, ypos] = min(rx);
    index = ypos  + [0:size(rx, 1):size(rx, 1)*(size(rx, 2) - 1)];
    xpos = xpostmp(index);
end
rpos = ones(size(xpos));

function tmp = MaxWeight(prob, A, fsize)
tmp = zeros(fsize);
[Aunique, b,c] = unique(A);
for jj = 1:length(Aunique)
    idx = find(c == jj);
    tmp(Aunique(jj)) = max(prob(idx));
end


function tmp = Weight(prob, A, fsize)
tmp = zeros(fsize);
[Aunique, b,c] = unique(A);
for jj = 1:length(Aunique)
    idx = find(c == jj);
    tmp(Aunique(jj)) = sum(prob(idx));
end