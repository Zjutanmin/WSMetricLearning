function TestData = GetPCAFeature(PCAMethod, featsize, LocalPCA, Normfea, Normfea1, ts_fea, PCACOEFF, FeatConf)
if isempty(ts_fea)
    TestData = [];
    return;
end
ts_label = ts_fea(:, end);
ts_fea = ts_fea(:, 1:end - 1);
if isempty(PCACOEFF)
    TestData = ts_fea;
    return;
end
    
if nargin < 8
    FeatConf = [1:length(PCACOEFF)];
end

if iscell(PCACOEFF{1})
    TestData = [];
    dim1 = 0;
    for i = 1:length(PCACOEFF)
        COEFF = PCACOEFF{i}{1};
        xmean = PCACOEFF{i}{2};
        dim2 = dim1+size(COEFF,1);
        if ismember(i, FeatConf)
            TestData_tmp = getPCAfeaT(featsize, LocalPCA, PCAMethod, ts_fea(:, dim1+1:dim2), PCACOEFF);
            TestData = [TestData, TestData_tmp];
        end
        dim1 = dim2;
    end
else
    TestData = getPCAfeaT(featsize, LocalPCA, PCAMethod, ts_fea, PCACOEFF);
end

TestData = GetSparseCoding(Normfea1{1}, TestData, Normfea1{2}, Normfea1{3},...
    Normfea1{4}, Normfea1{5}, Normfea1{6});

if iscell(Normfea)
    Normfea = Normfea{2};
end
    TestData = myNormlize(TestData, Normfea);
% end


function TestData = getPCAfeaT(featsize, LocalPCA, PCAMethod, ts_fea, PCACOEFF)
if LocalPCA
    [num, sdim] = size(ts_fea);tdim = sum(featsize);ndim = sdim/tdim;
    ts_fea = (reshape(ts_fea', tdim, num*ndim))';
end
    
switch PCAMethod
    case 'PCA'
        TestData = (ts_fea - repmat(PCACOEFF{2} , [size(ts_fea,1),1])) * PCACOEFF{1};
    case 'SAE'
        sae = nnff(PCACOEFF{1}, ts_fea, zeros(size(ts_fea,1), PCACOEFF{1}.size(end)));
        TestData = sae.a{2}(:,2:end);
    case 'SAE-NN'
        PCACOEFF{1}.testing = 1;
        sae = nnff(PCACOEFF{1}, ts_fea, zeros(size(ts_fea,1), PCACOEFF{1}.size(end)));
        TestData = sae.a{end};
    case 'LDA'
        TestData = ts_fea  * PCACOEFF{1};
end

if LocalPCA
    tdim = size(TestData, 2);
    TestData = (reshape(TestData', tdim*ndim, num))';
end