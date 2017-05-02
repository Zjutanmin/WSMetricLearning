function [cmethod, cpara, KNNround, SnippetRatio, C, setting] =...
    getMConfig(method, C,dataset,NFold, Round)
if nargin < 2
    C = -1;
end
if nargin < 3
    dataset ='TSR';
    NFold = 1;Round = 1;
end

switch method
    case 'KNN'
        cmethod = 'KNN';
        cpara = {};
        KNNround = 1;
        SnippetRatio = {1};
    case 'INNC'
        cmethod = 'INNC';
        cpara = 0.05;
        KNNround = 1;
        SnippetRatio = {1};
    case 'MLR'
        cmethod = 'MLR';
        if C == -1
            switch dataset
                case 'TSR'
                    C = 2048;
                    setting.Modelresult = ['SVMModel\TSR_GTSRB\FPY8_DOG_2_hog_dalal__S1_0.25_1_LDA_1_1_MLR-0-' ...
                        num2str(C) '-MRR-1-1-0-1-3\Model-Round' num2str(NFold) '_' num2str(Round) '.mat'];
                    
                case 'Sign'
                    C = 512;
                    
%                     setting.Modelresult = ['SVMModel\TSR_GTSRB\FPY8_DOG_2_hog_dalal__S1_0.25_1_LDA_1_1_MLR-0-' ...
%                         num2str(C) '-MRR-1-1-0-1-3\Model-Round' num2str(NFold) '_' num2str(Round) '.mat'];
            end
        end
        cpara = {C 'MRR', 1, 1, 0, 1};
        KNNround = 1;
        SnippetRatio = {1};  
    case 'MLR-W'
        cmethod = 'MLR';
        if C == -1
            switch dataset
                case 'TSR'
                    C = 2048;
                case 'Sign'
                    C = 512;
            end
        end
        cpara = {C, 'HINGE', 1, 1, 0, 1};
        KNNround = 5;
        SnippetRatio = {4,0}; 
    case 'MLR(I)'
        cmethod = 'MLR';
        cpara = {{C 'MRR', 1, 1, 0, 1},  [0.05]};
        KNNround = 1;
        SnippetRatio = {1};  
    case 'MLR-W(I)'  
        cmethod = 'MLR';
        cpara = {{C, 'HINGE', 1, 1, 0, 1},  [0.05]};
        KNNround = 5;
        SnippetRatio = {4,0}; 
end
if nargout > 5
    load(setting.Modelresult, 'Metric');setting.Metric = Metric;
    switch dataset
        case 'TSR'
            setting.PCAdir = ['TrainInfo\image_TSR_GTSRB_1_FPY8_DOG_2_hog_dalal_Round'...
                num2str(NFold) '_' num2str(Round) '_E_1_LDA_1_1_PCACOEFF.mat'];
            setting.Samplevoted = 1;
        case 'Sign'
            setting.PCAdir = ['TrainInfo\image_TSR_GTSRB_1_FPY8_DOG_2_hog_dalal_Round'...
                num2str(NFold) '_' num2str(Round) '_E_1_LDA_1_1_PCACOEFF.mat'];
    end
end
