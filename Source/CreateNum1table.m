function BitCount = CreateNum1table(maxk)
BitCount.N = maxk;
table = uint8(zeros(2.^(maxk+1), 1));
for i = 0:2.^(maxk+1)-1
    table(i+1) = getnumof1(i);
end
BitCount.table = table;