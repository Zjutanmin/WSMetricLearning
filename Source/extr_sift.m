function database = extr_sift(img_dir, data_dir, copyremove, feattpye, setting)
% for example
% img_dir = 'image/Caltech101';
% data_dir = 'data/Caltech101';
if nargin < 3
    copyremove = 0;
end
if nargin < 4
    feattpye = 'sift';
end
if nargin < 5
    setting.gridSpacing = 6;
    setting.patchSize = 16;
end

addpath('sift');

% gridSpacing = 6;
% patchSize = 16;
maxImSize = 300;
nrml_threshold = 1;

[database, lenStat] = CalculateSiftDescriptor(img_dir, data_dir, ...
    setting.gridSpacing, setting.patchSize, maxImSize, nrml_threshold, ...
    copyremove, feattpye, setting);