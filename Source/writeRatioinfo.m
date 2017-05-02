function writeRatioinfo(img_dir, ratio_dir)
load(fullfile(img_dir, 'Trainstr.mat'), 'Trainstr', 'TrainAlpha', 'datastruct', 'datastruct_test');
if ~exist(ratio_dir)
    mkdir(ratio_dir);
end
%%%for training
nameindex = strfind(datastruct.name, '#FileName');
b = cellfun('isempty',nameindex); b = find(b ~= 1);
nameindex = strfind(datastruct.name, 'AspectRatio');
b1 = cellfun('isempty',nameindex); b1 = find(b1 ~= 1);
Tratio = zeros(1, length(datastruct.value));
for i = 1:length(datastruct.value)
    name = datastruct.value{i}{b};
    ffile = fullfile(ratio_dir, [name(1:end - 4) '_Ratio.mat']);
    try
        load(ffile, 'ratio');
    catch
        ratio = str2num(datastruct.value{i}{b1});
        save(ffile, 'ratio');
    end
    Tratio(i) = ratio;
end

%%%for tseting
nameindex = strfind(datastruct_test.name, '#FileName');
b = cellfun('isempty',nameindex); b = find(b ~= 1);
    
    nameindex = strfind(datastruct_test.name, 'ULX');
    b1 = cellfun('isempty',nameindex); b1 = find(b1 ~= 1);
    nameindex = strfind(datastruct_test.name, 'ULY');
    b2 = cellfun('isempty',nameindex); b2 = find(b2 ~= 1);
    nameindex = strfind(datastruct_test.name, 'ULZ');
    b3 = cellfun('isempty',nameindex); b3 = find(b3 ~= 1);
    
    nameindex = strfind(datastruct_test.name, 'URX');
    b4 = cellfun('isempty',nameindex); b4 = find(b4 ~= 1);
    nameindex = strfind(datastruct_test.name, 'URY');
    b5 = cellfun('isempty',nameindex); b5 = find(b5 ~= 1);
    nameindex = strfind(datastruct_test.name, 'URZ');
    b6 = cellfun('isempty',nameindex); b6 = find(b6 ~= 1);
    
    nameindex = strfind(datastruct_test.name, 'LLX');
    b7 = cellfun('isempty',nameindex); b7 = find(b7 ~= 1);
    nameindex = strfind(datastruct_test.name, 'LLY');
    b8 = cellfun('isempty',nameindex); b8 = find(b8 ~= 1);
    nameindex = strfind(datastruct_test.name, 'LLZ');
    b9 = cellfun('isempty',nameindex); b9 = find(b9 ~= 1);
    
    nameindex = strfind(datastruct_test.name, 'LRX');
    b10 = cellfun('isempty',nameindex); b10 = find(b10 ~= 1);
    nameindex = strfind(datastruct_test.name, 'LRY');
    b11 = cellfun('isempty',nameindex); b11 = find(b11 ~= 1);
    nameindex = strfind(datastruct_test.name, 'LRZ');
    b12 = cellfun('isempty',nameindex); b12 = find(b12 ~= 1);
    
    for i = 1:length(datastruct_test.value)
        name = datastruct_test.value{i}{b};
        ffile = fullfile(ratio_dir, [name(1:end - 4) '_Ratio.mat']);
        
        try
            load(ffile, 'ratio');
        catch
            dx = (str2num(datastruct_test.value{i}{b10}) - str2num(datastruct_test.value{i}{b7}) + ...
                str2num(datastruct_test.value{i}{b4}) - str2num(datastruct_test.value{i}{b1})) / 2;
            
            dy = (str2num(datastruct_test.value{i}{b8}) - str2num(datastruct_test.value{i}{b2}) + ...
                str2num(datastruct_test.value{i}{b11}) - str2num(datastruct_test.value{i}{b5})) / 2;
            
            ratio = dx / dy;            
            save(ffile, 'ratio');
        end
    end