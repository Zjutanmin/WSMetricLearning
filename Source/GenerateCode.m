function Code = GenerateCode(fea, WTAperm, N, K)

%%%test

% t1 = fea(WTAperm);
% t2 = zeros(N,K);
% 
% fea1 = fea';
% for tt = 1:N
%     t2(tt,:) = fea1(WTAperm(tt,:));
% end
% nnz(t1 - t2)

%%%end of test
X = fea(WTAperm);
[max_val, C] = max(X, [], 2);
Code = uint8(C - 1);

bit = log(K) / log(2);
if bit > 8
    Code = double(C - 1);
end