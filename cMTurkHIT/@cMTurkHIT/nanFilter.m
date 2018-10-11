function [obj, nan_l] = nanFilter(obj)
%nanFilter Remove any rows from data where any value is nan
%   Detailed explanation goes here

tbl = obj.FileData;
mat = table2array(tbl);
nan_l = any(isnan(mat'));
nan_l = nan_l(:);
obj.NaNFilter = nan_l;
end