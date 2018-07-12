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
if nargin > 3
    
    otherInput_c = varargin(2:end);
end

if filtered
    
    tbl = obj.FilteredData;
else
    
    tbl = obj.FileData;
end

writetable(tbl, filename, otherInput_c{:});
end