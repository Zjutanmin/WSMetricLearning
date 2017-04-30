addpath('tool')
% dataTransform('Sign', '_NewT7', 'image\Temp\SignTemplates_N\')
% ChangedataStr_S('image/', 'Sign', 1, '_NewT7', 'image\Temp\SignTemplates_N\', '', 0, '', '');
fn =  dir(fullfile('image\Temp\SignTemplates_N', '*.jpg'));
for i = 1:length(fn)
    if strcmp(fn(i).name, '.') || strcmp(fn(i).name, '.')
        continue;
    end
    idx = findstr(fn(i).name, 'train_');
    if isempty(idx)
        fn(i).name = ['train_' fn(i).name];
    end
    [~, subname,ext] = fileparts(fn(i).name(7:end));
    if ~exist(fullfile('image\Sign_NewT7', subname))
        mkdir(fullfile('image\Sign_NewT7', subname))
    end
    
    fnn =  dir((fullfile('image\Sign_NewT7', subname, '*.jpg')));
% %     for j = 1:length(fnn)
% %         if strcmp(fnn(j).name(1:6), 'train_')
% %             continue;
% %         end
% %         imname = fullfile('image\Sign_NewT7', subname, fnn(j).name);
% %         [a, b, c] = fileparts(imname);
% %         imwrite(imread(imname), [a,'_', b], c);
% %         dos(['del ' imname])
% %     end
if ~exist(fullfile('image\Sign_NewT7', subname, fn(i).name))
    copyfile(fullfile('image\Temp\SignTemplates_N', fn(i).name), ...
        fullfile('image\Sign_NewT7', subname, fn(i).name));
end
    
    fid = fopen(fullfile('image\Sign_NewT7',subname, 'trainlist.txt'), 'w');
    fprintf(fid, '%s\r\n', fn(i).name);
    fclose(fid)
%     rmemptydir(fullfile('image\Sign_NewT7', subname));
end 
exFileFromFolder('image\Sign_NewT7') 




% [dis, dis2] = GetPerf('_NewT7', 0)