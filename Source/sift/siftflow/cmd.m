load('info', 'Im1','Im2','alpha','d','gamma','nIterationArray','nlevels', 'i','wsize','vx','vy','winSizeX','winSizeY')
cd 'D:\MinTan\project\Signdetect\SignClassify\code\release\release\mex'
mex -O BPFlow.cpp Stochastic.cpp mexDiscreteFlow.cpp
cd 'D:\MinTan\project\Signdetect\SignClassify\code\release\release'
[flow,foo]=mexDiscreteFlow(Im1,Im2,[alpha,d,gamma*2^(i-1),nIterationArray(i),nlevels-i,wsize],vx,vy,winSizeX,winSizeY);