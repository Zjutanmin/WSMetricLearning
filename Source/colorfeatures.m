function feat = colorfeatures(im,sbin,swin,stride, descriptor, norm)
if nargin < 6
    norm = 1;
end
% avg = 0;
im = VirBySbin(im,sbin,0);
meanL = 70;
switch descriptor
    case 1
        imr = im(:,:,1);imr = colorindex(imr,15,0,255);
        img = im(:,:,2);img = colorindex(img,15,0,255);
        imb = im(:,:,3);imb = colorindex(imb,15,0,255);        
        rfeat = densehist(imr,[swin,swin],[stride,stride],15,3);
        gfeat = densehist(img,[swin,swin],[stride,stride],15,3);
        bfeat = densehist(imb,[swin,swin],[stride,stride],15,3);
        feat = rfeat;
        feat(:,:,end+1:end+size(gfeat,3)) = gfeat;
        feat(:,:,end+1:end+size(bfeat,3)) = bfeat;
        feat = feat * norm /3;
        feat(:,:,end+1) = 0; 
    case 2   
    case 3     
    case 4
        imr = im(:,:,1);
        img = im(:,:,2);
        imb = im(:,:,3);
        tsum = imr + img + imb;
        imr = imr./tsum;imr = colorindex(imr,15,0,1);
        img = img./tsum;img = colorindex(img,15,0,1);
        rfeat = densehist(imr,[swin,swin],[stride,stride],15,3);
        gfeat = densehist(img,[swin,swin],[stride,stride],15,3);
        feat = rfeat;
        feat(:,:,end+1:end+size(gfeat,3)) = gfeat;
        feat = feat * norm /2;
        feat(:,:,end+1) = 0;
    case 5
    case 6
    case 7
    case 8
    case 9
    case 10
    case 11
    case 12
    case 15 %%%R+G+B / 3
        imr = im(:,:,1);
        img = im(:,:,2);
        imb = im(:,:,3);
        feat = (imr + img + imb) / 3;
        avg = feat;

        feat = cumsum(feat);feat = cumsum(feat, 2);
        
        feat = padarray(feat, [1 1], 'pre');
        feat = feat(swin+1:swin:end, swin+1:swin:end) + feat(1:swin:end-swin, 1:swin:end-swin) - ...
            (feat(swin+1:swin:end, 1:swin:end-swin) + feat(1:swin:end-swin, swin+1:swin:end));

        feat = feat / (swin*swin);
        feat1(:,:,1) = feat;
        feat = feat1;        
    case 16 %%%R,G,B
        imr = im(:,:,1);
        img = im(:,:,2);
        imb = im(:,:,3);
        rfeat = GetAvg(imr, swin, stride);feat1(:,:,1) = rfeat;
        gfeat = GetAvg(img, swin, stride);feat1(:,:,2) = gfeat;
        bfeat = GetAvg(imb, swin, stride);feat1(:,:,3) = bfeat;
        
        feat = feat1;   
    case 17 %%A,B
        imr = im(:,:,1);
        img = im(:,:,2);
        imb = im(:,:,3);
        [L,a,b] = RGB2Lab(imr,img,imb);
        
        afeat = GetAvg(a, swin, stride);feat1(:,:,1) = afeat;feat1(:,:,1) = afeat;
        bfeat = GetAvg(b, swin, stride);feat1(:,:,2) = bfeat;feat1(:,:,2) = bfeat;

        feat = feat1;   
    case 18 %%mean(A,B), std(A,B)
        imr = im(:,:,1);
        img = im(:,:,2);
        imb = im(:,:,3);
        [L,a,b] = RGB2Lab(imr,img,imb);
        feat1(:,:,1:2)  = GetStd(a, swin, stride);
        feat1(:,:,3:4)  = GetStd(b, swin, stride);

        feat = feat1;
    case 19 %%%R,G,B rate by L patch
        imr1 = im(:,:,1);
        img1 = im(:,:,2);
        imb1 = im(:,:,3);
        [L,a,b] = RGB2Lab(imr1,img1,imb1);
        rate = meanL ./ L; 
        L = rate.*L;a=rate.*a;b=rate.*b;
        
        [imr,img,imb] = Lab2RGB(L,a,b);
        
        
        rfeat = GetAvg(imr, swin, stride);feat1(:,:,1) = rfeat;
        gfeat = GetAvg(img, swin, stride);feat1(:,:,2) = gfeat;
        bfeat = GetAvg(imb, swin, stride);feat1(:,:,3) = bfeat;
        
        feat = feat1; 
    case 20 %%%R,G,B rate by L global
        imr1 = im(:,:,1);
        img1 = im(:,:,2);
        imb1 = im(:,:,3);
        [L,a,b] = RGB2Lab(imr1,img1,imb1);
        rate = meanL ./ mean(L(:)); 
        L = rate.*L;a=rate.*a;b=rate.*b;
        
        [imr,img,imb] = Lab2RGB(L,a,b);
        
        
        rfeat = GetAvg(imr, swin, stride);feat1(:,:,1) = rfeat;
        gfeat = GetAvg(img, swin, stride);feat1(:,:,2) = gfeat;
        bfeat = GetAvg(imb, swin, stride);feat1(:,:,3) = bfeat;
        
        feat = feat1; 
    case 21 %%%R,G,B rate by L global
        imr = im(:,:,1);
        img = im(:,:,2);
        imb = im(:,:,3);
        rfeat = GetAvg(imr, swin, stride);feat1(:,:,1) = rfeat / 255;
        gfeat = GetAvg(img, swin, stride);feat1(:,:,2) = gfeat / 255;
        bfeat = GetAvg(imb, swin, stride);feat1(:,:,3) = bfeat / 255;
        
        feat = feat1;
    case 22
        imr = im(:,:,1);imr = colorindex(imr,5,0,255);
        img = im(:,:,2);img = colorindex(img,5,0,255);
        imb = im(:,:,3);imb = colorindex(imb,5,0,255);        
        rfeat = densehist(imr,[swin,swin],[stride,stride],5,3);
        gfeat = densehist(img,[swin,swin],[stride,stride],5,3);
        bfeat = densehist(imb,[swin,swin],[stride,stride],5,3);
        feat = rfeat;
        feat(:,:,end+1:end+size(gfeat,3)) = gfeat;
        feat(:,:,end+1:end+size(bfeat,3)) = bfeat;
        feat = feat * norm /3;
        feat(:,:,end+1) = 0; 
    case 23
        imr = im(:,:,1);imr = colorindex(imr,3,0,255);
        img = im(:,:,2);img = colorindex(img,3,0,255);
        imb = im(:,:,3);imb = colorindex(imb,3,0,255);        
        rfeat = densehist(imr,[swin,swin],[stride,stride],3,3);
        gfeat = densehist(img,[swin,swin],[stride,stride],3,3);
        bfeat = densehist(imb,[swin,swin],[stride,stride],3,3);
        feat = rfeat;
        feat(:,:,end+1:end+size(gfeat,3)) = gfeat;
        feat(:,:,end+1:end+size(bfeat,3)) = bfeat;
        feat = feat * norm /3;
        feat(:,:,end+1) = 0; 
    case 24
        imr = im(:,:,1);imr = colorindex(imr,2,0,255);
        img = im(:,:,2);img = colorindex(img,2,0,255);
        imb = im(:,:,3);imb = colorindex(imb,2,0,255);        
        rfeat = densehist(imr,[swin,swin],[stride,stride],2,3);
        gfeat = densehist(img,[swin,swin],[stride,stride],2,3);
        bfeat = densehist(imb,[swin,swin],[stride,stride],2,3);
        feat = rfeat;
        feat(:,:,end+1:end+size(gfeat,3)) = gfeat;
        feat(:,:,end+1:end+size(bfeat,3)) = bfeat;
        feat = feat * norm /3;
        feat(:,:,end+1) = 0;
    case 26    
        hue = rgb2hsv(uint8(im));
        hue = hue(:, :, 1);
        hue = uint8(hue* 255);hue = colorindex(hue, 256,0,255);
        rfeat = densehist(double(hue),[swin,swin],[stride,stride],256,3);
        feat = rfeat;
        feat = feat * norm;
        feat(:,:,end+1) = 0; 
end

function fa = computepatchf(feat, swin)
feat = cumsum(feat);feat = cumsum(feat, 2);
feat = padarray(feat, [1 1], 'pre');
feat = feat(swin+1:stride:end, swin+1:stride:end) + feat(1:stride:end-swin, 1:stride:end-swin) - ...
    (feat(swin+1:stride:end, 1:stride:end-swin) + feat(1:stride:end-swin, swin+1:stride:end));
feat = feat / (swin*swin);


