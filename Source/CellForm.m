function ctr_fea = CellForm(tr_fea, tr_label, nrotate)
ctr_fea = cell(1, nrotate);
for i = 1:nrotate
    tmp = tr_fea(i:nrotate:end,:);
    [m,n] = size(tmp);
    ctr_fea{i} = mat2cell(tmp', n, ones([1, m]));
end

% imax = -inf;
% for i = 1:nrotate
%     for jj = 1:size(tmp,1)
%         dis = ctr_fea1{i}{jj} - ctr_fea1{i}{jj};
%         imax = max(imax, max(abs(dis(:))));
%     end
% end
% imax