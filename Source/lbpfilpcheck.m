function filpmapping= lbpfilpcheck(radius, neighbors)
addpath('D:\Tanmin\LSVM\lsvm\commom1');
addpath('D:\Tanmin\LSVM\lsvm\commom');
% if nargin < 1
%     spoints=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1]; 
%     spoints=[0 1; -1 1; -1 0; -1 -1; 0 -1; 1 -1; 1 0; 1 1];
% else
    spoints=zeros(neighbors,2);
% % %     Angle step.
    a = 2*pi/neighbors;   
    range = [1:neighbors];
    spoints(:,1) = -radius*sin((range-1)*a);
    spoints(:,2) = radius*cos((range-1)*a);
% end

neighbors = length(spoints);
filpmapping = zeros(2.^neighbors,1);

%%%%find mid point and rules
theta = (-atan2(spoints(:,1),spoints(:,2)))/pi*180;
index = (find(theta < 0));
theta(index) = 360 + theta(index);
distheta = min(abs(theta(2) - theta(1)),abs(theta(3) - theta(2)));

Sytheta = 180-theta;
index = (find(Sytheta < 0));
Sytheta(index) = 360 + Sytheta(index);

mididex = find( abs(theta - Sytheta(1)) < distheta);
mididex = sort(mididex);
mid = mididex(1);
mid = neighbors - mid;

for i = 0:(2^neighbors-1)
    ibit = dec2bin(i,neighbors);
    if mid > 0
        ibit1 = ibit(1:mid);
        num1 = bin2dec(ibit1(end:-1:1));
        num1 = num1*2.^(neighbors - mid);
    else
        num1 = 0;
    end    
    ibit2 = ibit(mid+1:end);
    num2 = bin2dec(ibit2(end:-1:1));
    filpmapping(i+1) = num1 + num2;
end

%%%%testing
slbp.radius= 1;
slbp.neighbors = neighbors;
slbp.spoints = spoints;
im = rand([128,56]);
im = uint8(im*255);
im = color(im);
sbin = 8;
im = VirBySbin(im,sbin);
im = uint8(im);
im = padarray(im,[slbp.radius,slbp.radius],'replicate');
im = rgb2gray(im);
im1 = im(:,end:-1:1);
slbp.mapping.table = [];
result = lbp_point(im,slbp.neighbors, slbp.spoints,slbp.mapping, true);
result1 = lbp_point(im1,slbp.neighbors, slbp.spoints,slbp.mapping, true);
result2 = result1(:,end:-1:1);
mapresult = uint8(filpmapping(result2+1));
if nnz(mapresult - result)~=0
    [a,b] = find(mapresult ~= result)
    error('no ,some error');
else
    fprintf('yes\n');
end

mapresult2 = uint8(filpmapping(result+1));
if nnz(mapresult2 - result2)~=0
    [a,b] = find(mapresult2 ~= result2)
    error('no ,some error');
else
    fprintf('yes\n');
end

MAPPINGTYPE = {'u2','ri','riu2','non'};
for j = 1:length(MAPPINGTYPE)
    mapping = getmapping(neighbors,MAPPINGTYPE{j});
    code = mapping.table + 1;%%%%%
    codeflip = mapping.table(filpmapping+1) + 1;
    clear 'filpindex'
    filpindex(codeflip) = code;   
    sz = [sbin,sbin];     
    mresult = lbp_point(im,slbp.neighbors, slbp.spoints,mapping, true);  
    mresult = densehistN(double(mresult),[2*sbin,2*sbin],sz,mapping.num); 

    mresult1 = lbp_point(im1,slbp.neighbors, slbp.spoints,mapping, true);
    mresult1 = densehistN(double(mresult1),[2*sbin,2*sbin],sz,mapping.num);    

    mmapresult = mresult(:,end:-1:1,filpindex);     
    if nnz(mmapresult - mresult1)~=0
        [a,b] = find(mmapresult ~= mresult1)
        error('no ,mappping error');
    else
        fprintf('mapping yes\n');
    end
    nnz(sort(filpindex) - [1:length(filpindex)])
end

