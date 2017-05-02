cd ..
cd ..
global PATH_F;
%%1. on PIE dataset
%%1.1. Increasing occlusion and corruption level. 
clear all;
GetGlobalSetting;cd(fullfile(PATH_F, 'demo\WSMTL'));
cstr = {{'_PIE411', '_PIE118',  '_PIE412',  '_PIE115',  '_PIE413',  '_PIE119'},...
    { '_PIE218',  '_PIE215',  '_PIE219'},...
    { '_PIE513',  '_PIE514',  '_PIE515', '_PIE516',  '_PIE517',  '_PIE518'}};
cnewd = { '_PIE65',  '_PIE75',  '_PIE85'};featnorm = 1;Ninit = 31;indindex = 1;  
for iind = [1]
    for jind = length(cstr{iind}):-1:1
        str = cstr{iind}{jind};
        ind = 2;TrainFun = @GetRecogRate;
        Voting = 7;cd(fullfile(PATH_F, 'demo\WSMTL'));VirTest = 0;newd = '_PIE';MLRvir1_S;
    end
end
clear all;
GetGlobalSetting;cd(fullfile(PATH_F, 'demo\WSMTL'));str = '_PIE';TrainFun = @GetRecogRate;TBest = 1;VirTest = 0;Ninit = 31;newd = -1;isdegree = 1;featnorm = 1;indindex = 1;Numtrain = 30;Srange = [1];iirange = [1, 2, 3, 5, 8];WSMLR_N_S

%%1.2. different ratios of occluded training samples
clear all;GetGlobalSetting;cd(fullfile(PATH_F, 'demo\WSMTL'));
cstr = {{ '_PIE113',  '_PIE114',  '_PIE115',  '_PIE116',  '_PIE117'},...
    { '_PIE214',  '_PIE215',  '_PIE216'},...
    { '_PIE615',  '_PIE616',  '_PIE517',  '_PIE618',  '_PIE619'}};
featnorm = 1;Ninit = 31;indindex = 1;  
for iind = [1]
    for jind = length(cstr{iind}):-1:1
        str = cstr{iind}{jind};
        ind = 2;TrainFun = @GetRecogRate; 
        Voting = 7;cd(fullfile(PATH_F, 'demo\WSMTL'));VirTest = 0;newd = '_PIE';MLRvir1_S;
    end
end
clear all;GetGlobalSetting;cd(fullfile(PATH_F, 'demo\WSMTL'));str = '_PIE';TrainFun = @GetRecogRate;TBest = 1;VirTest = 0;Ninit = 31;newd = -1;isdegree = 0;featnorm = 1;indindex = 1;Numtrain = 30;Srange = 1;iirange = [1, 2, 3, 5, 8];WSMLR_N_S
% % 
% % %%1.3. different balanced ratios
% % % clear all;
% % GetGlobalSetting;cd(fullfile(PATH_F, 'demo/WSMTL'));
% % cstr = {{ '_PIE113',  '_PIE114',  '_PIE115',  '_PIE116',  '_PIE117'},...
% % { '_PIE214',  '_PIE215',  '_PIE216'},...
% % { '_PIE615',  '_PIE616',  '_PIE517',  '_PIE618',  '_PIE619'}};
% % featnorm = 1;Ninit = 31;indindex = 1;  ismult = 1;RatioC = 1;
% % RR = [0.2:0.2:1];
% % for iind = [1]
% % for jind = 3
% % str = cstr{iind}{jind};
% % ind = 2;TrainFun = @GetRecogRate;
% % Voting = 7;cd(fullfile(PATH_F, 'demo/WSMTL'));VirTest = 0;newd = '_PIE';MLRvir_S;
% % end
% % end
% % try
% %     load('figure/WSMTL/_PIE115/Result/resultBTmpNNTemp1_PIE115PCA0.95NFFNM_PIE.2.4.6.8.mat', 'resultBTmp');
% %     save('figure/WSMTL/_PIE115/Result/resultBTmpNNTemp_PIE115PCA0.95NFFNM_PIE.2.4.6.8.mat', 'resultBTmp');
% % end
% % clear all;GetGlobalSetting;cd(fullfile(PATH_F, 'demo/WSMTL'));str = '_PIE';TrainFun = @GetRecogRate;
% % TBest = 0;VirTest = 0;Ninit = 31;newd = -1;isdegree = 0;RR = [0.2:0.2:1];featnorm = 1;indindex = 1;Srange = 1;Numtrain = 30;iirange = [1, 2, 3, 5, 8];WSMLR_N_S
