fname = {'_0_info_data.mat',...
'_0_Qulity.mat',...
'_0_SamplevotedCMV_0_0.mat',...
'_0_sizeinfo.mat',...
'_0_index.mat',...
'_0_database.mat',...
'_0_PixelO_c_1S1_ND_fdatabase.mat',...
'_0_PixelO_c_1S1_ND_S_data.mat',...
'_0_RoundInfo10_1R_30.mat'};

cstr = {{'_PIE411', '_PIE118',  '_PIE412',  '_PIE115',  '_PIE413',  '_PIE119'},...
    { '_PIE218',  '_PIE215',  '_PIE219'},...
    { '_PIE513',  '_PIE514',  '_PIE515', '_PIE516',  '_PIE517',  '_PIE518'}};
cnewd = { '_PIE65',  '_PIE75',  '_PIE85'};featnorm = 1;Ninit = 31;indindex = 1;  
for iind = [1]
    for jind = length(cstr{iind}):-1:1
        str = cstr{iind}{jind};
        for tt = 1:length(fname)
            M1 = ['TrainInfo_All\image_face' str fname{tt}];
            M2 = ['TrainInfo\image_face' str fname{tt}];
            copyfile(M1, M2)
        end
    end
end
cstr = {{ '_PIE113',  '_PIE114',  '_PIE115',  '_PIE116',  '_PIE117'},...
    { '_PIE214',  '_PIE215',  '_PIE216'},...
    { '_PIE615',  '_PIE616',  '_PIE517',  '_PIE618',  '_PIE619'}};
featnorm = 1;Ninit = 31;indindex = 1;  
for iind = [1]
    for jind = length(cstr{iind}):-1:1
        str = cstr{iind}{jind};
        for tt = 1:length(fname)
            M1 = ['TrainInfo_All\image_face' str fname{tt}];
            M2 = ['TrainInfo\image_face' str fname{tt}];
            copyfile(M1, M2)
        end
    end
end
cstr = {{ '_PIE113',  '_PIE114',  '_PIE115',  '_PIE116',  '_PIE117'},...
{ '_PIE214',  '_PIE215',  '_PIE216'},...
{ '_PIE615',  '_PIE616',  '_PIE517',  '_PIE618',  '_PIE619'}};
featnorm = 1;Ninit = 31;indindex = 1;  ismult = 1;RatioC = 1;
RR = [0.2:0.2:1];
for iind = [1]
for jind = 3
str = cstr{iind}{jind};
for tt = 1:length(fname)
            M1 = ['TrainInfo_All\image_face' str fname{tt}];
            M2 = ['TrainInfo\image_face' str fname{tt}];
            copyfile(M1, M2)
        end
    end
end