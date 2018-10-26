function tbl = appendOtherSpecVars(tbl, freq, type)
%appendOtherSpecVars Summary of this function goes here
%   Detailed explanation goes here

types = [1, 2];

% Get all variables in all other types
otherTypes_v = types(types ~= type);
othervars = cell(1, numel(otherTypes_v));
for ti = 1:numel(otherTypes_v)
    
    spec = cWanHai.specification(freq, otherTypes_v(ti));
    othervars{ti} = spec(:, 2);
end
othervars = [othervars{:}];
othervars(cellfun(@isempty, othervars)) = [];

tabVars = tbl.Properties.VariableNames;
vars2add_c = setdiff(othervars, tabVars);
for vi = 1:numel(vars2add_c)

    tbl.(vars2add_c{vi}) = nan(height(tbl), 1);
end