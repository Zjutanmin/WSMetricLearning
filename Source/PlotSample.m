load('SampleWT', 'SampleWTT', 'dataX');
[aa,bb] = sort(SampleWTT, 'descend');
xw = dataX(69:end,:);
xw = xw(bb,:);
showimage(xw(1:10:end,:), 12, 17, 32)
dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\_PIE\Sample\';
name = ['SampleW'];
print(gcf, '-djpeg', '-r0', [dir name '.jpg']);
saveas(gca,[dir name '.fig']);
print(gcf, '-depsc2','-r0', [dir name '.eps']);