function d = flowdistance(Sift1, Sift2, setting)
% Step 3. SIFT flow matching

% prepare the parameters
SIFTflowpara.alpha=setting.SIFTflowpara.alpha;
SIFTflowpara.d=setting.SIFTflowpara.d;
SIFTflowpara.gamma=setting.SIFTflowpara.gamma;
SIFTflowpara.nlevels=setting.SIFTflowpara.nlevels;
SIFTflowpara.wsize=setting.SIFTflowpara.wsize;
SIFTflowpara.topwsize=setting.SIFTflowpara.topwsize;
SIFTflowpara.nIterations=setting.SIFTflowpara.nIterations;

[vx,vy,energylist]=SIFTflowc2f(Sift1,Sift2,SIFTflowpara);
d = 0;
for i = 1:length(energylist)
    d = d + energylist(i).data(end);
end
d = d / length(energylist);