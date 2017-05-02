mex -O resize.cc
mex -O dt.cc
mex -O features.cc
mex -O hogfeatures.cc

mex -O features1.cc
mex -O hogfeatures1.cc

% mex -O hogfeatures1.cc
mex -O getdetections.cc
% 
% % use one of the following depending on your setup
% % 1 is fastest, 3 is slowest 
% 
% % 1) multithreaded convolution using blas
% % mex -O fconvblas.cc -lmwblas -o fconv
% % 2) mulththreaded convolution without blas
% % mex -O fconvMT.cc -o fconv
% % 3) basic convolution, very compatible
mex -O fconv.cc -output fconv
mex -O fconv_fast.cc

mex -O -largeArrayDims ReadData.cpp
mex -O densehist.cc
mex -O densehistN.cc