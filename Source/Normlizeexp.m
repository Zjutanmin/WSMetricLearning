function Cscore = Normlizeexp(Cscore, Ntype, onetype)
idxx = [1:length(Cscore)];
if strcmp(onetype(1), 'O')
    onetype = onetype(2:end);
    TH = min(Cscore(idxx))+0.5*(max(Cscore(idxx))-min(Cscore(idxx)));
    idxx = idxx(find(Cscore(idxx) >  TH));  
    Cscore(setdiff([1:length(Cscore)], idxx)) = 0;
end
Cscore(idxx) = Normlizeexp1(Cscore(idxx), Ntype, onetype);


function Cscore = Normlizeexp1(Cscore, Ntype, onetype)


% Normlizeexp(Cscore(idxx), setting.Ntype, setting.onetype);
thresh = max(Cscore);
justW = 0;
if length(onetype) > 5 && strcmp(onetype(1:5), 'worse')
    justW = 1;
    thresh = mean(Cscore);
    onetype = onetype(6:end);
end

NormT = 0;
if length(onetype) > 3
    if strcmp(onetype(1:3), 'max') || strcmp(onetype(1:3), 'min')
        NormMargin = str2num(onetype(4:end));
        NormT = 1;
    end
end

dis = (max(Cscore) - min(Cscore));
if dis == 0
    Cscore = exp(1)*ones(size(Cscore));
    if length(onetype) >= 3 && strcmp(onetype(1:3), 'max')
        Cscore(:) = 1;
    end
    if strcmp(onetype, 'sum')
        Cscore(:) = 1 / length(Cscore);
    end
else
    idx = find(Cscore <= thresh);
    Cscore1 = Cscore;
    
    Cscore = Cscore(idx);
    dis = (max(Cscore) - min(Cscore));
    if ~isempty(idx)
        Cscore = (Cscore - min(Cscore)) / dis;
        
        if NormT
            Cscore = Cscore * NormMargin - (NormMargin - 1);
        end
        
        Cscore = exp(Cscore);
        if length(onetype) >= 3 && strcmp(onetype(1:3), 'max')
            Cscore = Cscore / exp(1);
        end
        
        if strcmp(onetype, 'sum')
            Cscore(:) = 1 / length(Cscore);
        end
        Cscore1(:) = max(Cscore);
        if justW
            Cscore1(idx) = 0.5*(Cscore);
        else
            Cscore1(idx) = (Cscore);
        end
    end
    Cscore = Cscore1;
end