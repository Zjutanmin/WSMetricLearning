function setting = getconfig(config_file, bookfeat)

setting.featsetting.lbp.mapping.table = [];
setting.featsetting.lbp.flipindex = [];
setting.featsetting.ltp.mapping.table = [];
setting.featsetting.ltp.flipindex = [];
setting.bookfeat = bookfeat;
setting.config_file = config_file;

pwd = cd;
fn = [pwd '/setting/',config_file,'.m'];
if ~exist(fn)  %%%modify feature type
    %%%feattype
    setting.feattype = {'hog'};
    setting.overlap = [1];
    setting.stride = [8];
    setting.swin = [16];
    setting.featsize = [ 31];
    setting.descriptor = {'c'};
    setting.indexbow = [];
    setting.indexhog = 1;
    flipindex{1} = gethogsetting();
else
    cd([pwd '/setting/']);
    eval(config_file);
    cd(pwd);

    %%%pixel feature
    setting.indexpixel = union(find(ismember(setting.feattype,'Pixel')==1), ...
        find(ismember(setting.feattype,'PixelM')==1));
    setting.indexpixel = union(setting.indexpixel, ...
        find(ismember(setting.feattype,'Pixel1')==1));
    setting.indexpixel = union(setting.indexpixel, ...
        find(ismember(setting.feattype,'PixelM1')==1));
    setting.indexpixel = union(setting.indexpixel, ...
        find(ismember(setting.feattype,'PixelO')==1));
    if ~isempty(setting.indexpixel)
        setting.featsize(setting.indexpixel) = 784;
        if isempty(setting.overlap(setting.indexpixel))
            setting.overlap(setting.indexpixel) = 1;
        end
        setting.featnorm(setting.indexpixel) = 1;
        flipindex{setting.indexpixel} = [1:setting.featsize];
    end
    
    %%hog features' setting 
    setting.indexhog = union((find(ismember(setting.feattype,'hog')==1)) ...
        , (find(ismember(setting.feattype,'hog_dalal')==1)));
    setting.indexhog = union(setting.indexhog...
        , (find(ismember(setting.feattype,'sphog')==1)));
    setting.indexhog = union(setting.indexhog...
        , (find(ismember(setting.feattype,'sphogM')==1)));
    setting.indexhog = union(setting.indexhog...
        , (find(ismember(setting.feattype,'sphog1')==1)));
    setting.indexhog = union(setting.indexhog...
        , (find(ismember(setting.feattype,'sphogM1')==1)));
    if ~isempty(setting.indexhog)
        if ismember(setting.feattype,'hog_dalal')
            setting.featsize(setting.indexhog) = 32;
        else if ismember(setting.feattype,'sphog')
            setting.featsize(setting.indexhog) = 32;
            else
            setting.featsize(setting.indexhog) = 31;
            end
        end
        if isempty(setting.overlap(setting.indexhog))
            setting.overlap(setting.indexhog) = 1;
        end
        setting.featnorm(setting.indexhog) = 1;
        flipindex{setting.indexhog} = [1:setting.featsize];
%         flipindex{setting.indexhog} = gethogsetting();
    end
    %%%siftflow
    indexsiftflow = find(ismember(setting.feattype,'siftflow')==1);
    setting.indexsiftflow = indexsiftflow;
    if ~isempty(setting.indexsiftflow)
        flipindex{setting.indexsiftflow} = [1:100];  
    end
    
    %%%LLC features' setting
    indexllc = find(ismember(setting.feattype,'llc')==1);
    setting.indexllc = indexllc;
    if ~isempty(setting.indexllc)
        flipindex{setting.indexllc} = [1:setting.featsizellc(indexllc)];
        
        if ~isempty(find(ismember(setting.bookfeat,'lbp')==1))
            setting.featsetting.lbp = ... 
                getlbpsetting(setting.featsetting.lbp);
        end
        if ~isempty(find(ismember(setting.bookfeat,'ltp')==1))
            setting.featsetting.ltp = ... 
                getltpsetting(setting.featsetting.ltp);
        end
        if ~isempty(find(ismember(setting.bookfeat,'color')==1))
            
        end
        
    end

    %%%color features' setting
    indexcolor = union((find(ismember(setting.feattype,'color')==1)) ...
        , (find(ismember(setting.feattype,'Hue')==1)));
    setting.indexcolor = indexcolor;
    if ~isempty(setting.indexcolor)
        load('colortable.mat');
        if ~isfield(setting.featsetting.color,'descriptor')
            setting.featsetting.color.descriptor = 11;
        end
        colortmp = setting.featsetting.color.descriptor;
        
        if setting.featsetting.color.descriptor > 13
            colortable.featsize{setting.featsetting.color.descriptor} = 1;
        end
        
        if ismember(setting.feattype,'Hue')
            setting.featsize(setting.indexcolor) = 256;
        else
            setting.featsize(setting.indexcolor) = colortable.featsize{colortmp};
        end
        if isempty(setting.overlap(indexcolor))
            setting.overlap(indexcolor) = 1;
        end
        if ~isfield(setting.featsetting.color,'norm')
            setting.featnorm(indexcolor) = 1;
        else
            setting.featnorm(indexcolor) = setting.featsetting.color.norm;
        end
        flipindex{setting.indexcolor} = [1:length(colortable.featsize{colortmp})];
        setting.colortmp = colortmp;
    end
    
    %%lbp features' setting
    indexlbp = find(ismember(setting.feattype,'lbp')==1);
    setting.indexlbp = indexlbp;
    if ~isempty(setting.indexlbp)
        if ~isfield(setting.featsetting,'lbp')
            setting.featsetting.lbp = []; 
        end
        setting.featsetting.lbp = ...
            getlbpsetting(setting.featsetting.lbp);
        setting.featsize(indexlbp) =...
            setting.featsetting.lbp.featsize;
        if isempty(setting.overlap(indexlbp))
            setting.overlap(indexlbp) = 1;
        end
         if ~isfield(setting.featsetting.lbp,'norm')
            setting.featnorm(indexlbp) = 1;
        else
            setting.featnorm(indexlbp) = setting.featsetting.lbp.norm;
         end
         flipindex{setting.indexlbp} = setting.featsetting.lbp.flipindex;
    end
    
    %%ltp features' setting
    indexltp = find(ismember(setting.feattype,'ltp')==1);
    setting.indexltp = indexltp;
    if ~isempty(setting.indexltp)
        if ~isfield(setting.featsetting,'ltp')
            setting.featsetting.ltp = []; 
        end
        setting.featsetting.ltp = ...
            getltpsetting(setting.featsetting.ltp);
        setting.featsize(indexltp) =...
            setting.featsetting.ltp.featsize;
        if isempty(setting.overlap(indexltp))
            setting.overlap(indexltp) = 1;
        end
         if ~isfield(setting.featsetting.ltp,'norm')
            setting.featnorm(indexltp) = 1;
        else
            setting.featnorm(indexltp) = setting.featsetting.ltp.norm;
         end
         flipindex{setting.indexltp} = setting.featsetting.ltp.flipindex;
    end
end
setting.flipindex = mulfilpindex(flipindex);
%%%for features
if ~isfield(setting,'indexbow')
    setting.indexbow = [];
end
if ~isempty(setting.indexbow)
    addpath(genpath('D:/Tanmin/LSVM/BoW/BOW_code'));
    addpath(genpath('D:/Tanmin/LSVM/tensor_toolbox_2.4/tensor_toolbox_2.4'));
    EVENTinit
    setting.eventopts = eventopts;
    setting.dense = 1;
    make_directory_structure(eventopts)
    BOW_script;
end