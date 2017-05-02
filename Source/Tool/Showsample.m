% fn = 'D:\MinTan\project\Signdetect\SignClassify\image\sign\SignTemplates\';
% fndir = dir([fn '*.jpg']);
% num = length(fndir);
% col = ceil(sqrt(num));
% psize  = [8 8];
% im = zeros([col*psize, 3]);
% index = 0;
% for i = 1:col
%     for j = 1:col
%         index  = index  + 1;
%         if index > length(fndir)
%             continue;
%         end
%         pim  = imread([fn, fndir(index).name]);pim = imresize(pim, psize);
%         im((i-1)*psize(1)+1:i*psize(1), (j-1)*psize(2)+1:j*psize(2), :) = ...
%             pim;
%     end
% end
% imshow(im);
% titile('All the templates')
% print(gcf, '-djpeg', '-r0', ['D:\MinTan\project\Signdetect\SignClassify\Tool\templates.jpg']);


fn = 'D:\MinTan\project\Signdetect\SignClassify\image\sign\SignTemplates\';
fndir = dir([fn '*.jpg']);
num = length(fndir);

% col = ceil(sqrt(num));
psize  = [8 8];
imsize   = [10 10];
col = 5;row = 12;
N = col*row;
im = uint8(zeros([[col, row] .* imsize, 3]));
% im = zeros([col*psize, 3]);
index = 0;
dis = (imsize - psize) /2;
step = floor(num / N);
for i = 1:col
    for j = 1:row
        index  = index  + 1;
        tindex = (index-1) * step+1;
        
        if index > length(fndir)
            continue;
        end
        pim  = imread([fn, fndir(tindex).name]);
        subplot(col, row, index);imshow(uint8(pim ));
%         pim = imresize(pim, psize);
%         im((i-1)*imsize(1)+dis(1)+1:i*imsize(1)-dis(1), ...
%             (j-1)*imsize(2)+dis(2)+1:j*imsize(2)-dis(2), :) = ...
%             pim;
    end
end

% imshow(uint8(im));
titile('All the templates')
print(gcf, '-djpeg', '-r0', ['D:\MinTan\project\Signdetect\SignClassify\Tool\templates.jpg']);