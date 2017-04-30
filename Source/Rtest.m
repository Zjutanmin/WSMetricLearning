ratio = [0.1250    0.2500    0.3750    0.5000    0.6250    0.7500];
for i = 1:length(ratio)
    if i == 2
    load(['TrainInfo\image_Sign_NewT7-20-4-T2D_1_RoundInfo3_1.mat'], 'Trainset', 'Testset');
    else
    load(['TrainInfo\image_Sign_NewT7-20-4-T2D_1_RoundInfo3_1R_' num2str(ratio(i)) '.mat'], 'Trainset', 'Testset');
    end
    [length(Trainset) / (length(Trainset)+length(Testset)), length(Testset) / (length(Trainset)+length(Testset))]
end
for i = 1:length(ratio)
    if i == 2
    load(['TrainInfo\image_Sign_NewT7-20-4-T2D_1_RoundInfo3_2.mat'], 'Trainset', 'Testset');
    else
    load(['TrainInfo\image_Sign_NewT7-20-4-T2D_1_RoundInfo3_2R_' num2str(ratio(i)) '.mat'], 'Trainset', 'Testset');
    end
    [length(Trainset) / (length(Trainset)+length(Testset)), length(Testset) / (length(Trainset)+length(Testset))]
end
