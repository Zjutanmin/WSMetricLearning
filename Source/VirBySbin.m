function im = VirBySbin(im,sbin, radius)
virsize = round(size(im)/sbin) * sbin;
maxsize = min(size(im),virsize); 
padsize = [virsize-maxsize];
padsize(3) = 0;
im = padarray(im, padsize,'replicate','post');
im = im(1:virsize(1),1:virsize(2),:);
im = im(sbin+1-radius:end-sbin+radius,sbin+1-radius:end-sbin+radius,:);