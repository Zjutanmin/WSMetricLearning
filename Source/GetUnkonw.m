function GetUnkonw(rt_img_dir)

subfolders = dir(rt_img_dir);
database.orgimpath = {};
for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    if ~strcmp(subname, '.') & ~strcmp(subname, '..') & ~strcmp(subname, 'Trainstr.mat')

        if strcmp(subname, '-2')
        end


%         for jj = 1:c_num,
%             c_path = fullfile(rt_img_dir, subname, frames(jj).name);
%             database.path = [database.path, c_path];
%             database.orgimpath = [database.orgimpath, c_path];
%             
%             forBook = 0;
%             istrain = 0;
%             if Trainid
%                 tmp = [frames(jj).name(1:end-4), '.jpg'];
%                 xx = strfind(ids, tmp);
%                 b = cellfun('isempty',xx);
%                 if nnz(b-1)
%                     istrain = 1;
%                     tt = findstr(tmp, 'train_');tmp1 = tmp(tt+6:end);
%                     if ~isempty(Sel_img_dir) && exist(fullfile(fullfile(Sel_img_dir, ...
%                             'selected'), tmp1))
%                         forBook = 1;
%                     end
%                 end
%             end
%             database.isForBook = [database.isForBook, forBook];
%             database.istrain = [database.istrain; istrain];
%         end; 
    end;
end;
disp('done!');