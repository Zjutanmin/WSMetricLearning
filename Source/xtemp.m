load('TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_1_0_database.mat')
database.imnum = length(database.istrain);
database.isForBook = (database.isForBook)';
database.path = (database.path)';
database.orgimpath = (database.orgimpath)';
rmfield(database, 'imname')
database.imgpath = {};
save('TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_1_0_database.mat', 'database')

load('TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_1_database.mat')

load(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_1_0_hog_c_1S16_DOG_2_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');
database.imnum = length(database.istrain);
database.isForBook = (database.isForBook)';
database.path = (database.path)';
database.orgimpath = (database.orgimpath)';
rmfield(database, 'imname')
database.imgpath = {};
load(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_1_hog_c_1S16_DOG_2_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');

save(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_1_0_hog_c_1S16_DOG_2_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');


load(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_1_0_color_c_0S8(24)1_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');
database.imnum = length(database.istrain);
database.isForBook = (database.isForBook)';
database.path = (database.path)';
database.orgimpath = (database.orgimpath)';
rmfield(database, 'imname')
database.imgpath = {};
load(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_1_hog_c_1S16_DOG_2_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');

save(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_1_0_color_c_0S8(24)1_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');









load('TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_2_0_database.mat')
database.imnum = length(database.istrain);
database.isForBook = (database.isForBook)';
database.path = (database.path)';
database.orgimpath = (database.orgimpath)';
rmfield(database, 'imname')
database.imgpath = {};
save('TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_2_0_database.mat', 'database')

load('TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_1_database.mat')

load(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_2_0_hog_c_1S16_DOG_2_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');
database.imnum = length(database.istrain);
database.isForBook = (database.isForBook)';
database.path = (database.path)';
database.orgimpath = (database.orgimpath)';
rmfield(database, 'imname')
database.imgpath = {};
load(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_1_hog_c_1S16_DOG_2_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');

save(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_2_0_hog_c_1S16_DOG_2_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');


load(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_2_0_color_c_0S8(24)1_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');
database.imnum = length(database.istrain);
database.isForBook = (database.isForBook)';
database.path = (database.path)';
database.orgimpath = (database.orgimpath)';
rmfield(database, 'imname')
database.imgpath = {};
load(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_1_hog_c_1S16_DOG_2_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');

save(['TrainInfo\image_Sign_NewT11_N_M_1_80_20_R_OR_2_0_color_c_0S8(24)1_FPY8_fdatabase.mat'], 'fdatabase1', 'dfea1', 'database',...
    'WTAfea1', 'padx', 'pady');
