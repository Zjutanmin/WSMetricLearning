function F = rmlr_compute(W, C, K, Delta)

global REG FEASIBLE LOSS;

    %%%
    % Initialize the gradient directions for each constraint
    %
    global PsiR;
numConstraints = length(PsiR);
    W = FEASIBLE(W);

    Xi = 0;
    for R = numConstraints:-1:1
        Xi  = max(Xi, LOSS(W, PsiR{R}, Delta(R), 0));
    end
    F     = C * Xi + REG(W, K, 0);
end