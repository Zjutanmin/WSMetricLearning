function PlotFIG(ObjFun, FName, endplot)
if nargin < 3
    endplot = 0;
end

tStyle = GetStyle(); 
numStyle = length(tStyle);
figure;hold on;
bias = 0;

for i = 1:length(ObjFun)
    if isempty(ObjFun{i})
        continue;
    end
    styleID = mod(i-1, numStyle)+1; 
    plot([1+bias:length(ObjFun{i})+bias], ObjFun{i}, tStyle(styleID).color,... 
        'LineWidth', 0.5);
    bias = bias + length(ObjFun{i});
    tt(i) = ObjFun{i}(end);
end

print(gcf, '-djpeg', '-r0', [FName '.jpg']);
print(gcf, '-depsc2','-r0',[FName '.fig']);
close all;

if endplot
h = figure;
plot([1:length(tt)], tt, '-');
print(h, '-djpeg', '-r0',[FName 'tt.jpg']);
print(h, '-depsc2','-r0',[FName 'tt.fig']);
close all;
end


function tStyle = GetStyle()
%style array
%color style
styleID = 1;
tStyle(styleID).color = '-b'; 
tStyle(styleID).scolor = 'b';
styleID = styleID + 1;
tStyle(styleID).color = '-g'; 
tStyle(styleID).scolor = 'g';
styleID = styleID + 1;
tStyle(styleID).color = ':r'; 
tStyle(styleID).scolor = 'r';
styleID = styleID + 1;
tStyle(styleID).color = '-k';
tStyle(styleID).scolor = 'k';
styleID = styleID + 1;
tStyle(styleID).color = '-m';
tStyle(styleID).scolor = 'm';
styleID = styleID + 1;
tStyle(styleID).color = '-y';
tStyle(styleID).scolor = 'y';
styleID = styleID + 1;