%%%feattype
setting.feattype = {'hog_dalal'};
setting.overlap = 1;
setting.swin = 5;
setting.stride = 5;
setting.descriptor = {'c'};
setting.featsize = 31;
setting.featname = {'HOG_02'};
setting.hog.bsize = 2;
setting.hog.orientation = 8;
setting.hog.imsize = {[40, 40]};
setting.hog.issigned = 'signed';
setting.hog.descstride = 0.5;
setting.hog.Normalizer = 'l2hys';
setting.hog.interpolater = 'localinterpolate';