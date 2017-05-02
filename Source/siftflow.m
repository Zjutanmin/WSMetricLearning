function Sift = siftflow(im, setting)
% im1=imread('Mars-1.jpg');
% im2=imread('Mars-2.jpg');

im1=imresize(imfilter(im,fspecial('gaussian',7,1.),'same','replicate'),0.5,'bicubic');
% im2=imresize(imfilter(im2,fspecial('gaussian',7,1.),'same','replicate'),0.5,'bicubic');

im1=im2double(im1);

patchsize=setting.patchsize;
gridspacing=setting.gridspacing;

Sift=dense_sift(im1,patchsize,gridspacing);

% % prepare the parameters
% SIFTflowpara.alpha=2;
% SIFTflowpara.d=40;
% SIFTflowpara.gamma=0.005;
% SIFTflowpara.nlevels=4;
% SIFTflowpara.wsize=5;
% SIFTflowpara.topwsize=20;
% SIFTflowpara.nIterations=60;
% 
% tic;[vx,vy,energylist]=SIFTflowc2f(Sift1,Sift2,SIFTflowpara);toc
% % 
% % Step 4.  Visualize the matching results
% Im1=im1(patchsize/2:end-patchsize/2+1,patchsize/2:end-patchsize/2+1,:);
% Im2=im2(patchsize/2:end-patchsize/2+1,patchsize/2:end-patchsize/2+1,:);
% warpI2=warpImage(Im2,vx,vy);
% figure;imshow(Im1);title('Image 1');
% figure;imshow(warpI2);title('Warped image 2');
% 
% % display flow
% clear flow;
% flow(:,:,1)=vx;
% flow(:,:,2)=vy;
% figure;imshow(flowToColor(flow));title('SIFT flow field');