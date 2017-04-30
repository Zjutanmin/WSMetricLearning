function savehistfigure(Cscore, ylabel, setting)
try
if (max(Cscore) - min(Cscore)) < 1e-6
    return;
end
h = figure;
b1 = (max(Cscore(find(~ylabel))) - min(Cscore(find(~ylabel)))) / 100;
b2 = (max(Cscore(find(ylabel))) - min(Cscore(find(ylabel)))) / 100;
xx1 = [min(Cscore(find(~ylabel))):b1:max(Cscore(find(~ylabel)))];
yy1 = hist((Cscore(find(~ylabel))), xx1);
xx2 = [min(Cscore(find(ylabel))):b2:max(Cscore(find(ylabel)))];
if isempty(xx2)
    xx2 = 1;
    yy2 = [1:length(find(ylabel))];
else
    yy2 = hist((Cscore(find(ylabel))), xx2);
end
if isempty(xx2)
    xx1 = 1;
    yy1 = [1:length(find(~ylabel))];
else
    yy1 = hist((Cscore(find(~ylabel))), xx1);
end
plot(xx1, yy1, 'r-')
hold on;
plot(xx2, yy2, 'g--')
legend({'False', 'True'});
print(h, '-djpeg', '-r0',fullfile(setting.QualityResult,['Hist-', setting.Mstr(1:end-4)]));
print(h, '-depsc2','-r0',fullfile(setting.QualityResult,['Hist-', setting.Mstr(1:end-4)]));
close all;
catch
    t = 1;
end

