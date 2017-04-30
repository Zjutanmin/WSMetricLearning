dir = 'D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\fig\';
name = 'Class-others'; str = '_NewT5';name = [name, str];
load(['D:\MinTan\Study\CVPR\cvpr\cvpr14\latex\result\' name '-result.mat'], 'CbestV', 'result')
result3 = result;
classes = {'-3.13', '-3.20', '-3.26', '-3.33', '-3.39', '-3.46', '0'};
classesstr = {'13', '20', '26', '33', '39', '46', '52'};
classnum = [13, 20, 26, 33, 39, 46, 52];
crange = [0.1250, 2, 32, 512];
pcarange = 0.95;winit = 1;
CbestVV = CbestV;
resultF = result;


% KNN
% INNC
% MLR
% WMLR
% MLR-INNC
% INNC(K)
% MLR-INNC(K)
% 
% WMLR-INNC(K-KNN-Reciprocal)
% WMLR-INNC(K-INNC-Reciprocal)
% WMLR-INNC(K-INNC-norm)
% WMLR-INNC(K-KNN-Reciprocal-N)
% WMLR-INNC(K-INNC-Reciprocal-N)
% WMLR-INNC(K-INNC-norm-N)


i = 0;result2 = [];
krange = [1, 3, 10, 20];
Ntype = 2;
pcarange = 0.95;winit= 1;
Nnum = 9;
N = (Nnum+Ntype);
for jj = pcarange
    for kk = (krange)
        for tt = 1:length(classes);
            ii = CbestV(tt,2);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {ii, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20,0,1, {1},1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_3('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [-1], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20,0,1, {1},1);
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20,0,[1 0], {1},1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,0,[1], {1});  
        end
    end
end

for jj = pcarange
    for kk = (krange)
        for tt = 1:length(classes);
            for ii = c
            
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,jj,0,0,20,0,[1 0], {1},1);
            i =i + 1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[tmp, resultt(i), ranktime(i), ] = GetRecogRate_31('Sign', '_NewT5', 'cHoG_1_color24_0',{'sift'},'MLR', {'1',classes{tt}}, {{ii, 'MRR', 1, 1, 0, 1, 3}, [kk], [1, 0, -1], [2], [0], [0.05]}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,jj,0,0,20,0,[1], {1});  
            end
        end
    end
end