function [sizetitle,sizelengend, sizelabel,sizetick] = getsize(t)
if nargin < 1
    t = 1;
end
if t
sizetitle = 30;
sizelengend = 24;
sizelabel = 30;
sizetick = 24;
else
sizetitle = 24;
sizelengend = 18;
sizelabel = 24;
sizetick = 18;
end

% % % if nargin < 1
% % %     t = 1;
% % % end
% % % if t
% % % sizetitle = 24;
% % % sizelengend = 24;
% % % sizelabel = 36;
% % % sizetick = 24;
% % % else
% % % sizetitle = 18;
% % % sizelengend = 18;
% % % sizelabel = 24;
% % % sizetick = 18;
% % % end
% % 
% % if nargin < 1
% %     t = 0;
% % end
% % if t
% %     sizetitle = 32;
% %     sizelengend = 28;
% %     sizelabel = 32;
% %     sizetick = 28;
% % else
% %     sizetitle = 16;
% %     sizelengend = 14;
% %     sizelabel = 16;
% %     sizetick = 14;
% % end

