function [Ypos, Ynegative] = MultiY(Ypos, Ynegative, nbase, Nrotate)
Plus = [0:Nrotate-1] * nbase;
index1 = repmat(Plus,[length(Ypos),1]);
Ypos = repmat(Ypos(:),[Nrotate,1])+ index1(:);
index2 = repmat(Plus,[length(Ynegative),1]);
Ynegative = repmat(Ynegative(:),[Nrotate,1]) + index2(:);