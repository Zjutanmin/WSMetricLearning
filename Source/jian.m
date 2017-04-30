oldfile = 'a01_s01_e01_sdepth.bin';
[a,b,c,d]  = textread(oldfile, '%f%f%f%f',  'delimiter', ' ');
% 
% fin = fopen(oldfile, 'rb');
% % dim = 4;
% dim = 16588812;
% i = 0;
% while ~feof(fin)
%     i = i + 1;
% %     cc{i} = fgets(fin);
%     
%     x = fread(fin, dim, 'double');
%     y(i,:) = x';
%     
% end
% t = 1;
% = 