function tfea = pyrafeaturecompute(setting, im, i)
% feat1 = mulfeatures_im(warped, setting, i, setting.stride(i),1, -1,[],[]);
pyra = featpyramid(im, setting, i);
tfea = [];
for j = 1:length(pyra.feat)
    fea = pyra.feat{j};
    [a,b,c] = size(fea);fea = reshape(fea, [a, b*c]);
%     fea = fea(:);
    tfea = [tfea; fea(:)];
end


function pyra = featpyramid(im, setting, tt)

% pyra = featpyramid(im, model, padx, pady);
% Compute feature pyramid.
%
% pyra.feat{i} is the i-th level of the feature pyramid.
% pyra.scales{i} is the scaling factor used for the i-th level.
% pyra.feat{i+interval} is computed at exactly half the resolution of feat{i}.
% first octave halucinates higher resolution data.
% padx,pady optionally pads each level of the feature pyramid

% if nargin < 3
%   [padx, pady] = getpadding(model);
% end

sbin = setting.stride(tt);

max_scale = setting.Fpyramid;
minsize = 3*sbin;
imsize = [size(im, 1) size(im, 2)];
ratio = minsize / max(imsize);

% ratio = minsize / min(imsize);
% minimgsize = ratio * imsize;

sc = ratio ^(1/(max_scale-1));

% 
% max_scale = 1 + floor(log(min(imsize)/(3*sbin))/log(sc));
% 
% % max_scale = 1 + floor(log(min(imsize)/(5*sbin))/log(sc));
% % pyra.feat = cell(max_scale + interval, 1);
% % pyra.scales = zeros(max_scale + interval, 1);

pyra.feat = cell(max_scale, 1);
pyra.scales = zeros(max_scale, 1);

pyra.imsize = imsize;

% our resize function wants floating point values
im = double(im);
for i = 1:max_scale
    scaled = resize(im, sc^(i-1));
%     size(scaled)
%     setting.stride(tt)
    pyra.feat{i} = mulfeatures_im(scaled, setting, tt, setting.stride(tt),1, -1,[],[]);
%     size(pyra.feat{i})
% %   scaled = resize(im, 1/sc^(i-1));
% %   % "first" 2x interval
% %   pyra.feat{i} = mulfeatures_im(scaled, setting, tt, setting.stride(tt)/2,0.5, -1,[],[]);
% %   pyra.scales(i) = 2/sc^(i-1);
% %   % "second" 2x interval
% %   pyra.feat{i+interval} = mulfeatures_im(scaled, setting, tt, setting.stride(tt),1, -1,[],[]);
% %   pyra.scales(i+interval) = 1/sc^(i-1);
%   % remaining interals
% %   for j = i+interval:interval:max_scale
% %     scaled = resize(scaled, 0.5);
% %     pyra.feat{j+interval} = mulfeatures_im(scaled, setting, tt, setting.stride(tt),1, -1,[],[]);
% %     pyra.scales(j+interval) = 0.5 * pyra.scales(j);
% %   end
end
% t = 1;



% 
% interval = 10;
% sc = 2 ^(1/interval);
% imsize = [size(im, 1) size(im, 2)];
% max_scale = 1 + floor(log(min(imsize)/(5*sbin))/log(sc));
% pyra.feat = cell(max_scale + interval, 1);
% pyra.scales = zeros(max_scale + interval, 1);
% pyra.imsize = imsize;
% 
% % our resize function wants floating point values
% im = double(im);
% for i = 1:interval
%   scaled = resize(im, 1/sc^(i-1));
%   % "first" 2x interval
%   pyra.feat{i} = mulfeatures_im(scaled, setting, tt, setting.stride(tt)/2,0.5, -1,[],[]);
%   pyra.scales(i) = 2/sc^(i-1);
%   % "second" 2x interval
%   pyra.feat{i+interval} = mulfeatures_im(scaled, setting, tt, setting.stride(tt),1, -1,[],[]);
%   pyra.scales(i+interval) = 1/sc^(i-1);
%   % remaining interals
%   for j = i+interval:interval:max_scale
%     scaled = resize(scaled, 0.5);
%     pyra.feat{j+interval} = mulfeatures_im(scaled, setting, tt, setting.stride(tt),1, -1,[],[]);
%     pyra.scales(j+interval) = 0.5 * pyra.scales(j);
%   end
% end
% t = 1;
% for i = 1:length(pyra.feat)
%   % add 1 to padding because feature generation deletes a 1-cell
%   % wide border around the feature map
%   pyra.feat{i} = padarray(pyra.feat{i}, [pady+1 padx+1 0], 0);
%   % write boundary occlusion feature
%   pyra.feat{i}(1:pady+1, :, 32) = 1;
%   pyra.feat{i}(end-pady:end, :, 32) = 1;
%   pyra.feat{i}(:, 1:padx+1, 32) = 1;
%   pyra.feat{i}(:, end-padx:end, 32) = 1;
% end
% pyra.padx = padx;
% pyra.pady = pady;