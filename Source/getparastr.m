function str = getparastr(cpara)
if isempty(cpara)
    str = '';
    return;
end
str = ['-' num2str(cpara(1))];
for i = 2:length(cpara)
    str = [str '-' num2str(cpara(i))];
end