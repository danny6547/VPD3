function obj = printCSV(obj)
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

% Make table
input_tbl = table(image_url, 'VariableNames', {'image_url'});

% Write file
filename = obj.CSVFilePath;
writetable(input_tbl, filename);

end