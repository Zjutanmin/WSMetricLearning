function D  = Wdistance(X, B, nbase, nframe, W, innerfea)
% D = zeros(nframe, nbase);
% if size(W, 2) == 1
%     for i = 1:nframe
%         dis = repmat(X(i,:), nbase, 1) - B;
%         D(i,:) = sum(dis .* dis .* repmat(W', nbase, 1), 2);       
%     end
% else
%     for i = 1:nframe
%         dis = repmat(X(i,:), nbase, 1) - B;
%         T1 = dis * W;
%         D(i,:) = sum(T1 .* dis, 2);
%     end
% end


[vecs,vals] = eig(0.5 * (W + W'));
L = real(abs(vals)).^0.5 * vecs'; 
D  = setDistanceFullMKL_f(([X; B])', L, nframe + (1:nbase), 1:nframe, innerfea);
