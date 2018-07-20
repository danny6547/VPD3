function obj = printCSV(obj, varargin)
%writeCSV Summary of this function goes here
%   Detailed explanation goes here

% Inputs are one image per row
image_url = obj.ImageURL;

% Error if empty
if isempty(image_url)
    
    errid = 'CSV:URLNotGiven';
    errmsg = ['URL for images must be given in property ''ImageURL'' to '...
        'print CSV file'];
    error(errid, errmsg);
end

tbl_input = false;
if nargin > 1
    
    input_tbl = varargin{1};
    validateattributes(input_tbl, {'table'}, {}, 'cMTurkHIT.printCSV',...
        'tab', 2);
    tbl_input = true;
end

% Make table
if ~tbl_input
    
    image_url = cellstr(image_url);
    input_tbl = table(image_url, 'VariableNames', {'image_url'});
end

% Write file
filename = obj.CSVFilePath;
writetable(input_tbl, filename);

end