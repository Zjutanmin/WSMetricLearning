%%%feattype
setting.feattype = {'llc'};
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