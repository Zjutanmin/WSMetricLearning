setting.PCAMethod = 'PCA';
setting.LocalPCA = 0;
if iscell(setting.PCA)
    try setting.splitPCA = setting.PCA{2};  end
    if length(setting.PCA) > 2
        setting.AidConf = setting.PCA{3};
    else
        setting.AidConf = [];
    end
    try  setting.LocalPCA = setting.PCA{4};  end
    setting.PCA = setting.PCA{1};
    if iscell(setting.PCA)
        setting.PCAO = setting.PCA;
        setting.PCAMethod = setting.PCA{2};
        setting.PCAMethodTemp = setting.PCAMethod;
        if strcmp(setting.PCAMethod, 'SAE-NN')
            setting.PCAMethodTemp = 'SAE';
        end
        switch setting.PCAMethodTemp
            case 'SAE'
                setting.PCAdef = {'Def' 'Def' 'sigm' 1 0.5 1 1000 0.05 0 0.5 1 8000};
                try setting.PCA{3}; catch setting.PCA{3} = setting.PCAdef{3}; end
                try setting.PCA{4}; catch setting.PCA{4} = setting.PCAdef{4}; end
                try setting.PCA{5}; catch setting.PCA{5} = setting.PCAdef{5}; end
                try setting.PCA{6}; catch setting.PCA{6} = setting.PCAdef{6}; end
                try setting.PCA{7}; catch setting.PCA{7} = setting.PCAdef{7}; end
                try setting.PCA{8}; catch setting.PCA{8} = setting.PCAdef{8}; end
                try setting.PCA{9}; catch setting.PCA{9} = setting.PCAdef{9}; end
                try setting.PCA{10}; catch setting.PCA{10} = setting.PCAdef{10}; end
                try setting.PCA{11}; catch setting.PCA{11} = setting.PCAdef{11}; end
                try setting.PCA{12}; catch setting.PCA{12} = setting.PCAdef{12}; end
            case 'PCA'
                setting.PCA = setting.PCA{1};
            case 'LDA'
                setting.PCA{1} = 1;setting.PCAO{1}= 1;
                setting.PCAdef = {'Def' 'Def' 1 0};
                try setting.PCA{3}; catch setting.PCA{3} = setting.PCAdef{3}; end
                try setting.PCA{4}; catch setting.PCA{4} = setting.PCAdef{4}; end
        end
    end
end