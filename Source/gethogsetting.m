function hogindex = gethogsetting(nbin) 
cell = 180 / nbin;
if (round(cell) ~= cell)
    sprintf('error: nbin must be divisibility by 180');
    pause;
end

hogindex(1:nbin+1) = [nbin+1:-1:1];
hogindex(nbin+2:2*nbin) = [2*nbin:-1:nbin+2];
hogindex(2*nbin+1:3*nbin) = [2*nbin+1, 3*nbin:-1:2*nbin+2];
npad = [3*nbin+1:3*nbin+4];
hogindex(3*nbin+1:3*nbin+2) = [npad(3:4)];
hogindex(3*nbin+3:3*nbin+4) = [npad(1:2)];

% hogindex = [10 9 8 7 6 5 4 3 2 1 18 17 16 15 14 13 12 11 19 27 26 25 24 23 ...
%                 22 21 20 30 31 28 29];
% hogindex1 = [10 9 8 7 6 5 4 3 2 1 18 17 16 15 14 13 12 11 19 27 26 25 24 23 ...
%     22 21 20 30 31 28 29];
% nnz(hogindex1 - hogindex)