function ChangedataStr_S(imagedir, dataname, iomyself, str, templateDir, foldname, rename, filename, outdir)
if ~iomyself
    return;
end
switch dataname
    case 'Sign'
        convertSignDir_S(imagedir, dataname, str, templateDir, foldname, rename, filename, outdir);
end