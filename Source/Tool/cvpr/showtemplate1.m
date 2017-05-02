% function showtemplate1
dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
load('D:\MinTan\project\Signdetect\SignClassify\tr_imname.mat')
% load('D:\MinTan\project\Signdetect\SignClassify\result1.mat')
[sizetitle,sizelengend, sizelabel, sizetick] = getsize();
% load('D:\MinTan\project\Signdetect\SignClassify\haozhang\Sal\Traininfo\SampleQulitT_R_2Round3_1.mat')
% idx = find(result1== 1);
nc = length(tr_imname);
col = 7; 
row = 8;
np = 70;

im = zeros(row*np, col*np, 3);
tr_imname1 = tr_imname;
% tr_imname1 = tr_imname(idx);
for i = 1:nc  
    imname = tr_imname1{i};
    [A, B, C] = fileparts(imname);
    fid = (strfind(A, '\'));
    templateid = A(fid(end)+1:end);
    imname = fullfile('D:\MinTan\project\Signdetect\SignClassify\image\Sign_NewT5',...
        num2str(templateid), ['train_' num2str(templateid), '.jpg']);
    img = imread(imname);
    ccol = mod(i, col); 
    if ccol == 0 
        ccol = col; 
    end
    crow = ceil(i / col);
    im((crow-1)*np+1:(crow)*np, (ccol-1)*np+1:(ccol)*np, :) = imresize(img, [np, np]);
end
imshow(uint8(im));
name = 'TrueTemplates';

print(gcf, '-djpeg', '-r0', [dir name '.jpg']);
saveas(gca,[dir name '.fig']);
print(gcf, '-depsc2','-r0', [dir name '.eps']);
close all;



