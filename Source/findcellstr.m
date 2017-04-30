function index = findcellstr(cellstr, str)
index = find(~cellfun(@isempty, strfind(cellstr, str)));