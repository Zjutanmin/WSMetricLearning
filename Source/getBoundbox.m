function [range1, range2] = getBoundbox(l, xi, yi, displace, rawsize, fsize)
    si = displace(l);
    currsize = currsize1 + [2,2] * si;
    swin1 = round( [rawsize(1)] ./ (currsize(1)+2));
    swin2 = round( [rawsize(2)] ./ (currsize(2)+2));
    if swin2 ~= swin1
        fprintf('swin1 != swin2')
        pause;
    end
    range1 = [(xi) * swin1 + 1 : (fsize(1)+xi+1) * swin1];
    range2 = [(yi) * swin1 + 1 : (fsize(2)+yi+1) * swin1];