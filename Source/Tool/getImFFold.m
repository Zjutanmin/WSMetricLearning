function getImFFold(rt_data_dir_tmp)
if nargin < 1
    rt_data_dir_tmp = 'D:\MinTan\project\Signdetect\SignClassify\image\Sign_New2';
end

subfolders = dir(rt_data_dir_tmp);
 for kk = 1:length(subfolders)
     subname = subfolders(kk).name;
    if ~strcmp(subname, '.') & ~strcmp(subname, '..') & ~strcmp(subname, 'Trainstr.mat'),
        subfolders1 = dir(fullfile(rt_data_dir_tmp,subname, '*.jpg'));
        
        subfolders2 = dir(fullfile(rt_data_dir_tmp,subname));
        
        for tt = 1:length(subfolders2)
            subname1 = subfolders2(tt).name;
            if ~strcmp(subname1, '.') & ~strcmp(subname1, '..')
                fn = fullfile(rt_data_dir_tmp,subname,subname1);
                
                subfolders1 = dir(fullfile(fn, '*.jpg'));
                for jj = 1:length(subfolders1)
                    fn1 = fullfile(fn,subfolders1(jj).name);
                    newfn = [fn,'_' subfolders1(jj).name];
                    dos(['copy "' fn1 '" "' newfn '"']);
                end
                if length(subfolders1) > 0
                    rmdir(fn, 's')
                end
            end
        end
    end
 end