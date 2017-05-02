function setting = getClassNum(setting, knnpara, Nclass, lengthnum, lengthnum1)
NclassO = Nclass;
setting.Ngroup = 1;setting.Nclass = NclassO;
if length(knnpara) > 1 && knnpara(2) ~= 0
    if knnpara(2) < 0
        Ngroup = floor(abs(knnpara(2)));
        Nclass = abs(knnpara(2)) - Ngroup;
        Nclass = round(Nclass * 10.^(lengthnum));
        setting.Ngroup = Ngroup; setting.Nclass = Nclass;
    end
end
if nargin < 5
    lengthnum1= 0;
end
setting.NgroupT = setting.Ngroup;
setting.NclassT = setting.Nclass;
if length(knnpara) > 2
    if knnpara(3) ~= 0
    if knnpara(3) < 0
        Ngroup = floor(abs(knnpara(3)));
        Nclass = abs(knnpara(3)) - Ngroup;
        Nclass = round(Nclass * 10.^(lengthnum1));
        setting.NgroupT = Ngroup; setting.NclassT = Nclass;
    end
    if knnpara(3) == 0
        setting.NgroupT = Ngroup; setting.NclassT = NclassO;
    end
    else
        setting.NgroupT = setting.Ngroup;
        setting.NclassT = NclassO;
    end
end
        