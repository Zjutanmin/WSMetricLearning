function ltpsetting = getltpsetting(ltpsetting) 
if ~isfield(ltpsetting,'radius')
    ltpsetting.spoints=[0 1; -1 1; -1 0; -1 -1; 0 -1; 1 -1; 1 0; 1 1];
% %     form the mid-right
    ltpsetting.pointtype = 'r';
    ltpsetting.neighbors=8;
    ltpsetting.mapping=0;
    ltpsetting.mode='h';
    ltpsetting.radius = 1;
    ltpsetting.MAPPINGTYPE='u2';
else
    ltpsetting.spoints=zeros(ltpsetting.neighbors,2);
% % %     Angle step.
    a = 2*pi/ltpsetting.neighbors;   
    range = [1:ltpsetting.neighbors];
    ltpsetting.spoints(:,1) = -ltpsetting.radius*sin((range-1)*a);
    ltpsetting.spoints(:,2) = ltpsetting.radius*cos((range-1)*a);
    ltpsetting.pointtype = 'c';
end
ltpsetting.spoints = savedot(ltpsetting.spoints,4);
if ~isfield(ltpsetting,'mapping')
    ltpsetting.MAPPINGTYPE = 'u2';
end
if ~isfield(ltpsetting,'mode')
        ltpsetting.mode='h';
end   
ltpsetting.mapping=getmapping(ltpsetting.neighbors,ltpsetting.MAPPINGTYPE);
ltpsetting.str = [num2str(ltpsetting.radius),'_',...
    num2str(ltpsetting.neighbors),ltpsetting.pointtype,...
    ltpsetting.MAPPINGTYPE];
load('lbptable.mat');
index = find(ismember(lbptable.mappingtype,ltpsetting.MAPPINGTYPE)==1);
ltpsetting.bins = ltpsetting.mapping.num;
ltpsetting.ltppara = lbp_para(ltpsetting.neighbors,ltpsetting.spoints);

ltpsetting.featsize = lbptable.featsize{index} * 2;
ltpsetting.flipindex = lbpflipmapping(ltpsetting.spoints,ltpsetting.mapping);
nexist = length(ltpsetting.flipindex);
ltpsetting.flipindex = [ltpsetting.flipindex, ltpsetting.flipindex + nexist];
% repmat(ltpsetting.flipindex, [1,2]);