%%%dataTransform('Sign', '_NewT5', 'image\Temp\SignTemplates')
%%%convertDAT2Ntrain('face', '_PIE', 'image\dataset\face_PIE\PIE.mat')
%%%convertDAT2Ntrain('face', '_ORL', 'image\dataset\face_ORL\ORL_32x32.mat')
%%%convertDAT2Ntrain('face', '_YaleBE', 'image\face_YaleBE\YaleB_32x32.mat')
function convertDAT2Ntrain(dataname, suffix, orgfile)
cd ..
load(orgfile);
label = unique(gnd);
filename = [dataname, suffix];
switch filename
    case 'digit_MNIST'
        strtest = {'Training', 'Testing'};NTest = 10000;formatstr = '%05d';
        imsize = [28, 28];isTrans = 1;plus = 1;
    case 'face_YaleBE'
        strtest = {''};NTest = 0;formatstr = '%04d';
        imsize = [32, 32];isTrans = 0;plus = 0;
    case 'face_PIE'
        strtest = {''};NTest = 0;formatstr = '%05d';
        imsize = [32, 32];isTrans = 0;plus = 0;Ntrain = [10 30 70 110 150];
    case 'face_ORL'
        strtest = {''};NTest = 0;formatstr = '%03d';
        imsize = [32, 32];isTrans = 0;plus = 0;
end
% % NTrain = size(fea, 1) - NTest;
% % index = {[1:NTrain], [NTrain+1:size(fea, 1)]};
[a,b,c] = unique(gnd);
idx = cell(1, length(a));
for i = 1:length(a)
    idx{i} = find(c == i);
end

for nt = Ntrain
    fileD = fullfile('D:\MinTan\project\Signdetect\SignClassify\image\dataset', filename, [num2str(nt), 'Train']);
for kkk = 1:10
    cidx = cellfun(@(x) getidx(x, nt), idx, 'UniformOutput', false);
    trainIdx = cell2mat(cidx);trainIdx = trainIdx(:);
    testIdx = setdiff([1:length(gnd)], trainIdx);testIdx = testIdx(:);
    try 
        mkdir((fileD))
    end;
    save(fullfile(fileD, [num2str(kkk), '.mat']), 'testIdx', 'trainIdx')
end
end

function idx = getidx(idx, nt)
idx = idx(randperm(length(idx)));
idx = idx(1:nt);idx = reshape(idx, 1, []);
