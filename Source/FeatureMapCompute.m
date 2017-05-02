function cellfea = FeatureMapCompute(setting, im, j, latent, istrain)
warped = imresize(im, setting.rawsize, 'bilinear');
dfeat2 = cell(1, length(setting.displace));
% setting.rescale = 1;
pady = setting.pady;
padx = setting.padx;
if istrain
    feat1 = cell(1, length(setting.rotate));feat2 = cell(1, length(setting.rotate));
    for i = 1:length(setting.rotate)
        warped1 = imrotate(warped, setting.rotate(i), 'bilinear', 'crop');
        fea =  mulfeatures_im(warped1, setting, j, setting.stride(j), 1, -1,[],[]);
%         [a,b,c] = size(fea);fea = reshape(fea, [a, b*c]);fea = fea(:);
        fea = permute(fea, [2 3 1]);
        feat1{i} = fea;
        switch latent
            case 2
                fea = pyrafeaturecompute(setting, warped1, j);
                feat2{i} = fea;
            case 3
        end
    end
else
    swin = setting.stride(j);
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
        
        
        if setting.rescale && six > 1
            col = ceil(sqrt((2*six+1)*2*six*(2*siy+1)*2*siy));
        else
            col = 2*six+1;
        end
        
        
%         subplot((2*si+1)+1, (2*si+1), 1);imshow(uint8(warped))
        switch latent
            case 2
                dfeat2{i} = [];
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

                        tmp = warped;
                        if si
                            
                        tmp(end+1:range1(end), end+1:range2(end), :) = 0;
                        tmp1 = tmp(range1, range2, :);
                        else
                            tmp1 = tmp;
                        end
%                         subplot(col, col, jj);
%                         showboxes(warped, [range2(1), range1(1), range2(end), range1(end)])

                        setting.stride(j) = swin;tmp1 = imresize(tmp1, setting.rawsize, 'bilinear');
                        feat2{i}{jj} = pyrafeaturecompute(setting, tmp1, j);
                        dfeat2{i}  = [dfeat2{i}; [t1+six, t2+siy]];

                        end
                    
                    end
                end
%                 tdfeat2 = dfeat2;tfeat2 = feat2;
            
            case 3
        end
%         pause;
        
    end
    cellfea{1} = feat1;
end


% for kk = 1:length(tfeat2)
% dis = cell2mat(tfeat2{kk}) - cell2mat(t1feat2{kk});max(abs(dis(:)))
% dis = (tdfeat2{kk}) - (t1dfeat2{kk});max(abs(dis(:)))
% end

cellfea{1} = feat1;
cellfea{2} = feat2;
t = 1;