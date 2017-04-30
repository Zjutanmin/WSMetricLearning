function X = GetReal(X, dataIndex)
if ~isempty(X)
    X = X(dataIndex,:);
end