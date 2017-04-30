function [s_Metric, s_KNNlatent] = getmetricTest(Metric, CasTest, setting, ntrain)
s_Metric = Metric;
s_KNNlatent = setting.KNNlatent;
if CasTest == 2
    s_Metric = Metric{2};
    s_KNNlatent = ntrain;
end
if CasTest == 0
    s_Metric{1} = [];
    s_Metric{3} = setting.KNNlatent;
end

if ~setting.isKNNlatent
    if iscell(s_Metric)
        s_Metric = s_Metric{2};
        s_KNNlatent = ntrain;
    end
end

if ~s_KNNlatent
    s_KNNlatent = 1;
end