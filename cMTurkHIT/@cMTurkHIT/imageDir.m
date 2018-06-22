function [obj, imageDir] = imageDir(obj)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

objDir = obj.Directory;
imageDir = fullfile(objDir, 'Images');
end