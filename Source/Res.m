function x = Res(x)
index = strfind(x, '_');
str = x(index(end)+1:end);
idx = strfind(str, 'M');
if ~isempty(idx)
    x = [x(1:index(end)), str(1:idx(1)-1), '.jpg'];
end