% MEXFLAGS=
% MEX=mex
% 
% all: binarysearch cummax
% 
% binarysearch: binarysearch.c
% 	${MEX} ${MEXFLAGS} $<
% 
% cummax: cummax.c
% 	${MEX} ${MEXFLAGS} $<
    
% MEXFLAGS=
% MEX=mex
mex -O binarysearch.c
mex -O cummax.c
% all: binarysearch cummax
% 
% binarysearch: binarysearch.c
% 	${MEX} ${MEXFLAGS} $<
% 
% cummax: cummax.c
% 	${MEX} ${MEXFLAGS} $<
