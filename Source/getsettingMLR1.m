function [setting, suffix, cpara] = getsettingMLR1(setting, cpara, knnpara)
setting.MeanT = 0;setting.WeightUp = 1;setting.TempMLR = 0;setting.TemplateNorm = 0;
setting.TemplateINNC = 0;setting.GammaS = 0;setting.KmeanA = 1;setting.FeatUp = 0;              
suffx = '';
if iscell(cpara{1})
    setting.MeanNum = cpara{2};
    setting.AllTemp = 0;
    setting.MeanT = 1;
    setting.TemplateUp = 0;
    if setting.MeanNum > 0
        suffx = ['M' num2str(setting.MeanNum)];
        if length(cpara) > 2
            Temp = cpara{3};
            setting.TemplateUp = Temp(1);

            suffx = [suffx 'Up'];
            
            if length(Temp) > 1
                setting.TemplateNorm = Temp(2);
                suffx = [suffx 'N'];
                if setting.TemplateNorm
                    suffx = [suffx num2str(setting.TemplateNorm)];
                end
            end
            
            if length(Temp) > 2
                setting.TemplateINNC = Temp(3);
                switch setting.TemplateINNC
                    case -1
                        [setting.lambda_INNC, setting.K_INNC, setting.blocksize_INNC, ...
                            setting.verbose_INNC, setting.beta_INNC] = GetINNCpara(Temp(4:end));
                        suffx = [suffx getparastr(Temp(4:end))];
                    case 1
                        [setting.lambda_INNC, setting.K_INNC, setting.blocksize_INNC, ...
                            setting.verbose_INNC, setting.beta_INNC] = GetINNCpara(Temp(4:end));
                        suffx = [suffx 'IN' getparastr(Temp(4:end))];
                    case 2
                        setting.Codedis = 1;
                        try setting.K_dic = Temp(4);  catch setting.K_dic = 500; end
                        try setting.lamda_dic = Temp(5);  catch setting.lamda_dic = 1; end
                        try setting.iternum = Temp(6);  catch setting.iternum = 5; end
                        try setting.method_dic = Temp(7);  catch setting.method_dic = 3; end
                        try setting.mult_dic = Temp(8);  catch setting.mult_dic = 1; end
                        try setting.iter_dic = Temp(9);  catch setting.iter_dic = 10e3; end
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
                        end
                        suffx = [suffx 'IN(2)' getparastr(Temp(4:end))];
                end
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
            case 2
                if length(cpara) > 3
                    setting.KmeanA = cpara{4};
                end
                suffx = [suffx 'TU' num2str(setting.KmeanA)];
                if length(cpara) > 4
                    setting.FeatUp = cpara{5};
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

    else
        if setting.MeanNum == -1
            setting.MeanT = 0;
            setting.TemplateINNC = 1;
            Temp = cpara{3};
            [setting.lambda_INNC, setting.K_INNC, setting.blocksize_INNC, ...
                setting.verbose_INNC, setting.beta_INNC] = GetINNCpara(Temp);
            setting.TestSuf = ['IN' getparastr(Temp)];
        else
            setting.AllTemp = 1;
            suffx = [suffx 'RC'];
        end
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

setting.Modelresult = [setting.Modelresult '-' num2str(setting.Mplatent)];
suffix = [suffx, getparastr(cpara{1}), '-',cpara{2}, getparastr(cell2mat(cpara(3:end)))];
if length(knnpara) > 1
    suffix = [suffix setting.kparastr];
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
    nlength = 10;
else
    if length(cpara) > 7
        setting.MLRweight = cpara{8};
    end
    if length(cpara) > 8
        setting.MetricL2 = cpara{9};
    end
    nlength = 9;
    
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



