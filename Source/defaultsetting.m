%%the following parameters are for LLP features, expired
bookfeat = {'sift'}; 
sampling=-1;pyramid=[4,8,16];ncluster=100;Fpyramid = 0;patchsize = 16; 


%%the following parameters are for different sub-dataset, expired
copyremove = 1; changesize = 0;minLEN = -1;
VirUse = 0;VirUsestr = '';VirUseNum = 0;Nmax = 5000;NmaxMLR = 36000;
KNNNUM = 0;KNNPad = 0;
KNNNUM1 = 0;KNNPad1 = 0;HandClass = 0; 



%%%sub-dataset selection for evaluating scalability, refer to figure 8 in [1]
if iscell(knnpara)
    cknnpara = knnpara;clear 'knnpara'
    t = 0;
    try
        knnpara(1) = str2num(cknnpara{1});
    catch
        HandStr = cknnpara{1}(end);
        if strcmp(HandStr, 'H')
            HandClass = 1;
            knnpara(1) = str2num(cknnpara{1}(1:end-1));
        else
            t = 1;
        end
    end
    if t == 1
        fprintf('Input Error\n');
        pause;
    end
    if length(cknnpara) > 1
        tt = str2num(cknnpara{2});
        if round(tt) ~= tt
            idx = strfind(cknnpara{2}, '.');
            KNNNUM = length(cknnpara{2}) - idx;
        end
        knnpara(2) = str2num(cknnpara{2});
        if round(tt) ~= tt
            KNNPad = idx+KNNNUM-length(num2str(knnpara(2)));
        end
    end
    if length(cknnpara) > 1
        tt = str2num(cknnpara{2});
        if round(tt) ~= tt
            idx = strfind(cknnpara{2}, '.');
            KNNNUM = length(cknnpara{2}) - idx;
        end
        knnpara(2) = str2num(cknnpara{2});
        if round(tt) ~= tt
            KNNPad = idx+KNNNUM-length(num2str(knnpara(2)));
        end
    end
    if length(cknnpara) > 2
        tt = str2num(cknnpara{3});
        if round(tt) ~= tt
            idx = strfind(cknnpara{3}, '.');
            KNNNUM1 = length(cknnpara{3}) - idx;
        end
        knnpara(3) = str2num(cknnpara{3});
        if round(tt) ~= tt
            KNNPad1 = idx+KNNNUM1-length(num2str(knnpara(3)));
        end
        
    end
end
if length(knnpara) >1 && ~nnz(knnpara(2:end))
    knnpara = knnpara(1);
end


%%the following parameters are for storing results with orignal figure, expired
issave = 0;


%%the following parameters are for confidence model, expired
Rconfidence = 0;
svote = [];




ReciprocalInter = [2, 4, 7, 8, 9, 10, 11,12,13,14,15,20,21];
Crange = 0; 
featPad = 0;Ratio= 0;RRatio=0.5;Crange =0;
if nargin < 4
    cmethod = 'KNN'; 
    knnpara = 10;
end

PreModel = '';PreModelType = '';PreModel1 = '';





%%pretrained model and dataset
if iscell(suffix)
    if length(suffix) > 2 && ~isempty(suffix{3})
        VirUse = suffix{3}{1};  %%%if using vitual samples, expired
        VirUsestr = suffix{3}{2};
        try
            VirUseNum = suffix{3}{3};
            Nmax = suffix{3}{4};
            NmaxMLR = suffix{3}{5};
        end
    end
    if length(suffix) > 3  %%%if using pre-trained metric for new search schem only
        if iscell(suffix{4})
            PreModel1 = suffix{4}{2};
            PreModel = suffix{4}{1};
            PreModelType = 0;
        else
            PreModel = suffix{4};
            PreModelType = 0;
        end
    end
    if length(suffix) > 4
        PreModelType = suffix{5};
    end
    minLEN = suffix{2};
    suffix = suffix{1};
end


%   [1] Min Tan, Baoyuan Wang, Zhaohui Wu, Jingdong Wang, Gang Pan.
%   "Weakly Supervised Metric Learning for Traffic Sign Recognition in a
%   LIDAR Equipped Vehicle", T-ITS, 2015