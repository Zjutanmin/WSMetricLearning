function setting = getlabelmap(knnpara, fdatabase, feattype, ...
    setting, nclass,cindex,  tr_label, TFstr, tr_idx)
kpara = length(knnpara);
if length(knnpara) > 1 && knnpara(kpara) ~= 0
    if knnpara(kpara) < 0
        Nclass = setting.Nclass;Ngroup = setting.Ngroup;
        if Nclass ~= length(cindex)
            if setting.HandClass
                setting.Randclassstr = [setting.Randclassstr, '_H'];
            end
            try
                load([setting.TFstr, 'RandClass_', setting.Randclassstr(3:end), '.mat'], 'RClass')
            catch
                RClass = zeros(Ngroup, Nclass);
                for jj = 1:Ngroup
                id = randperm(length(cindex));
                RClass(jj,:) = sort(id(1:Nclass));
                end
                save([setting.TFstr, 'RandClass_', setting.Randclassstr(3:end), '.mat'], 'RClass')
            end
            setting.RClass = RClass;
        else
            setting.labelmap = [1:nclass];
            setting.Consider = unique(setting.labelmap);
            setting.ConsiderID = [1:length(tr_label)];
        end
    else
        setting.labelmap = (length(cindex)+1) * ones(nclass, 1);
        setting.labelmap(cindex) = [1:length(cindex)];
        setting.PClass = 1;
        switch knnpara(2)
            case 1
            setting.Consider = [1:length(cindex)];
            setting.ConsiderID = cindex;
            case 2
            setting.labelmap = tr_label;
            setting.Consider = unique(setting.labelmap);
            setting.ConsiderID = [1:length(tr_label)];
        end
    end
else
    setting.labelmap = [1:nclass];
    setting.Consider = unique(setting.labelmap);
    setting.ConsiderID = [1:length(tr_label)];
end
setting.rotate = 0;

ttidx = [setting.tr_idx; setting.ts_idx];
setting = getdataALL_1(setting, fdatabase, feattype, ttidx);
    
    
if setting.PCAenergy < 0
    setting = getPCABYdata(setting, fdatabase, feattype, setting.tr_idx);
end

% % % if length(knnpara) > 1 && knnpara(2) ~= 0
% % %     if knnpara(2) < 0
% % %         Nclass = setting.Nclass;Ngroup = setting.Ngroup;
% % %         if Nclass ~= length(cindex)
% % %             if setting.HandClass
% % %                 setting.Randclassstr = [setting.Randclassstr, '_H'];
% % %             end
% % %             try
% % %                 load([setting.TFstr, 'RandClass_', setting.Randclassstr(3:end), '.mat'], 'RClass')
% % %             catch
% % %                 RClass = zeros(Ngroup, Nclass);
% % %                 for jj = 1:Ngroup
% % %                 id = randperm(length(cindex));
% % %                 RClass(jj,:) = sort(id(1:Nclass));
% % %                 end
% % %                 save([setting.TFstr, 'RandClass_', setting.Randclassstr(3:end), '.mat'], 'RClass')
% % %             end
% % %             setting.RClass = RClass;
% % %         else
% % %             setting.labelmap = [1:nclass];
% % %             setting.Consider = unique(setting.labelmap);
% % %             setting.ConsiderID = [1:length(tr_label)];
% % %         end
% % %     else
% % %         setting.labelmap = (length(cindex)+1) * ones(nclass, 1);
% % %         setting.labelmap(cindex) = [1:length(cindex)];
% % %         setting.PClass = 1;
% % %         switch knnpara(2)
% % %             case 1
% % %             setting.Consider = [1:length(cindex)];
% % %             setting.ConsiderID = cindex;
% % %             case 2
% % %             setting.labelmap = tr_label;
% % %             setting.Consider = unique(setting.labelmap);
% % %             setting.ConsiderID = [1:length(tr_label)];
% % %         end
% % %     end
% % % else
% % %     setting.labelmap = [1:nclass];
% % %     setting.Consider = unique(setting.labelmap);
% % %     setting.ConsiderID = [1:length(tr_label)];
% % % end
% % % setting.rotate = 0;
% % % 
% % % ttidx = [setting.tr_idx; setting.ts_idx];
% % % setting = getdataALL(setting, fdatabase, feattype, ttidx);
% % %     
% % %     
% % % if setting.PCAenergy < 0
% % %     setting = getPCABYdata(setting, fdatabase, feattype, setting.tr_idx);
% % % end