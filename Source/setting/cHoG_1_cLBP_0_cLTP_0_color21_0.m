%%%feattype
%%%cHoG_1_cLBP_0_cLTP_0_color1_0
setting.feattype = {'hog','lbp','ltp','color'};
setting.overlap = [1,0,0,0];
setting.stride = [8,8,8,8];
setting.swin = [16,8,8,8];
setting.featsize = 31;
setting.descriptor = {'c','c','c','c'};
%%%for lbp
setting.featsetting.lbp.radius = 1;
setting.featsetting.lbp.neighbors = 8;
setting.featsetting.lbp.mapping = 'h';
setting.featsetting.lbp.MAPPINGTYPE = 'u2';
%%%for ltp
setting.featsetting.ltp.radius = 1;
setting.featsetting.ltp.neighbors = 8;
setting.featsetting.ltp.mapping = 'h';
setting.featsetting.ltp.MAPPINGTYPE = 'u2';
setting.featsetting.ltp.thresh = 5;
%%%for color
setting.featsetting.color.descriptor = 21;