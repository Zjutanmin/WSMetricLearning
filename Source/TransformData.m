function [tr_idx, ts_idx, data_label, cindex, Range, labelmap, issubgroup, ...
    tr_label_new, InvMap] = TransformData(labelmap, ...
    cindex, data_label, tr_idx, ts_idx, Range, tr_label_new)
issubgroup = 0;InvMap = [];
xx1 = sort(labelmap); xx2 = [1:length(cindex)];
if length(xx1) ~= length(xx2) || nnz(xx1(:) - xx2(:))
    issubgroup = 1;
    labelmap = sort(labelmap);
    idt = find(ismember([1:length(cindex)], labelmap));
    Map(labelmap) = [1:length(labelmap)];
    InvMap = labelmap(:);
    
    tr_label = data_label(tr_idx);idt1 = find(ismember(tr_label, idt));
    tr_idx = tr_idx(idt1);
    ts_label = data_label(ts_idx);idt1 = find(ismember(ts_label, idt));
    ts_idx = ts_idx(idt1);Range = Range(idt1);
    data_label(ts_idx) = Map(data_label(ts_idx));
    data_label(tr_idx) = Map(data_label(tr_idx));
    
    if nargin > 6
        tr_label_new = Map(tr_label_new);
    end
    
    data_label(setdiff([1:length(data_label)], [ts_idx; tr_idx])) = 0;
    cindex = [1:length(labelmap)];
    labelmap = cindex;
end




% % % % for ii = 1:length(ts_idx)
% % % %     org =data_label1(ts_idx(ii));
% % % %     new = data_label(ts_idx(ii));
% % % %     if Map(org) ~= new
% % % %         tt= 1
% % % %     end 
% % % %     if ~ismember(new, [1:length(labelmap)])
% % % %         tt = 2
% % % %     end
% % % % end
% % % % 
% % % % for ii = 1:length(tr_idx)
% % % %     org =data_label1(tr_idx(ii));
% % % %     new = data_label(tr_idx(ii));
% % % %     if Map(org) ~= new
% % % %         tt= 1
% % % %     end  
% % % %     if ~ismember(new, [1:length(labelmap)])
% % % %         tt = 2
% % % %     end
% % % % end
% % % % t = 1;