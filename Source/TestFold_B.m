function result = TestFold_B(dataname, suffix, templateDir, Indir, rstart, rend,...
    Nclass, method, C, knnpara, multiview,NFold, Round, evaltype, NeedHoG, ShowExist)

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
       
if nargin < 7  Nclass = '52'; end   
if nargin < 8  method = 'MLR'; end         
if nargin < 9  C = '512'; end   
if nargin < 10 knnpara = '1'; end 
if nargin < 11 multiview = '0';end   
if nargin < 12 NFold = '3';end  
if nargin < 13 Round = '1';end     
if nargin < 14 evaltype = '0';end  
if nargin < 15 NeedHoG = 0;end 
if nargin < 16 ShowExist = 0;end
  
% % TestFold_B('Sign', '_test', 'image\Temp\SignTemplates_US\','\TrueSign\Rectified\',1, 6, '52', { 'MLR-W', 'INNC'} ,{'512', '0.05'}, '1' ,'1' ,'3', '1' ,'-2', 1)
% % TestFold_B('Sign', '_test', 'image\Temp\SignTemplates_US\','\TrueSign\Rectified\',7, 12, '52', { 'MLR-W', 'INNC'} ,{'512', '0.05'}, '1' ,'1' ,'3', '1' ,'-2', 1)
% % TestFold_B('Sign', '_test', 'image\Temp\SignTemplates_US\','\TrueSign\Rectified\',25, 30, '52', {'MLR-W', 'INNC'} ,{'512', '0.05'}, '1' ,'1' ,'3', '1' ,'-2', 1)
% % TestFold_B('Sign', '_test', 'image\Temp\SignTemplates_US\','\TrueSign\Rectified\',19, 24, '52', {'MLR-W', 'INNC'} ,{'512', '0.05'}, '1' ,'1' ,'3', '1' ,'-2', 1)
% % TestFold_B('Sign', '_test', 'image\Temp\SignTemplates_US\','\TrueSign\Rectified\',13,18, '52', {'MLR-W', 'INNC'} ,{'512', '0.05'}, '1' ,'1' ,'3', '1' ,'-2', 1)

% TestFold_B('Sign', '_NewT5', 'image\Temp\SignTemplates\','\TrueSign\Rectified\',-1, -1,'52', {'KNN', 'INNC','MLR', 'MLR-W'},{'0','0.05','512','512'}, '1' ,'1', '3', '1', '0',0,1)

         
rename = 1;
foldname = Indir;
outdir = '-2';

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
end
% jj = 0;fnn = {};
% for i = 1:length(filename)
%     subfolder1 = dir(fullfile(rt_img_dir2, filename{i}, '*.jpg'));
% % fnn = {};
% for tt = 1:length(subfolder1)
%     jj = jj + 1;
% sname = subfolder1(tt).name;
% index = strfind(subfolder1(tt).name, '_');
% fnn{jj} = sname(1:index(1) - 1);
% end
% % jj = jj+);
% 
% end
% length(unique(fnn))
if rstart == -1 || rend == -1
    rstart = 1;
    rend = 1;
    sfilename = {};
    str = '';
else
    str = ['-' num2str(rstart), '-', num2str(rend)];
    sfilename = filename(rstart:rend);
end


append = 0;

if NeedHoG
    dataTransform(dataname, [suffix, str], templateDir, foldname, rename, sfilename, outdir);
    exFileFromFolder(['image\' dataname, suffix, '-', str], 0);
end
for jj = 1:length(method)
    if jj > 1    
        NeedHoG = 0;
    end    
    result(jj) = RecogRate(dataname, [suffix, str], Nclass, method{jj}, C{jj}, knnpara, multiview,...
       NFold, Round, evaltype, append, NeedHoG, ShowExist);
end;