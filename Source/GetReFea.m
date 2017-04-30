function ts_fea = GetReFea(ts_fea, Metric)
if ~isempty(Metric)
    W =Metric;
    [vecs,vals] = eig(0.5 * (W + W'));
    L = real(abs(vals)).^0.5 * vecs'; 
    ts_fea = ts_fea * L';
end