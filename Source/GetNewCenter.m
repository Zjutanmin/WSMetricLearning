function [disxN, disyN] = GetNewCenter(disx, disy, ratio)
disxN = disx * (1 + ratio);
disyN = disy * (1 + ratio);