function im = Lbppicture(w)
if isempty(w)
    im = [];
    return;
end
maxmargin = 1;
margin = size(w,3);
base = min(w(:));
wmax = max(w(:));
wmin = min(w(:));
if wmax==wmin
    w = round(0.5*margin)*ones(size(w));
else
    w = ceil((w-base)/(wmax-wmin)*margin);
end
s = size(w);
bs = margin;
im = ones((bs)*s(1), (bs+1)*s(2))*128;
for i = 1:s(1)
  for j = 1:s(2)
    im((i-1)*(bs)+1:i*(bs),(j-1)*(bs+1)+1:j*(bs+1)) = ...
        histImage(im((i-1)*(bs)+1:i*(bs),(j-1)*(bs+1)+1:j*(bs+1)), ...
        w(i,j,:),[bs,bs+1]);
  end
end


function im = histImage(im, w,imsize)
w = w(:);
pad = 2;
for i =1:imsize(1)
    im(imsize(1)-w(i)+1:imsize(1),i:i+1) = 0;
end
tim = im;
im = imresize(im,(size(im)-2*pad));
tim(1:pad,:) = 192;
tim(end-pad+1:end,:) = 192;
tim(:,1:pad) = 192;
tim(:,end-pad+1:end) = 192;
tim(pad+1:end-pad,pad+1:end-pad) = im;
im = tim;