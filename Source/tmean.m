function x = tmean(x, dir)
if nargin < 2
    dir = 1;
end
sumdir = 3 - dir;
zz = sum(x, sumdir);
idx = find(zz> 0 );
if ~isempty(idx)
    x(find(x < 0)) = 0;
% % if dir == 1
% %     x = x(idx,:);
% % end
% % if dir == 2
% %     x = x(:,idx);
% % end
x = mean(x, dir);
else
    if dir == 1
    x = x(1,:);
end
if dir == 2
    x = x(:,1);
end
end