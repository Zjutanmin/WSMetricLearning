function [C, label, RINDEX, Cmaxmin] = SelectBetterSPScore(Enorm, Traininfo, nclass, D, C, Scale, conf_tr_fea, tr_fea,...
    cmethod, SnippetRatio, Ypos, Yrank, RINDEX, Cmaxmin)
if Traininfo
    D = TransFormD(D, C, nclass);
end

[C, label, RINDEX1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, Scale, conf_tr_fea, tr_fea,...
    cmethod, SnippetRatio, Ypos, Yrank);
if floor(SnippetRatio{3}) ~= SnippetRatio{3}
    if isempty(RINDEX)
    RINDEX = cumsum(RINDEX1);
    RINDEX = [0, RINDEX];
    Cmaxmin = [];
    for i = 1:length(RINDEX) - 1
        Imax = max(max(C(:, RINDEX(i)+1:RINDEX(i+1))));
        Imin = min(min(C(:, RINDEX(i)+1:RINDEX(i+1))));
        Cmaxmin = [Cmaxmin, Imax, Imin];
    end
    end
    for i = 1:length(RINDEX) - 1
        Imax = Cmaxmin(2*i-1);
        Imin = Cmaxmin(2*i);
        if abs(Imax - Imin) > 1e-6
            C(:, RINDEX(i)+1:RINDEX(i+1)) = (C(:,...
                RINDEX(i)+1:RINDEX(i+1)) - Imin) / (Imax - Imin);
        end
    end
end

function D1 = TransFormD(D, C, nclass)
D1 = zeros(nclass, size(C, 2));
for i = 1:size(C, 2)
    Cid = unique(C(:,i), 'stable');
    Result = Whist(C(:,i), D(:, i), ones(length(D(:, i)), 1), nclass, 1);
    D1(:, i) = Result(Cid);
end

% 
% function Result = Whist(Tresult, Wresult, votescore, nclass)
% Result = zeros([1,nclass]);
% [UTresult, b, c] = unique(Tresult);
% for jj = 1:length(UTresult)
%     idx = (find(c == jj));
%     Result(UTresult(jj)) = sum(Wresult(idx).*votescore(idx));
% end