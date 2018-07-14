function obj = cropImageUI(obj)
%cropImageUI Summary of this function goes here
%   Detailed explanation goes here

% Get size of image
files = obj.imageFiles();

if isempty(files)
    
    errid = 'UI:FilesMissing';
    errmsg = 'No image files found';
    error(errid, errmsg);
end 

sampleImageFile = files{1};
sampleImage = imread(sampleImageFile);
[nRows, nCol, ~] = size(sampleImage);

% Show sample image
newFig = figure;
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
    set(gca,'XMinorTick','on');

    answer = input('Continue to width? [Y/N]:\n', 's');
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
    set(gca,'XMinorTick','on');
    
    answer = input('Finished? [Y/N]:\n', 's');
    con = strcmpi(answer, 'y');
end

% Crop all images with row and columns to keep
obj.cropImages(rows, cols);
close(newFig);