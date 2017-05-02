function feat = GetStd(feat, swin, stride)
ii = 0; 
for i = 1:stride:size(feat,1)
    ii = ii+1;jj = 0;
    for j = 1:stride:size(feat,2)
        jj = jj+1;
        patch = feat(i:i+swin-1, j:j+swin-1);
        feat(ii,jj,1) = mean(patch(:));
        feat(ii,jj,2) = std(patch(:));
    end
end