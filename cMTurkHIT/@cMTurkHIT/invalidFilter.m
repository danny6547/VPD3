function [obj, invalid] = invalidFilter(obj)
%invalidFilter Return logical indicating invalid rows as selected by user
%   Detailed explanation goes here

invalid = false(height(obj.FileData), 1);
invalidData = obj.InvalidData;
file = obj.FileData;
if isempty(invalidData)
    
    return
end

if obj.IsGrid

    invalid = ismember(file.Draft,  invalidData(:, 1)) &...
        ismember(file.Trim,  invalidData(:, 2));
else

    invalid = ismember(file.Draft,  invalidData(:, 1));
end

end