function [img] = rotImages90Counter(obj, img)
%rotImage90Counter Rotate all images by 90 degrees coutner-clockwise
%   Detailed explanation goes here

imgFiles = obj.imageFiles;
for fi = 1:numel(imgFiles)

    currFile = imgFiles{fi};
    img = imread(currFile);
    img = permute(img, [2, 1, 3]);
    img = img(end:-1:1, :, :);
    imwrite(img, currFile);
end