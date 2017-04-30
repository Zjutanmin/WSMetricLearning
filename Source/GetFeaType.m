function method = GetFeaType(omethod, setting)
method = '';
if ismember(omethod,  setting.feaInter)
    method =  [method  'feaInter'];
end
if ismember(omethod,  setting.EdgeInter)
    method =  [method  'EdgeInter'];
end
if ismember(omethod,  setting.CNNInter)
    method =  [method  'CNNInter'];
end
if ismember(omethod,  setting.CNNmInter)
    method =  [method  'CNNmInter'];
end
if ismember(omethod,  setting.CNNm_newInter)
    method =  [method  'CNNm_newInter'];
end
if ismember(omethod,  setting.CNNm_new2Inter)
    method =  [method  'CNNm_new2Inter'];
end
if ismember(omethod,  setting.CNNm_new3Inter)
    method =  [method  'CNNm_new3Inter'];
end


if ismember(omethod,  setting.CNNm_train1Inter)
    method =  [method  'CNNm_train1Inter'];
end
if ismember(omethod,  setting.CNNm_train2Inter)
    method =  [method  'CNNm_train2Inter'];
end
if ismember(omethod,  setting.CNNm_train3Inter)
    method =  [method  'CNNm_train3Inter'];
end
if ismember(omethod,  setting.CNNm_train4Inter)
    method =  [method  'CNNm_train4Inter'];
end
if ismember(omethod,  setting.CNNm_train5Inter)
    method =  [method  'CNNm_train5Inter'];
end
if ismember(omethod,  setting.CNNm_train6Inter)
    method =  [method  'CNNm_train6Inter'];
end
