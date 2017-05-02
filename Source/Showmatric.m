% =========================================================================
% An example code for the algorithm proposed in
%
%   Jinjun Wang, Jianchao Yang, Kai Yu, Fengjun Lv, Thomas Huang, and
%   Yihong Gong.
%   "Locality-constrained Linear Coding for Image Classification", CVPR
%   2010.
%
%
% Written by Jianchao Yang @ IFP UIUC
% May, 2010.
% =========================================================================
function [PCave, Ravg, ranktime, bestPara] = Showmatric(dataname, suffix, config_file, ...
    bookfeat, cmethod, knnpara, cpara, copyremove, issave, rawsize,sampling, ...
    pyramid, ncluster, normmerge, multiview, Rconfidence, config_DOG, ...
    config_WTA, WTAwithraw, Fpyramid, Ratio, RRatio, fast, config_latent, ...
    platent, confidence, svote, Crange, patchsize)
%%%prepocess = 0; non
%%%DOG = div(prepocess); WTA = mod(prepocess); 
if nargin < 1 dataname = 'Caltech101'; end
if nargin < 2 suffix = ''; end
if nargin < 3 config_file = 'llc_1'; end
if nargin < 4 bookfeat = {'sift'};  end
if nargin < 5
    cmethod = 'KNN'; 
    knnpara = 10;
end
if nargin < 7  cpara = []; end
if nargin < 8 copyremove = 1;   end
if nargin < 9 issave = 0;     end
if nargin < 10  rawsize = [90, 75];   end
if nargin < 29
    changesize = 0;
    patchsize = 16;     
else
    changesize = 1;
end
setting = getconfig(config_file, bookfeat);
if nargin >= 11 setting.sampling = sampling; end
if nargin >= 12 setting.pyramid = pyramid; end
if nargin >= 13 setting.ncluster = ncluster; end
if nargin < 14 normmerge = 0; end
if nargin < 15 multiview = 0;end
if nargin < 16  Rconfidence = 0.5;end
setting.Rconfidence = Rconfidence;
if nargin < 17   %%%for DOG
    setting.DoG = 0;
    config_DOG = '';
end

if nargin < 18    %%%for WTA
    setting.WTA = 0;
    config_WTA = '';
end
Nfold = 5;setting.Nfold = Nfold;
setting.config_DOG = config_DOG;
setting.multiview =multiview;
pwd = cd;
fn = [pwd '\setting\',config_DOG,'.m'];
if exist(fn)  %%%modify feature type
    cwd = pwd;cd([pwd '\setting\']);
    eval(config_DOG);cd(cwd);
    setting.DoG = 1;
end
setting.config_WTA = config_WTA;

pwd = cd;
fn = [pwd '\setting\',config_WTA,'.m'];
if exist(fn)  %%%modify feature type
    cwd = pwd;cd([pwd '\setting\']);
    eval(config_WTA);cd(cwd);
    setting.WTA = 1;
    if nargin < 18    %%%for WTA
        setting.WTAwithraw = 0;
    else
        setting.WTAwithraw = WTAwithraw;
    end
else
    setting.WTA = 0; setting.WTAwithraw = 0;
end
if nargin < 20    %%%for WTA
    setting.Fpyramid = 0;
else
    setting.Fpyramid = Fpyramid;
end   
if nargin < 21    %%%for WTA
    setting.Ratio = 0;
else
    setting.Ratio = Ratio;
    if nargin < 22    %%%for WTA
        setting.RRatio = 0.5;
    else
        setting.RRatio = RRatio;
    end
end
if strcmp(setting.feattype{1}, 'siftflow')
    if nargin < 23    %%%for WTA
        setting.fast = 1;
    else
        setting.fast = fast;
    end
else
    setting.fast = 1;
end
  
if nargin < 24   %%%for WTA
    setting.latent = 0;
    config_latent = '';
end


pwd = cd;
fn = [pwd '\setting\',config_latent,'.m'];
if exist(fn)  %%%modify feature type
    cwd = pwd; cd([pwd '\setting\']);
    eval(config_latent); cd(cwd);
    setting.latent = 1; setting.config_latent = config_latent;   
    if nargin < 25    %%%for WTA
        setting.platent = 0;
    else
        setting.platent = platent;
    end
    setting.platent = platent;
else
    setting.latent = 0;
    setting.platent = 0;
end

if nargin < 26    %%%for WTA
    setting.confidence = 0;
else
    setting.confidence = confidence;  
end

if nargin < 27   %%%for WTA
    setting.svote = {};
else
    setting.svote = svote;  
end
if nargin < 28   %%%for WTA
    setting.Crange= [-5,3];
else
    setting.Crange = Crange;  
end
if ~setting.WTA && isfield(setting, 'WTAwithraw') && setting.WTAwithraw
    fprintf('Error configuration: no WTA coding, but WTAwithraw is valid\n');
    pause;
end
if changesize
    setting.swin = ones(size(setting.swin)) * patchsize;
    idx = find(setting.overlap == 1);
    setting.stride = setting.swin;
    setting.stride(idx) = setting.swin(idx) / 2;
end

setting.rawsize = rawsize;
dataname1 = dataname;
addpath('Liblinear/matlab');        % we use Liblinear package, you need 
addpath('Libsvm/matlab');        % we use Liblinear package, you need 
addpath(genpath('mlr/'));


if ~strcmp(dataname, 'Caltech101')
    dataname = [dataname suffix];       % directory for the image database     
end

img_dir1 = ['image/' dataname1];       % directory for the image database  
feattype = setting.feattype;
img_dir = ['image/' dataname];       % directory for the image database   
data_dir = ['data/' dataname];  
fea_dir = ['features/' dataname];     % directory for saving final image features

if setting.Ratio
    setting.ratio_dir = ['Ratio/' dataname];
end


% setting.Mplatent = floor(setting.platent / 10);
setting.Tplatent = mod(setting.platent , 10);
if floor(setting.platent / 10)  %%%>10
    setting.Mplatent = 0;
else
    setting.Mplatent = setting.Tplatent;
end

setting.cmethod = cmethod;
[mfea_dir, feastr,codestr, bookstr, Mfeastr, setting, N, mfea_dir_WTA] = ...
    getfeastr(fea_dir, setting);

imRes_dir = ['imresult/' dataname '/'];
Res_dir = ['result/' dataname '/'];
nameresult = [Res_dir Mfeastr '_' cmethod getparastr(knnpara)];

setting.Tplatent = mod(setting.platent, 10);



nameimresult = [imRes_dir Mfeastr '_' cmethod getparastr(knnpara)];
setting.confidenceF = ['Confidence/' dataname '/' setting.Mfeastr2 '_' cmethod getparastr(knnpara)];
setting.latentresult = ['latent/' dataname '/' setting.Mfeastr1 '_' cmethod];
setting.Modelresult = ['SVMModel/' dataname '/' setting.Modelfeastr '_' cmethod];   
nameresulttmp = nameresult; 
suffix = '';
switch cmethod
    case 'MultiSVM'
        setting.latentresult = [setting.latentresult '-' num2str(mod(setting.platent, 2))];
        setting.Modelresult = [setting.Modelresult '-' num2str(mod(setting.platent, 2))];
        
        suffix = getparastr(cpara);
        if nnz(setting.Crange - [-5,3])
            suffix = [suffix '-' num2str(setting.Crange(1)) '-' num2str(setting.Crange(2))];
        end
        if length(knnpara) > 1
            suffix = [suffix '-' num2str(knnpara(2))];
        end
    case 'MLR'
        setting.latentresult = [setting.latentresult '-' num2str(setting.platent)];
%         setting.Modelresult = [setting.Modelresult '-' num2str(setting.platent)];
        
        setting.Modelresult = [setting.Modelresult '-' num2str(setting.Mplatent)];
        
        
        suffix = [getparastr(cpara{1}), '-',cpara{2}, getparastr(cell2mat(cpara(3:end)))];
        if length(knnpara) > 1
            suffix = [suffix '-' num2str(knnpara(2))];
        end
        setting.C = cpara{1};setting.LOSS = cpara{2}; setting.k = cpara{3};  
        setting.REG =cpara{4}; setting.Diagonal = cpara{5}; setting.B = cpara{6};
        setting.Latiter = cpara{7};
end
setting.latentresult = [setting.latentresult suffix];
setting.Modelresult = [setting.Modelresult suffix];
nameresult = [nameresult suffix];
nameimresult = [nameimresult suffix];       
if setting.confidence && ~exist(['Confidence/' dataname])
    mkdir(['Confidence/' dataname])
end
if length(feattype) >1
if ~normmerge
    nameresult = [nameresult '_C'];nameresulttmp = [nameresulttmp '_C']; nameimresult = [nameimresult '_C'];
end
end

latentresult1 = setting.latentresult;
if multiview
    nameresult = [nameresult '_MV' num2str(multiview)];nameresulttmp = [nameresulttmp  '_MV' num2str(multiview)];
    nameimresult = [nameimresult '_MV' num2str(multiview)];
    setting.latentresult = [setting.latentresult '_MV' num2str(multiview)];
%     setting.Modelresult = [setting.Modelresult '_MV' num2str(multiview)];
    if multiview ~= 1
        nameresult = [nameresult '_' num2str(Rconfidence)]; nameresulttmp = [nameresulttmp '_' num2str(Rconfidence)];
        nameimresult = [nameimresult '_' num2str(Rconfidence)];
        setting.latentresult = [setting.latentresult '_' num2str(Rconfidence)];
%         setting.Modelresult = [setting.Modelresult '_' num2str(Rconfidence)];
    end
end

nameresult = [nameresult '\'];nameresulttmp = [nameresulttmp '\'];
nameimresult = [nameimresult '\'];

if ~exist(nameresult) mkdir(nameresult);  end
if ~exist(nameresulttmp)  mkdir(nameresulttmp);  end
if ~exist(nameimresult) && issave mkdir(nameimresult);  end

if setting.WTA
    maxk = 7;
    name = ['BitCount_' num2str(maxk)];
    try
        load(['WTA\' name '.mat'], BitCount);
    catch
        if ~exist('WTA\')
            mkdir('WTA\')
        end
        BitCount = CreateNum1table(maxk);
        save(['WTA\' name '.mat'], 'BitCount');
    end
else
    BitCount = '';
    setting.K = 0;
end
setting.BitCount = BitCount;
bestPara = zeros([1,5]);

setting.Matric = [];
Error = 0;
PCave = zeros([7,1]);ranktime = 0;Ravg = 0;ranktime = 0;  
try
    load([nameresult 'acc'], 'PCave', 'Ravg', 'ranktime');
    if issave
        load([nameimresult 'issave'], 'issave');
    end
    if strcmp(cmethod, 'MultiSVM')
        Mstr = [num2str(mod(setting.platent, 2)), '_', num2str(1), '_', num2str(1), '.mat'];
        if cpara(1) == -1
            load(fullfile(setting.Modelresult,['Validate', Mstr]),'cbest', 'dbest', 'gbest', 'rbest', 'Vpara');  
            bestPara = [cbest, dbest, gbest, rbest, max(Vpara(:,end))];
        end
        load(fullfile(setting.Modelresult,['TrainError', Mstr]), 'a', 'C');
        ranktime = a(1);
    end
    
for tt = 1:Nfold
    if strcmp(cmethod, 'MLR') 
        Mstr = ['F' num2str(Nfold) '-' num2str(tt) '.mat'];
        try
            load(fullfile(setting.Modelresult,['Model-', Mstr]), 'Matric');
            margin  = max(Matric(:)) - min(Matric(:));
            Matric = (Matric - min(Matric(:))) / margin;
            sum(abs(diag(Matric))) / sum(abs(Matric(:)))
%             imshow(Matric);title([Mfeastr '-' Mstr]);
%             pause;
        end
    end
end

end
PCave = PCave';

% 
% ranktime = 
% ranktime = 0;