function exFileFromFolder(rt_img_dir, isrmdir)
if nargin < 2
    isrmdir = 1;
end
alfa = -1.05;
subfolders = dir(rt_img_dir);
for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    
    if ~strcmp(subname, '.') & ~strcmp(subname, '..') & ~strcmp(subname, 'Trainstr.mat'),
        frames = dir(fullfile(rt_img_dir, subname));
        if exist(fullfile(rt_img_dir,subname, 'trainlist.txt'))
            if length(frames) <= 3
            frames = dir(fullfile(rt_img_dir, subname, '*.jpg'));
            if length(frames)==0
                rmdir(fullfile(rt_img_dir, subname), 's')
            end
            continue;
            end
            if length(frames) <= 4
            if isrmdir
                rmdir(fullfile(rt_img_dir, subname), 's')
            end
            continue;
            end
        else
            if length(frames) <= 2
            if isrmdir
                rmdir(fullfile(rt_img_dir, subname), 's')
            end
            continue;
            end
        end
        if str2num(subname) > 0
            if exist(fullfile(rt_img_dir,subname, 'trainlist.txt'))
                Tframes = fullfile(rt_img_dir,subname, 'trainlist.txt');
                ids = textread(Tframes, '%s');
            else
                ids= [];
            end
        else
            ids= [];
        end
        
        Stemplate = [];
        if ~isempty(ids)
        for tt = 1:length(ids)
            name = fullfile(rt_img_dir,subname, ids{tt});
            Stemplate = [Stemplate; size(imread(name))];
        end
        if length(ids) == 1
            meanS = (Stemplate);
        else
            meanS = mean(Stemplate);
        end
        meanS = meanS(1:2);
        else
            meanS = -inf;
        end
        
       
        for i = 1:length(frames)
            if ~strcmp(frames(i).name, '.') & ~strcmp(frames(i).name, '..'),
                
                
            fn = fullfile(rt_img_dir, subname, frames(i).name);
            
            sframes = dir(fullfile(fn, '*.jpg'));
            
            if length(sframes) == 0
                continue;
            end
            
            maxsize = [-inf, -inf, -inf];
            for jj = 1:length(sframes)
                imname = [fn, '\', sframes(jj).name];
                Tsize = size(imread(imname));
                maxsize = max(maxsize, Tsize);
            end
            thresh = meanS * (1+alfa);
            if abs(meanS) == inf
                thresh = -inf;
            end
            if nnz(maxsize(1:2) >= thresh)

            for jj = 1:length(sframes)
                imname = [fn, '\', sframes(jj).name];
                newimname = [[fn, '_', sframes(jj).name]];
                if ~exist(newimname)
                    dos(['copy "' imname '" "' newimname '"']);
                end
            end
            
            end
            
            rmdir(fn, 's')
            
            end
        end
    end
end
disp('done!');