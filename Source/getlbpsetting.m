function lbpsetting = getlbpsetting(lbpsetting) 
if ~isfield(lbpsetting,'radius')
    lbpsetting.spoints=[0 1; -1 1; -1 0; -1 -1; 0 -1; 1 -1; 1 0; 1 1];
% %     form the mid-right
    lbpsetting.pointtype = 'r';
    lbpsetting.neighbors=8;
    lbpsetting.mapping=0;
    lbpsetting.mode='h';
    lbpsetting.radius = 1;
    lbpsetting.MAPPINGTYPE='u2';
else
    lbpsetting.spoints=zeros(lbpsetting.neighbors,2);
% % %     Angle step.
    a = 2*pi/lbpsetting.neighbors;   
    range = [1:lbpsetting.neighbors];
    lbpsetting.spoints(:,1) = -lbpsetting.radius*sin((range-1)*a);
    lbpsetting.spoints(:,2) = lbpsetting.radius*cos((range-1)*a);
    lbpsetting.pointtype = 'c';
end
lbpsetting.spoints = savedot(lbpsetting.spoints,4);
if ~isfield(lbpsetting,'mapping')
    lbpsetting.MAPPINGTYPE = 'u2';
end
if ~isfield(lbpsetting,'mode')
        lbpsetting.mode='h';
end   
lbpsetting.mapping=getmapping(lbpsetting.neighbors,lbpsetting.MAPPINGTYPE);
lbpsetting.str = [num2str(lbpsetting.radius),'_',...
    num2str(lbpsetting.neighbors),lbpsetting.pointtype,...
    lbpsetting.MAPPINGTYPE];
load('lbptable.mat');
index = find(ismember(lbptable.mappingtype,lbpsetting.MAPPINGTYPE)==1);
lbpsetting.featsize = lbptable.featsize{index};
lbpsetting.bins = lbpsetting.mapping.num;
lbpsetting.flipindex = lbpflipmapping(lbpsetting.spoints,lbpsetting.mapping);
lbpsetting.lbppara = lbp_para(lbpsetting.neighbors,lbpsetting.spoints);