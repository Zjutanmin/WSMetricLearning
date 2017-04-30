clear

dataset = 'TSR_BTSRB';

path_truth = fullfile('result_truth',dataset);
path_test = fullfile('result',dataset);

test_dir_1 = dir(path_truth);

for i = 3:length(test_dir_1)
    disp(['test dir ' num2str(i-2) ' start...']);
    path_truth_1 = fullfile(path_truth,test_dir_1(i).name);
    path_test_1 = fullfile(path_test,test_dir_1(i).name);
    
    if ~exist(path_test_1,'dir')
        disp(['No corresponding directory in test result: ' path_test_1]);
    else
        test_dir_2 = dir([path_truth_1 '/R*.mat']);
        for j = 1:length(test_dir_2)
            path_truth_2 = fullfile(path_truth_1,test_dir_2(j).name);
            path_test_2 = fullfile(path_test_1,test_dir_2(j).name);

            if ~exist(path_test_2,'file')
                disp(['No corresponding directory in test result: ' path_test_2]);
            else
%                 truth = struct2cell(load(path_truth_2));
%                 test = struct2cell(load(path_test_2));
                truth = load(path_truth_2);
                test = load(path_test_2);
                
                field_truth = fieldnames(truth);
                field_test = fieldnames(test);
                

                for k = 1:length(field_truth)
%                     temp = test{k} - truth{k};
                    temp = getfield(truth,field_truth{k}) - getfield(test,field_test{k});
                    if any(temp)
                        disp(['Error in:' path_test_2 '--' num2str(k) '--' field_test{k}]);
%                         disp(test{k}');
%                         disp(truth{k}');
                        disp(reshape(temp,1,numel(temp)));
                    end
                end
            end
        end
    end    
end

disp('=======================run over=========================');
