function thresh = getthresh(confidence, ylabel, npos, p)
if nargin < 4
    p = 0.9;
end
% sort detections by decreasing confidence
[sc,si] = sort(-confidence);
ylabel=ylabel(si);

% assign detections to ground truth objects
nd=length(confidence);
tp=zeros(nd,1);
fp=zeros(nd,1);
fp(find(~ylabel)) = 1;
tp(find(ylabel)) = 1;

% compute precision/recall
fp=cumsum(fp);
tp=cumsum(tp);

prec=tp./(fp+tp);
recall = tp./npos;

if isempty(p)
    I = find((prec >= recall) == 1, 1, 'last');
else
    I = find(prec >= p, 1, 'last');
end

sc = sort(confidence, 'descend');
thresh = sc(I);