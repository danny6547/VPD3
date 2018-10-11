function obj = cropImageUI(obj)
%cropImageUI Summary of this function goes here
%   Detailed explanation goes here

% Get size of image
obj.errorIfImagesMissing();

files = obj.imageFiles();
sampleImageFile = files{1};
sampleImage = imread(sampleImageFile);

% Show sample image
newFig = figure;
warning('off', 'images:initSize:adjustingMag');
imshow(sampleImage, 'Border', 'tight');
set(gca, 'Visible', 'on');

[rows, cols] = obj.requestCropIdx(sampleImage);
% 
% % Ask user for rows to keep
% con = false;
% while ~con
% 
%     imshow(sampleImage);
%     set(gca, 'Visible', 'on');
%     rows = input(['Enter guess at height to keep (index range between 1 and ',...
%         num2str(nRows) ', enclosed in square brackets:\n']);
% 
%     % Update image
%     imshow(sampleImage(rows, :, :));
%     set(gca, 'Visible', 'on');
%     set(gca,'XMinorTick','on');
% 
%     answer = input('Continue to width? [Y/N]:\n', 's');
%     con = strcmpi(answer, 'y');
% end
% sampleImage = sampleImage(rows, :, :);
% 
% % Ask user for rows to keep
% con = false;
% while ~con
% 
%     imshow(sampleImage);
%     set(gca, 'Visible', 'on');
%     cols = input(['Enter guess at width to keep (index range between 1 and ',...
%         num2str(nCol) ', enclosed in square brackets:\n']);
% 
%     % Update image
%     imshow(sampleImage(:, cols, :));
%     set(gca, 'Visible', 'on');
%     set(gca,'XMinorTick','on');
%     
%     answer = input('Finished? [Y/N]:\n', 's');
%     con = strcmpi(answer, 'y');
% end
warning('on', 'images:initSize:adjustingMag');

% Crop all images with row and columns to keep
obj.cropImages(rows, cols);
close(newFig);