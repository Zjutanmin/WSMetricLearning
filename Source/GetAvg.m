function feat = GetAvg(feat, swin, stride)
feat = cumsum(feat);feat = cumsum(feat, 2);   
feat = padarray(feat, [1 1], 'pre');
feat = feat(swin+1:stride:end, swin+1:stride:end) + feat(1:stride:end-swin, 1:stride:end-swin) - ...
    (feat(swin+1:stride:end, 1:stride:end-swin) + feat(1:stride:end-swin, swin+1:stride:end));
feat = feat / (swin*swin);