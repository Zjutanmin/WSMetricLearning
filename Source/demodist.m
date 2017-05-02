Wgts = diag(ones([1 5]));
weuc = @(XI,XJ,W)(sum(bsxfun(@minus,XI,XJ).^2 * W, 2));
Dwgt = pdist2(X,Y, @(Xi,Xj) weuc(Xi,Xj,Wgts));
Dwgt2 = Dwgt(1,:);

tt = bsxfun(@minus, X(1,:),Y);
% Dwgt1 = sum((tt*Wgts*tt'),2);
 Dwgt1 = sum(tt .* tt * Wgts, 2);   
 Dwgt1 - Dwgt2'


tt = X(1,:) - Y(1,:);
Dwgt3 = ((tt*Wgts*tt'));