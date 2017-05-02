function flipindex = lbpflipmapping(spoints,mapping)
neighbors = length(spoints);
flipmapping = zeros(2.^neighbors,1);

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
    flipmapping(i+1) = num1 + num2;
end
%%%%f,flipmapping:  x 1~256  0~255
%%%%g,mapping.table x 1~256  0~58
% x--f(x)--g(x)
% x--g(x)
% ??x--g(x)
%  ? x--gf(x)
% g(x)---g(f(x))
org = [0:(2^neighbors-1)];
if nnz(flipmapping(flipmapping(org+1)+1)-org')~=0
    error('error,not symmtric');
end

code = mapping.table + 1;
codeflip = mapping.table(flipmapping+1) + 1;
flipindex(codeflip) = code; 
if (nnz(sort(flipindex) - [1:length(flipindex)]) ~= 0)
    error('no ,flipindex can not denote a mapping\n');
end

flipindex(mapping.num) = mapping.num;