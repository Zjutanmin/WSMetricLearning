function AAim = GetAim(Aim, ccol, rrow, Margin)
if nargin < 2
    ccol = ceil(sqrt(length(Aim)));
    rrow = ceil(sqrt(length(Aim)));
end
if ccol == -1
    ccol = ceil(length(Aim) / rrow);
end
YesM = 0;
if nargin > 3
    YesM = 1;
else
    Margin = length(Aim) + 1;
end
if rrow  == -1
    rrow = ceil(length(Aim) / ccol);
end
diss = [0 0];
        psize = [size(Aim{1}, 1), size(Aim{1}, 2)];
        psize = [90,95];
        imsize  = ceil(1.1*psize) + mod(ceil(1.1*psize) - psize, 2);
        dis = (imsize - psize) /2;
        if YesM
            AAim = uint8(ones([[ccol, rrow] .* imsize, 3])*255);
        else
            AAim = uint8(ones([[ccol, rrow] .* imsize, 3])*128);
        end
        tt = 0;
        for i1 = 1:ccol
            for j1 = 1:rrow
                tt  = tt + 1;
                if tt > length(Aim)
                    break;
                end
                if ~mod(tt, Margin)
                    AAim((i1-1)*imsize(1)+diss(1)+1:i1*imsize(1)-diss(1), ...
                        (j1-1)*imsize(2)+diss(2)+1:j1*imsize(2)-diss(2), :) = 0;
                end
                AAim((i1-1)*imsize(1)+dis(1)+1:i1*imsize(1)-dis(1), ...
                    (j1-1)*imsize(2)+dis(2)+1:j1*imsize(2)-dis(2), :) = imresize(Aim{tt}, psize);
            end
        end
%         imshow((AAim))