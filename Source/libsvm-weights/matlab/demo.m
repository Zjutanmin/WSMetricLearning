[heart_scale_label, heart_scale_inst] = libsvmread('../heart_scale');
heart_scale_weight = load('../heart_scale.wgt');
model = svmtrain(heart_scale_weight, heart_scale_label, heart_scale_inst, '-c 1');
[predict_label, accuracy, dec_values] = svmpredict(heart_scale_label, heart_scale_inst, model);