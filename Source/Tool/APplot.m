function APplot(path, Class, stitle, celltitle, innertilte, cresult, ctitle)
for i = 1:length(cresult)
    PlotFigure(path, Class, stitle, celltitle, innertilte, cresult{i}, ctitle{i});
end
% 
% PlotFigure(Class, stitle, celltitle, innertilte, t2, 'Top 5');
% PlotFigure(Class, stitle, celltitle, innertilte, t1, 'Top 1');
% PlotFigure(Class, stitle, celltitle, innertilte, t2, 'Top 5');

function PlotFigure(path, Class, stitlet, celltitle, innertilte, t1, suffix)
[sizetitle,sizelengend, sizelabel, sizetick] = getsize();
figure;
dir = ['D:\MinTan\project\Signdetect\SignClassify\result\Sign_New1\Figure\' path '\'];
if ~exist(dir)
    mkdir(dir)
end
result = cell(1, length(Class));
for i = 1:length(Class)
    result{i} = zeros(length(innertilte), length(t1));
end

for j = 1:length(t1)
    for i = 1:length(Class)
        result{i}(:, j) = t1{j}(:, i);
    end
end
namestr = [stitlet '_' suffix];
if length(Class) > 1
    row = 3;
    col = 3;
else
    row = 1;
    col = 1;
end

for i = 1:length(Class)
    subplot(row, col, i);
    tmp = result{i};
    bar(tmp');
    stitle = [stitlet '_' Class{i} suffix];
    title(Class{i}, 'fontsize', sizetitle);
    set(gca,'XTick',[1:length(celltitle)]);set(gca,'xticklabel',celltitle,'fontsize', 14);
    set(gca,'fontsize', sizetick);
end
if length(Class) > 1
    subplot(row, col, i+1);
    tmp(:) = 0;bar(tmp');
    h = legend(innertilte, 'Location', 'NorthEast');set(h, 'fontsize', sizelengend);
else
    h = legend(innertilte, 'Location', 'NorthEast');set(h, 'fontsize', sizelengend);
end
print(gcf, '-djpeg', '-r0', [dir namestr '.jpg']);
close all