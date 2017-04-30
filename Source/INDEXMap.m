function [Map, MapSub2ind, MapRange] = INDEXMap(setting, im, j, latent, padx, pady)
if mod(latent, 5) == 0
    Map = [];
    MapSub2ind = [];
    MapRange = [];
    return;
end
warped = imresize(im, setting.rawsize, 'bilinear');
% pady = setting.pady;
% padx = setting.padx;
currsize1 = round(setting.rawsize / 8) - 2;
feat1 = cell(1, length(setting.displace));feat2 = cell(1, length(setting.displace));
for i = 1:length(setting.displace)
    si = setting.displace(i);
    
    currsize = currsize1 + [2,2] * si;
    swin1 = round( [setting.rawsize(1)] ./ (currsize(1)+2));
    swin2 = round( [setting.rawsize(2)] ./ (currsize(2)+2));
    if swin2 ~= swin1
        fprintf('swin1 != swin2')
        pause;
    end
    
    setting.stride(j) = swin1;
    feat1{i} =  mulfeatures_im(warped, setting, j, setting.stride(j), 1, -1,[],[]);
    feat1{i} = permute(feat1{i}, [2 3 1]);
    [a,b,c] = size(feat1{i}); 
    if setting.featPad
            feat1{i} = padarray(feat1{i}, [0 setting.pady+1 setting.padx+1], 0);
            % write boundary occlusion feature
            feat1{i}(1:pady+1, :, end) = 1;
            feat1{i}(end-pady:end, :, end) = 1;
            feat1{i}(:, 1:padx+1, end) = 1;
            feat1{i}(:, end-padx:end, end) = 1;
            six = si + pady+1; 
            siy = si + padx+1; 
    else
            six = si;
            siy = si;
    end
    jj = 0;
    for t1 = -six:six
        for t2 = -siy:siy
            if setting.rescale 
                irange = [a-2*six+2:a+2-six-t1];                 
                jrange = [b-2*siy+2:b+2-siy-t2];
            else
                irange = [a-2*six+2];
                jrange = [b-2*siy+2];
            end
            ntotal = length(irange) * length(jrange);
            for kk = 1:ntotal
                [xx,yy]=ind2sub([length(irange), length(jrange)], kk);
                step = [irange(xx), jrange(yy)];  
                jj = jj + 1;
                range1 = [(t1+six) * swin1 + 1 : ((t1+six)+step(1)) * swin1];
                range2 = [(t2+siy) * swin1 + 1 : ((t2+siy)+step(2)) * swin1];
                Map{i}(jj,:) = [t1+si+1, t2+si+1];
                MapSub2ind{i}(t1+si+1, t2+si+1) = jj;     
                MapRange{i}(jj,:) = [range1(1), range1(end), range2(1), range2(end)];
            end
        end
    end
end
                
                    
