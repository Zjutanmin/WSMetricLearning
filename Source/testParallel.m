function testParallel

%???

% matlabpool local 2

tic
total=10^5;
for (i=1:total)
    ss(i)=inSum;
end
plot(ss);
toc

% matlabpool close

function [s]=inSum
x=abs(round(normrnd(50,40,1,1000)));
s=sum(x);