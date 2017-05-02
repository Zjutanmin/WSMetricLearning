%ltp returns the local binary pattern image or ltp histogram of an image.
%  J = ltp(I,R,N,MAPPING,MODE) returns either a local binary pattern
%  coded image or the local binary pattern histogram of an intensity
%  image I. The ltp codes are computed using N sampling points on a 
%  circle of radius R and using mapping table defined by MAPPING. 
%  See the getmapping function for different mappings and use 0 for
%  no mapping. Possible values for MODE are
%       'h' or 'hist'  to get a histogram of ltp codes
%       'nh'           to get a normalized histogram
%  Otherwise an ltp code image is returned.
%
%  J = ltp(I) returns the original (basic) ltp histogram of image I
%
%  J = ltp(I,SP,MAPPING,MODE) computes the ltp codes using n sampling
%  points defined in (n * 2) matrix SP. The sampling points should be
%  defined around the origin (coordinates (0,0)).
%
%  Examples
%  --------
%       I=imread('rice.png');
%       mapping=getmapping(8,'u2'); 
%       H1=ltp(I,1,8,mapping,'h'); %ltp histogram in (8,1) neighborhood
%                                  %using uniform patterns
%       subplot(2,1,1),stem(H1);
%
%       H2=ltp(I);
%       subplot(2,1,2),stem(H2);
%
%       SP=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
%       I2=ltp(I,SP,0,'i'); %ltp code image using sampling points in SP
%                           %and no mapping. Now H2 is equal to histogram
%                           %of I2.
function [uresult, lresult] = ltp_pointr(image,mapping,thresh,ltppara,vir)
esp =10e-6;
thresh = max(thresh, eps);
id1 = ltppara.id1;
id2 = ltppara.id2;
v1 = ltppara.v1;
v2 = ltppara.v2;
w1 = ltppara.w1;
w2 = ltppara.w2;
w3 = ltppara.w3;
w4 = ltppara.w4;

cx = ltppara.cx;
cy = ltppara.cy;
fx = ltppara.fx;
fy = ltppara.fy;
rx = ltppara.rx;
ry = ltppara.ry;

bsizey = ltppara.bsizey;
bsizex = ltppara.bsizex;

origy =ltppara.origy;
origx =ltppara.origx;


[ysize xsize] = size(image);
d_image=double(image);

dx = xsize - bsizex;
dy = ysize - bsizey;

C = image(origy:origy+dy,origx:origx+dx);
d_C = double(C);

% Initialize the uresult matrix with zeros.
uresult=zeros(dy+1,dx+1);
for i = 1:length(id1)
    N = image(ry(id1(i)):ry(id1(i))+dy,...
        rx(id1(i)):rx(id1(i))+dx);
    D = (N - C ) > thresh;
    uresult = uresult + v1(i)*D;
end
for i = 1:length(id2)
    N = w1(i)*d_image(fy(i):fy(i)+dy,fx(i):fx(i)+dx) + w2(i)*d_image(fy(i):fy(i)+dy,cx(i):cx(i)+dx) + ...
        w3(i)*d_image(cy(i):cy(i)+dy,fx(i):fx(i)+dx) + w4(i)*d_image(cy(i):cy(i)+dy,cx(i):cx(i)+dx);
%     D = (N - d_C)>esp; 
    D = (N - d_C) > thresh;
    uresult = uresult + v2(i)*D;
end

% Initialize the lresult matrix with zeros.
lresult=zeros(dy+1,dx+1);
for i = 1:length(id1)
    N = image(ry(id1(i)):ry(id1(i))+dy,...
        rx(id1(i)):rx(id1(i))+dx);
    D = (N - C ) < -thresh;
    lresult = lresult + v1(i)*D;
end
for i = 1:length(id2)
    N = w1(i)*d_image(fy(i):fy(i)+dy,fx(i):fx(i)+dx) + w2(i)*d_image(fy(i):fy(i)+dy,cx(i):cx(i)+dx) + ...
        w3(i)*d_image(cy(i):cy(i)+dy,fx(i):fx(i)+dx) + w4(i)*d_image(cy(i):cy(i)+dy,cx(i):cx(i)+dx);
%     D = (N - d_C)>esp; 
    D = (N - d_C) < -thresh;
    lresult = lresult + v2(i)*D;
end


if ~isempty(mapping.table)
    uresult = mapping.table(uresult+1);
    lresult = mapping.table(lresult+1);
end
if ~vir
    tmp = uresult;
    uresult = zeros(size(image));
    uresult(origy:origy+dy,origx:origx+dx) = tmp;
    
    tmp = lresult;
    lresult = zeros(size(image));
    lresult(origy:origy+dy,origx:origx+dx) = tmp;
end