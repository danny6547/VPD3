function obj = catStandardVar(obj)
%catStandardVar Concatenate standard variables to table
%   Detailed explanation goes here

tbl = obj.Data;
emptyNumeric_v = nan(height(tbl), 1);

for vi = 1:numel(obj.StandardVariables)
    
    currVar = obj.StandardVariables{vi};
    if ~ismember(currVar, tbl.Properties.VariableNames)
        tbl.(currVar) = emptyNumeric_v;
    end
end
obj.Data = tbl;