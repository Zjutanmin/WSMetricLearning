function [C, label, RINDEX] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, Scale, conf_tr_fea, tr_fea,...
    cmethod, SnippetRatio, Ypos, Yrank)
SnippetRatio{3} = floor(SnippetRatio{3});
SelectMethod = SnippetRatio{3};
label = C(1,:);label = label';
Nrotate = 1;
[a,b] = min(D, [], 1);
if ~Traininfo && nnz(b - 1)
    fprintf('Wrong D in SelectBetterSPScoreD\n')
    pause;
end
RINDEX = [];
if SelectMethod < 5
    Smothod = mod(SelectMethod, 2);
    SDIVmothod = ceil(SelectMethod / 2) - 1;
else  %%%%5 6
    switch SelectMethod
        case 5
            Smothod = 1;
            SDIVmothod = 0;
            Ypos = (C(1,:))';
        case 6
            Smothod = 1;
            SDIVmothod = 1;
            Ypos = (C(1,:))';
        case 7
            if nargin < 9 && ~isempty(Ypos)
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [C1, C2, conf_tr_fea];RINDEX = [Rindex1, Rindex2, size(conf_tr_fea, 2)];
            return;
        case 8
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [C1, C2];RINDEX = [Rindex1, Rindex2];
            return;
        case 9
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [C1, C2, conf_tr_fea, tr_fea];RINDEX = [Rindex1, Rindex2, size(conf_tr_fea, 2), size(tr_fea, 2)];
            return;
            
        case 10
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [C1, C2, conf_tr_fea];RINDEX = [Rindex1, Rindex2, size(conf_tr_fea, 2)];
            return;
        case 11
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [C1, C2];RINDEX = [Rindex1, Rindex2];
            return;
            case 12
            C = [tr_fea(:,1)];
            return;
            case 13
            C = [tr_fea(:,2)];
            return;
            case 14
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [C1, C2, conf_tr_fea, tr_fea];RINDEX = [Rindex1, Rindex2, size(conf_tr_fea, 2), size(tr_fea, 2)];
            return;

        case 15
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [C1, C2, conf_tr_fea, tr_fea];RINDEX = [Rindex1, Rindex2, size(conf_tr_fea, 2), size(tr_fea, 2)];
            return;
        case 16
            C = [tr_fea(:,2) - tr_fea(:,1)];
            return;
        case 17
            nn = size(tr_fea, 2)/2;
            C = [min(tr_fea(:,nn+1:end), [], 2) - ...
                max(tr_fea(:,1:nn), [], 2)];
            return;
        case 18
            C = tr_fea;
            return;
        case 19
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [C1, C2, conf_tr_fea, tr_fea];RINDEX = [Rindex1, Rindex2, size(conf_tr_fea, 2), size(tr_fea, 2)];
            return;
        case 20
            nn = size(tr_fea, 2)/2;
            C = [mean(tr_fea(:,nn+1:end), 2) - ...
                mean(tr_fea(:,1:nn), 2)];
            return;
        case 21
            nn = size(tr_fea, 2)/2;
            C = [min(tr_fea(:,nn+1:end), [], 2) - ...
                max(tr_fea(:,1:nn), [], 2)];
            return;
        case 22
            nn = size(tr_fea, 2)/2;
            C = [mean(tr_fea(:,nn+1:end), 2) - ...
                mean(tr_fea(:,1:nn), 2)];
            return;
        case 23
            nn = size(tr_fea, 2)/2;
            C = [min(tr_fea(:,nn+1:end), [], 2) - ...
                max(tr_fea(:,1:nn), [], 2)];
            return;
        case 24
            nn = size(tr_fea, 2)/2;
            C = [mean(tr_fea(:,nn+1:end), 2) - ...
                mean(tr_fea(:,1:nn), 2)];
            return;
        case 25
            nn = size(tr_fea, 2)/2;
            C = [min(tr_fea(:,nn+1:end), [], 2) - ...
                max(tr_fea(:,1:nn), [], 2)];
            return;    
        case 30
            nn = size(tr_fea, 2)/2;
            C = [mean(tr_fea(:,nn+1:end), 2) - ...
                mean(tr_fea(:,1:nn), 2)];
            return;
        case 31
            nn = size(tr_fea, 2)/2;
            C = [mean(tr_fea(:,nn+1:end), 2) - ...
                mean(tr_fea(:,1:nn), 2)];
            return;
        case 32
            nn = size(tr_fea, 2)/2;
            C = [mean(tr_fea(:,nn+1:end), 2) - ...
                mean(tr_fea(:,1:nn), 2)];
            return;
        case 33
            nn = size(tr_fea, 2)/2;
            C = [mean(tr_fea(:,nn+1:end), 2) - ...
                mean(tr_fea(:,1:nn), 2)];
            return;
        case 34
            nn = size(tr_fea, 2)/2;
            C = [mean(tr_fea(:,nn+1:end), 2) - ...
                mean(tr_fea(:,1:nn), 2)];
            return;
        case 35
            nn = size(tr_fea, 2)/2;
            C = [mean(tr_fea(:,nn+1:end), 2) - ...
                mean(tr_fea(:,1:nn), 2)];
            return;
        case 40 %%latent rank
            C = Yrank;
            return;
        case 41 %%test rank
            C = Yrank;
            return;
        case 50 %%test rank
            C = Yrank;
            return;
            
        case 51 %%test rank  
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [C1, C2, conf_tr_fea, Yrank];RINDEX = [Rindex1, Rindex2, size(conf_tr_fea, 2), size(Yrank, 2)];
            return;
            
       case 60
           if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [normalizep(C1), normalizep(C2), normalizep(conf_tr_fea)];RINDEX = [Rindex1, Rindex2, size(conf_tr_fea, 2)];
            return;
        case 61 %%test rank  
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4;
                [C1,~,  Rindex1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6;
                [C2,~,  Rindex2] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [normalizep(C1), normalizep(C2), normalizep(conf_tr_fea), Yrank];RINDEX = [Rindex1, Rindex2, size(conf_tr_fea, 2), size(Yrank, 2)];
            return;
            
    end
end
if Scale
    SDIVmothod = 0;
end

if Smothod == 1
    NumNeg = zeros(size(D,2),1);
    NumNeg(:) = SnippetRatio{4} - 1;

    if nargin < 8 && ~exist('Ypos')
        Ypos = ones(size(D,2),1);
        subind          = sub2ind(size(D), Ypos', [1:length(Ypos)]);
    else
        dis = C(1:SnippetRatio{4},:) - repmat(Ypos', [SnippetRatio{4},1]);
        insize = 1 - sum(~dis, 1);
        NumNeg = NumNeg+insize';
        dis = C - repmat(Ypos', [size(C,1),1]);
        subind          = find(~dis);subind = subind';
    end
    
    
    ScorePos        = - D(subind);
    ScoreNeg        = - D(1:SnippetRatio{4},:);ScoreNeg1 = ScoreNeg;
    
    
    ScoreNeg = reshape(ScoreNeg, [size(ScoreNeg,1) / Nrotate, Nrotate, size(ScoreNeg, 2)]);

    C1 = ScorePos - reshape(sum(ScoreNeg, 1, 2), size(ScorePos))./ NumNeg';
    C = C1';
    if SDIVmothod
        RINDEX = [size(ScorePos', 2), size(C, 2)];
        C = [ScorePos', C];
        
    end
    if Scale
        RINDEX = [size(ScoreNeg1', 2), size(C, 2)];
        C = [ScoreNeg1', C];
        
    end
    
else
    distance = WeightedScore(cmethod, ...
        D', SnippetRatio{5}, ...
        SnippetRatio{6}, SnippetRatio{4});
    
    distance = distance(:, 1:SnippetRatio{4});
    C = WbyEntropy(distance, Enorm);
    if SDIVmothod
        RINDEX = [size(distance(:, 2), 2), size(C, 2)];
        C = [distance(:,1), C];
        
    end
    if Scale
        RINDEX = [size(distance, 2), size(C, 2)];
        C = [distance, C];
        
    end
    
end


function CN = normalizep(C)
Tsum = sqrt(sum(C.^2, 2));
CN = C ./ repmat(Tsum, [1, size(C,2)]);