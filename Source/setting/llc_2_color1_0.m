%%%feattype
setting.feattype = {'llc', 'color'};
setting.ncluster = 1024;
setting.knn = 5;
setting.patchsize = 16;
setting.sampling = 0;
setting.codesampleR = 0;
setting.pyramid = [1, 2, 4]; 
% setting.featsize = sum(setting.ncluster*setting.pyramid.^2);
setting.featsizellc = sum(setting.ncluster*setting.pyramid.^2);

setting.gridSpacing = 6;
setting.patchSize = 16;


%%%feattype
setting.overlap = [0 0];
setting.stride = [8 8];
setting.swin = [8 8];
setting.descriptor = {'c' 'c'};
%%%color
setting.featsetting.color.descriptor = 1;