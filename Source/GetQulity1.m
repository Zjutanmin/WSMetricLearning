function Quality_ts_fea = GetQulity1(setting, ts_imname)
setting.SQ = {'sizex', 'sizey', 'stdR', 'stdG', 'stdB','stdGm'};
setting.Nquality = length(setting.SQ);
Quality_ts_fea = zeros(length(ts_imname), setting.Nquality);
for jj = 1:length(ts_imname)
    Quality_ts_fea(jj, :) =  Getqulity_im(imread(ts_imname{jj}), setting);
end


function feat = Getqulity_im(im, setting) 
%%%size
feat = [size(im,1), size(im,2)] ./ setting.rawsize;

%%STD
imr = double(im(:,:,1) / 255);
img = double(im(:,:,2) / 255);
imb = double(im(:,:,3) / 255);
Gim = double(rgb2gray(im) / 255);
feat = [feat,std((imr(:))), std((img(:))), ...
    std((imb(:))), std((Gim(:)))];