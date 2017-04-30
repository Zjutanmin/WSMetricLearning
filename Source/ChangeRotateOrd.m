function ctr_fea = ChangeRotateOrd(ctr_fea, Nrotate)
% ctr_fea1 = ctr_fea;
ctr_fea = cell2mat(ctr_fea);
N = size(ctr_fea, 1);
sizet = size(ctr_fea);
ctr_fea = permute(reshape(ctr_fea, [Nrotate, size(ctr_fea, 1) / Nrotate,...
    size(ctr_fea, 2)]), [2 1 3]);
ctr_fea = reshape(ctr_fea, sizet);
ctr_fea = mat2cell(ctr_fea, ones(1,N), size(ctr_fea,2));
% for i = 1:Nrotate
%     dis = ctr_fea1(i:Nrotate:end,:) - ctr_fea((i-1)*sizet/ Nrotate+1:i*sizet/ Nrotate,:);
%     max(abs(dis(:)))
% end