function GetDataForm(ORG, DES, DELTYPE)
% % % % ORG = 'Sign_NewT11_N_M_1_80_20_R';DES = 'Sign_NewT11_N_M_1_80_20_R1';DELTYPE = [327, 316, 515, 1084, 1364, 1304, 1682, 1627, 1684, 1702, 1711];
% % % % GetDataForm(ORG, DES, DELTYPE)
% % % % ORG = 'Sign_NewT11_N_M_1_100_20_R';DES = 'Sign_NewT11_N_M_1_100_20_R1';DELTYPE = [327, 316, 515, 1084, 1364, 1304, 1682, 1627, 1684, 1702, 1711];
% % % % GetDataForm(ORG, DES, DELTYPE)
fn_dog = fullfile('image', [DES, '_DOG_2']);
if ~exist(fn_dog)
    mkdir(fn_dog)
    isDOG= 1;
    save(fullfile(fn_dog, 'isDOG.mat'), 'isDOG')
end
load(['TrainInfo\image_' ORG '_1_database.mat'], 'database');
database
cnamenum = cellfun(@str2num, database.cname,  'UniformOutput',true);
cnamenum = sort(find(~ismember(cnamenum, DELTYPE)));
index = sort(find(ismember(database.label, cnamenum)));
Label([1:length(database.cname)]) = 0;
Label(cnamenum) = [1:length(cnamenum)];
database.imnum = length(index);
database.cname = database.cname(cnamenum);
if size(database.label, 2) == 1
    sLabel = Label(:);
else
    sLabel = Label;
end
database.label = sLabel(database.label(index));
database.istrain = database.istrain(index);
database.isForBook = database.isForBook(index);
database.path = database.path(index);
database.orgimpath = database.orgimpath(index);
database.nclass = length(cnamenum);
database_new = database;
save(['TrainInfo\image_' DES '_1_database.mat'], 'database');
database

load(['TrainInfo\image_' ORG '_1_FlodLabel.mat'],'ts_Fold_label');
size(ts_Fold_label)
index = sort(find(Label(ts_Fold_label)));
slabel1(index) = [1:length(index)];
if size(ts_Fold_label, 2) == 1
    sLabel = Label(:);
else
    sLabel = Label;
end
ts_Fold_label = sLabel(ts_Fold_label(index));
save(['TrainInfo\image_' DES '_1_Floderinfo.mat'],'ts_Fold_label');
size(ts_Fold_label)

load(['TrainInfo\image_' ORG '_1_Floderinfo.mat'],'Asubname', 'ts_fold_idx');
size(Asubname)
size(ts_fold_idx)
Asubname = Asubname(index);
index1 = sort(find(ismember(ts_fold_idx, index)));
slabel1(index) = [1:length(index)];
if size(ts_fold_idx, 2) == 1
    slabel1 = slabel1(:);
end
ts_fold_idx =slabel1(ts_fold_idx(index1));
save(['TrainInfo\image_' DES '_1_Floderinfo.mat'],'Asubname', 'ts_fold_idx');
size(Asubname)
size(ts_fold_idx)


load(['TrainInfo\image_' ORG '_1_Qulity.mat']);
size(Quality_ts_fea)
size(ts_idx)
Quality_ts_fea = Quality_ts_fea(index1,:);
ts_idx = find(~database.istrain);
save(['TrainInfo\image_' DES '_1_Qulity.mat'],...
    'Quality_ts_fea', 'ts_idx')
size(Quality_ts_fea)
size(ts_idx)


load(['TrainInfo\image_' ORG '_1_color_c_0S8(24)1_FPY8_fdatabase.mat'],...
    'pady', 'WTAfea1', 'database', 'dfea1', 'fdatabase1', 'padx');
fdatabase1
index = sort(find(Label(fdatabase1.label)));
if size(fdatabase1.label, 2) == 1
    sLabel = Label(:);
else
    sLabel = Label;
end
fdatabase1.label = sLabel(fdatabase1.label(index));
fdatabase1.imgpath = fdatabase1.imgpath(index);
fdatabase1.path{1} = fdatabase1.path{1}(index);
database = database_new ;
save(['TrainInfo\image_' DES '_1_color_c_0S8(24)1_FPY8_fdatabase.mat'],...
    'pady', 'WTAfea1', 'database', 'dfea1', 'fdatabase1', 'padx');
fdatabase1

load(['TrainInfo\image_' ORG '_1_hog_c_1S16_DOG_2_FPY8_fdatabase.mat'],...
    'pady', 'WTAfea1', 'database', 'dfea1', 'fdatabase1', 'padx');
fdatabase1
if size(fdatabase1.label, 2) == 1
    sLabel = Label(:);
else
    sLabel = Label;
end
index = sort(find(Label(fdatabase1.label)));
fdatabase1.label = sLabel(fdatabase1.label(index));
fdatabase1.imgpath = fdatabase1.imgpath(index);
fdatabase1.path{1} = fdatabase1.path{1}(index);
database = database_new ;
save(['TrainInfo\image_' DES '_1_hog_c_1S16_DOG_2_FPY8_fdatabase.mat'],...
    'pady', 'WTAfea1', 'database', 'dfea1', 'fdatabase1', 'padx');
fdatabase1

load(['TrainInfo\image_' ORG '_1_color_c_0S8(24)1_data.mat'],...
    'data_fea', 'data_label');
size(data_fea)
size(data_label)
if size(data_label, 2) == 1
    sLabel = Label(:);
else
    sLabel = Label;
end
index = sort(find(Label(data_label)));
data_label = sLabel(data_label(index));
data_fea = data_fea(index,:);
save(['TrainInfo\image_' DES '_1_color_c_0S8(24)1_data.mat'],...
    'data_fea', 'data_label')
size(data_fea)
size(data_label)


load(['TrainInfo\image_' ORG '_1_hog_c_1S16_data.mat'],...
    'data_fea', 'data_label');
size(data_fea)
size(data_label)
if size(data_label, 2) == 1
    sLabel = Label(:);
else
    sLabel = Label;
end
index = sort(find(Label(data_label)));
data_label = sLabel(data_label(index));
data_fea = data_fea(index,:);
save(['TrainInfo\image_' DES '_1_hog_c_1S16_data.mat'],...
    'data_fea', 'data_label')
size(data_fea)
size(data_label)