function feat = ltpfeatures(im,sbin,overlap,swin,stride,sltp)
im = VirBySbin(im,sbin,sltp.radius);
[uresult, lresult] = ltp_pointr(rgb2gray(uint8(im)),sltp.mapping,sltp.thresh,...
    sltp.ltppara,true);
feat1 = densehistN(double(uresult),[swin,swin],[stride,stride],sltp.bins);
feat2 = densehistN(double(lresult),[swin,swin],[stride,stride],sltp.bins);
feat = [feat1;feat2];