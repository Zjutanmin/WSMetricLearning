%LBP returns the local binary pattern image or LBP histogram of an image.
%  J = LBP(I,R,N,MAPPING,MODE) returns either a local binary pattern
%  coded image or the local binary pattern histogram of an intensity
%  image I. The LBP codes are computed using N sampling points on a 
%  circle of radius R and using mapping table defined by MAPPING. 
%  See the getmapping function for different mappings and use 0 for
%  no mapping. Possible values for MODE are
%       'h' or 'hist'  to get a histogram of LBP codes
%       'nh'           to get a normalized histogram
%  Otherwise an LBP code image is returned.
%
%  J = LBP(I) returns the original (basic) LBP histogram of image I
%
%  J = LBP(I,SP,MAPPING,MODE) computes the LBP codes using n sampling
%  points defined in (n * 2) matrix SP. The sampling points should be
%  defined around the origin (coordinates (0,0)).
%
%  Examples
%  --------
%       I=imread('rice.png');
%       mapping=getmapping(8,'u2'); 
%       H1=LBP(I,1,8,mapping,'h'); %LBP histogram in (8,1) neighborhood
%                                  %using uniform patterns
%       subplot(2,1,1),stem(H1);
%
%       H2=LBP(I);
%       subplot(2,1,2),stem(H2);
%
%       SP=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
%       I2=LBP(I,SP,0,'i'); %LBP code image using sampling points in SP
%                           %and no mapping. Now H2 is equal to histogram
%                           %of I2.
function result = lbp_point(image,mapping,lbppara,vir)
esp =10e-6;
id1 = lbppara.id1;
id2 = lbppara.id2;
v1 = lbppara.v1;
v2 = lbppara.v2;
w1 = lbppara.w1;
w2 = lbppara.w2;
w3 = lbppara.w3;
w4 = lbppara.w4;

cx = lbppara.cx;
cy = lbppara.cy;
fx = lbppara.fx;
fy = lbppara.fy;
rx = lbppara.rx;
ry = lbppara.ry;

bsizey = lbppara.bsizey;
bsizex = lbppara.bsizex;

origy =lbppara.origy;
origx =lbppara.origx;


[ysize xsize] = size(image);
d_image=double(image);

dx = xsize - bsizex;
dy = ysize - bsizey;

C = image(origy:origy+dy,origx:origx+dx);
d_C = double(C);

% Initialize the result matrix with zeros.
result=zeros(dy+1,dx+1);
for i = 1:length(id1)
    N = image(ry(id1(i)):ry(id1(i))+dy,...
        rx(id1(i)):rx(id1(i))+dx);
    D = N > C;
    result = result + v1(i)*D;
end
for i = 1:length(id2)
    N = w1(i)*d_image(fy(i):fy(i)+dy,fx(i):fx(i)+dx) + w2(i)*d_image(fy(i):fy(i)+dy,cx(i):cx(i)+dx) + ...
        w3(i)*d_image(cy(i):cy(i)+dy,fx(i):fx(i)+dx) + w4(i)*d_image(cy(i):cy(i)+dy,cx(i):cx(i)+dx);
    D = (N - d_C)>esp; 
    result = result + v2(i)*D;
end
if ~isempty(mapping.table)
    result = mapping.table(result+1);
end
% result=uint8(result);

if ~vir
    tmp = result;
    result = zeros(size(image));
    result(origy:origy+dy,origx:origx+dx) = tmp;
end
