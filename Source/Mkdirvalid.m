function Mkdirvalid(fn)
if ~exist(fn)   
    mkdir(fn); 
end