disp('Loading iris data');
X1 = load('data/iris.mtx');

load('D:\MinTan\project\Signdetect\SignClassify\data', 'X', 'y')

X = (X - min(X1(:))) / (max(X1(:)) - min(X1(:)));
y = y - 1;
disp('Running ITML');
num_folds = 2;
knn_neighbor_size = 4;
acc = CrossValidateKNN(y, X, @(y,X) MetricLearningAutotuneKnn(@ItmlAlg, y, X), num_folds, knn_neighbor_size);

disp(sprintf('kNN cross-validated accuracy = %f', acc));

