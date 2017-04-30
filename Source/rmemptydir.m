function rmemptydir(rt_data_dir)
subfolders = dir(rt_data_dir);
for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    if ~strcmp(subname, '.') & ~strcmp(subname, '..')
        subfolders1 = dir(fullfile(rt_data_dir, subname));
        i = 0;
        for jj = 1:length(subfolders1)
            if ~strcmp(subfolders1(jj).name, '.') & ~strcmp(subfolders1(jj).name, '..')
                i = i + 1;
            end
            if i > 0
                break;
            end
        end
        if i == 0
            rmdir(fullfile(rt_data_dir, subname), 's')
        end
        end
    end
end