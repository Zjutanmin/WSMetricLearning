
function subfigplot(i, Cscore, ylabel, ap)
tstr = '';
if i ~= -1
    subplot(2, 4, i);
    cellname = {'probability', 'entropy', 'distance', 'margin','p+e','d+m','p+e+d+m+Q'};tstr = cellname{i};
end


b1 = (max(Cscore(find(~ylabel))) - min(Cscore(find(~ylabel)))) / 100;
b2 = (max(Cscore(find(ylabel))) - min(Cscore(find(ylabel)))) / 100;
xx1 = [min(Cscore(find(~ylabel))):b1:max(Cscore(find(~ylabel)))];
yy1 = hist((Cscore(find(~ylabel))), xx1);
xx2 = [min(Cscore(find(ylabel))):b2:max(Cscore(find(ylabel)))];
yy2 = hist((Cscore(find(ylabel))), xx2);
plot(xx1, yy1, 'r-')
hold on;
plot(xx2, yy2, 'g--')
% legend({'False', 'True'});

if nargin > 3
    ap = savedot(ap,2);
    tstr = [tstr, '-' num2str(ap)];
end
title(tstr)