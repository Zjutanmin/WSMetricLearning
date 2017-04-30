function [NNsae, X_pca] = SAE_Train(train_x, outdim, factivat, lRate, ...
    Masked, batchsize, numepochs, sparsityT, dropoutFraction, momentum,...
    Onebach, minepochs, fname, isnntrain,  rdim, train_yy)
%%  ex1 train a 100 hidden unit SDAE and use it to initialize a FFNN
%  Setup and train a stacked denoising autoencoder (SDAE)
if nargin < 8
    sparsityT = 0.05;
end
if nargin < 9
    dropoutFraction = 0;
end
if nargin < 10
    momentum = 0.5;
end
if nargin < 11
    Onebach = 1;
end 
if nargin < 12
    minepochs = 8000;
end
if nargin < 13
    fname = '';
end
if nargin < 14
    isnntrain = 0;
rdim = 0;
train_yy = 0;
end
rand('state',0)
sae = saesetup([size(train_x, 2) outdim]);
sae.ae{1}.activation_function       = factivat;
sae.ae{1}.learningRate              = lRate;
sae.ae{1}.inputZeroMaskedFraction   = Masked;


sae.ae{1}.sparsityTarget            = sparsityT;
sae.ae{1}.dropoutFraction           = dropoutFraction;
sae.ae{1}.momentum                  = momentum;

opts.fname     = fname;

opts.Onebach = Onebach;
if isnntrain
    opts.numepochs = numepochs / abs(numepochs) * max(round(abs(numepochs)/3), 1);
    opts.batchsize = max(batchsize/2, 1);
    opts.minepochs = max(minepochs/3, 1);
else
    opts.numepochs = numepochs;
    opts.batchsize = batchsize;
    opts.minepochs = minepochs;
end

sae = saetrain(sae, train_x, opts);
NNsae = sae.ae{end};
sae = nnff(NNsae, train_x, zeros(size(train_x,1), NNsae.size(end)));
X_pca = sae.a{2}(:,2:end);

if isnntrain
    % % sae = saetrain(sae, train_x, opts);
    % % visualize(sae.ae{end}.W{1}(:,2:end)')
    % Use the SDAE to initialize a FFNN
    nn = nnsetup([size(train_x, 2) outdim rdim]);
    nn.activation_function              = factivat;
    nn.learningRate                     = lRate;
    nn.W{1} = NNsae.W{1};

    % Train the FFNN

    opts.numepochs = numepochs;
    opts.batchsize = batchsize;
    opts.minepochs = minepochs;

    train_y= zeros(length(train_yy), rdim);
    tt = [1:length(train_yy)];
    index = sub2ind(size(train_y), tt(:), train_yy(:));
    train_y(index) = 1;

    NNsae = nntrain(nn, train_x, train_y, opts);
    sae = nnff(NNsae, train_x, zeros(size(train_x,1), NNsae.size(end)));
    X_pca = sae.a{end};
end