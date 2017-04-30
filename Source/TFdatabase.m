function database = TFdatabase(database, dir)
for i = 1:length(database.path)
    str = database.path{i};
    id = find(str == '\');
    name = str(id(end-1)+1:end);
    name(end - 3:end) = '.jpg';
    database.path{i} = fullfile(dir, name);
end