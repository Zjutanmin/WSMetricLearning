function PlotMultiFiG(TSS, TS, resultt, Bresultt, sname, dir, location, index)
if nargin < 7
    location = [];
end
idt = find(resultt == 0);
if ~isempty(idt)
    thre1 = max(setdiff(resultt(:), 0)); 
    thre = min(setdiff(resultt(:), 0)); 
    if isempty(thre1)
        return;
    end
    resultt(idt) = thre - (thre1 - thre)*0.08;
end

n = 0;
for jj = 1:length(TSS)
    n = n + 1;
    TSN{n} = TSS{jj};
    dim(n) = length(TS{jj});
end
tid = 0;tdim = prod(dim); idt = [1:n];
% % resultt = reshape(resultt, dim(end:-1:1)); 
resultt = permute(resultt, [n:-1:1]);
re = {};
if nargin < 8
    index = [1:length(idt)];
end
for tt = 1:length(idt)
    if ~ismember(tt, index)
        continue;
    end
    if dim(tt) ~= 1
        tid = tid + 1;
        result = permute(resultt, [tt, setdiff(idt, tt)]); 
        re{tid} = reshape(result, [dim(tt), tdim / dim(tt)]); 
        idx(tid) = tt;
    end
end
[sizetitle,sizelengend, sizelabel, sizetick] = getsize();
col = ceil(sqrt(length(re)));row = col;
while col*row > length(re)
    row = row - 1;
end
if col*row < length(re)
    row = row + 1;
end
close all
for tt = 1:length(re)
    res = re{tt};N = size( res, 1);
    subplot(col,row, tt);bar(res);hold on;
    resulttmp = [res(:); Bresultt];
    hold on; 
    plot([0:N + 1], Bresultt* ones(1, N+2), 'r-', 'LineWidth', 2);
    M= (max(resulttmp(:)) -  min(resulttmp(:)));
    axis([0.5,N + 0.5,min(resulttmp(:)) - 1/20*M,max(resulttmp(:)) + 1/20*M]);
    set(gca,'XTick',[1:N]);set(gca,'xticklabel',TS{idx(tt)},'fontsize', sizetick);
    if ~isempty(location)
        idd = setdiff([1:length(TS)], idx(tt));
        h = legend(TS{idd}, 'Location', location);
        set(h, 'fontsize', 5);
    end
    title(TSN{idx(tt)});
end
saveas(gca,[dir sname '.fig']);print('-depsc2','-r0', [dir sname '.eps']);saveas(gca,[dir sname '.jpg']);