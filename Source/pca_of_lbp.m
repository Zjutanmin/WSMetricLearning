function [coeff,latent] = pca_of_lbp(notecache, database, sbin, n, pcaname)

% globals;
% pascal_init;
[cachedir,tmpdir,VOCyear,VOCdevkit,VOCdevkit2006,cscdir] = globals(notecache);
if (strcmp(database(1:3),'voc'))&&(~strcmp(database(4:end),VOCyear))
    VOCyear = database(4:end);
    id = find(VOCdevkit == '\');
    VOCdevkit(id(end-2)+4:id(end-1)-1) = VOCyear;
end
if(strmatch(database(1:3),'voc', 'exact'))
    pascal_init;
else if(strmatch(database(1:5),'inria', 'exact'))
        inria_init;
    end;
end;


try
  load(['D:\Tanmin\LSVM\lsvm3\star-cascade\' pcaname]);
catch
  ids = textread(sprintf(VOCopts.imgsetpath, 'trainval'), '%s');
  num = length(ids);
  if nargin > 1
    num = min(n, num);
  end
  X = zeros(31, 31);
  n = 0;
  for i = 1:num
    fprintf('pca: %d/%d\n', i, num);
%     rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
%     name = [VOCopts.datadir rec.imgname];
%     im = color(imread(name));
    if(strmatch(database(1:5),'inria', 'exact'))
      name=ids{i}(11:end-4);
    else
      name=ids{i};
    end
    rec = PASreadrecord(sprintf(VOCopts.annopath, name));
    name = [VOCopts.datadir rec.imgname];
    im = color(imread(name));
    
%     feat = hogfeatures(resize(double(im), 0.25), sbin);
    feat = lbpfeatures(resize(double(im), 0.25), sbin, overlap,swin,stride,...
            setting.featsetting.lbp);
    % remove occlusion feature
%     feat(:,:,32) = [];
    for x = 1:size(feat,2)
      for y = 1:size(feat,1);
        v = feat(y,x,:);
        X = X + v(:) * v(:)';
        n = n+1;
      end
    end
    feat = features(resize(double(im), 0.5), sbin);
    feat(:,:,32) = [];
    for x = 1:size(feat,2)
      for y = 1:size(feat,1);
        v = feat(y,x,:);
        X = X + v(:) * v(:)';
        n = n+1;
      end
    end
    feat = features(resize(double(im), 0.75), sbin);
    feat(:,:,32) = [];
    for x = 1:size(feat,2)
      for y = 1:size(feat,1);
        v = feat(y,x,:);
        X = X + v(:) * v(:)';
        n = n+1;
      end
    end
  end

  X = X/n;
  [coeff, latent] = pcacov(X);
  save(['D:\Tanmin\LSVM\lsvm3\star-cascade\' pcaname], 'coeff', 'latent');
end
