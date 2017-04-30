function ResultFig(index, vartmp)
stitle = {'Feature', ...
    'book Feature', 'Method', 'Parameters', 'moveCopysample', 'rawsize', 'Sampling', ...
    'pyramid', 'booksize'};
var{1} = 'LLC_1';
var{2} = 'sift';
var{3} = 'KNN';
var{4} = 1;
var{5} = 1;
var{6} = [];
var{7} = -1;
var{8} = [4,8,16];

for i = 1:length(Temp)
    clc;close all; 
    cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i)] = GetRecogRate('Sign',...
        var{1},var{2},var{3}, var{4}, var{5}, var{6}, var{7}, var{8});
end