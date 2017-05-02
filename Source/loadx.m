function redo = loadx(ShowExist, filedir, isresult)
redo= 0;
if nargin < 3
    isresult = 1;
end
    load(filedir)
    if ~ShowExist
    if isresult
        fprintf(['The result is already saved in:\n%s'], filedir)
        fprintf(['\nDo you want to evalute again ? \n'])
    else
        fprintf(['The model already exist in:\n%s'], filedir)
        fprintf(['\nDo you want to train it again ? \n'])
    end
    
    a = input('Please input Y for yes, N for No: ', 's');
%     fprintf('Press Enter first\n')
    while ~strcmp(a, 'Y') && ~strcmp(a, 'N')
        a = input('Please input Y for yes, N for No: ', 's');
    end
    if strcmp(a, 'Y')
        redo = 1;
        load('abcdefg.mat')
    end
    end
