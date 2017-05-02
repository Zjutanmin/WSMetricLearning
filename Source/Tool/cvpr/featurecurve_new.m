function featurecurve_new(pca ,eps)
[sizetitle,sizelengend, sizelabel, sizetick] = getsize();
addpath(genpath('D:\Tanmin\LSVM\lsvm4'));
% dir = ['result\sparwithspeed\'];
dir = ['result\cvpr\'];
if ~exist(dir)
    mkdir(dir);
end

i = 0;
%%%%each group
i = i+1;
database{i} = 'inria';cls{i} = 'person';year{i} = '2007';testset{i} = 'test';
scachedir{i} = {'\lsvm\1_1_1_05_chog1S16_clbp0S8(1_8ru2)1f0s0C0.002(0)la1th1e0_0m20_0.1P0_0.0001_0.8tp1(0.001)_t(-1,100)_F',
    '\lsvm\1_1_1_05_chog1S16_clbp0S8(1_8ru2)1f0s62C0.125(0)la1th1e0_0m20_0.1P5_0.0001_0.8tp1(0.001)s_t(-1,100)_F'};
cov(i,:) = getcoeffsparse(scachedir{i}, cls{i}, year{i}, eps, pca, database{i}, testset{i});
fn(i).name = ['HoG+LBP'];

i = i+1;
database{i} = 'inria';cls{i} = 'person';year{i} = '2007';testset{i} = 'test';
scachedir{i} = {'\lsvm\1_1_1_05_clbp0S8(1_8ru2)1f0s0C0.002(0)la1th1e0_0m20_0.1P0_0.0001_0.8tp1(0.001)_t(-1,100)_F',
    '\lsvm\1_1_1_05_clbp0S8(1_8ru2)1f0s62C0.125(0)la1th1e0_0m20_0.1P5_0.0001_0.8tp1(0.001)s_t(-1,100)_F'};
cov(i,:) = getcoeffsparse(scachedir{i}, cls{i}, year{i}, eps, pca, database{i}, testset{i});
fn(i).name = ['LBP'];

i = i+1;
database{i} = 'inria';cls{i} = 'person';year{i} = '2007';testset{i} = 'test';
scachedir{i} = {'\lsvm\1_1_1_05_chog1S16f0s0C0.002(0)la1th1e0_0m20_0.1P0_0.0001_0.8tp1(0.001)_t(-1,100)_F',
    '\lsvm\1_1_1_05_chog1S16f0s62C0.125(0)la1th1e0_0m20_0.1P5_0.0001_0.8tp1(0.001)s_t(-1,100)_F'};
cov(i,:) = getcoeffsparse(scachedir{i}, cls{i}, year{i}, eps, pca, database{i}, testset{i});
fn(i).name = ['HOG'];

% cd 'D:\Tanmin\LSVM\Tool\test'
xx= testindex([0:0.2:0.8]);
% xx= testindex([0]);
cov(:,3) = xx(:,3);
% cov(:,3) = [0.2988 0.2392 0.1250]
%%%ideal
figure;hold on;
tStyle = GetNomarkStyle();
numStyle = length(tStyle);

x = [0:0.01:1];
for jj = 1:size(cov,1)
    styleID = mod(jj-1, numStyle)+1; 
    t = cov(jj,:);
    y = (t(1)+t(2))./(t(1)+(1-x)*(t(2)+t(3)));
    plot(x, y,tStyle(styleID).color,'LineWidth',2);
end
styleID= styleID+1;
format =[tStyle(styleID).scolor,'--'];
xxx = [0:0.05:1];
plot(xxx, ones(1,length(xxx)), format, 'LineWidth',2);  
h = text(1.01,0.95,'S(\gamma)=1','fontsize',sizetick);


hold on;
for jj = 1:size(cov,1)
    styleID = mod(jj-1, numStyle)+1; 
    t = cov(jj,:);
    theta = (t(3))/(t(2)+t(3));
    format =[tStyle(styleID).scolor,'.-'];
    yyy = [0:0.5:10];
    plot(theta*ones(1,length(yyy)),yyy, format);  
%     str = [sprintf('%0.3f',theta)];
    str = '\gamma_0';
    h = text(theta-0.02,10.8,str);set(h, 'fontsize', sizetick);
    fn(jj).name = [fn(jj).name,'(\gamma_0=',sprintf('%.3f',theta),')']; 
end

tStyle1 = GetStylemark(); 
numStyle = length(tStyle1);
for jj = 1:size(cov,1)
    xx = zeros(length(scachedir{jj}),3);
    for i = 1:length(scachedir{jj})
        cachedir = [database{jj} '\' cls{jj} scachedir{jj}{i}];
        cachedir = globals(cachedir);
        load([cachedir cls{jj} '_final'],'model')
        
        for t = 1:length(model.filters)
            xx(i,2:3) = xx(i,2:3) + [size(model.filters(t).w,2),size(model.filters(t).w,3)];
        end
        xx(i,1) = size(model.filters(1).w,1);
    end
    fsize{jj} = xx;
end

imax = -inf;
hold on;
x = [0:0.1:1];
for jj = 1:size(cov,1)
    styleID = mod(jj-1, numStyle)+1; 
    t = cov(jj,:);
    y = (t(1)+t(2))./(t(1)+(1-x)*(t(2)+t(3)));
    imax = max(imax, max(y));
    plot(x, y,'*');
end

xxx = [0:5:imax+5];
plot(ones(1,length(xxx)), xxx, 'k-.', 'LineWidth',2);  

styleID= styleID+1;
format =[tStyle(styleID).scolor,'--'];
xxx = [0:3:1];
plot(xxx, ones(1,length(xxx)), format, 'LineWidth',2);  
% h = text(1.01,0.95,'y=1','fontsize',sizetick);


% grid;
xlabel('sparsity degree \gamma' ,'fontsize', sizelabel); 
ylabel('speedup S(\gamma)' ,'fontsize', sizelabel); 
% title('Sparserate-speedup curve under different feature space on INRIA',...
%    'fontsize', sizetitle);
h = legend(fn.name, 'Location', 'NorthEast');set(h, 'fontsize', sizelengend);
set(gca,'fontsize', sizetick);

print(gcf, '-djpeg', '-r0', [dir 'featsparse_new.jpg']);
saveas(gca,[dir 'featsparse_new.fig']);
print(gcf, '-depsc2','-r0', [dir 'featsparse_new.eps']);
axis([0 1 0 15])
close all;
save([dir 'sparsefeat_new.mat'],'cov');


function t = getcoeffsparse(scachedir, cls, year, eps, pca, database, testset)
t = zeros(length(scachedir), 3);
t(:,2) = 1;
% t2 = 1;
for i = 1:length(scachedir)
    cachedir = [database '\' cls scachedir{i}];
    cachedir = globals(cachedir);
    load([cachedir cls '_boxes_' testset '_' year '_CAS__' num2str(eps) '_' num2str(pca) '.mat'],'times');
    times = mean(times);
    a1 =times(5)/ (times(3)-times(5));
    t(i,1) = a1;
    
    torg = times(3);
    load([cachedir cls '_boxes_' testset '_' year '_CAS__' num2str(eps) '_' num2str(pca) 'F.mat'],'times');
    tspeedup = mean(times(:,3));
    
     a2 = torg / tspeedup;
     
    load([cachedir cls '_final'],'model');
    spar = sparserate(model)/100;
    t(i,3) = ((1-a2)*a1+1)/(spar*a2) - 1;
end
t = mean(t,1);