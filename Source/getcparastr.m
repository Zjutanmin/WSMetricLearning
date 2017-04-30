function str = getcparastr(cpara, pdefault, PCAMethod)
str = '';
if isempty(cpara)
    return;
end
isdef = 1;
if nargin < 2
    isdef = 0;
    pdefault = 0;
end
if nargin < 3
    PCAMethod = 'PCA';
end

for i = 1:length(cpara)
    if strcmp(PCAMethod, 'SAE') && i > 7
        str = [str getstr(cpara{i}, isdef, pdefault{i}, 0)];
    else
        str = [str getstr(cpara{i}, isdef, pdefault{i}, 1)];
    end
end

function str = getstr(para, isdef, pdefault, isneed)
str = '';
eq = 0;
if isnumeric(para)
%     if strcmp(num2str(pdefault), 'Def') || (isdef && pdefault ~= para)
    str = ['_' num2str(para)];
    if para == pdefault
        eq = 1;
    end
%     end
end
if ischar(para)
%     if strcmp(num2str(pdefault), 'Def') || (isdef && ~strcmp(pdefault, para))
    str = ['_' (para)];
    if strcmp(para, pdefault)
        eq = 1;
    end
    %     end
end
if eq && ~isneed
    str = '_';
end