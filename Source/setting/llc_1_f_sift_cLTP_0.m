%%%feattype
setting.feattype = {'llc'};
setting.ncluster = 512;
setting.knn = 5;
setting.patchsize = 16;
setting.sampling = 100000;
setting.codesampleR = 0;
setting.pyramid = [1, 2, 4]; 
% setting.featsize = sum(setting.ncluster*setting.pyramid.^2);
setting.featsizellc = sum(setting.ncluster*setting.pyramid.^2);

setting.gridSpacing = 3;
setting.patchSize = 8;