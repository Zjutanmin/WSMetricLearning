function [C, lable] = SelectBetterSP(W, X, Y, cmethod, SnippetRatio, Diagonal)
%%%cselect, knnselect, svote, GlobarNorm)
     [d,n,m] = size(X);
     if m > 1
        MKL = 1;
    else
        MKL = 0;
    end
    global INIT;
    if ~MKL
        INIT        = @initializeFull;
    else
        INIT        = @initializeFullMKL;
    end
    if Diagonal > 0
        if ~MKL
            INIT        = @initializeDiag;
        else
            INIT        = @initializeDiagMKL;
        end
    end

    
    
     batchsize   = n;
     SAMPLES     = 1:n;
     if isa(Y, 'double')
        Ypos        = [];
        Yneg        = [];
        ClassScores = synthesizeRelevance(Y);
    elseif isa(Y, 'cell') && size(Y,1) == batchsize && size(Y,2) == 2
        dbprint(1, 'Using supplied Ypos/Yneg');
        Ypos        = Y(:,1);
        Yneg        = Y(:,2);

        % Compute the valid samples
        SAMPLES     = find( ~(cellfun(@isempty, Y(:,1)) | cellfun(@isempty, Y(:,2))));
    elseif isa(Y, 'cell') && size(Y,1) == batchsize && size(Y,2) == 1
        dbprint(1, 'Using supplied Ypos/synthesized Yneg');
        Ypos        = Y(:,1);
        Yneg        = [];
        SAMPLES     = find( ~(cellfun(@isempty, Y(:,1))));
    else
        error('MLR:LABELS', 'Incorrect format for Y.');
     end
    if isempty(W)
         W           = INIT(X);
    end
    Template = setdiff([1:length(X)], SAMPLES);
    
    [C, lable] = BetterSP(X, W, Ypos, Yneg, cmethod, Template, SAMPLES, SnippetRatio);