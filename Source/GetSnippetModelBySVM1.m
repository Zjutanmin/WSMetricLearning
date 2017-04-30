function [Snippetmodel, C, a, b] = GetSnippetModelBySVM1(setting, ylabel, Cscore, Clabel)
if setting.MultiSVM
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

    [CRe,a,b] = TestModel(ylabel, Clabel, Cscore, Snippetmodel, setting.SRKSVM);
else
    [Snippetmodel, C, a, b] = GetModelBySVM(setting, ylabel, Cscore);
end

    
function [Snippetmodel, C, a, b] = GetModelBySVM(setting, ylabel, Cscore)
Psvmtrain = setting.SRKSVM;
if Psvmtrain
    wstr = ' -b 1';
    kerneltype = 2;
    FunTrain = @svmtrain;FunTest = @svmpredict;
else
    wstr = ' ';
    kerneltype = 0;
    FunTrain = @train;FunTest = @predict;
end

if setting.WeightSVM  
    Snippetmodel = FunTrain(double(ylabel), sparse(Cscore));
    xx = zeros(1, length(Snippetmodel.Label));
    for i = 1:length(Snippetmodel.Label)
        xx(i) =length(find(ylabel == Snippetmodel.Label(i)));
    end
    slabel = Snippetmodel.Label;
    xx = xx / sum(xx);
    wi = min(xx) ./ xx; 
    wstr = [wstr getWstr(wi)];
end

if setting.typeSVM  %%%using -s 2
    wstr = [wstr ' -s 2'];
end

    
if setting.CrossSVM
    [cbest, dbest, gbest, rbest, options, Vpara] = CrossValidate(kerneltype, ...
        wstr, ylabel, Cscore, Psvmtrain);
    save(fullfile(setting.Modelresult,['Validate', setting.Mstr]), ...
        'cbest', 'dbest', 'gbest', 'rbest', 'Vpara');  
else
    cbest = 1;options = ['-c ' num2str(cbest) wstr];
end

Snippetmodel = FunTrain(double(ylabel), sparse(Cscore), options);
[C,a,b] = FunTest(double(ylabel), sparse(Cscore), Snippetmodel);

if setting.WeightSVM  

    if nnz(slabel- Snippetmodel.Label)
        fprintf('Error label\n');
        pause;
    end
    
end