function im = Colorpicture(w)
if isempty(w)
    im = [];
    return;
end
xx = jet;
maxmargin = 1;
margin = size(xx,1);
base = min(w(:));
wmax = max(w(:));
wmin = min(w(:));
w = (w-base)/(wmax-wmin);
s = size(w);
bs = margin;
im = ones((bs)*s(1), (bs+1)*s(2))*128;
for i = 1:s(1),
  for j = 1:s(2),
    im((i-1)*(bs)+1:i*(bs),(j-1)*(bs+1)+1:j*(bs+1)) = ...
        histImage(im((i-1)*(bs)+1:i*(bs),(j-1)*(bs+1)+1:j*(bs+1)), ...
        w(i,j,:),[bs,bs+1]);
  end
end
% % figure;
% % imshow(im)
% % t =1;
% color


function im = histImage(im, w,imsize)
w = w(:);
p = hist(w,imsize(1));
p = round((p./imsize(1))*imsize(2));
for i =1:imsize(1)
    im(imsize(1)-p(i)+1:imsize(1),i:i+1) = 0;
end