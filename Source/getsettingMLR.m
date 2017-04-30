function [setting, suffix, cpara, suffixMod, nameresult] = getsettingMLR(nameresult, setting, cpara, knnpara)
setting.MeanT = 0;setting.WeightUp = 1;setting.TempMLR = 0;setting.TemplateNorm = 0;
setting.TemplateINNC = 0;setting.GammaS = 0;setting.KmeanA = 1;setting.FeatUp = 0; 
setting.mult_dic = 1;
setting.iter_dic = 10e3;setting.Newcode = 0;setting.ITERkmean = 0;
suffx = '';
setting.FIXW = 0;setting.FIXW_T = 0;
setting.KmeanELabel= 0;setting.FeatUpkmean = 0;
setting.KmeanE = 0;
setting.MeanNum = 0;
setting.isMetricL2 = 1;
setting.NewinitGD = 0;
setting.testMetric = 0;
if iscell(cpara{1})
    
    setting.MeanNum = cpara{2};
    setting.AllTemp = 0;
    setting.MeanT = 1;
    suffx = '';
    if iscell(setting.MeanNum)
        setting.FIXW_T = setting.MeanNum{2};
        setting.MeanNum = setting.MeanNum{1};
        if setting.FIXW_T
            suffx = [suffx 'FW'];
        end
    end
    
    if setting.MeanNum > 0
        suffx = [suffx 'M' num2str(setting.MeanNum)];
        if length(cpara) > 2
            Temp = cpara{3};
            setting.TemplateUp = Temp(1);

            suffx = [suffx 'Up'];
           
            if length(Temp) > 1
% % %                 setting.ITERkmean = floor(Temp(2) / 8);
% % %                 Temp(2) = mod(Temp(2), 8); 
                
                setting.innerkmean = floor(Temp(2) / 4);
                Temp(2) = mod(Temp(2), 4); 
                
                if setting.MeanNum == 1 && Temp(2)
                    Temp(2) = Temp(2) - 2*floor(Temp(2) / 2);
                end
                
                setting.TemplateNorm = Temp(2);
                
                setting.Svlfeat = floor(setting.TemplateNorm / 2);
                setting.TemplateNorm = mod(setting.TemplateNorm, 2);

                suffx = [suffx 'N'];
                if Temp(2)
                    suffx = [suffx num2str(Temp(2))];
                end
                if setting.innerkmean
                    suffx = [suffx 'IK'];
                end
                
            end
            
            if length(Temp) > 2
                if Temp(3)>0
                    setting.FeatUpkmean = floor(Temp(3) / 20);
                    if setting.FeatUpkmean
                        suffx = [suffx 'F'];
                    end
                    Temp(3) = mod(Temp(3), 20);
                    setting.ITERkmean = floor(Temp(3) / 10);
                    if setting.ITERkmean
                        suffx = [suffx 'I'];
                    end
                    Temp(3) = mod(Temp(3), 10);
                end
                setting.TemplateINNC = Temp(3);
                try
                    setting.TestKNN = Temp(4) < 0; 
                    Temp(4) = abs(Temp(4));
                    if setting.TestKNN
                        setting.TestSuf = [setting.TestSuf 'TK'];
                    end
                end
                if ismember(setting.TemplateINNC, [0, 1, 2])
                    setting.exitDiC = 1;
                        try setting.K_dic = Temp(4);  catch setting.K_dic = 500; end
                        try setting.lamda_dic = Temp(5);  catch setting.lamda_dic = 1; end
                        try setting.iternum = Temp(6);  catch setting.iternum = 5; end
                        try setting.method_dic = Temp(7);  catch setting.method_dic = 1; end
                        try setting.mult_dic = Temp(8);  catch setting.mult_dic = 1; end
                        try setting.iter_dic = Temp(9);  catch setting.iter_dic = 10e3; end
%                         try setting.SGD = Temp(10);  catch setting.SGD = 0; end
                        setting.testMetric = floor(Temp(10) /10);
                        Temp(10) = mod(Temp(10), 10); 
                        try 
                            setting.NewinitGD = floor(Temp(10) / 4);  
                            GDTemp = mod(Temp(10), 4);
                            setting.isMetricL2 = 1 - floor(GDTemp / 2);  
                            setting.SGD = mod(GDTemp, 2);  
                        catch
                            setting.isMetricL2 = 1;setting.SGD = 0;  
                        end
                        try setting.Nround = Temp(11);  catch setting.Nround = 0; end
                        try setting.Nex = Temp(12);  catch setting.Nex = 0; end
                        try setting.Tfreq = Temp(13);  catch setting.Tfreq = 1; end
                        try setting.NCP = Temp(14);  catch setting.NCP = 1000; end
                        try setting.FIXW = Temp(15);  catch setting.FIXW = 0; end
                        try setting.KmeanE = Temp(16);  catch setting.KmeanE = 0; end
                        try setting.Tnorm = Temp(17);  catch setting.Tnorm = 1; end
                        switch setting.method_dic
                            case 1
                                setting.method_dic = 'L0';
                            case 2
                                setting.method_dic = 'L1';
                            case 3
                                setting.method_dic = 'Own';
                            case 4
                                setting.method_dic = 'Grad';
                            case 5
                                setting.method_dic = 'Own-L0';
                            case 6
                                setting.method_dic = 'LGrad';
                            case 7
                                setting.method_dic = 'SLEP';
                            case 8
                                setting.method_dic = 'SLEP_L0';
                        end
                end
                setting.KmeanELabel = floor(setting.KmeanE / 2);
                setting.KmeanE = mod(setting.KmeanE, 2);
                switch setting.TemplateINNC
                    case 0
                       suffx = [suffx 'M' getparastr(Temp(4:end))]; 
                    case 1
                        suffx = [suffx 'IN' getparastr(Temp(4:end))];
                    case 2
                        setting.Codedis = 1;
                        suffx = [suffx 'IN(2)' getparastr(Temp(4:end))];
                end
            else
                setting.TrainINNC = 0;
            end
            
        end
        switch setting.TemplateUp
            case 1
                if length(cpara) > 3
                    setting.WeightUp = cpara{4};
                end
                if setting.WeightUp ~= 1
                    suffx = [suffx 'U' num2str(setting.WeightUp)];
                end
                setting.WeightUpC = floor(setting.WeightUp / 10);
                setting.WeightUp = mod(setting.WeightUp, 10);
            case 2
                if length(cpara) > 3
                    Temp = cpara{4};
                    setting.KmeanA = Temp(1);
                end
                suffx = [suffx 'TU' num2str(setting.KmeanA)];
                if length(Temp) > 1
                   setting.FeatUp = Temp(2);
                end
                if setting.FeatUp
                    suffx = [suffx 'FU'];
                end
        end
        setting.GammaS = 0;
        if length(cpara) > 4
            Temp = cpara{5};
            setting.GammaS =Temp(1);
            setting.Nfixed = floor(setting.GammaS / 2);   
            setting.GammaS = mod(setting.GammaS, 2);
            if setting.Nfixed
                suffx = [suffx 'UG'];
                try setting.lamda_dic = Temp(2);  catch setting.lamda_dic = 1; end
                try setting.iternum = Temp(3);  catch setting.iternum = 5; end
                suffx = [suffx getparastr(Temp(2:end))];
            end
            if setting.GammaS
                suffx = [suffx 'GS'];
            end
        end
         if length(cpara) > 5 && ~isempty(cpara{6})
             if iscell(cpara{6})
                 setting.INNCSP = mod(cpara{6}{2}, 2);
                 setting.Enorm = floor(cpara{6}{2} / 2);
                 cpara{6} = cpara{6}{1};
             end
             if setting.INNCSP
                 suffx = [suffx 'S'];
             end
             if setting.Enorm
                 suffx = [suffx 'E'];
             end
             if ~isempty(cpara{6})
                 setting.TestINNC = 1;
                 [setting.lambda_INNC, setting.K_INNC, setting.blocksize_INNC, ...
                     setting.verbose_INNC, setting.beta_INNC] = GetINNCpara(cpara{6});
                 if setting.INNCSP
                     if setting.lambda_INNC == 0.05 && setting.beta_INNC == 0.95
                         setting.TestSuf = [setting.TestSuf getparastr(cpara{6})];
                     else
                         suffx = [suffx getparastr(cpara{6})];
                     end
                 else
                     setting.TestSuf = [setting.TestSuf getparastr(cpara{6})];
                 end
             end
         end 
         if length(cpara) > 6 && cpara{7}
            setting.Newcode = cpara{7};
            if setting.Newcode
                setting.TestSuf = [setting.TestSuf 'C'];
            end
         end   
    else
        if setting.MeanNum == -1
            setting.TrainINNC = 0;
            setting.MeanT = 0;
            setting.TemplateINNC = -1;
            setting.TestINNC = 1;
            Temp = cpara{3};
            [setting.lambda_INNC, setting.K_INNC, setting.blocksize_INNC, ...
                setting.verbose_INNC, setting.beta_INNC] = GetINNCpara(Temp);
            setting.TestSuf = [setting.TestSuf 'IN' getparastr(Temp)];
        else
            setting.AllTemp = 1;
            suffx = [suffx 'RC'];
        end
    end
    if setting.testMetric
        setting.TestSuf = [setting.TestSuf 'M'];
    end
    cpara = cpara{1};
end
setting.WUp = mod(setting.WeightUp, 2);
setting.MUp = floor(setting.WeightUp/2);

setting.latentresult = [setting.latentresult '-' num2str(setting.platent)];
if ~isempty(setting.config_latent)
    ids = strfind(setting.Modelresult, setting.config_latent);
    setting.ModelresultO = setting.Modelresult;
    setting.ModelresultO(ids:ids+length(setting.config_latent)) = '';
    ids = strfind(setting.ModelresultO,setting.suffixx);
    setting.ModelresultO(ids:ids-1+length(setting.suffixx)) = '';
    setting.ModelresultO = [setting.ModelresultO '-0'];
end


    
    
if mod(setting.latent, 10) == 5
    ids = strfind(setting.ModelresultO,setting.suffixx);
    setting.ModelresultO(ids:ids-1+length(setting.suffixx)) = '';
    setting.ModelresultO = [setting.ModelresultO '-0'];
end
if length(setting.SnippetRatio) > 2 && floor(setting.SnippetRatio{3} / 10000) == 1
    setting.Modelresult = [setting.Modelresult '-0'];
%     nameresult = [nameresult, '-0'];
else
    if length(setting.SnippetRatio) == 1
        setting.Modelresult = [setting.Modelresult '-0'];
%         nameresult = [nameresult, '-0'];
    else
        setting.Modelresult = [setting.Modelresult '-' num2str(setting.Mplatent)];
        if setting.Mplatent
        nameresult = [nameresult '-' num2str(setting.Mplatent)]; 
        end
    end
end
if length(cpara) < 7
    cpara{7} = 3;
end
setting.RC = 0;
if iscell(cpara{1})
    setting.RC = cpara{1}{2};
    cpara{1} = cpara{1}{1};
end
suffix = [suffx, getparastr(cpara{1}), '-',cpara{2}, getparastr(cell2mat(cpara(3:end)))];
suffixMod= suffix;
if length(knnpara) > 1
    suffix = [suffix setting.kparastr];
    suffixMod = [suffixMod setting.kparastrMod];
end
setting.C = cpara{1};setting.LOSS = cpara{2}; setting.k = cpara{3};
setting.REG =cpara{4}; setting.Diagonal = cpara{5}; setting.B = cpara{6};
setting.Latiter = cpara{7};
setting.lamda = 0;
if length(cpara) > 7 && strcmp(setting.cmethod, 'RMLR')
    setting.lamda = cpara{8};
end
setting.MLRweight = 0;
if strcmp(setting.cmethod, 'RMLR')
    if length(cpara) > 8
        setting.MLRweight = cpara{9};
    end
    if length(cpara) > 9
        setting.MetricL2 = cpara{10};
    end
    if length(cpara) > 10
        setting.innerfea = cpara{11};
    end
    nlength = 11;
else
    if length(cpara) > 7
        setting.MLRweight = cpara{8};
    end
    if length(cpara) > 8
        setting.MetricL2 = cpara{9};
    end
    if length(cpara) > 9
        setting.innerfea = cpara{10};
    end
    nlength = 10;
end
if length(cpara) > nlength
    setting.MetricTemplate = cpara{nlength};
    if length(cpara) > nlength
        setting.Ttrain.config_latent = cpara{nlength+1};
        setting.Ttrain.platent = cpara{nlength+2};
    else
        setting.Ttrain.config_latent = 'Latent1';
        setting.Ttrain.platent = cpara{nlength+2};
    end
    setting.Platent = cpara{nlength};
    setting.MetricTemplate = cpara{nlength};
else
    setting.MetricTemplate = 0;
end