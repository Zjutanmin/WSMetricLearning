function showtemplate
dir = 'D:\MinTan\Study\CVPR\cvpr\src_13\fig\';
[sizetitle,sizelengend, sizelabel, sizetick] = getsize();
load('D:\MinTan\project\Signdetect\SignClassify\haozhang\Sal\Traininfo\SampleQulitT_R_2Round3_1.mat')
nc = size(SampleQulityT.labelimname, 1);
col = 13; 
row = 4;
np = 70;
im = zeros(row*np, col*np, 3);
for i = 1:nc
    imname = SampleQulityT.labelimname{i,1}{1};
    [A, B, C] = fileparts(imname);
    fid = (strfind(A, '\'));
    templateid = A(fid(end)+1:end);
    imname = fullfile('D:\MinTan\project\Signdetect\SignClassify\image\Sign_NewT4',...
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
name = 'Templates';

print(gcf, '-djpeg', '-r0', [dir name '.jpg']);
saveas(gca,[dir name '.fig']);
print(gcf, '-depsc2','-r0', [dir name '.eps']);
close all;



