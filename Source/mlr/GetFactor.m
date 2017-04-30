function [S, Sn, Sp] = GetFactor(Ypos, Yneg)
S = 0; Sn = 0; Sp = 0;
if ~isempty(Ypos)
    Npos = cell2mat(cellfun(@(x) length(x), Ypos, 'UniformOutput', false));
    Nneg = cell2mat(cellfun(@(x) length(x), Yneg, 'UniformOutput', false));           
    S = (Npos.*Nneg);
    Sn = Nneg;
    Sp = Npos;
end