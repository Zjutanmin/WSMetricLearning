function model = SVMtrain_S(setting, cpara, ctr_fea, tr_label, Psvmtrain, kerneltype, SampleWT, issave)
[tr_label, ord] = sort(tr_label);
ctr_fea = ctr_fea(ord,:);

if nargin < 7
    SampleWT = ones(1, length(tr_label));
end
SampleWT = SampleWT(ord);
SampleWT = SampleWT';
if nargin < 8
    issave = 1;
end
Mstr = setting.Mstr;
% % try
% %     load(fullfile(setting.Modelresult,['Model-', Mstr]), 'model');
% % catch
    c = cpara(1);
    w = cpara(2);
    if Psvmtrain
        wstr = ['-b 1 -t ' num2str(kerneltype)];
    else
        wstr = '';
    end
    if w ~= 0
        xx = hist(tr_label, [1:length(setting.cindex)]);
        xx = xx / sum(xx);
        wi = min(xx) ./ xx; 
        [tt, idx] = min(wi);
        wi(idx) = w * wi(idx); 
        wstr = [wstr ' ' getWstr(wi)];
    end
    
    if c == -1
        if length(setting.Crange) > 2
            Margin = setting.Crange(3);
        else
        if setting.Crange(2) - setting.Crange(1) >= 10
            Margin = 2;
        else
            Margin = 1;
        end
        end
        [cbest, dbest, gbest, rbest, options, Vpara] = CrossValidate(kerneltype, ...
            wstr, tr_label, ctr_fea, Psvmtrain, setting.Crange(1:2), Margin, SampleWT);
        save(fullfile(setting.Modelresult,['Validate', Mstr]), ...
            st', 'dbest', 'gbest', 'rbest', 'Vpara');  
    else
        if Psvmtrain
            options = ['-c ' num2str(c) ' ' wstr];
        else
            options = ['-c ' num2str(c) ' ' wstr];
        end
    end
    
    %%%%%%%
% % % %     idx = [];
% % % %     for jj = 1:length(setting.cindex)
% % % %         ids = find(tr_label == jj);
% % % %         idx = [idx, ids(1)];
% % % %     end
% % % %     randp = randperm(size(ctr_fea, 1));
% % % %     ctr_fea = [ctr_fea(idx,:); ctr_fea(randp(1:20), :)];
% % % %     tr_label = [tr_label(idx); tr_label(randp(1:20))];
    %%%%%%%%%%%%
    
    if Psvmtrain
        model = svmtrain(SampleWT, double(tr_label), sparse(ctr_fea), options);
        [C,a,b] = svmpredict(tr_label, sparse(ctr_fea), model);
    else
        model = train(SampleWT, double(tr_label), sparse(ctr_fea), options);
        [C,a,b] = predict(tr_label, sparse(ctr_fea), model);
    end
    clear ctr_fea;
    
    if issave
    save(fullfile(setting.Modelresult,['TrainError', setting.Mstr]), 'a', 'C');
    
    save(fullfile(setting.Modelresult,['Model-', setting.Mstr]), 'model');
    end
% % end

if ~Psvmtrain
    if nnz(model.Label' - [1:length(model.Label)])
        model.w(model.Label,:) = model.w;
        model.Label = [1:length(model.Label)]';
        save(fullfile(setting.Modelresult,['Model-',setting.Mstr]), 'model');
    end
% else
%     Adiag = repmat(model.Label', [length(model.Label),1 ]);A = tril(Adiag, -1);
%     model.A = A(find(A~=0));
%     Bdiag = repmat(model.Label, [1, length(model.Label)]);B = tril(Bdiag, -1);
%     model.B = B(find(B~=0));
end