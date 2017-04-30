% function [X,LX,NX,T,LT,NT] = readMNIST()
%=========== training images
path = 'image\digit_MNIST\MNIST\train-images.idx3-ubyte';
fid = fopen(path,'r','b');  %big-endian
magicNum = fread(fid,1,'int32');    %Магическое числ?
if(magicNum~=2051) 
    display('Error: cant find magic number');
    return;
end
imgNum = fread(fid,1,'int32');  %Количество изображени?
rowSz = fread(fid,1,'int32');   %Размер изображени?по вертикал?
colSz = fread(fid,1,'int32');   %Размер изображени?по горизонтал?

% if(num<imgNum) 
%     imgNum=num; 
% end

X=zeros(rowSz*colSz,imgNum,'uint8');
for k=1:imgNum 
        im = uint8(fread(fid,[colSz rowSz],'uchar'))';
        % MINST stores row-wise, MATLAB reads column-wise
        X(:,k)=im(:);      
end
fclose(fid);

%============ training labels
path = 'image\digit_MNIST\MNIST\train-labels.idx1-ubyte';
fid = fopen(path,'r','b');  % big-endian
magicNum = fread(fid,1,'int32');    %Магическое числ?
if(magicNum~=2049) 
    display('Error: cant find magic number');
    return;
end
itmNum = fread(fid,1,'int32');  %Количество мето?

% if(num<itmNum) 
%     itmNum=num; 
% end

LX = uint8(fread(fid,[1 itmNum],'uint8'));   %Загружае?вс?метк?

fclose(fid);

%============ test images
path = 'image\digit_MNIST\MNIST\t10k-images.idx3-ubyte';
fid = fopen(path,'r','b');  % big-endian
magicNum = fread(fid,1,'int32');    %Магическое числ?
if(magicNum~=2051) 
    display('Error: cant find magic number');
    return;
end
imgNum = fread(fid,1,'int32');  %Количество изображени?
rowSz = fread(fid,1,'int32');   %Размер изображени?по вертикал?
colSz = fread(fid,1,'int32');   %Размер изображени?по горизонтал?

% if(num<imgNum) 
%     imgNum=num; 
% end
T=zeros(rowSz*colSz,imgNum,'uint8');
for k=1:imgNum
        im = uint8(fread(fid,[colSz rowSz],'uchar'))';
        T(:,k)=im(:);
end
fclose(fid);

%============ test labels
path = 'image\digit_MNIST\MNIST\t10k-labels.idx1-ubyte';
fid = fopen(path,'r','b');  % big-endian
magicNum = fread(fid,1,'int32');    %Магическое числ?
if(magicNum~=2049) 
    display('Error: cant find magic number');
    return;
end
itmNum = fread(fid,1,'int32');  %Количество мето?
% if(num<itmNum) 
%     itmNum=num; 
% end
LT = uint8(fread(fid,[1 itmNum],'uint8'));   %Загружае?вс?метк?

fclose(fid);



%--------------- post processing: store the data by digit class
% % % % % [LX,idx]=sort(LX);
% % % % % X=X(:,idx);
% % % % % for i=0:9
% % % % %     NX(i+1)=nnz(LX==uint8(i));
% % % % % end
% % % % % 
% % % % % [LT,idx]=sort(LT);
% % % % % T=T(:,idx);
% % % % % for i=0:9
% % % % %     NT(i+1)=nnz(LT==uint8(i));
% % % % % end
% % % % % 
% % % % % save MINST X LX NX T LT NT
% % % % % 0;

