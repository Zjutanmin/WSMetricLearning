function oldName = RenameOldConvention(newName)
nameNew = 'Truth_Rectified_';
[mapEntity res] = strtok(newName, '_');
[imagenum res] = strtok(res, '_');
[imageindex res] = strtok(res, '.');
oldName = strcat(nameNew, imagenum, '_', imageindex(2:end),'_', mapEntity(1:end), '.jpg');