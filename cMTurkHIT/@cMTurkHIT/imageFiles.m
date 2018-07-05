function [files] = imageFiles(obj)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

% Get size of image
[~, imageDir] = obj.imageDir;
imageFile_st = dir([imageDir, '\*.jpg']);
fileNames = {imageFile_st.name};
files = cellfun(@(x) fullfile(imageDir, x), fileNames, 'Uni', 0);


end