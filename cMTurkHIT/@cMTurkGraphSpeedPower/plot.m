function [ax, h] = plot(obj, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if nargin > 1 && ~isempty(varargin{1})
    
    ax = varargin{1};
    validateattributes(ax, {'matlab.graphics.axis.Axes'}, {'scalar'},...
        'cMTurkHIT.plot', 'h', 2);
else
    
    ax = gca;
end

filtered = false;
if nargin > 2
    
    filtered = varargin{2};
    validateattributes(filtered, {'logical'}, {'scalar'}, ...
        'cMTurkHIT.plot', 'filtered', 3);
end

% Error if data not loaded
tbl = obj.FileData;
if ~isempty(tbl)
    
    if filtered
        
        tbl = obj.FilteredData;
    end
    
    % Open image and show axes
    warning('off', 'images:initSize:adjustingMag');
    imageFile = obj.imageFiles;
    img = imread(imageFile{1});
    imshow(img, 'Border', 'tight');
%     openfig(
    set(ax, 'Visible', 'on', 'NextPlot', 'add');
    set(get(ax, 'Parent'), 'Visible', 'on');
    
    % Plot points with image pixel indices
    xname = obj.ImageSpeedName;
    yname = obj.ImagePowerName;
    x = tbl.(xname);
    y = tbl.(yname);
    h = plot(ax, x, y, 'o', 'MarkerFaceColor', [0.3, 0.3, 1]);
    
    warning('on', 'images:initSize:adjustingMag');
end