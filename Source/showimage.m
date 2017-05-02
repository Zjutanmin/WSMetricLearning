% % % function showimage(dataXT, row, col, imsize)
% % % im = zeros([row*imsize, col*imsize]);
% % % for i = 1:size(dataXT, 1)
% % %     [x,y] = ind2sub([row, col], i);
% % %     im(imsize* (x  -1) + 1:imsize* x, imsize* (y  -1) + 1:imsize* y) = reshape(dataXT(i,:), imsize, imsize);
% % % end
% % % im = (im - min(im(:))) / (max(im(:)) - min(im(:)));
% % % % figure;
% % % imshow((im));
% % % 
% % % 



function showimage(dataXT, row, col, imsize)
im = zeros([row*imsize, col*imsize]);
for i = 1:size(dataXT, 1)
    [x,y] = ind2sub([row, col], i);
    tim = dataXT(i,:);
    tim = (tim - min(tim(:))) / (max(tim(:)) - min(tim(:)));
    im(imsize* (x  -1) + 1:imsize* x, imsize* (y  -1) + 1:imsize* y) = reshape(tim, imsize, imsize);
end
% im = (im - min(im(:))) / (max(im(:)) - min(im(:)));
% figure;
imshow((im));