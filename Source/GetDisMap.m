function dfeat2 = GetDisMap(setting)
dfeat2 = cell(1, length(setting.displace));
for i = 1:length(setting.displace)
    si = setting.displace(i);
    dfeat2{i} = zeros([si*2+1, si*2+1]);
    jj = 0;
    for t1 = -si:si
        for t2 = -si:si
            jj = jj + 1;
            dfeat2{i}(t1+si+1, t2+si+1)  = jj;
        end
    end
end