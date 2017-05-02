function setting = get_tr_idx(setting)     
ts_idx = setting.ts_idx(setting.ts_idx_conf);
tr_idx = setting.tr_idx;
if isfield(setting, 'ts_idx_conf') && ~isempty(setting.ts_idx_conf)
    Range = setting.ts_idx_conf;
else
    Range = [1:length(ts_idx)];
end

TFstr = setting.TFstr;
load([TFstr, '_', setting.feaname{1}, '_data.mat'], 'data_label')

[tr_idx, ts_idx, data_label, cindex, Range] = TransformData(setting.labelmap, ...
    setting.cindex, data_label, tr_idx, ts_idx, Range);

Samplevoted = setting.Samplevoted;
Samplevoted = Samplevoted(Range);
idx = find(Samplevoted);

setting.Metric_tr_idx = [tr_idx; ts_idx(idx)];