function [C1, voted, votedis, voteinfo] = GetRerank2(setting, Samplevoted, C, distance, nclass, ts_idx, method, Rdistance, ...
    ts_imname, ts_label, tr_imname, tr_size, ts_size, knn)
if nargin < 8
    method = 1;
    Rdistance = 0.5;
    ts_imname = [];
end
if length(setting.ccoverage) > 1
    [C1, voted, votedis, voteinfo] = GetRerank2_A(setting, Samplevoted, C, distance, nclass, ts_idx, method, Rdistance, ...
        ts_imname, ts_label, tr_imname, tr_size, ts_size, knn);
    return;
end


softK = size(C, 2);

tt = unique(ts_idx);

exp = 0.001;
Sweight = ones(length(ts_idx),1);

switch setting.confidence
    case 1
        Sweight = (setting.conf_tr_fea * setting.WConf(:) + 1) / 2; %%%BY SVM       
        Sweight(find(setting.conf_tr_fea(:,6) < exp)) = 0;
    case 6
        %%%for size
        conf_tr_fea = setting.conf_tr_fea;
        Sweight1 = conf_tr_fea(:, 1);
        Sweight2 = conf_tr_fea(:, 2);
        Sweight = (Sweight1+Sweight2) / 2;
    case 8
        %%%for size
        conf_tr_fea = setting.conf_tr_fea;
        Sweight1 = ones(length(ts_idx),1);idx1 = find(conf_tr_fea(:,1) < 1);
        Sweight2 = ones(length(ts_idx),1);idx2 = find(conf_tr_fea(:,2) < 1);
        Sweight1(idx1) = conf_tr_fea(idx1, 1);
        Sweight2(idx2) = conf_tr_fea(idx2, 2);
        Sweight = (Sweight1+Sweight2) / 2;
    case 7
        %%%for size
        Sweight = ones(length(ts_idx),1);
    case 2
        %%%for size
        conf_tr_fea = setting.conf_tr_fea;
        Sweight1 = ones(length(ts_idx),1);idx1 = find(conf_tr_fea(:,1) < 1);
        Sweight2 = ones(length(ts_idx),1);idx2 = find(conf_tr_fea(:,2) < 1);
        Sweight1(idx1) = conf_tr_fea(idx1, 1);
        Sweight2(idx2) = conf_tr_fea(idx2, 2);
        Sweight = (Sweight1+Sweight2) / 2;
        Sweight(find(conf_tr_fea(:,6) < exp)) = 0;
    case 3
        Sweight = seting.WEntropy;
        Sweight(find(setting.conf_tr_fea(:,6) < exp)) = 0;
    case 4
        Sweight = setting.WCscore;Sweight = Sweight(:);
    case 5
        Sweight = setting.WCscore;Sweight = Sweight(:);
end
if setting.coverage ~= -1
    Sweight = setting.WCscore;Sweight = Sweight(:);
end

% % %%%for debug
% % % method = 1;knn = 1;C = C(:,1);distance = distance(:,1);
% % % method = 2;knn = 1;C = C(:,1);distance = distance(:,1);
% % % method = 3;knn = 1;C = C(:,1);distance = distance(:,1);
% % % method = 1;knn = 5;
% % % method = 2;knn = 5;
% % method = 3;knn = 5;
% % imax = 0;
% % %%%end debug


% xdata = zeros(size(Wi));
% ydata = zeros(size(Wi));

weightK = 1 ./ [1:softK];
if setting.RankK
    weightK(:) = 1;
end

Sweight = Sweight * weightK;


if ~setting.confidence
    Sweight(:) = 1;
end
% % % %%%for debug
% % % Sweight(:) = 1;
% % % %%%end debug

C1 = ones(size(C,1), knn);
C_cov = ones(size(C,1), length(setting.coverage));

voted = zeros(length(ts_size), knn);
voteinfo = zeros(length(tt), 4);
votedis = zeros(length(tt), 12);
for i = 1:length(tt)
%     try
    index = find(ts_idx == tt(i));  %%%find the fold's index
    tmpvoted = zeros(length(index), knn);
    C_i = C(index, :);
    C_i_O = C_i;
    Sweight_i = Sweight(index, :);
    distance_i = distance(index, :);

    if ~isempty(setting.svote) && ~strcmp(setting.svote, 'None')
        votescore_i = distance_i;
    else
        votescore_i = ones(size(distance_i));
    end
    
    switch method
        case 1
            ind = find(Samplevoted(index));
            Tresult = C_i(ind); votescore = votescore_i(ind);
            tmpvoted1 = zeros(size(C_i));tmpvoted1(ind) = 1;
            Wresult= Sweight_i(ind);
            xx = Whist(Tresult, Wresult, votescore, nclass);
            [xx, ord] = sort(xx, 'descend');
            uTresult = -1 * ones(1, knn);  
            if length(ord) < knn
                uTresult(1:length(ord)) = ord(1:end);
            else
                uTresult = ord(1:knn);
            end
            tmpvoted = repmat(tmpvoted1(:,1), [1, knn]);
            C_i = repmat(uTresult, [length(index), 1]);
        case 2
            Tresult = C_i(:);
            Conf = distance_i(:);
            thresh = min(Conf) + (max(Conf) - min(Conf)) * Rdistance;
            ind = find(Conf < thresh);
            Tresult = Tresult(ind);
            tmpvoted1 = zeros(size(C_i));
            tmpvoted1(ind) = 1;
            
            Wresult = Sweight_i(ind);xx = Whist(Tresult, Wresult, votescore, nclass);
            tmpvoted = repmat(tmpvoted1(:,1), [1, knn]);
            [xx, ord] = sort(xx, 'descend');
            uTresult = ord(1:knn);
            C_i = repmat(uTresult, [length(index), 1]);
        case 3
            xtr_size = tr_size(:,1);ytr_size = tr_size(:,2);
            xcurr_tr_size = reshape(xtr_size(C_i), size(C_i));
            ycurr_tr_size = reshape(ytr_size(C_i), size(C_i));%%%size of templete
            xts_size = ts_size(:,1);yts_size = ts_size(:,2);  
            xcurr_ts_size = repmat(xts_size(index), [1, softK]);
            ycurr_ts_size = repmat(yts_size(index), [1, softK]);
            
            ind1 = find(xcurr_ts_size >= xcurr_tr_size * Rdistance);
            ind2 = find(ycurr_ts_size >= ycurr_tr_size * Rdistance);
            ind = union(ind1, ind2);
            
            ind = intersect(ind, find(Samplevoted(index)));
            
            Tresult = C_i(ind); votescore = votescore_i(ind);
%             tmpvoted(ind) = 1;
            tmpvoted1 = zeros(size(C_i));tmpvoted1(ind) = 1;
            Wresult= Sweight_i(ind);

            
            if setting.coverage == -1
                
                xx = Whist(Tresult, Wresult, votescore, nclass);
                [xx, ord] = sort(xx, 'descend');
                uTresult = -1 * ones(1, knn);  
                if length(ord) < knn
                uTresult(1:length(ord)) = ord(1:end);
                else
                uTresult = ord(1:knn);
                end
                tmpvoted = repmat(tmpvoted1(:,1), [1, knn]);
                C_i = repmat(uTresult, [length(index), 1]);
            else
                [~,bb] = sort(Wresult.* votescore, 'descend');
                Num_C = ceil(length(Tresult)*setting.coverage);
                if length(unique(Tresult(bb(1:Num_C)))) ~= 1;
                    C_i= repmat(-1, [length(index), 1]);
                else
                    C_i= repmat(Tresult(bb(1)), [length(index), 1]);
                end
            end
            
            
        case 4
            ind = find(Samplevoted(index));
            Tresult = C_i(ind); votescore = votescore_i(ind);
            tmpvoted1 = zeros(size(C_i));tmpvoted1(ind) = 1;
            Wresult= Sweight_i(ind);
            if setting.coverage == -1
                
                xx = Whist(Tresult, Wresult, votescore, nclass);
                [xx, ord] = sort(xx, 'descend');
                uTresult = -1 * ones(1, knn);  
                if length(ord) < knn
                uTresult(1:length(ord)) = ord(1:end);
                else
                uTresult = ord(1:knn);
                end
                tmpvoted = repmat(tmpvoted1(:,1), [1, knn]);
                C_i = repmat(uTresult, [length(index), 1]);  

            else
                [~,bb] = sort(Wresult.* votescore, 'descend');
                Num_C = ceil(length(Tresult)*setting.coverage);
                if length(unique(Tresult(bb(1:Num_C)))) ~= 1;
                    C_i= repmat(-1, [length(index), 1]);
                else
                    C_i= repmat(Tresult(bb(1)), [length(index), 1]);
                end
            end
        case 5
            ind = find(Samplevoted(index));
            Tresult = C_i(ind); votescore = votescore_i(ind);
            tmpvoted1 = zeros(size(C_i));tmpvoted1(ind) = 1;
            Wresult= Sweight_i(ind);
            xx = Whist(Tresult, Wresult, votescore, nclass);
            [xx, ord] = sort(xx, 'descend');
            uTresult = -1 * ones(1, knn);  
            if length(ord) < knn
                uTresult(1:length(ord)) = ord(1:end);
            else
                uTresult = ord(1:knn);
            end
            tmpvoted = repmat(tmpvoted1(:,1), [1, knn]);
            C_i = repmat(uTresult, [length(index), 1]);  
    end
    C1(index, :) = C_i;
    
    voted(index, :) = tmpvoted; 

    idt = find(Samplevoted(index));
    if isempty(idt)
        continue
    end
    index = index(idt);
    distance_i = distance_i(idt,:);
    idd = C_i_O(idt,1) == ts_label(index(1));

    if C_i(1,1) == ts_label(index(1))
        voteinfo(i, 1) = length(find(idd)) / length(index);
        voteinfo(i, 2) = length(find(~idd)) / length(index);
        if length(find(idd))
        votedis(i, 1:3) = [mean(distance_i((find(idd)))), min((distance_i((find(idd))))), max((distance_i((find(idd)))))];
        end
        if length(find(~idd))
    
            votedis(i, 4:6) = [mean(distance_i((find(~idd)))), min((distance_i((find(~idd))))), max((distance_i((find(~idd)))))];
        end
    else
        voteinfo(i, 3) = length(find(idd)) / length(index);
        voteinfo(i, 4) = length(find(~idd)) / length(index);
        if length(find(idd))
        votedis(i, 7:9) = [mean(distance_i((find(idd)))), min((distance_i((find(idd))))), max((distance_i((find(idd)))))];
        end
        if length(find(~idd))
            votedis(i, 10:12) =[mean(distance_i((find(~idd)))), min((distance_i((find(~idd))))), max((distance_i((find(~idd)))))];
        end
    end    
    
%     idt = find(Samplevoted(index));
%     index = index(idt);
%     
%     if ts_label(index(1)) ~= C_i(1,1)
%         
%     C_i_O = C_i_O(idt,:);C_i= C_i(idt,:);
%     distance_i = distance_i(idt,:);
%     Sweight_i = Sweight_i(idt,:);
%     [i, index']
%     figure(1)
%     set (1,'Position',[1,1,750,1150])
%     for jj = 1:length(index)
%         subplot(length(index)+1, 3, (jj-1)*3+1);
%         im = imread(ts_imname{index(jj)});
%         imshow(uint8(im));
%         
%         subplot(length(index)+1, 3, (jj-1)*3+2);
%         im = imread(tr_imname{C_i_O(jj,1)});
%         imshow(uint8(im));
%         
%         subplot(length(index)+1, 3, (jj-1)*3+3);
%         xx = sort(distance_i(jj,:), 'descend');
%         plot([1:setting.KNNlatent(1)], xx(1:setting.KNNlatent(1)), '-');
%         title([num2str(Sweight_i(jj)), 'SV_', num2str(Samplevoted(index(jj)))]);   
%         
%         xdata(index(jj)) = Wi(index(jj));
%         ydata(index(jj)) = C_i_O(jj,1) == ts_label(index(1));
%         
%     end
%     
%     subplot(length(index)+1, 3, length(index)*3+1);
%     im = imread(tr_imname{ts_label(index(1))});
%     imshow(uint8(im));
%     title('ground truth');
%     subplot(length(index)+1, 3, length(index)*3+2);
%     im = imread(tr_imname{C_i(1,1)});
%     imshow(uint8(im));
%     title('Targe class');
% 
% 
% 
% 
% %     col = ceil(sqrt(length(uTresult)));
% %     for jj = 1:length(index)
% %         im = imread(ts_imname{uTresult(jj)});
% %         subplot(col, col, jj);
% %         imshow(uint8(im));
% %     end
% %     title('Targe class\n');
%     
% %     pause;
% 
%     
%     print(gcf, '-djpeg', '-r0', ['C:\Users\v-mintan\Desktop\testing\false\' num2str(i) '.jpg']); 
%     close all
%     end
%     catch
%         t = 1;
%     end
end
% xx = xdata(find(Samplevoted));
% yy = ydata(find(Samplevoted));
% idx1 = find(yy);idx2 = find(~yy);
% plot([1:length(idx1)], sort(xx(idx1)), 'r-');
% hold on;
% plot([1:length(idx2)], sort(xx(idx2)), 'g-');
% % 
% % imax
