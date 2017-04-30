
function feat = computerfea(im, sbin, nbin, feattype, swin, stride, ...
    descriptor,cache, imageid, overlap , setting,wordmap,fsize)
switch feattype
    case 'hog'
        feat = features(im,stride);
        feat = permute(feat, [3 1 2]);
        feat = feat(1:end-1,:,:);
    case 'lbp'
        feat = lbpfeatures(im,sbin,overlap,swin,stride,...
            setting.featsetting.lbp);
    case 'ltp'
        feat = ltpfeatures(im,sbin,overlap,swin,stride,...
            setting.featsetting.ltp);
    case 'color'
        feat = colorfeatures(im,sbin,swin,stride,...
                setting.featsetting.color.descriptor,1);
        feat = permute(feat, [3 1 2]);
    case 'sift'
        [frames1,feat] = sift(im);
    case 'bow' 
        feat = bowfeature(im,sbin,wordmap,fsize);
    otherwise
        display('A non existing assignment method is selected');
end