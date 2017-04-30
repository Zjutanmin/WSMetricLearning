
function [cbest, dbest, gbest, rbest, options, Vpara] = CrossValidate(kernel, ...
    wistr, tr_label, ctr_fea, Psvmtrain, Crange, Margin)
if Psvmtrain
    FunTrain = @svmtrain;FunTest = @svmpredict;
else
    FunTrain = @train;FunTest = @predict;
end

wistr1 = wistr;
wistr = [wistr ' -v 5'];
if nargin < 6
    Crange = [-5,3];
end
if nargin< 7
    Margin = 1;
end
Vpara = [];
c = 2.^[Crange(1):Margin:Crange(2)];
switch kernel
    case 0
        for i = 1:length(c)
            options = ['-c ' num2str(c(i)) wistr];
            acc = FunTrain(ones(size(tr_label)),double(tr_label), sparse(ctr_fea), options);
            Vpara = [Vpara; c(i), 0, 0, 0, acc];
        end
        [cbest, dbest, gbest, rbest] = GetMax(Vpara);
        options = ['-c ' num2str(cbest) ' ' wistr1];
        
    case 1
        d = [2:5];r = [-0.5:0.5:0.5];g = 2.^[-4:0];
        for i = 1:length(c)
            for j = 1:length(d)
                for k = 1:length(g)
                    for l = 1:length(r)
                        options = ['-c ' num2str(c(i)) ' -d ' num2str(d(j))...
                            ' -g ' num2str(g(k)) ' -r ' num2str(r(l)) ' ' wistr];
                        acc = FunTrain(ones(size(tr_label)),double(tr_label), sparse(ctr_fea), options);
                        Vpara = [Vpara; c(i), d(j), g(k), r(l), acc];
                    end
                end
            end
        end
        [cbest, dbest, gbest, rbest] = GetMax(Vpara);
        options = ['-c ' num2str(cbest) ' -d ' num2str(dbest)...
            ' -g ' num2str(gbest) ' -r ' num2str(rbest) ' ' wistr1];
        
    case 2
        g = 2.^[-4:0];
        for i = 1:length(c)
            for j = 1:length(g)
                options = ['-c ' num2str(c(i)) ' -g ' num2str(g(j)) wistr];
                acc = FunTrain(ones(size(tr_label)), double(tr_label), sparse(ctr_fea), options);
                Vpara = [Vpara; c(i), 0, g(j), 0, acc];
            end
        end
        [cbest, dbest, gbest, rbest] = GetMax(Vpara);
        options = ['-c ' num2str(cbest) ' -g ' num2str(gbest) wistr1];
        
    case 3
        g = 2.^[-4:0];r = [-0.5:0.5:0.5];
        for i = 1:length(c)
            for j = 1:length(g)
                for k = 1:length(r)
                    options = ['-c ' num2str(c(i)) ' -g ' num2str(g(j))...
                        ' -r ' num2str(r(k)) ' ' wistr];
                    acc = FunTrain(ones(size(tr_label)),double(tr_label), sparse(ctr_fea), options);
                    Vpara = [Vpara; c(i), 0, g(j), r(k), acc];
                end
            end
        end
        [cbest, dbest, gbest, rbest] = GetMax(Vpara);
        options = ['-c ' num2str(cbest) ' -g ' num2str(gbest)...
            ' -r ' num2str(rbest) ' ' wistr1];
end

function [cbest, dbest, gbest, rbest] = GetMax(Vpara)
[id, ord] = max(Vpara(:,end));
cbest = Vpara(ord, 1);
dbest = Vpara(ord, 2);
gbest = Vpara(ord, 3);
rbest = Vpara(ord, 4);