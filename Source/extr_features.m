% function extr_features(img_dir, data_dir, copyremove, featuretype)
% % for example
% % img_dir = 'image/Caltech101';
% % data_dir = 'data/Caltech101';
% if nargin < 3
%     copyremove = 0;
% end
% 
% switch featuretype
%     case 'SIFT'
%         
%     case 'HOG'
%         extr_hog(img_dir, data_dir, copyremove);
% end