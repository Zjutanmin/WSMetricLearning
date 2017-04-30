function SampleWT = gettrainW(SampleW, weightNorm, isboost)
SampleWT = SampleW;
if nargin < 3
    isboost = 0;
end
if weightNorm
    SampleWT = SampleW ./ sum(SampleW);
    SampleWT = SampleWT * length(SampleWT);
end