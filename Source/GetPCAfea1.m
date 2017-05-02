function [COEFF, xmean, X_pca, rdim] = GetPCAfea1(featNorm, X, energy, Xtest, PCACOEFF)
Y = X(:, end);
X = X(:, 1:end-1);
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

if energy == 0
    return;
end

if nargin < 4
    Xtest = [];
else
    Ytest = Xtest(:, end);
    Xtest = Xtest(:, 1:end-1);
end
if featNorm
    X = L2normMatrix(X);
    Xtest = L2normMatrix(Xtest);
end

    if nargin < 5
        [COEFF, xmean, X_pca] = GetPCA(X, Y, abs(energy), PCAmethod, asePara);
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
                X_tmp = (X(:, dim1+1:dim2) - repmat(xmean{i}, [size(X,1),1])) * COEFF{i};
                X_pca = [X_pca, X_tmp];
                dim1 = dim2;
            end
        else
            COEFF = PCACOEFF{1};
            xmean = PCACOEFF{2};
            X_pca = (X - repmat(xmean, [size(X,1),1])) * COEFF;
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
                TestData_tmp = (Xtest(:, dim1+1:dim2) - repmat(xmean{i}, [size(Xtest,1),1])) * COEFF{i};
                TestData = [TestData, TestData_tmp];
                dim1 = dim2;
            end
        else
            COEFF = PCACOEFF{1};
            xmean = PCACOEFF{2};
            TestData = (Xtest - repmat(xmean, [size(Xtest,1),1])) * COEFF;
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
    
if featNorm
    X_pca = L2normMatrix(X_pca);
end

function X_pca = GetPCA(X, Y, PCAMethod, COEFF, xmean)
switch PCAMethod
    case 'PCA'
        X_pca = (X - repmat(xmean, [size(X,1),1])) * COEFF;
    case 'SAE'
        sae = nnff(COEFF, X, zeros(size(X,1), COEFF.size(end)));
        X_pca = sae.a{2}(:,2:end);
    case 'LDA'
        X_pca = X*COEFF;
%     case 'mylda'
%         [X_pca, COEFF, xmean, COEFF1]=mylda(X,Y);
%         [m,n] = size(X);
%         X_pca1 = (X - repmat(xmean, [m,1])) * COEFF1 * COEFF;
    case 'LDA1'
        X_pca = X*COEFF;
end



function [COEFF, xmean, X_pca] = GetPCATest(X, Y, energy, PCAMethod, asePara)
switch PCAMethod
    case 'PCA'
        [COEFF, SCORE, LATENT] = princomp(X);
        idx = find( cumsum(LATENT) / sum(LATENT) >= energy);
        COEFF = COEFF(:, 1:idx(1));
        xmean = mean(X);
        [m,n] = size(X);
        X_pca = (X - repmat(xmean, [m,1])) * COEFF;
    case 'SAE'
        [COEFF, X_pca] = SAE_Train(X, round(energy*size(X,2)), asePara{1}, ...
            asePara{2}, asePara{3}, asePara{4}, asePara{5});
        xmean = [];
    case 'LDA'
        options = [];
        try options.Fisherface = asePara{1}; catch options.Fisherface = 1; end
        if asePara{2} ~= 0
            options.Regu = 1;options.ReguAlpha = asePara{2};
        end
        [COEFF, xmean] = LDA(Y, options, X);
        X_pca = X*COEFF;
%     case 'mylda'
%         [X_pca, COEFF, xmean, COEFF1]=mylda(X,Y);
%         [m,n] = size(X);
%         X_pca1 = (X - repmat(xmean, [m,1])) * COEFF1 * COEFF;
    case 'LDA1'
        options = [];
        options.Fisherface = 1;
        [COEFF, xmean] = LDA(Y, options, X);
        X_pca = X*COEFF;
end