function parastr = getoptions(cbest, dbest, gbest, rbest, kerneltype)
switch kerneltype
    case 0
        parastr = ['-c ' num2str(cbest)];        
    case 1
        parastr = ['-c ' num2str(cbest) ' -d ' num2str(dbest) ' -g ' num2str(gbest) ' -r ' num2str(rbest)];     
    case 2
        parastr = ['-c ' num2str(cbest) ' -g ' num2str(gbest)];     
    case 3
        parastr = ['-c ' num2str(cbest) ' -g ' num2str(gbest) ' -r ' num2str(rbest)];     
end