% vilisizeMODEL('latent\Sign_New2\DOG_2_hog__Latent1_R1_0.5_MultiSVM-1-1-0_MV3_0.5', 'Model-1_1_1.mat')
% vilisizeMODEL('latent\Sign_New2\DOG_2_hog__Latent1_R1_0.5_MultiSVM-1-1-1_MV3_0.5', 'Model-1_1_1.mat')
% vilisizeMODEL('latent\Sign_New2\DOG_2_hog__Latent1_R1_0.5_MultiSVM-1-1-10_MV3_0.5', 'Model-1_1_1.mat')
% 
% vilisizeMODEL('latent\Sign_New2\DOG_2_hog__Latent1_R1_0.5_MultiSVM-1-1-100_%MV3_0.5', 'Model-1_1_1.mat')
function vilisizeMODEL(dir, name)
load(fullfile(dir, name), 'model');
if numel(model.w(1,:)) ~= prod([9 7 31])
    return;
end
 Class = {'Yield','Donotenter', 'Speed(30)', 'Speed(35)', ...
     'Oneway(L)', 'Oneway(R)','Stop','Others'};

    for i = 1:size(model.w,1)
        w = reshape(model.w(i,:), [9 7 31]);
        id = model.Label(i);
        subplot(2,4,id);
        visualizeHOG(w);
        title(Class{id})
    end

print(gcf, '-djpeg', '-r0', fullfile(dir, [name(1:end-4) '.jpg']));
close all