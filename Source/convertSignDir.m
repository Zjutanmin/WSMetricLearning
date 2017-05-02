function convertSignDir(imagedir, dataname)
fn = [imagedir dataname '_d'];
if ~exist(fn)
    mkdir(fn);
end
oldfn = [imagedir dataname];
try
    load([fn '\Trainstr.mat'], 'Trainstr');
catch
    Trainstr = Readdata_Sign(oldfn, fn);
    save([fn '\Trainstr.mat'], 'Trainstr');
end