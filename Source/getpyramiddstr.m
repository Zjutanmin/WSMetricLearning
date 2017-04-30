function setting = getpyramiddstr(setting)
if isfield(setting, 'pyramid')
str = '';
if length(setting.pyramid) == 3 && ~nnz(setting.pyramid - [1, 2, 4])
else
    str = [str '_p'];
    for jj = 1:length(setting.pyramid)
        str = [str num2str(setting.pyramid(jj))];
    end
end
setting.pyramidstr = str;
end
if ~mod(setting.latent, 5)
    return;
end
setting.latentstr = (num2str(setting.displace'))';
switch setting.latent
    case 2
        setting.latentstr = [setting.latentstr, str];
    case 3
        setting.latentstr = [setting.latentstr '_FPY' num2str(setting.Fpyramid)];
end