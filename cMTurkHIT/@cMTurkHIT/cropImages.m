function obj = cropImages(obj, rows, cols)
%cropImages Crop all images in directory after user interaction
%   Detailed explanation goes here

% Read in images and crop and save
% objDir = obj.Directory;
% imageDir = fullfile(fileparts(objDir), 'Images');
% files_st = rdir([imageDir, '\*.jpg']);
% files_c = {files_st.name};

files_c = obj.imageFiles();

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