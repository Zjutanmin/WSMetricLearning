function  [Fname, Sname]= GetFoldName(fdir, str, DEL)
if nargin < 2
    str = 'test_';
end
if nargin < 3
    DEL = 0;
end
SP =  '_rectified';
ffn = dir(fullfile(fdir, [str '*.jpg']));
Sname = {};Fname = {};
tt = 0;
for kk = 1:length(ffn)
    if strcmp(ffn(kk).name(1:5), 'train')
        continue
    end
    if isempty(strfind(ffn(kk).name, '_'))
        continue
    end
   tt = tt + 1;
   Sname{tt} = ffn(kk).name; 
   
   [~,b,c] =fileparts(Sname{tt});
   if strcmp(b(end-length(SP)+1:end),SP)
       ORG = Sname{tt};
       Sname{tt} = [b(1:end-length(SP)), c];
       imwrite(imread(fullfile(fdir, ORG)), Sname{tt})
       dos(['del ' fullfile(fdir, ORG)])
   end
   
   
   if DEL ~= 0
       [~,b,c] =fileparts(Sname{tt});
   if DEL == 1
       range = [1:length(str)];
       range1 = [length(str)+1:length(b)];
   end
   if DEL == -1
       range = [length(b)-length(str)+1:length(b)];
       range1 = [1:length(b)-length(str)];
   end
   if strcmp(b(range),str)
       ORG = Sname{tt};
       Sname{tt} = [b(range1), c];
       imwrite(imread(fullfile(fdir, ORG)), Sname{tt})
       dos(['del ' fullfile(fdir, ORG)])
   end
   end
   index = strfind(Sname{tt}, '_');
   Fname{tt} = Sname{tt}(1:index(end-1)-1); 
end