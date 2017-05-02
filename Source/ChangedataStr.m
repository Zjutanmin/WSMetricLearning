function ChangedataStr(imagedir, dataname, iomyself)
if ~iomyself
    return;
end
switch dataname
    case 'Sign'
        convertSignDir(imagedir, dataname);
end