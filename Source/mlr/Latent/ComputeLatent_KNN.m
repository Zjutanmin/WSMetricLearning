function Yneg = ComputeLatent_KNN(KNNlatent, SnippetRatio, X, hLatent, numSign, cellbase, W, Ypos, Yneg, ...
    batchSize, Template, Nrotate, SAMPLES, ClassScores)        
    if SnippetRatio{1} ~= 1
        L = zeros(size(W));
    for i = 1:size(W,3)
        [vecs,vals] = eig(0.5 * (W(:,:,i) + W(:,:,i)'));
        L(:,:,i) = real(abs(vals)).^0.5 * vecs';
    end
    n = length(X);
    Xtemplate = cell2mat(X(Template));
    XTest = (X(setdiff(1:n, Template)));
    clear 'X'

    nbase = length(Template) / Nrotate;
    ntrain = length(Template);
    plus = zeros(Nrotate, 1);
    for jj = 1:Nrotate 
        plus(jj) = (jj - 1)*nbase;
    end
    Tnum = cumsum(numSign(setdiff((1:n)', Template)));
    rangeS = [0,Tnum(1:end-1)];
    rangeE = Tnum(1:end);
    
    if isempty(ClassScores)
        Xtest = (cell2mat(XTest));
        
        D1 = setDistanceFullMKL_f([Xtemplate Xtest], L, ...
            ntrain + (1:size(Xtest, 2)), 1:ntrain, 0);   
        
        for j = SAMPLES'
            
            Ynegative = setdiff(Yneg{j},Ypos{j});
            D    = D1(:, rangeS(j-ntrain)+1:rangeE(j-ntrain));
            [YposT, YnegativeT] = MultiY(Ypos{j}, Ynegative, nbase, Nrotate);
            [ScoreNeg, idx] = sort(D, 1);
            negtmp         = (idx(1:KNNlatent,:))';
            
            
                xx = Whist(negtmp(:), ones(1, numel(negtmp)), ones(1, numel(negtmp)), nbase);
                [xx, ord] = sort(xx, 'descend');
                uTresult = -1 * ones(1, KNNlatent);
                if length(ord) < KNNlatent
                    uTresult(1:length(ord)) = ord(1:end);
                else
                    uTresult = ord(1:KNNlatent);
                end
                Yneg{j} = uTresult;
            

        end
    end
    end
end