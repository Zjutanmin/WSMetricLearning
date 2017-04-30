%%%feattype
setting.feattype = {'hog','lbp','color'};
setting.overlap = [1,1,1];
setting.stride = [8,8,8];
setting.swin = [16,16,16];
setting.featsize = 31;
setting.descriptor = {'c','b','b'};
%%%for lbp
setting.featsetting.lbp.radius = 1;
setting.featsetting.lbp.neighbors = 8;
setting.featsetting.lbp.mapping = 'h';
setting.featsetting.lbp.MAPPINGTYPE = 'u2';
%%%color
setting.featsetting.color.descriptor = 1;