function feat = lbpfeatures(im,sbin,overlap,swin,stride,slbp)
% size(im)
% [sbin,overlap,swin,stride]
% slbp
im = VirBySbin(im,sbin,slbp.radius);
% size(im)
result = lbp_pointr(rgb2gray(uint8(im)),slbp.mapping,slbp.lbppara,true);
feat = densehistN(double(result),[swin,swin],[stride,stride],slbp.bins);
% size(feat)