function [tbl] = removeNonStandard(tbl, spec)
%removeNonStandard Summary of this function goes here
%   Detailed explanation goes here

name2remove_l = cellfun(@isempty, spec(:, 2));
% name2remove_c = spec(name2remove_l, 1);
name2remove_c = spec(name2remove_l, 1);

tblVar = tbl.Properties.VariableNames;
name2rm_l = ismember(tblVar, name2remove_c);
tbl(:, name2rm_l) = [];
end