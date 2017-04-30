
%%%%%differnt DOG parameters
%  clear all
  dir = pwd;index = find(dir == '\');path = dir(index(end)+1:end);
 Class = {'Yield','Donotenter', 'Speedlimit(30)', 'Speed limit(35)', ...
     'Oneway(L)', 'Oneway(R)','Stop','Average'};
     
     
 addpath('Tool');
 stitle = 'Differnt kenern for M_SVM';
 celltitle = {'linear', 'polynomial', 'radial', 'sigmoid'};
 innertilte = {'HoG', 'LBP', 'LTP'};
 
  
  jj = 0;tresult = [];tranktime = [];para = [];


 jj = jj+1;i = 0;
i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cHoG_1',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cLBP_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cLTP_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
% i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'color24_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
%  i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cHoG_1_cLBP_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
%  i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cHoG_1_color24_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
% i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cLBP_0_color24_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
% i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cHoG_1_cLBP_0_color24_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
%  i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cHoG_1_cLBP_0_cLTP_0_color24_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 0, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
%   result2 = result2(:); ranktime = ranktime(:); 
%  
%  tresult = [tresult; result1, result2,ranktime];
%  tranktime = [tranktime; ranktime];
%  t1{jj} = [result1, result2];
%  ranktime1{jj} = [ranktime]; 
%  
%  
%  
%  jj = jj+1;i = 0;
% i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cHoG_1',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 1, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
% i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cLBP_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 1, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
% i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cLTP_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 1, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
% i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'color24_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 1, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
%  i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cHoG_1_cLBP_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 1, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
%  i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cHoG_1_color24_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 1, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
% i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cLBP_0_color24_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 1, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
% i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cHoG_1_cLBP_0_color24_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 1, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
%  i = i+1;clc;close all; clc;cd 'D:\MinTan\project\Signdetect\SignClassify';[result1(i,:), result2(i), ranktime(i), ] = Showmatric('Sign', '_New2', 'cHoG_1_cLBP_0_cLTP_0_color24_0',{'sift'},'MLR', 1, {1, 'MRR', 1, 1, 1, 1, 3}, 1, 0, [90, 75], -1, [4,8,16], 100, 1,3,0.5,'DOG_2','',0,0,1,0.5,0,'',0,2);
%  
%  
%  result2 = result2(:); ranktime = ranktime(:); 
%  
%  tresult = [tresult; result1, result2,ranktime];
%  tranktime = [tranktime; ranktime];
%  t1{jj} = [result1, result2];
%  ranktime1{jj} = [ranktime]; 