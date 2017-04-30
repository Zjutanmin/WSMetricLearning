%%%feattype
%%%cHoG_1_cLBP_0_cLTP_0_color1_0
setting.feattype = {'lbp','color'};
setting.overlap = [0,0];
setting.stride = [8,8];
setting.swin = [8,8];

setting.descriptor = {'c','c'};
%%%for lbp
setting.featsetting.lbp.radius = 1;
setting.featsetting.lbp.neighbors = 8;
setting.featsetting.lbp.mapping = 'h';
setting.featsetting.lbp.MAPPINGTYPE = 'u2';

%%%for color
setting.featsetting.color.descriptor = 24;