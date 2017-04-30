function [patterns, colorstr] = getcolor(n)
colors = 'rgbymck';
m = ceil(n / length(colors));
colors = repmat(colors, [1, m]);
colorstr = colors(1:n);

colors = '\-x./|+';
m = ceil(n / length(colors));
colors = repmat(colors, [1, m]);
patterns = colors(1:n);