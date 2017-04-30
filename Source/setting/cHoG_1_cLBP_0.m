%%%feattype
setting.feattype = {'hog','lbp'};
setting.overlap = [1,0];
setting.stride = [8,8];
setting.swin = [16,8];
setting.featsize = 31;
setting.descriptor = {'c','c'};
%%%for lbp
setting.featsetting.lbp.radius = 1;
setting.featsetting.lbp.neighbors = 8;
setting.featsetting.lbp.mapping = 'h';
setting.featsetting.lbp.MAPPINGTYPE = 'u2';