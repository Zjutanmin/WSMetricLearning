function getRclass(classesstr, sstr, NC, Ngroup)
NNC = cellfun(@str2num, classesstr, 'ErrorHandler', @errorfun, ...
    'UniformOutput', true);
try
    for jj = 1:length(classesstr) - 1
        load(['TrainInfo\image_Sign' sstr '_1RandClass_3.', classesstr{jj}, '.mat'], 'RClass');
        NRClass{jj} = RClass;
    end
catch
    id = [];
    for i = 1:Ngroup
        id(i,:) = randperm(NC);
    end
    for jj =1:length(classesstr) - 1
        RClass = sort(id(:, 1:NNC(jj)), 2);
        save(['TrainInfo\image_Sign' sstr '_1RandClass_3.', classesstr{jj}, '.mat'], 'RClass');
        NRClass{jj} = RClass;
    end
end