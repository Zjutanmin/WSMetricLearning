function inum = getnumof1(i, maxk)
inum = 0;
while i
%     dec2bin(i)
    inum = inum + bitand(i, 1);
    i = bitshift(i, -1); 
end
