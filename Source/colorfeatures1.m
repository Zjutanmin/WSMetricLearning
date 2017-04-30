function feat = colorfeatures(im,sbin,imageid,overlap,cache,descriptor)
load('D:\Tanmin\LSVM\lsvm\commom\colortable.mat');

descriptor = colortable.descriptors{descriptor};
im = VirBySbin(im,sbin,sbin);
imsize = round(size(im)/sbin -2);
fn=[cache,'imtmp',num2str(imageid),'.png'];
outfn = [cache,'output',num2str(imageid)];
imwrite(uint8(im),fn);
logofn = [cache,'log',num2str(imageid),'.txt'];
cmd = sprintf('colorDescriptor %s --detector densesampling --descriptor %s --ds_spacing %d --outputFormat binary --output %s >"%s"',...
    fn,descriptor,sbin,outfn,logofn);
status = dos(cmd);  
imsize = imsize(1:2);
[feat, f, dim] = readBinaryDescriptors(outfn);
dos(['del "',fn,'"']);
dos(['del "',outfn,'"']);
dos(['del "',logofn,'"']);
map = (reshape([1:size(feat,1)],[imsize(2),imsize(1)]))';    
feat = feat(map(:),:);
feat = reshape(feat,[imsize,dim]);
% feat = overlapfeat(feat,overlap);
% spacing = 2-overlap;
% feat = feat(1:spacing:end,1:spacing:end,:);  
feat = normalize(feat,3);
feat(:,:,end+1) = 0; 