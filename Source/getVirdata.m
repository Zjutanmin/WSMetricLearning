function getVirdata
if strcmp(dataname, 'Sign_NewT4')
    index1 = find(len >= 8);
    index1 = setdiff(index1, index);
    aa = a(index1);
    %%%Max num 24
    maxnum = 24;Rotate = [5,8,10,15];Rlabel = [-1, 1];dis = 2;
    [a, b, c] = unique(setting.ts_Fold_label); 
    for ii = 1:length(aa)
        ccname = database.cname(aa(ii));
        idx = find(setting.ts_Fold_label == aa(ii));
        orgfold = length(idx);
        Virfold = maxnum - orgfold;
        ord = randperm(Virfold);
        if Virfold <= length(idx)
            idx = idx(ord(1:Virfold));
        end
        Round = ceil(Virfold  / orgfold);
        cur = 0;
        for kkk = 1:Round
            if cur > Virfold
                break;
            end
        Virsubname = Asubname(idx);
        for jj = 1:length(Virsubname)
            if cur > Virfold
                break;
            end
            
            cur = cur+1;
            tid = randperm(2);
            sidx = find(idx(jj) == setting.ts_fold_idx);
            rot = Rlabel(tid(1)) * rand(1) * Rotate(kkk);
            for kk = 1:length(sidx)
                idd = randperm(2);
                rott = rot + Rlabel(idd(1)) * rand(1) * dis;
                img = imread(ts_imname{sidx(kk)});
                [dirf, name, ext] = fileparts(ts_imname{sidx(kk)});
                idt = strfind(dirf, '\');
                idt = strfind(name, '_');idt = idt(end-1);
                imname = [name(1:idt-1),'C',num2str(kkk),name(idt:end), ext];
                namenew = fullfile(dirf, imname);
                imgr = imrotate(img, rott, 'crop');
                J = imnoise(imgr,'gaussian');
                imwrite(J, namenew);           
            end
        end
        end
    end
    
end