function [m, fobj] = ITERKmean(Margins, A, KmeanLAMDA, m, X, Y, npos, nfac, k,...
    Ymatched, W, SW, Ycons, PsiClock, TempID, TemplateNorm, UpSolver, cpara)
nTemp = length(TempID);
nneg = nTemp - npos;
factor = 1./nfac;
n = size(X,2);
SW = SW / sum(SW);
last = 0;
CodeINN  = INNCode(m', [1:nTemp]', X',  ...
    cpara(1), cpara(2), cpara(3), cpara(4), cpara(6));
m = zeros(size(X, 1), nTemp);
maxiter = 50;
iter = 0;
X1 = bsxfun(@times, X, SW');

YlabelT = int16(bsxfun(@times, ones([n,nTemp]), -npos));
[aind,~] =ind2sub(size(YlabelT), Ymatched);
YlabelT(Ymatched) = nneg(aind);

Ylabel = (cell2mat(Ycons(end)));
Ylabel = (Ylabel - YlabelT) / 2;
index = find(Ylabel > 0);
[row, R2] = ind2sub(size(Ylabel), index);R2 = [R2, row, double(Ylabel(index)) .* A(row)];
index = find(Ylabel < 0);
[row, R1] = ind2sub(size(Ylabel), index);R1 = [R1, row, double(Ylabel(index)) .* A(row)];
nPsi = length(PsiClock);
YesU = 1;
mk = k;
k = 1;
while iter < maxiter && (any(CodeINN(:) ~= last(:)) || YesU)
    m = zeros(size(X, 1), nTemp);fm = 0;
%     if KmeanLAMDA
%         E = sparse(1:n,CodeINN,1,n,nTemp);  % transform CodeINN into indicator matrix
%         m = X1*(E*spdiags(1,0,k,k));fm = SW'*(E*spdiags(1,0,k,k));
%     end
    
    if ~isempty(R1)
        E = sparse(R1(:, 2),R1(:, 1),R1(:, 3),n,nTemp);  % transform CodeINN into indicator matrix
        m = m - X1*(E*spdiags(1,0,k,k));fm = fm - SW'*(E*spdiags(1,0,k,k));
    end
    if ~isempty(R2)
        E = sparse(R2(:, 2),R2(:, 1),R2(:, 3),n,nTemp);   % transform CodeINN into indicator matrix
        m = m - X1*(E*spdiags(1,0,k,k));fm = fm - SW'*(E*spdiags(1,0,k,k));
    end
    
    if UpSolver
        CodeINN2 = CodeINN.*CodeINN;
        for jj = 1:nTemp
            index = setdiff([1:nTemp], jj);
            if KmeanLAMDA
                mm = m(:, jj) + sum(X1 - bsxfun(@times, m(:, index)*(CodeINN(:, index))', SW'), 2);
                fmm = fm(jj) + SW'*CodeINN2(:, jj);
            end
            cvx_begin
               variables Tmp(size(X, 1));
               minimize( fmm * Tmp' * W * Tmp  - 2 * mm' * W * Tmp);
               subject to
               norm(Tmp) < 1; 
            cvx_end
            m(:,jj) = Tmp;
        end
    else
        m = bsxfun(@times, m, 1./fm);
        tindex = find(abs(fm) < 1e-8);
        m(:, tindex) = Inf; 
        if TemplateNorm
            m(:, tindex) = L2normMatrix(m(:, tindex));
        end
    end
% %     tindex = find(abs(fm) < 1e-8);
% %     xx = setdiff([1:nTemp], tindex);
% %     m11 = m(:, xx);m22 = m1(:, xx);
% %     imax = max(imax, max(abs(m11(:) - m22(:))));
% %     
% %     m = mc;
    
    D  = Wdistance(X', m', size(m, 2), n, W);D = -D';
    R2last = R2;
    R1last = R1;
    maxscore = sum(double(cell2mat(Ycons)) .* repmat(D', nPsi, 1), 2) ;
    maxscore = bsxfun(@times, reshape(maxscore, n, nPsi), factor);    
    maxscore = mean(maxscore, 1) + Margins';
    [maxscore, index] = max(maxscore, [], 2);
    
% %      load('SS');
% %      dis = mean(maxsocre1) - maxscore;
% %      imax = max(imax, max(abs(dis(:))))
    
    Ylabel = Ycons{index};
    Ylabel = (Ylabel - YlabelT) / 2;
    index = find(Ylabel > 0);
    [row, R2] = ind2sub(size(Ylabel), index);R2 = [R2, row, double(Ylabel(index)) .* A(row)];
    index = find(Ylabel < 0);
    [row, R1] = ind2sub(size(Ylabel), index);R1 = [R1, row, double(Ylabel(index)) .* A(row)];


    [a,b,c] = unique([R2;R2last], 'rows');
    Overlap = min(min(length(a), size(R2, 1)), size(R2last, 1));
    Overlap1 = max(max(length(a), size(R2, 1)), size(R2last, 1));
    YesU = 1;
    if iter > 0 && (Overlap1 - Overlap) / size(a, 1) < 0.05;
        YesU = 0;
    end
    
    if KmeanLAMDA
        last = CodeINN;
        CodeINN  = INNCode(m', [1:nTemp]', X',  ...
            cpara(1), cpara(2), cpara(3), cpara(4), cpara(6));
%         if mk ~= 1
%             D(Ymatched) = -Inf;
%             [~,CodeINN] = max(D,[],1); % assign samples to the nearest centers
%         end
    end
    
    iter = iter + 1;
end
% Bn = [1:n];
% DT = -D(sub2ind(size(D), label(:), Bn(:)));
% fobj = KmeanLAMDA * (SW' * DT);
