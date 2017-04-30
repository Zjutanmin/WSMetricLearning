1. Test right
    1.1 K:  BTSRC,GTSRC
            cvprcmd\cmdtans_N(overallBB2_R, overallGB2_R)
            :copy svmmodel(K:-D) when result~=0
            
            to here
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            demo
            
            
    1.2 D:  cvprcmd\cmdtran_T(cmdtmp5) Result->     figure->WSMLR_N
    1.2.1   PIE   run D-K cover(M+R)        Result->figure->WSMLR_N
    1.2.2   YaleB run D-K cover(M+R)        
    
    1.2.3   BTSRC run cover relative:copy svmmodel(D:-K) when result~=0   
    
    1.2.4   copy  D:  cvprcmd\cmdtran_T  to  K:  cvprcmd\cmdtran_T
        K:  cvprcmd\cmdtran_T(cmdtmp5)
        Result->     figure
        K:  demo

    
2. MODEL\result Simple  for best para




WSMTL mlrvir