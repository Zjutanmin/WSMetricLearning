function [TNfold, Nfold] = GetFoldN(RRatiostr)
RRatiostr
Nfold = 1;
t = 1;
while round(Nfold / RRatiostr)~= 0
    t = t+1;
    Nfold = Nfold + 1;
    TNfold = Nfold / RRatiostr;
    if t > 10e3
        s = input('Input two inter var, Nfold, TNfold:\r\n', 's'); 
        ferror = 0;
        try
            id = find(s == ',');Nfold = str2num(s(1:id(1) - 1));TNfold = str2num(s(id(1) + 1:end));
            if TNfold <= Nfold || round(TNfold) ~= TNfold || round(Nfold) ~= Nfold
                    ferror = 1;
            end
        catch
            ferror = 1;
        end
        while ferror
            s = input('Input two inter var, Nfold, TNfold:\r\n', 's'); 
            ferror = 0;
            try
                id = find(s == ',');
                Nfold = str2num(s(1:id(1) - 1))
                TNfold = str2num(s(id(1) + 1:end))
                if TNfold <= Nfold || round(TNfold) ~= TNfold || round(Nfold) ~= Nfold
                    ferror = 1;
                end
            catch
                ferror = 1;
            end
        end
        break
    end
end