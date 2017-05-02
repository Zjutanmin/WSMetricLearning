function mulfeat = mulfeatures_im(im,setting,i, sbin, rate,imageid,wordmap,fsize)
overlap = setting.overlap(i);
feattype = setting.feattype(i);
stride = setting.stride(i) * rate;
swin = setting.swin(i) * rate;
descriptor = setting.descriptor(i);
mulfeat = [];
dim = 0;
for i = 1:length(feattype)
    feat = computerfea(im, sbin, sbin, feattype{i}, swin(i), stride(i), descriptor{i}, [],imageid,...
        overlap(i), setting, wordmap, fsize); 
    mulfeat(dim+1:dim+size(feat,1), :,:) = feat;
    dim = dim+size(feat,1);
end