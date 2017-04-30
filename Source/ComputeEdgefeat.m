function edge_fea = ComputeEdgefeat(QulityFeadir, fdatabase, feattype, setting)

edge_fea =  ComputeEfeat(fdatabase, feattype, [setting.tr_idx; setting.ts_idx], setting, setting.labelmap);
save(QulityFeadir, 'edge_fea')



function ctr_fea = ComputeEfeat(fdatabase, feattype, tr_idx, setting, labelmap, ir, jr)
ctr_fea = []; 
if nargin < 6
    ir = [1:length(feattype)];
end

for i = ir
    bookfeattype = length(fdatabase{i}.path);
    if nargin < 7
        jr = [1:length(bookfeattype)];
    end
    for j = jr
        %ctr_fea_t = []; 
        for jj = 1:length(tr_idx),
            if ~mod(jj, 5),
                fprintf('.');
            end
            if ~mod(jj, 100),
                fprintf(' %d images processed\n', jj);
            end
            fpath = fdatabase{i}.imgpath{tr_idx(jj)};
            img =  rgb2gray(imread(fpath));
            
            if size(img,1)*size(img,2) == 1
                tmp(1) = 0;
                tmp(2) = 0;
                ctr_fea_t(tr_idx(jj),:) = tmp;
                continue;
            end 
            
            imgedge = edge(img, 'Canny');
            [dx,dy] = gradient(double(img));
            xx = sqrt(dx.^2+dy.^2);
            tmp(1) = mean(mean(xx .* imgedge));
            
            tmp(2) = mean(mean(xx));
            
            ctr_fea_t(tr_idx(jj),:) = tmp;
        end
        ctr_fea = [ctr_fea,ctr_fea_t];
    end
end
clear 'ctr_fea_t'