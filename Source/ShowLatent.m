% function ShowLatent(ffile, [latentinfo(hLatent,:), Rlatent, Groundtruth],ts_imname, Asubname)
function ShowLatent(ffile, latentinfo, ts_imname, tr_imname, Asubname, rotate, rawsize, Latent)
if nargin < 7
  rawsize = [90, 75];
end
if nargin < 8
  Latent = 1;
end
if ~exist(ffile)
    mkdir(ffile)
end

ts_fold_label = latentinfo(:, end-2);
[a,b,c] = unique(ts_fold_label);
rt_data_dir = 'image\Sign\TrueSign\-1';

ts_img_index = latentinfo(:, end-3);
tr_im = cell(1, length(tr_imname));

for ii = 1:length(tr_imname)
    tr_im{ii} = imread(tr_imname{ii});
end

ShouldPatch = 0;
if Latent == 1 %%%if latent is true
    str = 'GroundTruth';
else
    if Latent == 2
        str = 'Predict';
    else
        ShouldPatch = 1;
    end
end

for i = 1:length(ts_imname)
    if ~isempty(ts_imname{i})
        index = find(ts_imname{i} == '_');
        ts_imname{i} = ['I', ts_imname{i}(index(end-1)+1:end)];
    end
end

for ff = 1:length(a)
    if a(ff) == 0
        continue;
    end
    index = find(c == ff);
    imname = ts_imname(setdiff(ts_img_index(index), 0));
    subname = Asubname{a(ff)};
    subname = subname(1:end-1);
    
    subfolders1 = dir(fullfile(rt_data_dir, subname, '*.jpg'));
    n = length(subfolders1);
    if n == 0
        fprintf(['Can not find file: \n']);
        fprintf([subname ' in ' sfilename '\n']);
        continue;
    end

    figure;
    row = ceil(sqrt(n));
    col = row;
    if ~ShouldPatch
       row = row + 1;
    end
    for tt = 1:n
        fn = fullfile(rt_data_dir, subname, subfolders1(tt).name);
        im = imread(fn);
        tindex = find(~cellfun(@isempty, strfind(imname, ['I', subfolders1(tt).name])));
        subplot(row, col, tt);
        warped = imresize(im, rawsize, 'bilinear');
        if length(tindex) > 0
            LatentI = latentinfo(index(tindex(1)),:);
            warped = GenerrateIm(warped, LatentI, ShouldPatch, tr_im);
            showboxes(warped, LatentI(:, [3,1,4,2]), rotate(LatentI(end-1)));
        else
            imshow(warped);
        end
    end
    
    if ~ShouldPatch
        TrueL = latentinfo(index(1),end);
        subplot(row, col, (row-1)*col+1);
        imshow(tr_im{TrueL});
        title(str);
    end

    print(gcf, '-djpeg', '-r0', fullfile(ffile, [num2str(ff), '.jpg']));
    close all
end



function im = GenerrateIm(im,LatentI, ShouldPatch, tr_im)
if ShouldPatch
    im2 = tr_im{LatentI(end)};
    im2 = imresize(im2, [size(im,1), size(im,2)]);
    im = [im, zeros([size(im,1), 5, 3]), im2];
end