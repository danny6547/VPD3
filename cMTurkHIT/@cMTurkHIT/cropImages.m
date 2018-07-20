function obj = cropImages(obj, rows, cols, varargin)
%cropImages Crop all images in directory after user interaction
%   Detailed explanation goes here

% Input
files_c = obj.imageFiles();
if nargin > 3
    
    files_c = varargin{1};
    validateCellStr(files_c, 'cMTurkHIT.cropImages', 'files', 4);
end


for fi = 1:numel(files_c)
    
    % Read
    currFile = files_c{fi};
    img = imread(currFile);
    
    % Crop
    img = img(rows, cols, :);
    
    % Save
    imwrite(img, currFile);
end
end