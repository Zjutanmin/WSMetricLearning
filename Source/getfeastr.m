function [mfea_dir, feastr, codestr, bookstr, Mfeastr, setting, N,...
    mfea_dir_WTA] = getfeastr(fea_dir, setting)
N = 0;
mfea_dir = cell(1, length(setting.feattype));
feastr = cell(1, length(setting.feattype));
codestr = cell(1, length(setting.feattype));
bookstr = cell(1, length(setting.feattype));
Mfeastr = '';
setting = getpyramiddstr(setting);

strind = [];
for i = 1:length(setting.feattype)
    if setting.precom
        tmp1 = '';feastr{i} = {};codestr{i} = {}; bookstr{i} = {}; 
        sstr = [setting.featname{i} 'P'];
    else
        [tmp1, feastr{i}, codestr{i}, bookstr{i}] = getstr(setting, setting.feattype{i}, i);
        sstr = setting.feattype{i};
    end
    for j = 1:length(bookstr{i})
        mfea_dir{i}{j} = [fea_dir '/' feastr{i}{j}];
        if ~exist(mfea_dir{i}{j})
            mkdir(mfea_dir{i}{j}); % directory for saving final image features
        end
        N = N +1;
    end
    if length(bookstr{i}) == 0
        mfea_dir{i}{1} = [fea_dir '/' sstr '_' tmp1];N = N +1;
    end
    Mfeastr = [Mfeastr sstr '_'];
    strind(i) = length(Mfeastr);
end
setting.feastr = feastr;setting.mfea_dir = mfea_dir;
setting.codestr = codestr;
setting.bookstr = bookstr;

mfea_dir1 = mfea_dir;
if isfield(setting, 'DoG') && setting.DoG
    Mfeastr = [setting.config_DOG '_' Mfeastr];
    for i = 1:length(setting.feattype)
        if strcmp(setting.feattype{i}, 'color') || strcmp(setting.feattype{i}, 'Hue')
            continue;
        end
        for j = 1:length(mfea_dir{i})
            mfea_dir{i}{j} = [mfea_dir{i}{j}, '_', setting.config_DOG];
            if ~strcmp(setting.config_DOG, 'DOG_2') && ~setting.precom
                mfea_dir1{i}{j} = [mfea_dir1{i}{j}, '_', setting.config_DOG];
            end
        end
    end
else
    if ~setting.precom
    for i = 1:length(setting.feattype)
        if strcmp(setting.feattype{i}, 'color') || strcmp(setting.feattype{i}, 'Hue')
            continue;
        end
        for j = 1:length(mfea_dir{i})
            mfea_dir{i}{j} = [mfea_dir{i}{j}, '_ND'];
            mfea_dir1{i}{j} = [mfea_dir1{i}{j}, '_ND'];
        end
    end
    end
end

mfea_dir_WTA = mfea_dir;
if isfield(setting, 'WTA') && setting.WTA
    str = [setting.config_WTA];
    if setting.WTAwithraw
        str = [str '_raw'];
    end
    Mfeastr = [str '_' Mfeastr];
    for i = 1:length(setting.feattype)
        for j = 1:length(mfea_dir_WTA{i})
            mfea_dir_WTA{i}{j} = [mfea_dir_WTA{i}{j}, '_', setting.config_WTA];
            mfea_dir1{i}{j} = [mfea_dir1{i}{j}, '_', setting.config_WTA];
        end
    end
end



Mfeastr1 = Mfeastr;
setting.confidencestr = setting.confidence;
setting.Bconfidence = floor(setting.confidence / 10);
setting.confidence = mod(setting.confidence, 10);
if setting.Bconfidence
    Mfeastr2 = Mfeastr;
else
    Mfeastr2 = '';
end

if setting.Mplatent && ~isempty(setting.config_latent)
    if length(setting.SnippetRatio) > 2 && floor(setting.SnippetRatio{3} / 10000) == 1
        Modelfeastr = [Mfeastr1];  
    else
        if length(setting.SnippetRatio) == 1
            Modelfeastr = [Mfeastr1];  
        else
            Modelfeastr = [Mfeastr1  '_' setting.config_latent];
        end
    end
else
    Modelfeastr = [Mfeastr1];
end

Modelfeastr1 = [Mfeastr1];

latentfstr = '';
if ~isempty(setting.config_latent)
    latentfstr = ['_' setting.config_latent];
end
setting.latentfstr = latentfstr;
if setting.latent
    Mfeastr = [Mfeastr  latentfstr '_' num2str(setting.platent)];
    Mfeastr1 = [Mfeastr1  latentfstr];
    if setting.Bconfidence Mfeastr2 = [Mfeastr2  latentfstr]; end
    for i = 1:length(setting.feattype)
        for j = 1:length(mfea_dir_WTA{i})
%             mfea_dir_WTA{i}{j} = [mfea_dir_WTA{i}{j}, latentfstr];
%             mfea_dir{i}{j} = [mfea_dir{i}{j}, latentfstr];
%             mfea_dmfea_dir{i}{1}ir1{i}{j} = [mfea_dir1{i}{j}, latentfstr];
            
        end
    end
end

if setting.isKNNlatent
    knnstr = getparastr(setting.KNNlatent);
    Mfeastr = [Mfeastr '_KNN' knnstr(2:end)];
    Mfeastr1 = [Mfeastr1 '_KNN' knnstr(2:end)];
    Mfeastr2 = [Mfeastr2  '_KNN' knnstr(2:end)];
    Modelfeastr = [Modelfeastr  '_KNN' knnstr(2:end)];
end


if setting.featPad
    Mfeastr = [Mfeastr  '_P'];   
    Mfeastr1 = [Mfeastr1  '_P'];   
    for i = 1:length(setting.feattype)
        for j = 1:length(mfea_dir_WTA{i})
            mfea_dir_WTA{i}{j} = [mfea_dir_WTA{i}{j}, '_P'];
            mfea_dir{i}{j} = [mfea_dir{i}{j}, '_P'];
            mfea_dir1{i}{j} = [mfea_dir1{i}{j}, '_P'];
        end
    end

end

if setting.Fpyramid
    if mod(setting.latent, 5) ~= 0
        setting.latent = 2;
    end
    pyrastr = ['FPY' num2str(setting.Fpyramid)];   
    Mfeastr = [pyrastr '_' Mfeastr];
    
    if ~strcmp(setting.cmethod, 'KNN')
        Modelfeastr = [pyrastr '_'  Modelfeastr];
        
        Mfeastr1 = [pyrastr '_' Mfeastr1];
    end
    Modelfeastr1 = [pyrastr '_'  Modelfeastr1];
    
    for i = 1:length(setting.feattype)
        if strcmp(setting.feattype{i}, 'Hue')
            continue;
        end
        for j = 1:length(mfea_dir_WTA{i})
            mfea_dir_WTA{i}{j} = [mfea_dir_WTA{i}{j}, '_', pyrastr];
            mfea_dir{i}{j} = [mfea_dir{i}{j}, '_', pyrastr];
            if ~strcmp(pyrastr, 'FPY8') && ~setting.precom
                mfea_dir1{i}{j} = [mfea_dir1{i}{j}, '_', pyrastr];
            end
        end
    end
else
    if ~setting.precom
    for i = 1:length(setting.feattype)
        if strcmp(setting.feattype{i}, 'Hue')
            continue;
        end
        for j = 1:length(mfea_dir_WTA{i})
            mfea_dir1{i}{j} = [mfea_dir1{i}{j}, '_S'];
        end
    end
    end
end

setting.mfea_dir = mfea_dir1;

setting.strfea = Modelfeastr1;
setting.mstrfea = {};
if setting.splitPCA
    sstr = [setting.feattype{1} '_'];
    idd = strfind(setting.strfea, sstr) - 1;
    setting.mstrfea{1} = setting.strfea([1:idd, idd+1:idd+strind(1)]);
    for i = 2:length(setting.feattype)
        setting.mstrfea{i} = setting.strfea([1:idd, idd+strind(i-1)+1:idd+strind(i)]);
    end
end


if setting.Ratio  
    Mfeastr = [Mfeastr '_R' num2str(setting.Ratio) '_' num2str(setting.RRatio)];
    Modelfeastr = [Modelfeastr '_R' num2str(setting.Ratio) '_' num2str(setting.RRatio)];
    Mfeastr1 = [Mfeastr1 '_R' num2str(setting.Ratio) '_' num2str(setting.RRatio)];
    Mfeastr2 = [Mfeastr2 '_R' num2str(setting.Ratio) '_' num2str(setting.RRatio)];
end
suffixx = '';

if setting.selfpaced(1)
    suffixx = ['WI-' num2str(setting.selfpaced(1))];
    if length(setting.selfpaced) > 1
        suffixx = [suffixx 'K' num2str(setting.selfpaced(2)) '-' num2str(setting.selfpaced(3))];
    end
    Mfeastr = [Mfeastr suffixx];
    Modelfeastr = [Modelfeastr suffixx];
    Mfeastr1 = [Mfeastr1 suffixx];
    Mfeastr2 = [Mfeastr2 suffixx];
end
setting.suffixx = suffixx;
if setting.fast && strcmp(setting.feattype{1}, 'siftflow')
    Mfeastr = [Mfeastr '_F'];
    Modelfeastr = [Modelfeastr '_F'];
Mfeastr1 = [Mfeastr1 '_F'];
    Mfeastr2 = [Mfeastr2 '_F'];
end

if setting.confidence
    Mfeastr = [Mfeastr '_C' num2str(setting.confidencestr)];
end
if ~isempty(setting.svote)
    Mfeastr = [Mfeastr '-' (setting.svote{1}) '-' ...
        num2str((setting.svote{2})) '-' num2str((setting.svote{3})) '-' num2str((setting.svote{4}))];
end


setting.Mfeastr1 = Mfeastr1;
setting.Modelfeastr = Modelfeastr;
setting.Mfeastr2 = Mfeastr2;



function [str, featstr, codestr, bookstr] = getstr(setting, feattype, i)
% if setting.precom
%     str, featstr, codestr, bookstr
%     return;
% end

codestr = {};
bookstr = {};
rawstr  = '';
if ~strcmp(feattype, 'llc') & ~strcmp(feattype, 'siftflow') & ~strcmp(feattype, 'Pixel')
    rawstr  = [setting.descriptor{i},'_',num2str(setting.overlap(i)),'S',...
        num2str(setting.swin(i))];
end
featstr = {};
switch feattype
    case 'llc'
        str = '';
        featstr = cell(1, length(setting.bookfeat));
        codestr = cell(1, length(setting.bookfeat));
        bookstr = cell(1, length(setting.bookfeat));
        for i = 1:length(setting.bookfeat)
            str = [str setting.bookfeat{i} '_'];  
            
            codestr{i} = [setting.bookfeat{i} '_' num2str(setting.gridSpacing)...
                '_' num2str(setting.patchSize)];
            bookstr{i} = [setting.bookfeat{i} '_' num2str(setting.ncluster) '_' num2str(setting.knn) '_' ...
                num2str(setting.codesampleR) '_' num2str(setting.gridSpacing)...
                '_' num2str(setting.patchSize)];
            
            featstr{i} = [setting.bookfeat{i} '_' num2str(setting.ncluster) '_' num2str(setting.knn) '_' ...
                num2str(setting.codesampleR) '_' num2str(setting.gridSpacing)...
                '_' num2str(setting.patchSize)];  
            
            if setting.sampling
                featstr{i} = [featstr{i} '_' num2str(setting.sampling)];
                bookstr{i} = [bookstr{i} '_' num2str(setting.sampling)];
                featstr{i} = [featstr{i}, setting.pyramidstr];
            end
        end
        str = [str num2str(setting.ncluster) '_' num2str(setting.knn) '_' ...
                num2str(setting.codesampleR) '_' num2str(setting.gridSpacing)...
                '_' num2str(setting.patchSize)];   
        if setting.sampling
            str = [str '_' num2str(setting.sampling)];
        end
        str = [str, setting.pyramidstr];

    case 'hog'
        str = rawstr;
    case 'sphog1'
        str = rawstr;
    case 'Pixel1'
        str = rawstr;
    case 'sphogM1'
        str = rawstr;
    case 'PixelM1'
        str = rawstr;
    case 'PixelO'
        str = rawstr;
    
    case 'sphog'
        str = rawstr;
    case 'Pixel'
        str = rawstr;
    case 'sphogM'
        str = rawstr;
    case 'PixelM'
        str = rawstr;
    case 'hog_dalal'
        str = [rawstr,'(b',num2str(setting.hog.bsize),'-o',num2str(setting.hog.orientation),...
            '-s',num2str(strcmp(setting.hog.issigned, 'signed')), '-d',num2str(setting.hog.descstride),...
            '-' setting.hog.Normalizer, ')'];
    case 'color'
        str = [rawstr,'(',num2str(setting.colortmp),')',num2str(setting.featnorm(i))];
    case 'Hue'
        str = [rawstr,'(',num2str(setting.featsetting.color.border),'-', num2str(setting.featsetting.color.maxvalue), ...
            '-', num2str(setting.featsetting.color.minvalue), ')',num2str(setting.featnorm(i))];
    case 'lbp'
%         if(slbp == 0)
            str = [rawstr,'(',setting.featsetting.lbp.str,')',num2str(setting.featnorm(i))];
%             slbp = slbp + 1;
%         end
    case 'ltp'
%         if(slbp == 0)
            str = [rawstr,'(',setting.featsetting.ltp.str,')',num2str(setting.featnorm(i))];
%             slbp = slbp + 1;
%         end 
        str = [str,'t',num2str(setting.featsetting.ltp.thresh)];
    
    case 'siftflow'
        str = ['Patch_', num2str(setting.patchsize), '_', num2str(setting.gridspacing)];
end