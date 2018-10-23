function printData(obj, filename, varargin)
%printData Print data into flat file
%   Detailed explanation goes here

% Input
validateattributes(filename, {'char'}, {'vector'}, 'cMTurkHIT.printData',...
    'filename', 2);
filename = obj.prependScriptPath(filename);

filtered = false;
if nargin > 2 && ~isempty(varargin{1})
    
    filtered = varargin{1};
    validateattributes(filtered, {'logical'}, {'scalar'}, ...
        'cMTurkHIT.printData', 'filtered', 3);
end

otherInput_c = {};
if nargin > 4
    
    otherInput_c = varargin(3:end);
end

printOnlyModelVars = false;
if nargin > 3
    
    printOnlyModelVars = varargin{2};
end

if filtered
    
    tbl = obj.FilteredData;
else
    
    tbl = obj.FileData;
end

% Find Model Vars
if printOnlyModelVars
    
    modelVars = {'Displacement','Draft','LCF','TPC', 'Trim'};
    cols2print_l = ismember(tbl.Properties.VariableNames, modelVars);
else
    
    cols2print_l = true(1, width(tbl));
end
tbl = tbl(:, cols2print_l);

writetable(tbl, filename, otherInput_c{:});
end