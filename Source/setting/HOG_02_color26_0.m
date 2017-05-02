%%%feattype
%%%feattype
setting.feattype = {'hog_dalal', 'color'};
setting.overlap = [1,0];
setting.stride = [5,5];
setting.swin = [5,5];
setting.featsize = 31;
setting.descriptor = {'c','c'};
setting.featname = {'HOG_02', 'HueHist'};
setting.hog.bsize = 2;
setting.hog.orientation = 8;
setting.hog.imsize = {[40, 40]};
setting.hog.issigned = 'signed';
setting.hog.descstride = 0.5;
setting.hog.Normalizer = 'l2hys';
setting.hog.interpolater = 'localinterpolate';

%%%feattype
setting.featsetting.color.descriptor = 26;
setting.featname = {'HueHist'};
setting.featsetting.color.border = 5;
setting.featsetting.color.maxvalue = 0;
setting.featsetting.color.minvalue = 255;