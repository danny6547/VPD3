function obj = cropImages(obj, rows, cols)
%cropImages Crop all images in directory after user interaction
%   Detailed explanation goes here


[filepath, filename] = obj.imageFiles();
sampleImageFile = filepath{1};
sampleImage = imread(sampleImageFile);

% Copy files into new dir "Original"
[~, imageDir] = obj.imageDir();
origDir_ch = fullfile(imageDir, 'Original');
origFiles_c = cellfun(@(x) fullfile(origDir_ch, x), filename, 'Uni', 0);
mkdir(origDir_ch);
cellfun(@(x, y) copyfile(x, y), filepath, origFiles_c);

% Copy files to be cropped into x axis
[~, nameOnly_c, ext_c] = cellfun(@fileparts, filename, 'Uni', 0);
xAxFiles_c = cellfun(@(x, y, z) fullfile(fileparts(x), [y, '_x_axis', z]),...
    filepath, nameOnly_c, ext_c, 'Uni', 0);
cellfun(@(x, y) copyfile(x, y), filepath, xAxFiles_c);

% Copy files to be cropped into y axis
yAxFiles_c = cellfun(@(x, y, z) fullfile(fileparts(x), [y, '_y_axis', z]),...
    filepath, nameOnly_c, ext_c, 'Uni', 0);
cellfun(@(x, y) copyfile(x, y), filepath, yAxFiles_c);

% Crop x axis images
[nRow, nCol, ~] = size(sampleImage);
xbuffer = obj.GraphImageOffsetHorizontal; % 50;
ybuffer = obj.GraphImageOffsetVertical; %75;
xrows = max(rows):min([max(rows)+ybuffer, nRow]);
xcols = min([min(cols)-xbuffer, nCol]):min([max(cols)+xbuffer, nCol]);
cropImages@cMTurkHIT(obj, xrows, xcols, xAxFiles_c);

% Crop y axis images
yrows = min([min(rows)-ybuffer, nRow]):min([max(rows)+ybuffer, nRow]);
ycols = max([min(cols)-100, 1]):min(cols);
cropImages@cMTurkHIT(obj, yrows, ycols, yAxFiles_c);

% Crop all images with row and columns to keep
grows = min(rows):max(rows);
gcols = min(cols):max(cols);
cropImages@cMTurkHIT(obj, grows, gcols, filepath);
obj.GraphWidthPixels = numel(unique(cols));
obj.GraphHeightPixels = numel(unique(rows));

% Anonymise images
fig = obj.anonymiseUI(filepath);
close(fig)

% Concatenate image of axes tick marks
obj.concatPixelAxes(filepath);