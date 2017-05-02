function lbppara = lbp_para(neighbors,spoints)
range = [1:neighbors];
miny=min(spoints(:,1));
maxy=max(spoints(:,1));
minx=min(spoints(:,2));
maxx=max(spoints(:,2));

% Block size, each LBP code is computed within a block of size bsizey*bsizex
bsizey=ceil(max(maxy,0))-floor(min(miny,0))+1;
bsizex=ceil(max(maxx,0))-floor(min(minx,0))+1;

% Coordinates of origin (0,0) in the block
origy=1-floor(min(miny,0));
origx=1-floor(min(minx,0));

%Compute the LBP code image
y = spoints(:,1)+origy;
x = spoints(:,2)+origx;
fy = floor(y); cy = ceil(y); ry = round(y);
fx = floor(x); cx = ceil(x); rx = round(x);
id1 = find(double((abs(x - rx) < 1e-6)).*double((abs(y - ry) < 1e-6))==1);
v1 = 2.^(id1-1);

id2 = setdiff(range,id1);
fy = fy(id2);
cy = cy(id2);
cx = cx(id2);
fx = fx(id2);

ty = y(id2) - fy;
tx = x(id2) - fx;
%Calculate the interpolation weights.
w1 = (1 - tx) .* (1 - ty);w1 = savedot(w1,4);
w2 =      tx  .* (1 - ty);w2 = savedot(w2,4);
w3 = (1 - tx) .*      ty ;w3 = savedot(w3,4);
w4 =      tx  .*      ty ;w4 = savedot(w4,4);
% w1 = (1 - tx) .* (1 - ty);
% w2 =      tx  .* (1 - ty);
% w3 = (1 - tx) .*      ty ;
% w4 =      tx  .*      ty ;
v2 = 2.^(id2-1);

lbppara.id1 = id1;
lbppara.id2 = id2;
lbppara.v1 = v1;
lbppara.v2 = v2;
lbppara.w1 = w1;
lbppara.w2 = w2;
lbppara.w3 = w3;
lbppara.w4 = w4;

lbppara.cx = cx;
lbppara.cy = cy;
lbppara.fx = fx;
lbppara.fy = fy;
lbppara.rx = rx;
lbppara.ry = ry;

lbppara.bsizey = bsizey;
lbppara.bsizex = bsizex;

lbppara.origy = origy;
lbppara.origx = origx;