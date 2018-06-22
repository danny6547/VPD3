function obj = cropImageUI(obj)
%cropImageUI Summary of this function goes here
%   Detailed explanation goes here

% Get size of image
[~, imageDir] = obj.imageDir;
imageFile_st = dir([imageDir, '\*.jpg']);
sampleImageFile = fullfile(imageDir, imageFile_st(1).name);
sampleImage = imread(sampleImageFile);
[nRows, nCol, ~] = size(sampleImage);

% Show sample image
imshow(sampleImage, 'Border', 'tight');
set(gca, 'Visible', 'on');

% Ask user for rows to keep
con = false;
while ~con

    imshow(sampleImage);
    set(gca, 'Visible', 'on');
    rows = input(['Enter guess at height to keep (between 1 and ', num2str(nRows) ':\n']);

    % Update image
    imshow(sampleImage(rows, :, :));
    set(gca, 'Visible', 'on');

    answer = input('Continue to columns? [Y/N]:\n', 's');
    con = strcmpi(answer, 'y');
end
sampleImage = sampleImage(rows, :, :);

% Ask user for rows to keep
con = false;
while ~con

    imshow(sampleImage);
    set(gca, 'Visible', 'on');
    cols = input(['Enter guess at width to keep (between 1 and ', num2str(nCol) ':\n']);

    % Update image
    imshow(sampleImage(:, cols, :));
    set(gca, 'Visible', 'on');
    
    answer = input('Finished? [Y/N]:\n', 's');
    con = strcmpi(answer, 'y');
end

% Crop all images with row and columns to keep
obj.cropImages(rows, cols);