function [feat, xx] = computerfea(im, sbin, nbin, feattype, swin, stride, ...
    descriptor,cache, imageid, overlap , setting,wordmap,fsize)
switch feattype
    case 'hog'
        feat = features(im,stride);
        feat = permute(feat, [3 1 2]);
        feat = feat(1:end-1,:,:);
    case 'lbp'
        feat = lbpfeatures(im,sbin,overlap,swin,stride,...
            setting.featsetting.lbp);
    case 'hog_dalal'
        Params = [setting.hog.orientation swin setting.hog.bsize ...
            strcmp(setting.hog.issigned, 'signed') 0.2];
        feat = HoG(im, Params);
        ff = 2+ceil(-0.5 + size(im)/swin);
        ff = ff - 2 - (setting.hog.bsize - 1);
        dim = numel(feat) / (ff(1) * ff(2));
        feat = reshape(feat, [dim, ff(1), ff(2)]);
    case 'ltp'
        feat = ltpfeatures(im,sbin,overlap,swin,stride,...
            setting.featsetting.ltp);
    case 'color'
        feat  = colorfeatures(im,sbin,swin,stride,...
                setting.featsetting.color.descriptor,1);
        feat = permute(feat, [3 1 2]);
    case 'Hue'
        hue = rgb2hsv(im(6:end-5, 6:end-5,:));
        hue = hue(:, :, 1);
        hue = (hue - min(hue(:))) / (max(hue(:)) - min(hue(:)));
        hue = uint8(hue* 255);
        feat = hist(hue(:), [0:255]);
        feat = reshape(feat, [256, 1, 1]);
%         feat  = colorfeatures(im,sbin,swin,stride,...
%                 setting.featsetting.color.descriptor,1);
%         feat = permute(feat, [3 1 2]);
%         
%         setting.featsetting.color
        
        
    case 'sift'
        [frames1,feat] = sift(im);
    case 'bow' 
        feat = bowfeature(im,sbin,wordmap,fsize);
    case 'sphog1'
        feat = ((im)) / 255;
        feat = feat(:);          
        feat = compute_sphog_features(feat', ones(1, length(feat)));  
        feat = feat(:);
    case 'Pixel1'
        feat = ((im)) / 255;
        feat = feat(:);
    case 'sphogM1'
        feat = ((im));
        feat = feat(:);          
        feat = compute_sphog_features(feat', ones(1, length(feat)));  
        feat = feat(:);
    case 'PixelM1'
        feat = ((im));
        feat = feat(:);
    case 'sphog'
        feat = ((im')) / 255;
        feat = feat(:);          
        feat = compute_sphog_features(feat', ones(1, length(feat)));  
        feat = feat(:);
    case 'PixelO'
        feat = ((im));
        feat = feat(:);
    case 'Pixel'
        feat = ((im')) / 255;
        feat = feat(:);
    case 'sphogM'
        feat = ((im'));
        feat = feat(:);          
        feat = compute_sphog_features(feat', ones(1, length(feat)));  
        feat = feat(:);
    case 'PixelM'
        feat = ((im'));
        feat = feat(:);
    otherwise
        display('A non existing assignment method is selected');
end