function ClassW = getWclass(ts_label)
[a,b,c] = unique(ts_label);
len = zeros(1, length(a));
for i = 1:length(a)
    len(i) = length(find(c == i));
end
len = 1./len;
% % 
% % hlen = len;
% % len = (len - min(len))/ (max(len) - min(len));
% % len = 1 - len;
% % len = exp(len);
% % len = len / exp(1);
ClassW = zeros(1, length(ts_label));
for i = 1:length(a)
    idt = find(c == i);
    ClassW(idt) = len(i);
end
ClassW = ClassW ./ sum(ClassW);
ClassW = ClassW * length(ClassW);

% % % [a,b,c] = unique(ts_label);
% % % len = zeros(1, length(a));
% % % for i = 1:length(a)
% % %     len(i) = length(find(c == i));
% % % end
% % % hlen = len;
% % % len = (len - min(len))/ (max(len) - min(len));
% % % len = 1 - len;
% % % len = exp(len);
% % % len = len / exp(1);
% % % ClassW = zeros(1, length(ts_label));
% % % for i = 1:length(a)
% % %     idt = find(c == i);
% % %     ClassW(idt) = len(i);
% % % end
% % % ClassW = ClassW ./ sum(ClassW);
% % % ClassW = ClassW * length(ClassW);
