function test_example_SAE
load mnist_uint8;

train_x = double(train_x)/255;
test_x  = double(test_x)/255;
train_y = double(train_y);
test_y  = double(test_y);

%%  ex1 train a 100 hidden unit SDAE and use it to initialize a FFNN
%  Setup and train a stacked denoising autoencoder (SDAE)
rand('state',0)
sae = saesetup([784 100]);
sae.ae{1}.activation_function       = 'sigm';
sae.ae{1}.learningRate              = 1;
sae.ae{1}.inputZeroMaskedFraction   = 0.5;
opts.numepochs =  1;
opts.batchsize = 100;
opts.minepochs = 1;
opts.fname = [];
sae = saetrain(sae, train_x, opts);
visualize(sae.ae{end}.W{1}(:,2:end)')


% tty = zeros(size(test_x));tty(:, 1) = 1;
% [er, bad] = nntest(sae.ae{end}, test_x, tty);

NNsae = sae.ae{end};
sae_x = nnff(NNsae, train_x, zeros(size(train_x,1), NNsae.size(end)));
score1 = sae_x.a{2}(:,2:end);
% score = nnpredictScore(NNsae, train_x);



% sae1 = nnff(sae.ae{end}, test_x, test_x);



% Use the SDAE to initialize a FFNN
nn = nnsetup([784 100 10]);
nn.activation_function              = 'sigm';
nn.learningRate                     = 1;
nn.W{1} = sae.ae{1}.W{1};

% Train the FFNN
opts.numepochs =   1;
opts.batchsize = 100;
nn = nntrain(nn, train_x, train_y, opts);
[er, bad] = nntest(nn, test_x, test_y);

score1 = nnpredictScore(nn, test_x);
nn = nnff(nn, test_x, zeros(size(test_x,1), nn.size(end)));
score2 = nn.a{end};
dis = score2 - score1; max(abs(dis(:)))

assert(er < 0.16, sprintf('Too big error %d', er));
