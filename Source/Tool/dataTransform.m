%%%dataTransform('Sign', '_NewT5', 'image\Temp\SignTemplates')
function dataTransform(dataname, suffix, templateDir, foldname, rename, filename, outdir)
%INPUT
% dataname          :  dataset name
% suffix            :  version name, e.g. "Sign_NewT5" denotes "Sign" dataset with version "_NewT5"
%templateDir        :  directory for storing the template images
%Output: Dataset folder “image\Sign_NewT5” with fixed format, it contains:
% sign templates    :  each sub-folder contains a sign template for one category as well as a file "trainlist.txt" defining
%                   :  the template filename for this category.
% unlabeled snippets:  saved in folder “image\Sign_NewT5\-1”, and each sub-folder is one sign with multi-view snippets.
%                   :  e.g., " SignClassify\image\Sign_NewT5\-1\test_UCM_T3-0005-20130503-190839_SignSnippetsRectified_0_Truth_Rectified_1768\22_3.jpg",
%                   :  where "test_UCM_T3-0005-20130503-190839_SignSnippetsRectified_0_Truth_Rectified_1768" the sign name, "22_3.jpg" is for the snippet.
% cd ..;
% addpath 'Tool'
if nargin < 4
    rename = 1;
    outdir = '-1';
end
% ChangedataStr('image/', 'Sign', 1);
% ChangedataStr_S('image/', 'Sign', 1, '_New', templateDir, rename);
% ChangedataStr_S('image/', 'Sign', 1, '_New', templateDir, rename);
% ChangedataStr_S('image/', 'Sign', 1, '_New2', templateDir, rename);
ChangedataStr_S('image/', dataname, 1, suffix, templateDir, foldname, rename, filename, outdir);