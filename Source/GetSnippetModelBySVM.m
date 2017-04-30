function [Snippetmodel, C, a, b] = GetSnippetModelBySVM(setting, ylabel, Cscore, Clabel)
if setting.MultiSVM
    disp('test_5_1');
    disp(length(Cscore));
    C = zeros(1, length(ylabel));
    b = zeros(1, length(ylabel));
    
    [aa,bb,cc] = unique(Clabel);
    
    Snippetmodel = cell(1, length(aa));
    for i = 1:length(aa)
        idxx = find(cc == i);
        ylabel_i = ylabel(idxx); 
        Cscore_i = Cscore(idxx); 
        if length(find(ylabel_i == -1)) == 0 || length(find(ylabel_i == 1)) == 0
            Snippetmodel{i}.Class = aa(i);
            continue;
        end
        [Snippetmodel{i}, C(idxx), a, b(idxx)] = GetModelBySVM(setting, ylabel_i, Cscore_i);
        Snippetmodel{i}.Class = aa(i);
    end
    disp('test_5_1');
    disp(length(Cscore));
else
    disp('test_5_2');
    disp(length(Cscore));
    [Snippetmodel, C, a, b] = GetModelBySVM(setting, ylabel, Cscore);
    disp('test_5_2');
    disp(Snippetmodel);
    disp(length(C));
    disp(length(a));
    disp(length(b));
end

    
function [Snippetmodel, C, a, b] = GetModelBySVM(setting, ylabel, Cscore)
Psvmtrain = setting.SRKSVM;
global PATH_F
addpath(genpath([PATH_F 'liblinear-weights']));
addpath(genpath([PATH_F 'libsvm-weights']));
if Psvmtrain
    disp('test_svmtrain');
    wstr = ' -b 1';
    kerneltype = 2;
    FunTrain = @svmtrain;FunTest = @svmpredict;
else
    disp('test_train');
    wstr = ' ';
    kerneltype = 0;
    FunTrain = @train;FunTest = @predict;
end
disp(mfilename('fullpath'));


disp('test_5_3');
disp(length(Cscore));
if setting.WeightSVM  
    disp(pwd);
    Snippetmodel = FunTrain(double(ylabel), sparse(Cscore));
    xx = zeros(1, length(Snippetmodel.Label));
    for i = 1:length(Snippetmodel.Label)
        xx(i) =length(find(ylabel == Snippetmodel.Label(i)));
    end
    slabel = Snippetmodel.Label;
    xx = xx / sum(xx);
    wi = min(xx) ./ xx; 
    wstr = [wstr getWstr(wi)];
    
    disp('test_5_4');    
    disp(Snippetmodel);
end

if setting.typeSVM  %%%using -s 2
    wstr = [wstr ' -s 2'];
end


if setting.CrossSVM
    [cbest, dbest, gbest, rbest, options, Vpara] = CrossValidate(kerneltype, ...
        wstr, ylabel, Cscore, Psvmtrain);
%     save(fullfile(setting.Modelresult,['Validate', setting.Mstr]), ...
%         'cbest', 'dbest', 'gbest', 'rbest', 'Vpara');  
else
    cbest = 1;options = ['-c ' num2str(cbest) wstr];
end
disp('test_5_5');
disp(pwd);
% disp(length(Cscore));

Snippetmodel = FunTrain(ones(size((ylabel))), double(ylabel), sparse(Cscore), options);
disp('test_5_5_1');
disp(options);
[C,a,b] = FunTest(double(ylabel), sparse(Cscore), Snippetmodel);

disp('test_5_6');
disp(length(C));
disp(length(a));
disp(length(b));
disp(Snippetmodel);

ids = find(Snippetmodel.Label == 1);
if ids == 2
    b = -b;
end

                                
if setting.WeightSVM  

    if nnz(slabel- Snippetmodel.Label)
        fprintf('Error label\n');
        pause;
    end
    
end