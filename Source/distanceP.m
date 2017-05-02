function Gamma = distanceP(n, C, D,data,lamda,SCode)
if ~isempty(SCode)
    cvx_begin
       variables Gamma(n, size(data,2)) xi;
         minimize(norm(data - D*Gamma, 'fro') +  ...
             norm(Gamma .* repmat(lamda, n, 1), 1) + C*xi);
       subject to
         SCode.P1 * vec(Gamma) >= SCode.Q1 - n/4 * xi;
         xi >= 0;
    cvx_end
else
    cvx_begin
       variables Gamma(n, size(data,2)) xi;
         minimize(norm(data - D*Gamma, 'fro') + lamda * norm(Gamma, 1));
    cvx_end
end