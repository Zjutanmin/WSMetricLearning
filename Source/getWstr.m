function wstr = getWstr(wi)
wstr = [];
for i = 1:length(wi)
    wstr = [wstr '-w' num2str(i) ' ' num2str(wi(i)) ' '];
end 