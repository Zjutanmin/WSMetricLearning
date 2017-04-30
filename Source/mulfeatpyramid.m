function pyra = mulfeatpyramid(im, model,imageid, padx, pady)
% pyra = featpyramid(im, model, padx, pady);
% Compute feature pyramid.
%
% pyra.feat{i} is the i-th level of the feature pyramid.
% pyra.scales{i} is the scaling factor used for the i-th level.
% pyra.feat{i+interval} is computed at exactly half the resolution of feat{i}.
% first octave halucinates higher resolution data.
% padx,pady optionally pads each level of the feature pyramid

if nargin < 4
  [padx, pady] = getpadding(model);
end

sbin = model.sbin;
interval = model.interval;
sc = 2 ^(1/interval);
imsize = [size(im, 1) size(im, 2)];
max_scale = 1 + floor(log(min(imsize)/(5*sbin))/log(sc));
pyra.feat = cell(max_scale + interval, 1);
pyra.scales = zeros(max_scale + interval, 1);
pyra.imsize = imsize;
sbin = model.sbin;

% our resize function wants floating point values
im = double(im);
for i = 1:interval
  scaled = resize(im, 1/sc^(i-1));
  % "first" 2x interval
  pyra.feat{i} = mulfeatures(scaled, model, sbin/2, 0.5, imageid,[],[]);
  pyra.scales(i) = 2/sc^(i-1);
  % "second" 2x interval
  pyra.feat{i+interval} = mulfeatures(scaled, model, sbin,1, imageid,[],[]);
  pyra.scales(i+interval) = 1/sc^(i-1);
  % remaining interals
  for j = i+interval:interval:max_scale
    scaled = resize(scaled, 0.5);
    pyra.feat{j+interval} = mulfeatures(scaled, model, sbin, 1 ,imageid,[],[]);
    pyra.scales(j+interval) = 0.5 * pyra.scales(j);
  end
end
pyra.size = [];
for i = 1:length(pyra.feat)
  % add 1 to padding because feature generation deletes a 1-cell
  % wide border around the feature map
  pyra.feat{i} = padarray(pyra.feat{i}, [0 pady+1 padx+1], 0);
  % write boundary occlusion feature
  pyra.feat{i}(end, 1:pady+1, :) = 1;
  pyra.feat{i}(end, end-pady:end, :) = 1;
  pyra.feat{i}(end, :, 1:padx+1) = 1;
  pyra.feat{i}(end, :, end-padx:end) = 1;
  pyra.size = [pyra.size, size(pyra.feat{i})'];
end
pyra.size = [ones(1, size(pyra.size,2));pyra.size(1,:);pyra.size(1,:).*pyra.size(2,:)];
pyra.padx = padx;
pyra.pady = pady;