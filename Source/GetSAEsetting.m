function setting = GetSAEsetting(setting)
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