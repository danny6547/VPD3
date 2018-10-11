function printCSV(obj)
%printCSV Print CSV containing batch
%   Detailed explanation goes here

% Make table from image url
obj.errorIfImagesURLEmpty()
input_tbl = cell2table(obj.ImageURL, ...
    'VariableNames', {'image1_url', 'image2_url', 'image3_url'});

% Pass to print method
printCSV@cMTurkHIT(obj, input_tbl);

end

