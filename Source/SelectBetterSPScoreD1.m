function [C, label] = SelectBetterSPScoreD1(Enorm, Traininfo, D, C, Scale, conf_tr_fea, tr_fea,...
    cmethod, SnippetRatio, Ypos, Yrank)
info = [];
SelectMethod = SnippetRatio{3};
GETNORM = 0;
if round(SelectMethod) ~= SelectMethod
   GETNORM = 1;
%    SelectMethod = floor(SelectMethod);
end
label = C(1,:);label = label';
Nrotate = 1;SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
[a,b] = min(D, [], 1);
if ~Traininfo && nnz(b - 1)
    fprintf('Wrong D in SelectBetterSPScoreD\n')
    pause;
end
info_conf_tr_fea = [];
info_tr_fea = [];
info_Yrank = [];
if 
    info_conf_tr_fea = [-inf, max(max(conf_tr_fea(:, 1:2))), min(min(conf_tr_fea(:, 1:2))),...
       max(max(conf_tr_fea(:, 3:end))),  min(min(conf_tr_fea(:, 3:end))),...
        2, size(conf_tr_fea, 2) - 2];
    info_tr_fea = [-inf, max(max(tr_fea)), min(min(tr_fea)), size(tr_fea, 2)]; 
end

conf_tr_fea = x_GetNOMR(conf_tr_fea, GETNORM);
tr_fea = x_GetNOMR(tr_fea, GETNORM);
if exist('Yrank')
    Yrank = x_GetNOMR(Yrank, GETNORM);
    info_Yrank = [-inf, max(max(Yrank)), min(min(Yrank)), size(Yrank, 2)];
end


SelectMethodX = floor(SelectMethod);
if SelectMethodX < 5
    Smothod = mod(SelectMethodX, 2);
    SDIVmothod = ceil(SelectMethodX / 2) - 1;
else  %%%%5 6
    switch SelectMethodX
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
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            if GETNORM
                combine_fea = [conf_tr_fea, info_conf_tr_fea]; 
            else
                combine_fea = [conf_tr_fea];             
            end
            C = [C1, C2, combine_fea];
            return;
        case 8
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [C1, C2];
            return;
        case 9
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            if GETNORM
                combine_fea = [conf_tr_fea, info_conf_tr_fea, tr_fea, info_tr_fea]; 
            else
                combine_fea = [conf_tr_fea, tr_fea];             
            end
            C = [C1, C2, combine_fea];
            return;
            
        case 10
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            if GETNORM
                combine_fea = [conf_tr_fea, info_conf_tr_fea]; 
            else
                combine_fea = [conf_tr_fea];             
            end
            C = [C1, C2, combine_fea];
            
            return;
        case 11
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            C = [C1, C2];
            
            return;
            case 12
            C = [tr_fea(:,1)];
            return;
            case 13
            C = [tr_fea(:,2)];
            return;
            case 14
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 0, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            if GETNORM
                combine_fea = [conf_tr_fea, info_conf_tr_fea, tr_fea, info_tr_fea]; 
            else
                combine_fea = [conf_tr_fea, tr_fea];             
            end
            C = [C1, C2, combine_fea];
            return;

        case 15
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            if GETNORM
                combine_fea = [conf_tr_fea, info_conf_tr_fea, tr_fea, info_tr_fea]; 
            else
                combine_fea = [conf_tr_fea, tr_fea];             
            end
            C = [C1, C2, combine_fea];
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
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            if GETNORM
                combine_fea = [conf_tr_fea, info_conf_tr_fea, tr_fea, info_tr_fea]; 
            else
                combine_fea = [conf_tr_fea, tr_fea];             
            end
            C = [C1, C2, combine_fea];
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
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
            if GETNORM
                combine_fea = [conf_tr_fea, info_conf_tr_fea, tr_Yrank, info_tr_Yrank]; 
            else
                combine_fea = [conf_tr_fea, tr_Yrank];             
            end
            C = [C1, C2, combine_fea];
            return;
            
       case 60
           if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
%             C = [normalizep(C1), normalizep(C2), normalizep(conf_tr_fea)];
           if GETNORM
                combine_fea = [conf_tr_fea, info_conf_tr_fea]; 
            else
                combine_fea = [conf_tr_fea];             
            end
            C = [normalizep(C1), normalizep(C2), combine_fea];
            return;
        case 61 %%test rank  
            if nargin < 10 && ~isempty(Ypos)
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio);
            else
                SnippetRatio{3} = 4; if GETNORM == 1; SnippetRatio{3} = 4.5; end
                C1= SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
                SnippetRatio{3} = 6; if GETNORM == 1; SnippetRatio{3} = 6.5; end
                C2 = SelectBetterSPScoreD(Enorm, Traininfo, D, C, 1, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos);
            end
%             C = [normalizep(C1), normalizep(C2), normalizep(conf_tr_fea), Yrank];
            if GETNORM
                combine_fea = [normalizep(conf_tr_fea), info_conf_tr_fea, Yrank, info_Yrank]; 
            else
                combine_fea = [normalizep(conf_tr_fea), Yrank];             
            end
            C = [normalizep(C1), normalizep(C2), combine_fea];
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

    C1 = ScorePos - reshape(sum(ScoreNeg, 1), size(ScorePos))./ NumNeg';
    C = C1';
    if SDIVmothod
%         C = [x_GetNOMR(ScorePos', GETNORM), x_GetNOMR(C, GETNORM)];
        C = GETINFO(ScorePos', C, GETNORM);
    end
    if Scale
%         C = [x_GetNOMR(ScoreNeg1', GETNORM), x_GetNOMR(C, GETNORM)];
        C = GETINFO(ScoreNeg1', C, GETNORM);
    end
    
else
    distance = WeightedScore(cmethod, ...
        D', SnippetRatio{5}, ...
        SnippetRatio{6}, SnippetRatio{4});
    
    distance = distance(:, 1:SnippetRatio{4});
    C = WbyEntropy(distance, Enorm);
    if SDIVmothod
        C = GETINFO(distance(:,1), C, GETNORM)
    end
    if Scale
        C = GETINFO(distance, C, GETNORM)
    end
end

function C = GETINFO(distance, C, GETNORM)
if GETNORM
[X1, X2, X3, X4] = x_GetNOMR(distance, GETNORM);
[Y1, Y2, Y3, Y4] = x_GetNOMR(C, GETNORM);
C = [X1, Y1, -inf, X2, X3, X4, Y2, Y3, Y4];
end

function [C, MAXC, MINC SIZEC] = x_GetNOMR(C, GETNORM)
if GETNORM & abs((max(C(:)) - min(C(:)))) > 1e-6
    C = (C - min(C(:))) / (max(C(:)) - min(C(:)));
end
MAXC = max(C(:));
MINC = min(C(:));
SIZEC = size(C, 2);


function CN = normalizep(C)
Tsum = sqrt(sum(C.^2, 2));
CN = C ./ repmat(Tsum, [1, size(C,2)]);