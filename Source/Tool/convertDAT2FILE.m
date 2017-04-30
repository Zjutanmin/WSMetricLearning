%%%dataTransform('Sign', '_NewT5', 'image\Temp\SignTemplates')
%%%convertDAT2FILE('face', '_PIE', 'image\dataset\face_PIE\PIE.mat')
%%%convertDAT2FILE('face', '_ORL', 'image\dataset\face_ORL\ORL_32x32.mat')
%%%convertDAT2FILE('face', '_YaleBE', 'image\face_YaleBE\YaleB_32x32.mat')
function convertDAT2FILE(dataname, suffix, orgfile)
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
        imsize = [32, 32];isTrans = 0;plus = 0;
    case 'face_ORL'
        strtest = {''};NTest = 0;formatstr = '%03d';
        imsize = [32, 32];isTrans = 0;plus = 0;
end
NTrain = size(fea, 1) - NTest;
index = {[1:NTrain], [NTrain+1:size(fea, 1)]};
for kkk = 1:length(strtest)
for i = 1:length(label)
    fileD = fullfile('D:\MinTan\project\Signdetect\SignClassify\image', filename, strtest{kkk}, num2str(label(i)));
    if ~exist(fileD)   mkdir(fileD);   end
    fileD = fullfile('D:\MinTan\project\Signdetect\SignClassify\image', filename, strtest{kkk}, num2str(label(i)));
    if ~exist(fileD)   mkdir(fileD);   end
end
end
%%%training

                
NN = zeros(1, length(label));
for kkk = 1:length(strtest)
for i = index{kkk}
    fileD = fullfile('D:\MinTan\project\Signdetect\SignClassify\image', filename, strtest{kkk}, num2str(gnd(i)));
    NN(gnd(i)+plus) = NN(gnd(i)+plus) + 1;
    im = (reshape(fea(i,:), imsize));   if isTrans   im = im';    end
    sFolder = num2str(i, formatstr);
    imwrite(uint8(im), fullfile(fileD, [sFolder, '.bmp']));
end
end

