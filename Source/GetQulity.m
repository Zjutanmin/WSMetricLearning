function Quality_ts_fea = GetQulity(setting, ts_imname, ts_idx, cur_ts_idx)
if nargin < 4
    cur_ts_idx = [];
end
try
    load([setting.TFstr, '_Qulity.mat'],  'Quality_ts_fea', 'ts_idx'); 
%     if setting.multiview
        if ~isempty(cur_ts_idx)
            C = arrayfun(@(x) find(ts_idx==x), cur_ts_idx, 'UniformOutput',true);
            Quality_ts_fea = Quality_ts_fea(C,:);
        end
%     else
%         Quality_ts_fea = 0;
%     end
catch
    setting.SQ = {'sizex', 'sizey', 'stdR', 'stdG', 'stdB','stdGm'};
    setting.Nquality = length(setting.SQ);
    Quality_ts_fea = 0;
%     if setting.multiview
        Quality_ts_fea = zeros(length(ts_imname), setting.Nquality);
        for jj = 1:length(ts_imname)
            Quality_ts_fea(jj, :) =  Getqulity_im(double(imread(ts_imname{jj})), setting);
        end
%     end
    save([setting.TFstr, '_Qulity.mat'],  'Quality_ts_fea', 'ts_idx');
    if ~isempty(cur_ts_idx)
        cur_ts_idx = find(cur_ts_idx, ts_idx);
        Quality_ts_fea = Quality_ts_fea(cur_ts_idx,:);
    end
end






function feat = Getqulity_im(im, setting) 
%%%size
feat = [size(im,1), size(im,2)] ./ setting.rawsize;

%%STD
imr = double(im(:,:,1) / 255);
try
img = double(im(:,:,2) / 255);
imb = double(im(:,:,3) / 255);
Gim = double(rgb2gray(im / 255));
catch
img = imr;
imb = imr;
Gim = double((im / 255));
end

feat = [feat,std((imr(:))), std((img(:))), ...
    std((imb(:))), std((Gim(:)))];