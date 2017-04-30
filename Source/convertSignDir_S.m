function convertSignDir_S(imagedir, dataname, str, templateDir, foldname, rename, filename, outdir)
fn = [imagedir dataname str];
if ~exist(fn)
    mkdir(fn);
end
oldfn = [imagedir dataname];
[Trainstr, TrainAlpha, datastruct, datastruct_test] = Readdata_Sign_S(...
    oldfn, fn, templateDir, foldname, rename, filename, outdir);
save([fn '\Trainstr.mat'], 'Trainstr', 'TrainAlpha', 'datastruct', 'datastruct_test');