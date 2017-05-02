function mflipindex = mulfilpindex(flipindex)
mflipindex = [];
for i = 1:length(flipindex)
    mflipindex =[mflipindex,flipindex{i}+length(mflipindex)];
end
mflipindex(end+1) = length(mflipindex) + 1;