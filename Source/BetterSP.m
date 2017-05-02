function [C, label] = BetterSP(X, W, Ypos, Yneg, ...
    cmethod, Template,  SAMPLES, SnippetRatio)
   Smothod = mod(SnippetRatio{3}, 2);
   SDIVmothod = ceil((SnippetRatio{3} / 2) - 1);         
    L = zeros(size(W));
    for i = 1:size(W,3)
        [vecs,vals] = eig(0.5 * (W(:,:,i) + W(:,:,i)'));
        L(:,:,i) = real(abs(vals)).^0.5 * vecs';
    end
    tord = [];
    [d,n,m] = size(X);

    Xtest = X(:, setdiff(1:n, Template));
    Xtemplate  = X(:, Template);
    ntrain = length(Template);
    Nrotate = 1;
    nbase = length(Template);
        
        D1 = setDistanceFullMKL_f([Xtemplate Xtest], L, ...
            ntrain + (1:size(Xtest, 2)), 1:ntrain);  
        C = zeros(length(SAMPLES),1);
        label = zeros(length(SAMPLES),1);
        
        for j = SAMPLES'
            D    = D1(:, j-ntrain);
            ord = [Yneg{j},Ypos{j}];
            [DD, idx] = min(D(ord));
            label(j-ntrain) = ord(idx(1));
        end
        
        if Smothod == 1
            for j = SAMPLES'
            
            Ynegative = setdiff(Yneg{j},Ypos{j});
            D    = D1(:, j-ntrain);
            
%             ord = [Yneg{j},Ypos{j}];
%             [DD, idx] = min(D(ord));label(j-ntrain) = ord(idx(1));
            [YposT, YnegativeT] = MultiY(Ypos{j}, Ynegative, nbase, Nrotate);
                
            ScorePos        = - D(YposT,:);
            ScoreNeg        = - D(YnegativeT,:);
            
            
            ScoreNeg = reshape(ScoreNeg, [size(ScoreNeg,1) / Nrotate, Nrotate, size(ScoreNeg, 2)]);
            C1 = ScorePos - reshape(sum(ScoreNeg, 1) / size(ScoreNeg, 1), size(ScorePos));                
            C(j-ntrain,1) = C1;
            
            if SDIVmothod
                C(j-ntrain,2) = ScorePos;
            end
            end
            
        else
            distance = WeightedScore(cmethod, ...
                D1', SnippetRatio{4}, ...
                SnippetRatio{5}, SnippetRatio{6});
            distance = sort(distance,2);
            distance = distance(:,end-SnippetRatio{6}+1:end);
            C = WbyEntropy(distance);
            if SDIVmothod
                C = [distance(:,end), C];
            end
        end
       
end