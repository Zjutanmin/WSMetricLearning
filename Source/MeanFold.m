function [N, Nmax, Nmin] = MeanFold(dataset)
% dataset = 'Sign_NewT10';
load(['D:\MinTan\project\Signdetect\SignClassify\TrainInfo\image_' dataset '_1_Floderinfo.mat'])
[aa,bb,cc] = unique(ts_fold_idx);
for i = 1:length(aa)
    len(i) = length(find(cc == i));
end
N = mean(len);
Nmax = max(len);
Nmin = min(len);