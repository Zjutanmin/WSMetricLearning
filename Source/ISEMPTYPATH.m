function is_Emptydir = ISEMPTYPATH(file_path)
s = dir(file_path);
names = fieldnames(s);
fieldIdx = find(cellfun(@(x) strcmp(x, 'bytes'), names));
cs = struct2cell(s);
is_Emptydir = sum(cell2mat(cs(fieldIdx, :))) == 0;
