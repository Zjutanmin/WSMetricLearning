function resultt = TestFold(dataname, suffix, templateDir, Indir, NeedHoG, outdir, config_file, ...
    bookfeat, cmethod, knnpara, cpara, copyremove, issave, rawsize,sampling, ...
    pyramid, ncluster, normmerge, multiview, Rconfidence, config_DOG, ...
    config_WTA, WTAwithraw, Fpyramid, Ratio, RRatio, fast, config_latent, ...
    platent, confidence, svote, Crange, UseSplit, PCA, testSOutput, featPad, ...
    GBlimit, selfpaced, KNNlatent, SnippetRatio, FirstRound, Comverge, useall, APcompute, Fcompute)
%INPUT
% dataname    :  dataset name
% suffix      :  version name for dataset
%             :  e.g. "Sign_NewT5" denotes "Sign" dataset with version "_NewT5"
% templateDir :  directory for template set
% Indir       :  directory for saving the original snippets
% rstart      :  The starting batch index
% rend        :  The ending batch index
% Nclass      :  number of categories for the dataset
% method      :  1*N cell, N classification method. Currently, it support 'INNC'. 'KNN', 'MLR', 'MLR-W', 'MLR(I)', 'MLR-W(I)'. Default = "MLR" (metric learning)
% C           :  1*N cell, parameters for the N method, each is the balance parameter C for one method. Default = 512. 
%             :  For INNC, C = [lambda, K, blocksize,verbose, beta]. If [K, blocksize,verbose,beta) are not defined, then they are depended on lambda (refer to INNC.m)
% multiview   :  0/1, multi-view input mode, default = 1 (For Germany benchmark is 0)
% NFold       :  NFold for training / testing split. Default = 3. 
% Round       :  Evaluating split (For N-folder setting, otherwise is 1). Default = 1
% evaltype    :  Training and evaluation mode. Default = 0
% evaltype    :  Re-creat the train information for the dataset (For a Newly-dataset). Default = 0
       
if nargin < 1 dataname = 'Caltech101'; end
if nargin < 2 suffix = ''; end
if nargin < 5 outdir = '-2'; end
if nargin < 7 config_file = 'llc_1'; end
if nargin < 9
    cmethod = 'KNN'; 
    knnpara = 10;
end
if nargin < 11  cpara = []; end
if nargin < 12 copyremove = 1;   end
if nargin < 13 issave = 0;     end
if nargin < 14  rawsize = [90, 75];   end
changesize = 0;
patchsize = 16;     
if nargin < 18 normmerge = 0; end
if nargin < 19 multiview = 0;end
if nargin < 20  Rconfidence = 0.5;end
if nargin < 21 config_DOG = '';end
if nargin < 22 config_WTA = '';end
if nargin < 23  Fpyramid = 0; end
if nargin < 25  Ratio = 0; end
if nargin < 27  fast = 1; end
if nargin < 28  config_latent = ''; end
if nargin < 29  platent = 0;  end
if nargin < 30   confidence = 0; end
if nargin < 31  svote = {}; end
if nargin < 32  Crange= [-5,3]; end
if nargin < 33 
    UseSplit = 0;
    Nfold = 5;
end
if nargin < 34  PCA = 0; end
if nargin < 35   testSOutput = 0; end
if nargin < 36  featPad = 0; end
if nargin < 37  GBlimit = 4; end
if nargin < 38  setting.selfpaced = 0; end
if nargin < 39  KNNlatent = 1; end
if nargin < 40 SnippetRatio = {1}; end
if nargin < 41 FirstRound = 0; end
if nargin < 42 Comverge = 0; end
if nargin < 43 useall = -1; end
if nargin < 44 APcompute = 0; end
if nargin < 45 Fcompute = 1; end


% i = 0;
% i = i +1;resultt(i) = TestFold('Sign', '_NewT', 'image\Temp\SignTemplates_US\','\TrueSign\Rectified\', 1, '-2', 'cHoG_1_color24_0',{'sift'},'KNN', 1, {}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,0.95,0,0,20, 0, 1, {1}, 1, 0);
% i = i +1;resultt(i) = TestFold('Sign', '_NewT', 'image\Temp\SignTemplates_US\','\TrueSign\Rectified\', 1, '-2', 'cHoG_1_color24_0',{'sift'},'INNC', 1, 0.05, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,0.95,0,0,20, 0, 1, {1}, 1, 0);
% i = i +1;resultt(i) = TestFold('Sign', '_NewT', 'image\Temp\SignTemplates_US\','\TrueSign\Rectified\', 1, '-2', 'cHoG_1_color24_0',{'sift'},'MLR', 1, {512, 'MRR', 1, 1, 0, 1}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,0.95,0,0,20, 0, 1, {1}, 1, 0);
% i = i +1;resultt(i) = TestFold('Sign', '_NewT', 'image\Temp\SignTemplates_US\','\TrueSign\Rectified\', 1, '-2', 'cHoG_1_color24_0',{'sift'},'MLR', 1, {512, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,0.95,0,0,20, 1,[1,5,1,0,1], {4,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);

% i = 0;
% i = i +1;resultt(i) = TestFold('Sign', '_NewT5', 'image\Temp\SignTemplates\','\TrueSign\Rectified\', 0, '-1', 'cHoG_1_color24_0',{'sift'},'KNN', 1, {}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,0.95,0,0,20, 0, 1, {1}, 1, 0);
% i = i +1;resultt(i) = TestFold('Sign', '_NewT5', 'image\Temp\SignTemplates\','\TrueSign\Rectified\', 0, '-1', 'cHoG_1_color24_0',{'sift'},'INNC', 1, 0.05, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,0.95,0,0,20, 0, 1, {1}, 1, 0);
% i = i +1;resultt(i) = TestFold('Sign', '_NewT5', 'image\Temp\SignTemplates\','\TrueSign\Rectified\', 0, '-1', 'cHoG_1_color24_0',{'sift'},'MLR', 1, {512, 'MRR', 1, 1, 0, 1}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,2,[],0,-3.5,0.95,0,0,20, 0, 1, {1}, 1, 0);
% i = i +1;resultt(i) = TestFold('Sign', '_NewT5', 'image\Temp\SignTemplates\','\TrueSign\Rectified\', 0, '-1', 'cHoG_1_color24_0',{'sift'},'MLR', 1, {512, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'',0,4,[],0,-3.5,0.95,0,0,20, 1,[1,5,1,0,1], {4,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);


% i = i +1;resultt(i) = TestFold('Sign', '_NewT5', 'image\Temp\SignTemplates\','\TrueSign\Rectified\', 0, '-1', 'cHoG_1_color24_0',{'sift'},'MLR', 1, {512, 'HINGE', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,8,0,0.5,0,'Latent2',0,4,[],0,-3.5,0.95,0,0,20, 1,[1,5,1,0,1], {4,0,22404,10, 'Reciprocal',0,1,1, 'NA', 'max2'},1,1);



rename = 1;
foldname = Indir;


sfilename = {};
str = '';

rt_img_dir2 = ['image\Sign' foldname];
subfolders = dir(rt_img_dir2);
addpath('Tool')
if strcmp(suffix(1:5), '_test')
jj = 0;kk = 0;filename = {};
try
    load(fullfile('TrainInfo', ['image_', dataname, suffix, '_RoundINFO']), 'filename');
catch
    for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    if ~strcmp(subname, '.') & ~strcmp(subname, '..'),
        jj = jj + 1;
        fprintf('Processing the %d-th folder: %s\n', jj, subname)
        kk =kk+1;filename{kk} = subname;
    end
    end;
    save(fullfile('TrainInfo', ['image_', dataname, suffix, '_RoundINFO']), 'filename');
end

if rstart == -1 || rend == -1
    rstart = 1;
    rend = 1;
else
    str = ['-' num2str(rstart), '-', num2str(rend)];
    sfilename = filename(rstart:rend);
end
end

append = 0;

if NeedHoG
%     dataTransform(dataname, [suffix,  str], templateDir, foldname, rename, sfilename, outdir);
    exFileFromFolder(['image\' dataname, suffix,  str], 0);
end
[~,resultt] = GetRecogRate_3(dataname, suffix, config_file, ...
    bookfeat, cmethod, knnpara, cpara, copyremove, issave, rawsize,sampling, ...
    pyramid, ncluster, normmerge, multiview, Rconfidence, config_DOG, ...
    config_WTA, WTAwithraw, Fpyramid, Ratio, RRatio, fast, config_latent, ...
    platent, confidence, svote, Crange, UseSplit, PCA, testSOutput, featPad, ...
    GBlimit, selfpaced, KNNlatent, SnippetRatio, FirstRound, Comverge, useall, APcompute, Fcompute);