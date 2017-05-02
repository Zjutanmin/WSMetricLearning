#include <math.h>
#include "mex.h"

#define eps 0.0001

int normtype;
///0:no
///1:l2
///2:l2Hys
///3:l1
///4:l1-sqrt

static inline double min(double x, double y) { return (x <= y ? x : y); }
static inline double max(double x, double y) { return (x <= y ? y : x); }

static inline int min(int x, int y) { return (x <= y ? x : y); }
static inline int max(int x, int y) { return (x <= y ? y : x); }

mxArray *process(const mxArray *mximage, const mxArray *mxsz, const mxArray *mxstride, 
				 const int& nbin) {
  double *src = (double *)mxGetPr(mximage);
  const int *src_dims = mxGetDimensions(mximage);

  double *hist = new double[nbin]; 
  int var;

  double *tmp_sz = (double *)mxGetPr(mxsz);
  int dims_sz[2];
  dims_sz[0] = (int)tmp_sz[0];
  dims_sz[1] = (int)tmp_sz[1];

  tmp_sz = (double *)mxGetPr(mxstride);
  int stride_h = (int)tmp_sz[0];
  int stride_w = (int)tmp_sz[1];
  
  int blocks[2];
  blocks[0] = (int)((double)src_dims[0]/(double)stride_h);
  blocks[1] = (int)((double)src_dims[1]/(double)stride_w);

  int out[3];
  int bound[2];
  bound[0] = (int)(double)(dims_sz[0]/(double)stride_h + 0.5) - 1;
  bound[1] = (int)(double)(dims_sz[1]/(double)stride_w + 0.5) - 1;
  out[1] = max(blocks[0]-bound[0], 0);
  out[2] = max(blocks[1]-bound[1], 0);
  out[0] = nbin;

  mxArray *mxfeat = mxCreateNumericArray(3, out, mxDOUBLE_CLASS, mxREAL);
  double *dst = (double *)mxGetPr(mxfeat);
  
  int dim[2];
  dim[0] = src_dims[0] - dims_sz[0] + 1;
  dim[1] = src_dims[1] - dims_sz[1] + 1;

  double norm;


  for (int x = 0; x < dim[1]; ) { 
	  for (int y = 0; y < dim[0]; ) {
		  norm = 0.0;
		  for (int f = 0; f < nbin; f++) 
			  hist[f] = 0.0;
		  for (int xp = 0; xp < dims_sz[1]; xp++) {
			  
			  //im + min(x, dims[1]-2)*dims[0] + min(y, dims[0]-2);

			  double *off = src + (x+xp)*src_dims[0] + y;



			  switch(dims_sz[0]) {
				  case 20: {var = (int)(off[19]); hist[var]++;}
				  case 19: {var = (int)(off[18]); hist[var]++;}
				  case 18: {var = (int)(off[17]); hist[var]++;}
				  case 17: {var = (int)(off[16]); hist[var]++;}
				  case 16: {var = (int)(off[15]); hist[var]++;}
				  case 15: {var = (int)(off[14]); hist[var]++;}
				  case 14: {var = (int)(off[13]); hist[var]++;}
				  case 13: {var = (int)(off[12]); hist[var]++;}
				  case 12: {var = (int)(off[11]); hist[var]++;}
				  case 11: {var = (int)(off[10]); hist[var]++;}
				  case 10: {var = (int)(off[9]); hist[var]++;}
				  case 9: {var = (int)(off[8]); hist[var]++;}
				  case 8: {var = (int)(off[7]); hist[var]++;}
				  case 7: {var = (int)(off[6]); hist[var]++;}
				  case 6: {var = (int)(off[5]); hist[var]++;}
				  case 5: {var = (int)(off[4]); hist[var]++;}
				  case 4: {var = (int)(off[3]); hist[var]++;}
				  case 3: {var = (int)(off[2]); hist[var]++;}
				  case 2: {var = (int)(off[1]); hist[var]++;}
				  case 1: {var = (int)(off[0]); hist[var]++;}
					  break;
				  default:	
					  for (int yp = 0; yp < dims_sz[0]; yp++)
					  {
						  var = (int)(*(off++));
						  hist[var]++;}
			  }
		  }
		  switch(normtype)
		  {
		  case 0:
			  break;
		  case 1:
			  for (int f = 0; f < nbin; f++) 
				  norm += hist[f]*hist[f];
			  norm = sqrt(norm + eps*eps);
			  for (int f = 0; f < nbin; f++) 
				  hist[f] = hist[f] / norm;
			  break;
		  case 2:
			  for (int f = 0; f < nbin; f++) 
				  norm += hist[f]*hist[f];
			  norm = sqrt(norm + eps*eps);
			  for (int f = 0; f < nbin; f++) 
				  hist[f] = max(hist[f] / norm,0.2);
			  break;
		  case 3:
			  for (int f = 0; f < nbin; f++) 
				  norm += abs(hist[f]);
			  norm = norm + eps;
			  for (int f = 0; f < nbin; f++) 
				  hist[f] = hist[f] / norm;
			  break;
		  case 4:
			  for (int f = 0; f < nbin; f++) 
				  norm += abs(hist[f]);
			  norm = norm + eps;
			  for (int f = 0; f < nbin; f++) 
				  hist[f] = sqrt(hist[f] / norm);
			  break;
		  default:
			  fprintf(stderr, "Error: unknown normlization type\n");
			  break;
		  }
		  for (int f = 0; f < nbin; f++) 
			  dst[f] = hist[f];
		  dst += nbin;
		  y += stride_h;
	  }
	  x += stride_w;
  }
  delete [] hist;
  return mxfeat;
}

// matlab entry point
// C = fconv(A, cell of B, start, end);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  int bins = (int)mxGetScalar(prhs[3]);
  if (nrhs < 4)
	  mexErrMsgTxt("Wrong number of inputs");
  if (nrhs < 5)
	  normtype = 4;
  else
	  normtype = (int)mxGetScalar(prhs[4]);

  plhs[0] = process(prhs[0], prhs[1], prhs[2], bins);
  if (nlhs != 1)
    mexErrMsgTxt("Wrong number of outputs");
}