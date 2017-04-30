fn = 'sign detection_img\SignTemplates\_Metadata.tsv';
fid = fopen(fn, 'r');
fgetl(fid); %%% the first
spatten = sprintf('\t');
while ~feof(fid)
    str = fgetl(fid);
    i = i+1;
    index = strfind(str, spatten);
    text{i,1} = str(1:index(1)-1);
    for j = 2:length(index)
        text{i,j} = str(index(j-1)+1:index(j)-1);
    end
    text{i,j+1} = str(index(j)+1:end);
end
fclose(fid);