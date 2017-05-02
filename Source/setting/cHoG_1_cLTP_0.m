%%%feattype
setting.feattype = {'hog','ltp'};
setting.overlap = [1,0];
setting.stride = [8,8];
setting.swin = [16,8];
setting.featsize = 31;
setting.descriptor = {'c','c'};
%%%for ltp
setting.featsetting.ltp.radius = 1;
setting.featsetting.ltp.neighbors = 8;
setting.featsetting.ltp.mapping = 'h';
setting.featsetting.ltp.MAPPINGTYPE = 'u2';
setting.featsetting.ltp.thresh = 5;