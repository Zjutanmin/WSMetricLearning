function showhist
dir = 'D:\MinTan\Study\CVPR\cvpr\src_13\fig\';
[sizetitle,sizelengend, sizelabel, sizetick] = getsize();
load('D:\MinTan\project\Signdetect\SignClassify\TrainInfo\image_Sign_NewT4_1_Floderinfo.mat')
load('D:\MinTan\project\Signdetect\SignClassify\TrainInfo\image_Sign_NewT4_1_FlodLabel.mat')
[a, b, c] = unique(ts_Fold_label); 
for ii = 1:length(a)
    len(ii) = length(find(c == ii));
end
ii = find(a == 0);tmp = setdiff([1:length(len)], ii);
len = len(tmp);c = c(tmp);a = a(tmp);
% load([img_diro, '\datainfo.mat']);
index = find(len >= 20);
bar(len(index))
xlabel('Class' ,'fontsize', sizelabel); 
ylabel('class frequencies' ,'fontsize', sizelabel); 
name = 'class frequencies';

print(gcf, '-djpeg', '-r0', [dir name '.jpg']);
saveas(gca,[dir name '.fig']);
print(gcf, '-depsc2','-r0', [dir name '.eps']);
close all;