function XLatent = getLatent_Large(datastr, numSign, X, h)
if nargin < 4
    h = ones(size(numSign));
end
for jj = 1:Num
    ffile = [datastr, num2str(jj), '.mat'];
    load(ffile, 'Xtmp')
    XLatent(jj,:) = Xtmp(h(j),:);
end
        
% 
% base = cumsum(numSign);base = [0, base];
% XLatent = cell2mat(X);
% XLatent = XLatent(:,base(1:end-1) + h);
