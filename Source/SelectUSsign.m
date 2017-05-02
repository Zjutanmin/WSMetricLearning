function fn = SelectUSsign(fn, country, remove)
if nargin < 2
    country = 'UnitedStates';
    remove = 1;
end
% fn = '\image\Sign_NewT';
load(fullfile(fn, 'Trainstr.mat'), 'datastruct');
index = strfind(datastruct.name, 'Country');
index = find(~cellfun(@isempty, index));

index1 = strfind(datastruct.name, '#FileName');
index1 = find(~cellfun(@isempty, index1));

TestData = datastruct.value;
isTrain = zeros(1, length(TestData));
strcell = cell(length(TestData),1);
fn = {};
num = 0;
for i = 1:length(TestData)
    if strfind(TestData{i}{index}, country)
        isTrain(i) = 1;
        num = num + 1;
        fn{num} = TestData{i}{index1};
    else
        if remove
            filename = fullfile(fn, TestData{i}{index1}(1:end - 4));
            rmdir(filename, 's');
        end
    end
    strcell{i} = TestData{i}{index};
end
