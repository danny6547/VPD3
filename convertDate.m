function [ perStruct ] = convertDate( perStruct, varargin )
%convertDate Convert dates to matlab serial date numbers
%   outStruct = convertDate(inStruct) will return in OUTSTRUCT field 
%   'DateTime_UTC' the equivalent MATLAB serial date numbers of the 
%   date strings in field 'DateTime_UTC' of INSTRUCT. These dates are
%   expected to be in the form 'dd-mm-yyyy'.
%   outStruct = convertDate(inStruct, dateConv) will, in addition to the
%   above, apply the date format string to perform the conversion. DATECONV
%   is the same as the second input to datestr, see HELP DATESTR for
%   further information.

% Input
dateConv_s = 'dd-mm-yyyy';
if nargin > 1

    dateConv_s = varargin{1};
    validateattributes(dateConv_s, {'char'}, {'vector'}, 'convertDate', ...
        'dateConv', 2);
end

% Iterate over elements of data array
for si = 1:numel(perStruct)
    
    % If already converted, move on
    if isnumeric(perStruct(si).DateTime_UTC)
        continue
    end
    
    % Convert to numeric
    perStruct(si).DateTime_UTC = ...
        datenum(perStruct(si).DateTime_UTC, dateConv_s);
end