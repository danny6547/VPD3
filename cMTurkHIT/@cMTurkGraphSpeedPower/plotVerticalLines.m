function h = plotVerticalLines(obj, filename)
%plotHorizontalLines Plot horizontal lines on axis at y values
%   Detailed explanation goes here

% Input
% validateattributes(ax, {'matlab.graphics.axis.Axes'}, {'vector'},...
%     'cMTurkGraphSpeedPower.plotVerticalLines', 'ax', 1);
filename = validateCellStr(filename, ...
    'cMTurkGraphSpeedPower.plotVerticalLines', 'filename', 2);
% validateattributes(speed, {'numeric'}, {'vector', 'integer', 'positive', 'real'},...
%     'cMTurkGraphSpeedPower.plotVerticalLines', 'x', 3);

for fi = 1:numel(filename)
    
    % Load file
    currFile = filename{fi};
    img1 = imread(currFile);
    imshow(img1);
    ax = gca;
    
    % Plot lines
    speed = obj.linspaceSpeedOrdinate(ax);
    
    % Expand vector data to multiple lines
    nLines = numel(speed);
    y_v = ylim(ax(fi));
    x_m = repmat(speed(:)', [2, 1]);
    y_m = repmat(y_v(:)', [nLines, 1])';
    
    % Get original graphic properties
    origNextPlotAx = get(ax(fi), 'NextPlot');
    currFig = get(ax(fi), 'Parent');
    origNextPlotFig = get(currFig, 'NextPlot');
    set(ax(fi), 'NextPlot', 'add');
    set(currFig, 'NextPlot', 'add');
    
    % Plot
    h = plot(ax(fi), x_m, y_m, 'Color', 'b', 'LineWidth', 1);
    uistack(h, 'top');

    % Re-assign original graphics properties
    set(ax(fi), 'NextPlot', origNextPlotAx);
    set(currFig, 'NextPlot', origNextPlotFig);
    
    % Tick marks
    set(ax(fi), 'XTick', speed(2:2:end));
    set(ax(fi), 'YTick', 50:50:floor(max(ylim(ax(fi)))));
    xtickangle(ax(fi), 45)
    set(currFig, 'Color', [1, 1, 1])
    
    % Save image
    set(ax(fi), 'Visible', 'on');
    f = getframe(currFig);
    img2 = frame2im(f);
    imwrite(img2, currFile);
    
    % Assign into obj
    obj.RowValues = speed;
    close(currFig);
end