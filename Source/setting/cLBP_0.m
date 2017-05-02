%%%feattype
setting.feattype = {'lbp'};
setting.overlap = 0;
setting.stride = 8;
setting.swin = 8;
setting.descriptor = {'c'};
%%%for lbp
setting.featsetting.lbp.radius = 1;
setting.featsetting.lbp.neighbors = 8;
setting.featsetting.lbp.mapping = 'h';
setting.featsetting.lbp.MAPPINGTYPE = 'u2';