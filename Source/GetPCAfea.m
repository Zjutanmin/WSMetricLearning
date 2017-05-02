function [COEFF, xmean, X_pca, rdim] = GetPCAfea(setting, X, energy, Xtest, PCACOEFF)
if isstruct(setting)
    featNorm = setting.NormFea;
    if ~isfield(setting, 'NormFea1') featNorm1 = {[], []};else featNorm1 = setting.NormFea1;end
    if ~isfield(setting, 'fname')    fname = [];    else fname = setting.fname;       end
    if ~isfield(setting, 'featsize') featsize = []; else featsize = setting.featsize; end
    if ~isfield(setting, 'LocalPCA') LocalPCA = []; else LocalPCA = setting.LocalPCA; end
else
    featNorm = setting{1};
    featNorm1 = setting{2};
    fname = [];
    featsize = [];
    LocalPCA = 0;
end
LDANORM = 1;
if iscell(featNorm)
    LDANORM = featNorm{2};
    featNorm = featNorm{1};
end
Y = [];Ytest = [];
if size(X, 1) > 1
    Y = X(:, end);
    X = X(:, 1:end-1);  
end
X_pca = X;
COEFF = [];
xmean = [];
rdim = [];
if iscell(energy)
    asePara = energy(3:end);
    PCAmethod = energy{2};
    energy = energy{1};
else
    PCAmethod = 'PCA';
    asePara = [];
end
if nargin < 4
    Xtest = [];
else
    if ~isempty(Xtest)
        Ytest = Xtest(:, end);
        Xtest = Xtest(:, 1:end-1);
    end
end

if energy == 0
    X_pca = [X; Xtest];
    return;
end



X = myNormlize(GetSparseCoding(featNorm1{1}, X, featNorm1{2}), featNorm);
Xtest = myNormlize(GetSparseCoding(featNorm1{1}, Xtest, featNorm1{2}), featNorm);
% % if featNorm
% %     X = L2normMatrix(X);
% %     Xtest = L2normMatrix(Xtest);
% % end

    if nargin < 5
        [COEFF, xmean, X_pca] = GetPCA(X, Y, abs(energy), PCAmethod, ...
            asePara, fname, featsize, LocalPCA);
        PCACOEFF{1} = COEFF;
        PCACOEFF{2} = xmean;
    else
        if iscell(PCACOEFF{1})
            X_pca = [];
            dim1 = 0;
            COEFF = cell(1, length(PCACOEFF));
            xmean = cell(1, length(PCACOEFF));
            for i = 1:length(PCACOEFF)
                COEFF{i} = PCACOEFF{i}{1};
                xmean{i} = PCACOEFF{i}{2};
                dim2 = dim1+size(COEFF{i},1);
                X_tmp = GetPCATest(X(:, dim1+1:dim2), Y, PCAmethod, ...
                    COEFF{i}, xmean{i}, featsize, LocalPCA);
                X_pca = [X_pca, X_tmp];
                dim1 = dim2;
            end
        else
            COEFF = PCACOEFF{1};
            xmean = PCACOEFF{2};
            X_pca = GetPCATest(X, Y, PCAmethod, COEFF, xmean, featsize, LocalPCA);
            
        end
    end
    if ~isempty(Xtest)
        if iscell(PCACOEFF{1})
            TestData = [];
            dim1 = 0;
            COEFF = cell(1, length(PCACOEFF));
            xmean = cell(1, length(PCACOEFF));
            for i = 1:length(PCACOEFF)
                COEFF{i} = PCACOEFF{i}{1};
                xmean{i} = PCACOEFF{i}{2};
                dim2 = dim1+size(COEFF{i},1);
%                 TestData_tmp = (Xtest(:, dim1+1:dim2) - repmat(xmean{i}, [size(Xtest,1),1])) * COEFF{i};
                TestData_tmp = GetPCATest(Xtest(:, dim1+1:dim2), Ytest, ...
                    PCAmethod, COEFF{i}, xmean{i}, featsize, LocalPCA);
                TestData = [TestData, TestData_tmp];
                dim1 = dim2;
            end
        else
            COEFF = PCACOEFF{1};
            xmean = PCACOEFF{2};
%             TestData = (Xtest - repmat(xmean, [size(Xtest,1),1])) * COEFF;
            TestData = GetPCATest(Xtest, Ytest, PCAmethod, COEFF, xmean,...
                LocalPCA, featsize); 
        end
    else
        TestData = [];
    end
    X_pca = [X_pca; TestData]; 
    clear 'TestData';
    if iscell(PCACOEFF{1})
    iter = 0;
    rdim = cell(1, length(PCACOEFF));
    for i = 1:length(PCACOEFF)
        ss = size(PCACOEFF{i}{1}, 2);
        rdim{i} = [iter+1, iter+ss];
        iter = iter + ss;
    end
else
    rdim{1} = [1, size(PCACOEFF{1}, 2)];
    end
    
% if featNorm
%     X_pca = L2normMatrix(X_pca);
% end
if LDANORM
    X_pca = myNormlize(X_pca, featNorm);
end

function X_pca = GetPCATest(X, Y, PCAMethod, COEFF, xmean, LocalPCA, featsize)
if isempty(X)
    X_pca = [];
    return;
end
if LocalPCA
    [num, sdim] = size(X);tdim = sum(featsize);ndim = sdim/tdim;
    X = (reshape(X', tdim, num*ndim))';
end
switch PCAMethod
    case 'PCA'
        X_pca = (X - repmat(xmean, [size(X,1),1])) * COEFF;
    case 'SAE'
        sae = nnff(COEFF, X, zeros(size(X,1), COEFF.size(end)));
        X_pca = sae.a{2}(:,2:end);
    case 'SAE-NN'
        COEFF.testing = 1;
        sae = nnff(COEFF, X, zeros(size(X,1), COEFF.size(end)));
        X_pca = sae.a{end};
        
    case 'LDA'
        X_pca = X*COEFF;
    case 'LDA1'
        X_pca = X*COEFF;
end
if LocalPCA
    tdim = size(X_pca, 2);
    X_pca = (reshape(X_pca', tdim*ndim, num))';
end

function [COEFF, xmean, X_pca] = GetPCA(X, Y, energy, PCAMethod, asePara,...
    fname, featsize, LocalPCA)
% X1 = X;
% if LocalPCA
%     [num, sdim] = size(X);tdim = sum(featsize);ndim = sdim/tdim;
%     X = (reshape(X', tdim, num*ndim))';
%     Y = repmat(Y', [ndim, 1]);Y = Y(:);
%     asePara{4} = asePara{4} * ndim;
% end

if LocalPCA
    [num, sdim] = size(X);tdim = sum(featsize);ndim = sdim/tdim;
    X = (reshape(X', tdim, num*ndim))';
    Y = repmat(Y', [ndim, 1]);Y = Y(:);
end

% dis = X - X1; max(abs(dis(:)))
nY = length(Y);
idxx = find(~isnan(sum(X.^2, 2)));
X = X(idxx, :);Y = Y(idxx);

switch PCAMethod
    case 'PCA'
%         [min((sum(X.^2, 2))), max(sum(X.^2, 2))]
%         find(~isnan(sum(X.^2, 2)))
        if energy < 1
            [COEFF, SCORE, LATENT] = princomp(X);
            idx = find( cumsum(LATENT) / sum(LATENT) >= energy);
        COEFF = COEFF(:, 1:idx(1));
        xmean = mean(X);
        [m,n] = size(X);
        X_pca = (X - repmat(xmean, [m,1])) * COEFF;
        else
            options=[];
            options.ReducedDim=energy;
			[COEFF,eigvalue] = PCA(X,options);
            xmean = mean(X);
            [m,n] = size(X);
            X_pca = (X - repmat(xmean, [m,1])) * COEFF;
        end
    case 'SAE'
        [COEFF, X_pca] = SAE_Train(X, round(energy*size(X,2)), asePara{1}, ...
            asePara{2}, asePara{3}, asePara{4}, asePara{5}, asePara{6}, ...
            asePara{7}, asePara{8}, asePara{9}, asePara{10}, fname);
        xmean = [];
    case 'SAE-NN'
        nClass = length(unique(Y));
        Dim = nClass;
        [COEFF, X_pca] = SAE_Train(X, round(energy*size(X,2)), asePara{1}, ...
            asePara{2}, asePara{3}, asePara{4}, asePara{5}, asePara{6}, ...
            asePara{7}, asePara{8}, asePara{9}, asePara{10}, fname, 1, Dim, Y);
     
        xmean = [];
    case 'LDA'
        options = [];
        try options.Fisherface = asePara{1}; catch options.Fisherface = 1; end
        if asePara{2} ~= 0
            options.Regu = 1;options.ReguAlpha = asePara{2};
        end
        if options.Fisherface == -1  
            options.Fisherface = 0;
            [COEFF, xmean] = LSDA(Y, options, X);
        else
            if options.Fisherface == -2  
                options.Fisherface = 0;
                options.ReguType = 'Custom'; 
                options.regularizerR = GenSpatialSmoothRegularizer(32, 32); 
                [COEFF, xmean] = LDA(Y, options, X);
            else
                [COEFF, xmean] = LDA(Y, options, X);
            end
        end
        X_pca = X*COEFF;
    case 'LDA1'
        options = [];
        options.Fisherface = 1;
        [COEFF, xmean] = LDA(Y, options, X);
        X_pca = X*COEFF;
end
if LocalPCA && ~isempty(X_pca)
    tdim = size(X_pca, 2);
    X_pca = (reshape(X_pca', tdim*ndim, num))';
end
XX_pca = zeros(nY, size(X_pca, 2));
XX_pca(idxx, :) = X_pca;
X_pca = XX_pca;