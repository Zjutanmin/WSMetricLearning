load('ttinfo1','X','Xs','Xi','grad','options','options')
nn = 10;grad1 = grad(1:nn,:);
tic;[tree,p] = buildtree(X',Xs,Xi,-grad1',options.depth,options);toc;
nn = 20;grad1 = grad(1:nn,:);
tic;[tree,p] = buildtree(X',Xs,Xi,-grad1',options.depth,options);toc;
nn = 50;grad1 = grad(1:nn,:);
tic;[tree,p] = buildtree(X',Xs,Xi,-grad1',options.depth,options);toc;
nn = 100;grad1 = grad(1:nn,:);
tic;[tree,p] = buildtree(X',Xs,Xi,-grad1',options.depth,options);toc;
tic;[tree,p] = buildtree(X',Xs,Xi,-grad',options.depth,options);toc;

200 trees
Elapsed time is 24.254121 seconds.   1.347    10
Elapsed time is 38.109003 seconds.   2.117    20
Elapsed time is 123.388965 seconds.  6.855    50
Elapsed time is 227.667473 seconds.  12.648   100
Elapsed time is 1426.667473 seconds. 79.259   500