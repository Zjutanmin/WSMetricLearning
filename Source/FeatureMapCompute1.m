function cellfea = FeatureMapCompute1(setting, im, j, latent, istrain)
warped = imresize(im, setting.rawsize, 'bilinear');
dfeat2 = cell(1, length(setting.displace));
% setting.rescale = 0;

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
        
%         subplot((2*si+1)+1, (2*si+1), 1);imshow(uint8(warped))
        switch latent
            case 2
                dfeat2{i} = [];
                
                
                
                jj = 0;
                for t1 = -si:si
                    for t2 = -si:si
                        
%                         step = (a-si+t1+2) - (t1+si) -1;
                        
                        
                        jj = jj + 1;
                        
                        
                        range1 = [(t1+si) * swin1 + 1 : (a-si+t1+2) * swin1];
                        range2 = [(t2+si) * swin1 + 1 : (b-si+t2+2) * swin1];
                        
                        tmp = warped;
                        tmp(end+1:range1(end), end+1:range2(end), :) = 0;
                        tmp1 = tmp(range1, range2, :);
                        
                        setting.stride(j) = swin;tmp1 = imresize(tmp1, setting.rawsize, 'bilinear');
                        feat2{i}{jj} = pyrafeaturecompute(setting, tmp1, j);
                        dfeat2{i}  = [dfeat2{i}; [t1+si, t2+si]];
                    end
                    
                end
                t1dfeat2 = dfeat2;t1feat2 = feat2;
                
                dfeat2{i} = [];
                jj = 0;
                for t1 = -si:si
                    for t2 = -si:si
                        if setting.rescale
                            jrange = [b-2*si+2:b+2-si-t2];
                        else
                            jrange = [b-2*si+2];
                        end
                        
                        
                        for kk = 1:length(jrange)

                        step = [(a-2*si+2), jrange(kk)];   
                        
                        jj = jj + 1;
                        
                        
                        range1 = [(t1+si) * swin1 + 1 : ((t1+si)+step(1)) * swin1];
                        range2 = [(t2+si) * swin1 + 1 : ((t2+si)+step(2)) * swin1];

                        tmp = warped;
                        tmp(end+1:range1(end), end+1:range2(end), :) = 0;
                        tmp1 = tmp(range1, range2, :);
                        
                        setting.stride(j) = swin;tmp1 = imresize(tmp1, setting.rawsize, 'bilinear');
                        feat2{i}{jj} = pyrafeaturecompute(setting, tmp1, j);
                        dfeat2{i}  = [dfeat2{i}; [t1+si, t2+si]];
                    end
                    
                    end
                end
                tdfeat2 = dfeat2;tfeat2 = feat2;
            
            case 3
        end
        
    end
    cellfea{1} = feat1;
end

%for kk = 1:length(tfeat2)
%dis = cell2mat(tfeat2{kk}) - cell2mat(t1feat2{kk});max(abs(dis(:)))
%dis = (tdfeat2{kk}) - (t1dfeat2{kk});max(abs(dis(:)))
%end

cellfea{1} = feat1;
cellfea{2} = feat2;