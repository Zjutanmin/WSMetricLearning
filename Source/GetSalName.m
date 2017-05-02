function Salname = GetSalName(img_ts_imname)
Salname = cell(1, length(img_ts_imname));
if length(img_ts_imname) < 1
    return;
end
sufx = findstr(img_ts_imname{1}, 'image') + length('image') - 1;

for i = 1:length(img_ts_imname)
    Salname{i} = ['Sal' img_ts_imname{i}(sufx+1:end-4) '.png'];
end