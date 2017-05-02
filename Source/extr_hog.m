function extr_hog(img_dir, data_dir, copyremove)
% for example
% img_dir = 'image/Caltech101';
% data_dir = 'data/Caltech101';
if nargin < 3
    copyremove = 0;
end
addpath('hog');

gridSpacing = 6;
patchSize = 16;
maxImSize = 300;
nrml_threshold = 1;

[database, lenStat] = CalculateHOGDescriptor(img_dir, data_dir, ...
    gridSpacing, patchSize, maxImSize, nrml_threshold, copyremove);