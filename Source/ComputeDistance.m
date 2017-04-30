function Cdistance = ComputeDistance(dataX, nbase, nframe)
B = dataX(1:nbase,:);
X = dataX(nbase+1:end,:);
if size(dataX, 1) - nbase ~= nframe
    fprintf('Data Error\n');
    pause;
end
XX = sum(X.*X, 2);
BB = sum(B.*B, 2);
Cdistance  = repmat(XX, 1, nbase)-2*X*B'+repmat(BB', nframe, 1);
Cdistance = (Cdistance - min(Cdistance(:))) / (max(Cdistance(:)) - min(Cdistance(:)));
        