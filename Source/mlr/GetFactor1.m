function S = GetFactor1(X, Ypos, Yneg, batchSize, SAMPLES, ClassScores)
[d,n,m] = size(X);
S       = zeros(n, 1);
if isempty(ClassScores)
    NN  = zeros(batchSize, 1);
    for i = 1:batchSize
        if i <= length(SAMPLES)
            j = SAMPLES(i);
            if isempty(Ypos{j})
                continue;
            end
            if isempty(Yneg)
                Ynegative = setdiff((1:n)', [j ; Ypos{j}]);
            else
                Ynegative = setdiff(Yneg{j},Ypos{j}) ;
            end
            NN(i)         = length(Ypos{j})*length(Ynegative);
        end
    end
    S(SAMPLES)    = NN;
else
    for j = 1:length(ClassScores.classes)
        c       = ClassScores.classes(j);
        points  = find(ClassScores.Y == c);
        Yneg    = find(ClassScores.Yneg{j});
        yp      = ClassScores.Ypos{j};
        S(points) = length(yp)*length(Yneg);
    end
end