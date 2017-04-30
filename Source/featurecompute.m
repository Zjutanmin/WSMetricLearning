function fea = featurecompute(setting, im, i)
fea = mulfeatures_im(im, setting, i, setting.stride(i),1, -1,[],[]);
[a,b,c] = size(fea);fea = reshape(fea, [a, b*c]);fea = fea(:);