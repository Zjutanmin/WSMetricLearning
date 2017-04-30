function Result = Whist(Tresult, Wresult, votescore, nclass, ave)
if nargin < 5
    ave = 0;
end

Result = zeros([1,nclass]);
[UTresult, b, c] = unique(Tresult);
for jj = 1:length(UTresult)
    idx = (find(c == jj));
    Result(UTresult(jj)) = sum(Wresult(idx).*votescore(idx));
    if ave
        Result(UTresult(jj)) = Result(UTresult(jj)) / length(idx);
    end
end