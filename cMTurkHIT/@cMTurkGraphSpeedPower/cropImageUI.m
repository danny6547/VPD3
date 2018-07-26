function obj = cropImageUI(obj, varargin)
%cropImageUI Summary of this function goes here
%   Detailed explanation goes here

% Input
rowsInput_l = false;
colsInput_l = false;
if nargin > 1 && ~isempty(varargin{1})
    
    rowsInput_l = true;
    bottomleft = varargin{1};
    validateattributes(bottomleft, {'numeric'}, {'vector', 'integer', ...
        'positive', 'real'}, 'cMTurkGraphSpeedPower.cropImageUI', ...
        'bottomleft', 2);
end
if nargin > 2 && ~isempty(varargin{2})
    
    colsInput_l = true;
    topright = varargin{2};
    validateattributes(topright, {'numeric'}, {'vector', 'integer',...
        'positive', 'real'}, 'cMTurkGraphSpeedPower.cropImageUI', ...
        'cols', 3);
end
skipUI_l = rowsInput_l && colsInput_l;

% Get sample image
obj.errorIfImagesMissing();
filepath = obj.imageFiles();
sampleImageFile = filepath{1};
sampleImage = imread(sampleImageFile);

% Get rows and columns of graph area
if skipUI_l
    
    sz = size(sampleImage);
    sz(end) = [];
    [rows, cols] = obj.areaFromExtents(bottomleft, topright, sz);
else
    
%     newFig = figure;
    warning('off', 'images:initSize:adjustingMag');
    imshow(sampleImage, 'Border', 'tight');
    set(gca, 'Visible', 'on');
    [rows, cols] = obj.requestCropIdx(sampleImage);
    warning('on', 'images:initSize:adjustingMag');
end

obj = cropImages(obj, rows, cols);

% % Copy files into new dir "Original"
% [~, imageDir] = obj.imageDir();
% origDir_ch = fullfile(imageDir, 'Original');
% origFiles_c = cellfun(@(x) fullfile(origDir_ch, x), filename, 'Uni', 0);
% mkdir(origDir_ch);
% cellfun(@(x, y) copyfile(x, y), filepath, origFiles_c);
% 
% % Copy files to be cropped into x axis
% [~, nameOnly_c, ext_c] = cellfun(@fileparts, filename, 'Uni', 0);
% xAxFiles_c = cellfun(@(x, y, z) fullfile(fileparts(x), [y, '_x_axis', z]),...
%     filepath, nameOnly_c, ext_c, 'Uni', 0);
% cellfun(@(x, y) copyfile(x, y), filepath, xAxFiles_c);
% 
% % Copy files to be cropped into y axis
% yAxFiles_c = cellfun(@(x, y, z) fullfile(fileparts(x), [y, '_y_axis', z]),...
%     filepath, nameOnly_c, ext_c, 'Uni', 0);
% cellfun(@(x, y) copyfile(x, y), filepath, yAxFiles_c);
% 
% % Crop x axis images
% [nRow, nCol, ~] = size(sampleImage);
% xbuffer = obj.GraphImageOffsetHorizontal; % 50;
% ybuffer = obj.GraphImageOffsetVertical; %75;
% xrows = max(rows):min([max(rows)+ybuffer, nRow]);
% xcols = min([min(cols)-xbuffer, nCol]):min([max(cols)+xbuffer, nCol]);
% obj.cropImages(xrows, xcols, xAxFiles_c);
% 
% % Crop y axis images
% yrows = min([min(rows)-ybuffer, nRow]):min([max(rows)+ybuffer, nRow]);
% ycols = max([min(cols)-100, 1]):min(cols);
% obj.cropImages(yrows, ycols, yAxFiles_c);
% 
% % Crop all images with row and columns to keep
% obj.cropImages(rows, cols, filepath);
% obj.GraphWidthPixels = numel(unique(cols));
% obj.GraphHeightPixels = numel(unique(rows));
% 
% % Anonymise images
% fig = obj.anonymiseUI(filepath);
% close(fig)
% 
% % Concatenate image of axes tick marks
% obj.concatPixelAxes(filepath);
% close(newFig);