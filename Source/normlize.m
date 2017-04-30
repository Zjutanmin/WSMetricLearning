function fea = normlize(fea)
if nargin < 2
    p = 2;
end
fea = fea./norm(fea,p);