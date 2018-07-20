function [filepath, filename] = imageFiles(obj)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

% Get size of image
[~, imageDir] = obj.imageDir;
imageFile_st = dir([imageDir, '\*.jpg']);
filename = {imageFile_st.name};
filepath = cellfun(@(x) fullfile(imageDir, x), filename, 'Uni', 0);


end