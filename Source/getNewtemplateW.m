function [dataX, dataY, inum, setting, Label, dataXX] = getNewtemplateW(idx1, idx2,  dataX, dataY,...
    ts_label,  setting,  W,  SW)   
% addpath('ksvdbox');addpath('ompbox')
if nargin < 8
    SW = ones(idx2 - idx1 + 1, 1);
end   
% if ~isempty(W)
%     [vecs,vals] = eig(0.5 * (W + W'));
%     L = real(abs(vals)).^0.5 * vecs';
%     dataX = dataX*L';   
% end
[dataX, dataY, inum, setting, Label, dataXX] = getNewtemplate(idx1, idx2,  dataX, dataY,...
    ts_label,  setting,  SW);  
% if ~isempty(W)
%     dataX = dataX*inv(L)';
% end
if isfield(setting, 'Codedis') && setting.Codedis
    Temp = full(dataXX);
    dataXX = dataX;
    dataX = Temp;
else
    dataXX = [];
end
if setting.TemplateNorm
    dataX = L2normMatrix(dataX);
end