function [CRe,a,Cscoreb] = TestModel(yy, Clable, Cscore, Snippetmodel, SRKSVM)

Slabel = zeros(1, length(Snippetmodel));
for ii = 1:length(Snippetmodel)
    Slabel(ii) = Snippetmodel{ii}.Class;
end
if SRKSVM
    FunTest = @svmpredict;
else
    FunTest = @predict;
end
a = [];
[aa,bb,cc] = unique(Clable);
CRe = zeros(1, length(yy));
% b = zeros(1, length(yy));
Cscoreb = zeros(1, length(yy));
for i = 1:length(aa)
    idxx = find(cc == i);
    yy_i = yy(idxx); 
    Cscore_i = Cscore(idxx); 
    
    iclass = aa(i);
    tt = Slabel - iclass;
    idt = find(~tt);
    if idt
        if isfield(Snippetmodel{idt}, 'w')
            [CRe(idxx),a,b] = FunTest(yy_i, sparse(Cscore_i), Snippetmodel{idt});
            ids = find(Snippetmodel{idt}.Label == 1);
            if ids == 2
                Cscoreb(idxx) = -b;
            else
                Cscoreb(idxx) = b;
            end
        else
            CRe(idxx) = 1;
            Cscoreb(idxx) = 1;
        end
    else
        CRe(idxx) = 1;
        Cscoreb(idxx) = 1; 
    end 
            
end
% t = 1;

    