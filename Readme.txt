This is the code for the Weakly Supervised Metric Learning alogrithm.

Its implementaion is based on 
Metric Learning to Rank (mlr-1.2)
http://www-cse.ucsd.edu/~bmcfee/code/mlr/  


AUTHORS:
Min Tan <tanmin@hdu.edu.cn>


INTRODUCTION
------------
This package contains the MATLAB code for feature exaction, dimension reduction,  and some common object recognition algorithms (including NN, K-NN, multi-class SVM, LMNN, gbLMNN, MLR, and the proposed MSMLR\MSMTL)

The software included here implements the algorithm described in

[1]Tan, M., Wang, B., Wu, Z., Wang, J., & Pan, G. (2016). 
   Weakly supervised metric learning for traffic sign recognition in a lidar-equipped vehicle. 
   IEEE Transactions on Intelligent Transportation Systems, 17(5), 1415-1427.

   Implemetation of the Weakly Supervised Metric Learning (WSMLR) Algorithm

   
[2] Min Tan, Zhenfang Hu, Baoyuan Wang, Jieyi Zhao, Yueming Wang. 
   Robust object recognition via weakly supervised metric and template learning. 
   Neurocomputing, 2016, 181:96-107.

   Implemetation of the Weakly Supervised Metric and Template Learning (WSMTL) Algorithm


INSTALLATION
------------

1. Requirements

This software requires MATLAB R2007a or later.  Because it makes extensive use
of the "bsxfun" function, earlier versions of Matlab will not work.


2. Running the demo


To test the installation, first add the path to your Matlab environment:

    >> addpath(genpath('/path'));
	
Under your own '/path', create the following folders:
    1). "SVMModel" folder to store the trained models;
	2). "result" folder to store the results;

2.1 demo for WSMLR[1] compared with other recognitino methods

The demo uses BTSC and GTSC to evaluate WSMLR compared with other alogrithms.

2.1.1 download dataset

Please download the dataset from

1) GTSC dataset: http://pan.baidu.com/s/1nuSJGql
1) BTSC dataset: http://pan.baidu.com/s/1i43Puw1

unzip these files and put them into the 'TrainInfo' file directory under '/path'

2.1.2 download Models

If you want to use the trained models, please download the models from:

1) Models for GTSC: http://pan.baidu.com/s/1jI0FHwa
2) Models for BTSC: http://pan.baidu.com/s/1c8xAjk

unzip these files and put them into 'SVMModel' file directory under '/path'

Otherwise, it will re-train the models when no related models have been stored.

2.1.3 download Results

If you want to show the results, please download the recognition results from:

1) Results for GTSC: http://pan.baidu.com/s/1nuSdIsx
1) Results for BTSC: http://pan.baidu.com/s/1bp8v8SZ

unzip these files and put them into 'result' file directory under '/path'

2.1.4 Go to the demo files '/path\demo\WSMLR' for WSMLR and other compared methods:

run the demo script:

    >> demo_S


Related figure and results are saved in '/path\figure\WSMLR'






2.2 demo for WSMTL[2] compared with other recognitino methods

The demo uses CMU PIE dataset to evaluate WSMTL[2] compared with other alogrithms.

2.2.1 download dataset

Please download the dataset from

http://pan.baidu.com/s/1miF4LLY

unzip these files and put them into the 'TrainInfo' file directory under '/path'

2.2.2 download Models

If you want to use the trained models, please download the models from

http://pan.baidu.com/s/1i4DsL97

unzip these files and put them into the 'SVMModel' file directory under '/path'

2.2.3 download Results

If you want to show the results, please download the recognition results from

http://pan.baidu.com/s/1qYrafEG

unzip these files and put them into the 'result' file directory under '/path'

2.2.4 Go to the demo files '/path\demo\WSMTL' for WSMLR and other compared methods:

run the demo script:

    >> demo_PIE_S

NOTE:
1).Related figure and results are saved in '/path\figure\WSMTL'
2).Best parameters for each method saved in '/path\figure\WSMLR\{DATANAME}\Result\re_Best.mat'

3. Important functions
MAIN FUNCTION - COMPUTE ACCURACY
--------
[CPCave, CRavg, Cranktime, modelresult, CAresult] = ...
    GetRecogRate(dataname, suffix, config_file, cmethod, knnpara, cpara, rawsize,...
    normmerge, multiview, confidence, UseSplit, PCA, selfpaced, KNNlatent, SnippetRatio, ...
    FirstRound, Comverge, useall, APcompute, Fcompute, SetNormFea, ReCnew, coverage)
      dataname     = database name
      suffix       = dataset name suffix, i.e. datasetname = [dataname,suffix]
      config_file  = configuration file for used feature and related parameters
      cmethod      = used model
        'KNN'      : KNN classifier
        'INNC'     : INNC classifier
        'MLR'      : metric learing based template matching
        'MultiSVM' : multi-class SVM
      knnpara      = 1*2 cell {K, set}
         K         = ['-' num2str(K)]: weight K-NN searching;[num2str(K)]: K-NN search;
         set       =0: use all classes; otherwise use sub-classes defined by set
      cpara        = model parameters
        'KNN'      : 
        'INNC'     : value of lamda in [2]
        'MLR'/ 'RMLR': settings for metric learningin [3]/[4] based template matching: 1*3 cell
              first for metric learning
                     C, LOSSTYPE, k, REG, isDiagonal, B, isLatiter : refer to C:\Users\Tan\Downloads\mlr\mlr_train.m
                     lamda                                         : refer to C:\Users\Tan\Downloads\mlr\rmlr_train.m
                     MLRweight                                     : using sample weight for unbalanced dataset
                     MetricL2                                      : 
                     innerfea                                      : distance computing method (1:inner product;0:Eclidean)
              second for template learning
             third for INNC search
                     lamda                                         : value of lamda in [2]
      rawsize      = normalized image size
      normmerge    = normalization weight when combining different features
      multiview    = type of weight
          0     : single-view training and testing
          0.5   : multi-view training, single-view testing       
          3     : multi-view training and testing
      confidence  : using confidence model when merging reocgnition results for multiple snippets
      UseSplit     = split number in the N-Fold Training
         1      : fixed training/testing split
      PCA          = parameters for dimension reduction
      selfpaced    = metric initilization
          0:      random initilization
          1:      initilization based on covariance matrix
      KNNlatent    = hard sample training scheme
          [1]:      unuse hard training
          [1,a,b,c,d]:    use hard training or less than 5 Round
               a - floor(a)
                   0  :   unuse hard training
                   !0 :   use hard training with [round(10*(a - floor(a)))] ROUND
               a  :  interation round in hard sample
      SnippetRatio = parameters for learning reliability feature by 1*13 cell
         {-1,[],Wfea{ind},KFea{ind}, 'Reciprocal',0,1,1, 'NA', WNorm{ind},Norm{ind}}
      FirstRound   = evaluating split in the N-fold training mode
         0:        all N folders
         i:        the i-th folder
      Comverge     = converage condition for metric learning
         1:        norm(w1 - w) / norm(w1) < exp
         0:        abs(trace(w1) - trace(w)) / abs(trace(w1)) < exp
      useall       = using templates and 
          TSREMPTY(floor(useall/ 10)) = 0:including templates; 1:excluding templates
           useall(mod(useall, 10))    = 0:including training samples; 1:excluding training samples
      APcompute    = 1:overall accuracy; 0:average per-class accuracy
      Fcompute     expired
      SetNormFea   = whether use normalized feature
      ReCnew       = whether use INNC testing mode
      coverage     = accuracy under a fixed coverage (refer to [1])

      CPCave      = accuracy in each class
      CRavg       = overall accuracy
      Cranktime   = time consumed in recognition
      modelresult = directory for storing the recognition model
      CAresult    = directory for storing the result


EXTRACT IMAGE FEATURES
--------
[fdatabase, database, dFea, WTAFea, padx, pady] = getrawfeature(img_dir, dataname, fea_dir,  ...
    fea_dir_WTA, i, setting, copyremove, database, colorpath)

       img_dir      :  labels (positive/negative samples for true/flase recognized samples) 
       dataname     :  dataset name
       fea_dir      :  file directory for storing features
       fea_dir_WTA  :  file directory for storing WTA features
       i            :  the i-th feature type
       setting      :  parameters for feature extraction
       copyremove   :  expired
       database     :  structure for dataset 
       colorpath    :  for DoG IMAGE
       
       fdatabase    :  file directory names for storing features
       database     :  structure for dataset       
       dFea         :  feature dimension 
       WTAfea       :  using winner takes all (WTA) feature or not
       padx         :  x pad size for images when extracting features 
       pady         :  y pad size for images when extracting features



TRAINING & TESTING interface
--------
[acc_RE, C_RE, ranktime_RE, WConf, Metric, PCACOEFF] = Classify_2(setting, img_dir, tr_idx, ts_idx, ...
    dFea, WTAfea, fdatabase, feattype, knnpara, cpara, cmethod,  cindex, ...
    nameresult, nameimresult, issave, normmerge, multiview, Rconfidence)

       setting      :  parameters for training & testing prase
       img_dir      :  labels (positive/negative samples for true/flase recognized samples) 
       tr_idx       :  reliability feature
       ts_idx       :  classify label
       dFea         :  feature dimension 
       WTAfea       :  using winner takes all (WTA) feature or not
       fdatabase    :  file directory names for storing features
       feattype     :  feature type
       knnpara      :  parameters for template matching
       cpara        :  parameters for recognition method
       cmethod      :  used recognition method
       cindex       :  used sub-classes (expired)
       nameresult   :  file directory for storing results
       nameimresult :  file directory for storing images according to their predicted label
       issave       :  save images or not
       normmerge    :  feature normalizatin type
       multiview    :  weight normalizatin type
       Rconfidence  :  used confidence feature (expired)
       
       acc_RE       :  recognition accuracy for each category
       C_RE         :  predicted label for each sample 
       ranktime_RE  :  recognition time consumption for each category (machine depended)
       WConf        :  confidence classifer (expired)
       Metric       :  learned metric
       PCACOEFF     :  parameters for dimension reduction


TRAINING metric and templates with weighted structured SVM
--------
   [W, Xi, D] = mlr_train(W, SampleW, X, Y, Cslack, varargin)
[W, Xi, Diagnostics, yrank, X, XDic] = mlr_train(W, SampleW, X, Y, Cslack, varargin)
             
       W            :  Initial metric
       SampleW      :  sample weight 
       X            :  d*n data matrix
       Y            :  either n-by-1 label of vectors
           OR
           n-by-2 cell array where 
               Y{q,1} contains relevant indices for q, and
               Y{q,2} contains irrelevant indices for q
       Cslack       :  >= 0 slack trade-off parameter (default=1)
       varargin     :  training parameters for metric and template learning

       W            :  the learned metric, i.e., the inner product matrix of the learned 
                space can be computed by X' * W * X
       Xi           :  slack value on the learned metric (see [1])
       D            :  diagnostics


TRAINING reliability feature 
--------
[C, label, RINDEX1] = SelectBetterSPScoreD(Enorm, Traininfo, D, C, Scale, conf_tr_fea, tr_fea, cmethod, SnippetRatio, Ypos, Yrank)

       Enorm        :  normalization type 
       TrainInfo    :  expired
       D            :  matrix for sample confidence score
       C            :  matrix for sample classes
       Scale        :  Scale for normalization
       conf_tr_fea  :  image quality featrue from properties
       tr_fea       :  image quality featrue from confidence classifers
       cmethod      :  method for computing reliability feature
       SnippetRatio :  expired
       Ypos         :  class label for each sample
       Yrank        :  search rank for each sample
       
       C            :  reliability feature
       label,       :  predicted class label 
       RINDEX1      :  expired

       
TRAINING reliability classifier 
--------
       [Snippetmodel, C, a, Cscore] = GetSnippetModelBySVM(setting, ...
       ylabel, Cscore, Clabel);

       setting      :  parameters for SVM training method
       ylabel       :  labels (positive/negative samples for true/flase recognized samples) 
       Cscore       :  reliability feature
       Clabel       :  classify label
       
       Snippetmodel :  reliability classifier via SVM
       C            :  predict label
       a            :  expired
       Cscore       :  reliability value