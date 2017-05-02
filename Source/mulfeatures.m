function mulfeat = mulfeatures(im,model,sbin, rate,imageid,wordmap,fsize)
overlap = model.setting.overlap;
feattype = model.setting.feattype;
stride = model.setting.stride * rate;
swin = model.setting.swin * rate;
descriptor = model.setting.descriptor;
mulfeat = [];
dim = 0;
for i = 1:length(feattype)
    feat = computerfeature(im, sbin, model.nbin, feattype{i}, swin(i), stride(i), descriptor{i}, model.cache,imageid,...
        overlap(i), model.setting, wordmap, fsize);  
    mulfeat(dim+1:dim+size(feat,1), :,:) = feat;
    dim = dim+size(feat,1);
end
% mulfeat(end+1,:,:) = 0;
mulfeat = padarray(mulfeat,[1,0,0],0,'post');

function feat = computerfeature(im, sbin, nbin, feattype, swin, stride, ...
    descriptor,cache, imageid, overlap , setting,wordmap,fsize)
switch feattype
    case 'hog'   
        feat = hogfeatures1(im,stride,nbin);
%         toc;
    case 'lbp'
%         tic;
        feat = lbpfeatures(im,sbin,overlap,swin,stride,...
            setting.featsetting.lbp);
%         toc;
    case 'ltp'
%         tic;
        feat = ltpfeatures(im,sbin,overlap,swin,stride,...
            setting.featsetting.ltp);
%         toc;
    case 'color'
        feat = colorfeatures(im,sbin,swin,stride,...
                setting.featsetting.color.descriptor,setting.featsetting.color.norm);  
    case 'sift'
        [frames1,feat] = sift(im);
    case 'bow' 
        feat = bowfeature(im,sbin,wordmap,fsize);
    case 'sphog'
        feat = compute_sphog_features(im(:), []);       
    otherwise
        display('A non existing assignment method is selected');
end