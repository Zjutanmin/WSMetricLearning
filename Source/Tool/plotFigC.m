function h = plotFigC(ratio, result, TS, name, xlabels, ylabels,...
    xdir, dir, location, issave, plotTest, rot, Viewidr, viewlabel, barfig, xyaxis, XTICK)
if nnz(result)  == 0
    return;
end
if nargin < 10
    issave = 0;
end
if nargin < 11
    plotTest = 1;
end
if nargin < 12
    rot = 0;
end
if nargin < 13
    Viewidr = 0;
end
if nargin < 14
    viewlabel = [1, 1];
end
if nargin < 15
    barfig = 0;
end
if nargin < 16
    xyaxis = [-1 -1 -1 -1];
end
if nargin < 17
    XTICK = 0;
end
ttnum = 0;
 if iscell(location)
    ttnum = location{1};
    location = location{2};
end
Barlegend = 0;
if iscell(ratio)
    classes = ratio{1}; 
    ratio = ratio{2};
    Barlegend = 1;
end
STyle1 = 0;
if iscell(xyaxis)
    STyle1 = xyaxis{2};
    xyaxis = xyaxis{1};
end
isFromID = 0;
if iscell(result)
    FromID = result{2};
    isFromID = 1;
    result = result{1};
end
idt = find(result == 0);
thre1 = max(setdiff(result(:), 0)); 
thre = min(setdiff(result(:), 0)); 
if thre1 ~= thre
    result(idt) = thre - (thre1 - thre);
end
subplotF = 0;
if iscell(name)
    subplotF = 1;
end

hold on;
[sizetitle,sizelengend, sizelabel, sizetick] = getsize(ttnum);
isplot = 1;
if subplotF
    figure(name{2}+1);
    sizetitle = get(gca, 'fontsize');
    plot([1:5], rand(1, 5));
    h = legend({'test'});
    sizelengend = get(h, 'fontsize');
    sizelabel = sizetitle;
    sizetick = sizetitle;
    close(name{2}+1);isplot = name{3};
    figure(name{2});name = name{1};
else
    figure;
end
if ~isempty(strfind(location, 'Outside'))
% %     sizelengend = sizelengend / 2;
% %     sizetitle = sizetitle / 2;
% %     sizelabel = sizelabel / 2;
% %     sizetick = sizetick / 2;
%     sizelengend = sizelengend* 2;
%     sizetitle = sizetitle* 2;
%     sizelabel = sizelabel* 2;
%     sizetick = sizetick* 2;
else
    
end
if STyle1
    tStyle = GetStyle_zyt1(); 
else
    tStyle = GetStyle_zyt(); 
end
numStyle = length(tStyle);


if Viewidr
    view(90, -90);
else
    
end
barname = 'xticklabel';
barTname = 'XTick';
if size(result, 1) == 1 || barfig
    bar(result);
    if xdir
        TS = TS(end:-1:1);
    end
    resultM = result(:);
    if iscell(plotTest)
        resultM = [resultM; plotTest{2}];
    end
    M= (max(resultM) -  min(resultM));
    if size(result, 1) == 1
        NR = length(result);
    else
        NR = length(TS);
%         NR = size(result, 2);
    end
    if M == 0
        return
    end
    axis([0.5,NR + 0.5,min(resultM) - 1/20*M,max(resultM) + 1/20*M]);
    if ~isempty(TS)
        set(gca,barTname,[1:NR]);
        set(gca,barname,TS,'fontsize', sizetick);
    end
    if iscell(plotTest)
        plot(plotTest{1}, plotTest{2}*ones(1,length(plotTest{1})), 'r-', 'linewidth', 2);
        if length(plotTest) > 2
            text(plotTest{3}, plotTest{4}, plotTest{5}, 'fontsize', sizetitle, 'Color', [1 0 0])
        end
    else
        if plotTest
        for jj= 1:NR
            text(jj - 0.1, result(jj) + M/100, num2str(savedot(result(jj), 4)), 'fontsize', sizelengend)
        end
        end
    end

    if Barlegend
        Flegend(ratio, location, sizelengend);
    end
else
    for jj = 1:size(result, 2)
        hold on;
        styleID = mod(jj-1, numStyle)+1; 
        
        if STyle1
            plot(ratio, result(:, jj),tStyle(styleID).color,...
            'LineWidth', tStyle(styleID).LineWidth, 'MarkerFaceColor', tStyle(styleID).MarkerFaceColor,...
            'Color', tStyle(styleID).scolor, 'MarkerSize',  tStyle(styleID).MarkerSize);
        else
            if isFromID
                plot(ratio(FromID(jj):end), result(FromID(jj):end, jj),tStyle(styleID).color,...
                    'LineWidth', tStyle(styleID).LineWidth, 'MarkerFaceColor', tStyle(styleID).MarkerFaceColor,...
                    'Color', tStyle(styleID).scolor);
            else
                plot(ratio, result(:, jj),tStyle(styleID).color,...
                    'LineWidth', tStyle(styleID).LineWidth, 'MarkerFaceColor', tStyle(styleID).MarkerFaceColor,...
                    'Color', tStyle(styleID).scolor);
            end
        end
    end
    if XTICK
    set(gca,barTname,ratio);
    end
    Flegend(TS, location, sizelengend);
    
    if xdir
        set(gca, 'xdir', 'reverse');
    end
end

set(gca, 'fontsize', sizetick);
if viewlabel(1)
    xlabel(xlabels, 'fontsize', sizelabel)
end
if viewlabel(2)
    ylabel(ylabels, 'fontsize', sizelabel)
end

if ~exist(dir)
    mkdir(dir);
end
if rot
%     get(gca,barTname,[1:length(result)]);
%     set(gca,barname,TS,'fontsize', sizetick);
    hh = get(gca,barname);
    xticklabel_rotate([1:length(hh)],rot,hh,'interpreter','none')
end

% set(gcf, 'PaperPositionMode', 'auto')
% % % X = get(gca,'Xlim');
% % % Y = get(gca,'Ylim');
% % % axis([X(1)-1, X(2), Y(1), Y(2)]);
if size(result, 1) == 1
    set(gcf, 'unit', 'normalized', 'position', [0,0,1,1]);
end

if Viewidr
    set(gca, 'OuterPosition', [0.1 0.1 0.9 0.9])
end
% if nnz(xyaxis())
xx = axis;
xx(find(xyaxis~= -1)) = xyaxis(find(xyaxis~= -1));
axis(xx)
h = gcf;
if size(result, 1) == 1 || barfig
    if size(result, 1) == 1
        [patterns, colorstr] = getcolor(length(result));
    else
        [patterns, colorstr] = getcolor(size(result, 2));
    end
    applyhatch_plusC(gcf, patterns, colorstr);
end
if isplot
    print(gcf, '-djpeg', '-r0', [dir name '.jpg']);
saveas(gca,[dir name '.fig']);
print(gcf, '-depsc2','-r0', [dir name '.eps']);
if issave
    save([dir name '.mat'], ['result']);
end
end



function Flegend(TS, location, sizelengend)
if ~isempty(TS)
    h = legend(TS, 'Location', location);
    set(h, 'fontsize', sizelengend);
end