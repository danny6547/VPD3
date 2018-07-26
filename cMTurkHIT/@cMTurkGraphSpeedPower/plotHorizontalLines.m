function h = plotHorizontalLines(ax, y)
%plotHorizontalLines Plot horizontal lines on axis at y values
%   Detailed explanation goes here

% Input
validateattributes(ax, {'matlab.graphics.axis.Axes'}, {'scalar'},...
    'cMTurkGraphSpeedPower.plotHorizontalLines', 'ax', 1);
validateattributes(y, {'numeric'}, {'vector', 'integer', 'positive', 'real'},...
    'cMTurkGraphSpeedPower.plotHorizontalLines', 'ax', 1);

% Plot
nLines = numel(y);
x_v = xlim(ax);
y_m = repmat(y(:)', [2, 1]);
x_m = repmat(x_v(:)', [nLines, 1])';
origNextPlot = get(ax, 'NextPlot');
set(ax, 'NextPlot', 'add');
h = plot(x_m, y_m, 'Color', 'b', 'LineWidth', 1);

% Re-assign original graphics properties
set(ax, 'NextPlot', origNextPlot);
end