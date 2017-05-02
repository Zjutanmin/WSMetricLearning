function [X, fobj, XDic] = mlr_Temp3(NNT, nfac, Nneg, Npos, Margins, A, KmeanLAMDA, MeanK, X,XX, XDic, Y, SampleW, templateUP, ...
    Ymatched, W, SAMPLES, FeatUp, TemplateNorm, UpSolver, innc, INNCpara, innerfea, cparaINNC, ITERkmean) 
fobj = 0;
if ~templateUP
    return;
end
global Ycons Yloss PsiClock PsiR C;
TempID = setdiff([1:size(X, 2)], SAMPLES);
TempUp = 1;
Feat_GD = 0;
if length(INNCpara) > 10 && INNCpara{11}
    if mod(NNT, INNCpara{11})
        TempUp = 0;
    end
end
switch innc
    case 0
        if TempUp
            [X(:, TempID), Feat_GD, fobj] = (mykmeans(Margins, C, KmeanLAMDA, X(:, TempID), X(:, SAMPLES), ...
            Y(SAMPLES), Npos, nfac, MeanK, Ymatched, W, SampleW(:), Ycons, Yloss, ...
            PsiClock, TempID, TemplateNorm, UpSolver, INNCpara, innerfea, cparaINNC, ITERkmean));
        end
    case 1
        if TempUp
            [X(:, TempID), Feat_GD, fobj] = (mykmeans(Margins, C, KmeanLAMDA, X(:, TempID), X(:, SAMPLES), ...
            Y(SAMPLES), Npos, nfac, MeanK, Ymatched, W, SampleW(:), Ycons, Yloss, ...
            PsiClock, TempID, TemplateNorm, UpSolver, INNCpara, innerfea, cparaINNC, ITERkmean));
        end
    case 2
        
        if TempUp
        [X, fobj, XDic] = (DLITER(Margins, C, KmeanLAMDA, X, ...
            XX', XDic, Y(TempID), Npos, nfac, MeanK, Ymatched, W, [ones(length(TempID), 1);SampleW(:)], Ycons, ...
            Yloss, PsiClock, TempID, TemplateNorm, UpSolver, INNCpara, innerfea));    
        end
end
if TempUp
    if FeatUp
        PsiR = ComputePsiR(SAMPLES, X, Ycons, Feat_GD, nfac, Npos, Nneg, Ymatched, innerfea);    
    end
end

% function [m, fobj] = mykmeans(Margins, A, KmeanLAMDA, mc, X, Y, npos, nfac, k,...
%     Ymatched, W, SW, Ycons, PsiClock, TempID, TemplateNorm, UpSolver)
% nTemp = length(TempID);
% % npos = size(Y, 2);
% nneg = nTemp - npos;
% factor = 1./nfac;
% n = size(X,2);
% SW = SW / sum(SW);
% last = 0;
% % % Map = [0:k:k*(length(unique(Y)) - 1)];
% % % label = ceil(k*rand(1,n)) + Map(Y);  % random initialization
% label = ceil(npos'.*rand(1,n));
% label = cell2mat(cellfun(@(x,label) x(label), Y', mat2cell(label, 1, ones(1, length(label))),...
%     'UniformOutput', false));
% 
% % label = Y(sub2ind(size(Y), [1:n], label));
% 
% m = zeros(size(X, 1), nTemp);
% maxiter = 50;
% iter = 0;
% X1 = bsxfun(@times, X, SW');
% 
% YlabelT = int16(bsxfun(@times, ones([n,nTemp]), -npos));
% 
% [aind,~] =ind2sub(size(YlabelT), Ymatched);
% YlabelT(Ymatched) = nneg(aind);
% 
% Ylabel = (cell2mat(Ycons(end)));
% Ylabel = (Ylabel - YlabelT) / 2;
% index = find(Ylabel > 0);
% [row, R2] = ind2sub(size(Ylabel), index);R2 = [R2, row, double(Ylabel(index)) .* A(row)];
% index = find(Ylabel < 0);
% [row, R1] = ind2sub(size(Ylabel), index);R1 = [R1, row, double(Ylabel(index)) .* A(row)];
% nPsi = length(PsiClock);
% YesU = 1;
% mk = k;
% k = 1;
% % imax = 0;
% while iter < maxiter && (any(label(:) ~= last(:)) || YesU)
% %     [u,~,label] = unique(label);   % remove empty clusters
% %     for jj = 1:nTemp
% %         idx = find(label == jj);
% %         fac = sum(SW(idx));
% %         Tj = sum(X1(:, idx), 2);
% %         if ~isempty(R1)
% %             idx = find(R1(:,1) == jj);
% %             Tj = Tj - sum(bsxfun(@times, X1(:, R1(idx,2)), (R1(idx,3))'), 2);
% %             fac = fac - (SW(R1(idx,2)))'*R1(idx,3);
% %         end
% %         if ~isempty(R2)
% %             idx = find(R2(:,1) == jj);
% %             Tj = Tj - sum(bsxfun(@times, X1(:, R2(idx,2)), (R2(idx,3))'), 2);
% %             fac = fac - (SW(R2(idx,2)))'*R2(idx,3);
% %         end
% %         m(:, jj) = Tj / fac;
% %     end
% %     m1 = m;
%     
%     m = zeros(size(X, 1), nTemp);fm = 0;
%     if KmeanLAMDA
%         E = sparse(1:n,label,1,n,nTemp);  % transform label into indicator matrix
%         m = X1*(E*spdiags(1,0,k,k));fm = SW'*(E*spdiags(1,0,k,k));
%     end
%     
%     if ~isempty(R1)
%         E = sparse(R1(:, 2),R1(:, 1),R1(:, 3),n,nTemp);  % transform label into indicator matrix
%         m = m - X1*(E*spdiags(1,0,k,k));fm = fm - SW'*(E*spdiags(1,0,k,k));
%     end
%     if ~isempty(R2)
%         E = sparse(R2(:, 2),R2(:, 1),R2(:, 3),n,nTemp);   % transform label into indicator matrix
%         m = m - X1*(E*spdiags(1,0,k,k));fm = fm - SW'*(E*spdiags(1,0,k,k));
%     end
%     
%     if UpSolver
%         for jj = 1:nTemp
%             try
%             cvx_begin
%                variables Tmp(size(X, 1));
%                minimize( fm(jj) * Tmp' * W * Tmp  - 2*m(:,jj)' * W * Tmp);
%                subject to
%                norm(Tmp) < 1; 
%             cvx_end
%             catch
%                 t = 1;
%             end
%             m(:,jj) = Tmp;
%         end
%     else
%         m = bsxfun(@times, m, 1./fm);
%         tindex = find(abs(fm) < 1e-8);
%         m(:, tindex) = Inf; 
%         if TemplateNorm
%             m(:, tindex) = L2normMatrix(m(:, tindex));
%         end
%     end
% % %     tindex = find(abs(fm) < 1e-8);
% % %     xx = setdiff([1:nTemp], tindex);
% % %     m11 = m(:, xx);m22 = m1(:, xx);
% % %     imax = max(imax, max(abs(m11(:) - m22(:))));
% % %     
% % %     m = mc;
%     
%     D  = Wdistance(X', m', size(m, 2), n, W);D = -D';
%     R2last = R2;
%     R1last = R1;
%     maxscore = sum(double(cell2mat(Ycons)) .* repmat(D', nPsi, 1), 2) ;
%     maxscore = bsxfun(@times, reshape(maxscore, n, nPsi), factor);    
%     maxscore = mean(maxscore, 1) + Margins';
%     [maxscore, index] = max(maxscore, [], 2);
%     
% % %      load('SS');
% % %      dis = mean(maxsocre1) - maxscore;
% % %      imax = max(imax, max(abs(dis(:))))
%     
%     Ylabel = Ycons{index};
%     Ylabel = (Ylabel - YlabelT) / 2;
%     index = find(Ylabel > 0);
%     [row, R2] = ind2sub(size(Ylabel), index);R2 = [R2, row, double(Ylabel(index)) .* A(row)];
%     index = find(Ylabel < 0);
%     [row, R1] = ind2sub(size(Ylabel), index);R1 = [R1, row, double(Ylabel(index)) .* A(row)];
% 
% 
%     [a,b,c] = unique([R2;R2last], 'rows');
%     Overlap = min(min(length(a), size(R2, 1)), size(R2last, 1));
%     Overlap1 = max(max(length(a), size(R2, 1)), size(R2last, 1));
%     YesU = 1;
%     if iter > 0 && (Overlap1 - Overlap) / size(a, 1) < 0.05;
%         YesU = 0;
%     end
%     
%     if KmeanLAMDA
%         last = label;
%         if mk ~= 1
%             D(Ymatched) = -Inf;
%             [~,label] = max(D,[],1); % assign samples to the nearest centers
%         end
%     end
%     
%     iter = iter + 1;
% end
% Bn = [1:n];
% DT = -D(sub2ind(size(D), label(:), Bn(:)));
% fobj = KmeanLAMDA * (SW' * DT);
% % imax
% % t = 1;


function PsiR = ComputePsiR(SAMPLES, X, Ycons, Feat_GD, nfac, Npos, Nneg, Index, innerfea)
global CPGRADIENT;
batchSize = length(SAMPLES);
n = size(X,2);
% Index = sub2ind([batchSize,length(TempID)], repmat([1:batchSize]', size(Ypos, 2), 1), Ypos(:));
ss =1./nfac;
dIndex  = sub2ind([n n], 1:n, 1:n);
PsiR = cell(length(Ycons), 1);
[aind,~] =ind2sub(size(Ycons{1}), Index);
% % for i = 1:length(Ycons)
% %     S       = zeros(n);
% %     TS = getTS(double(Ycons{i}),ss, Npos, Nneg, aind, Index, batchSize);
% %     if ~innerfea
% %         S(SAMPLES,:)    = TS;
% %         S(:,SAMPLES)    = S(:,SAMPLES) + TS';
% %         S(dIndex)       = S(dIndex) - sum(TS, 1);
% %     else
% %         S(SAMPLES,:)    = TS;
% %     end
% %     PsiR{i}   = CPGRADIENT(X, S, batchSize)+Feat_GD;  
% % end
for i = 1:length(Ycons)
    S       = zeros(n);
    TS = getTS(double(Ycons{i}),ss, Npos, Nneg, aind, Index, batchSize);
    if ~innerfea
        S(SAMPLES,:)    = TS;
        S(:,SAMPLES)    = S(:,SAMPLES) + TS';
        S(dIndex)       = S(dIndex) - sum(TS, 1);
    
    else
        S(SAMPLES,:)    = TS;
    end
    
    PsiR{i}   = CPGRADIENT(X, S, batchSize, n - batchSize)+Feat_GD;
end

function TS = getTS(Ycons, ss, Npos, Nneg, aind, index, batchSize)
TS = bsxfun(@times, bsxfun(@minus, -Npos, Ycons), ss);
TS(index) = (Nneg(aind) - Ycons(index)) .* ss(aind);
TS(:, end+1:end+batchSize) = 0;