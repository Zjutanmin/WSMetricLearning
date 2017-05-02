function model = initmodel_reg(setting,cls, notecache,pos, note, symmetry, sbin, sz)

% model = initmodel(cls, pos, note, symmetry, sbin, sz)
% Initialize model structure.
load(pos(1).im, 'im');
h = size(im,2);
w = size(im,1);

if nargin < 5
  note = '';
end

% get an empty model
model = model_create(cls,notecache, note);
model.setting = setting;
% model.interval = 10;

if nargin < 6
  symmetry = 'N';
end

sz = [1 1];

if isfield(setting, 'npca')
    w = zeros(1, setting.npca);
else
    w = zeros(1, w*h);
end
windex = [1:numel(w)]';

if ~isempty(setting.indexcolor)
    if ~setting.overlap(setting.indexcolor)
        setting.featsetting.color.spacing = setting.stride(setting.indexcolor)*2;
    else
        setting.featsetting.color.spacing = setting.stride(setting.indexcolor);  
    end    
end
[w,windex] = initfeature(sz,model);


% add root filter
[model, symbol, filter] = model_addfilter(model, w, windex, symmetry);

% start non-terminal
[model, Q] = model_addnonterminal(model);
model.start = Q;

% add structure rule deriving only a root filter placement
model = model_addrule(model, 'S', Q, symbol, 0, {[0 0 0]});

% set detection window
model.numclass = 1;
model.ncomponent = length(model.rules{model.start});