function [ADFea, findex, normmerge, WTAindex] = sumcell(dFea, WTAfea, normme)
ADFea = 0;
findex = cell(1, length(dFea));
if nargin < 2
    normme  = 0;
end
t = 0;
WTAindex = [];
normmerge = 0;
for i = 1:length(dFea)
    sADFea = ADFea;
    for j = 1:length(dFea{i})
        t = t+1;
        ADFea = dFea{i}{j} + ADFea;
        currindex = [sADFea + 1, ADFea];
        findex{i}{j} = currindex;
        tcurrindex = [currindex(1): currindex(2)];
        WTAindex = [WTAindex, tcurrindex(end - WTAfea{i}{j} +1: end)];
    end
end
if nnz(normme) && t>1
    normmerge = true;
end