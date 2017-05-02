function [dataX, dataY] = GetTrainSample(feattype, ...
    tr_idx, setting, fdatabase)

addpath(genpath('mlr/'));
addpath(genpath('sift/'));

config_latent = 'Latent1';
pwd = cd;
fn = [pwd '\setting\',config_latent,'.m'];
if exist(fn)  %%%modify feature type
    cwd = pwd; cd([pwd '\setting\']);
    eval(config_latent); cd(cwd);
    setting.latent = 1; setting.config_latent = config_latent;   
    setting.platent = 3;
    setting.protate = mod(setting.platent, 2);
    setting.pdisplace = floor(setting.platent / 2); 
end

tr_label = zeros(length(tr_idx), 1);
labelmap = setting.labelmap;

try
    load(fullfile(setting.Modelresult,['ctr_fea.mat']), 'ctr_fea', 'tr_label');
catch
    [ctr_fea, tr_label] = GetFeastr(fdatabase, feattype, tr_idx, setting, labelmap);
    save(fullfile(setting.Modelresult,['ctr_fea.mat']), 'ctr_fea', 'tr_label');
end
dataX = [ctr_fea];
dataY = [tr_label];

function [ctr_fea, tr_label] = GetFeastr(fdatabase, feattype, tr_idx, setting, labelmap)
ctr_fea = []; 
for i = 1:length(feattype)
            bookfeattype = length(fdatabase{i}.path);
            for j = 1:length(bookfeattype)
                ctr_fea_t = []; tr_label = [];
                for jj = 1:length(tr_idx),
                    if ~mod(jj, 5),
                        fprintf('.');
                    end
                    if ~mod(jj, 100),
                        fprintf(' %d images processed\n', jj);
                    end
                    fpath = fdatabase{i}.path{j}{tr_idx(jj)};
                    load(fpath, 'label');
                    if ~ismember(labelmap(label), setting.Consider)
                        continue;
                    end
                   
                    im = double(color(imread(fdatabase{i}.imgpath{tr_idx(jj)})));
                    im = imnoise(im,'gaussian');
                    warped = imresize(im, setting.rawsize, 'bilinear');
                    fea = FeatureMapCompute(setting, warped, i, setting.latent, 1); 
     
                    for tt = 1:length(setting.rotate)   %%%if no rotate then for one
                        switch setting.latent
                            case 1
                                tmp = fea{1}{tt}(:);
                            case 2
                                tmp = fea{2}{tt}(:);
                        end
                        for kk = 1:length(setting)
                            ctr_fea_t = [ctr_fea_t; tmp'];
                            tr_label = [tr_label; labelmap(label)];
                        end
                        
                    end
                end
                ctr_fea = [ctr_fea,ctr_fea_t]; 
            end
end
clear 'ctr_fea_t'


function feat = Combine(feat, fea)
for i = 1:length(feat)
    feat{i}(:,:,end+1:end+size(fea{i},3)) = fea{i};
end
