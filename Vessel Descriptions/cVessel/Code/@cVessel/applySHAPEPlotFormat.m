function applySHAPEPlotFormat(~, varargin)
% applySHAPEPlotFormat Apply plot format of SHAPE report performance graph

% Input
if nargin > 1
    
    ax = varargin{1};
    validateattributes(ax, {'matlab.graphics.axis.Axes'}, {'vector'}, ...
        'cVessel.applySHAPEPlotFormat', 'ax', 2);
else
    
    ax = gca;
end

% Set graph properties to match those of Delegate report
currLines = findall(ax, 'Type', 'line');

set(currLines, 'MarkerSize', 2.25);
currFig = [ax.Parent];
set(currFig, 'Color', [1, 1, 1]);
datetick('x', 'QQ-YYYY');

set([ax.YLabel], 'String', 'Speed Deviation (%)');
set([ax.Title], 'String', '');

set(ax, 'XGrid', 'on');
set(ax, 'YGrid', 'on');
set(ax, 'XColor', [0.35, 0.35, 0.35]);
set(ax, 'YColor', [0.35, 0.35, 0.35]);
set(ax, 'XAxisLocation', 'top');

axis tight;

set(currFig, 'Units', 'normalized', ...
    'Position', [0.5, 0.2, 0.5, 0.35]);

for ai = 1:numel(ax)
    
    lines_h = findall(ax(ai), 'Type', 'Line');
    lines_h = lines_h(end:-1:1);

    col_m = [0.1, 0.2, 0.7;...
            0.2, 0.55, 0.2;...
            0.875 0.1 0.1;...
            0.95 0.850 0.2;...
            0.65 0.40 0.75];

    % Filter out any lines representing averages
    ddLines = findall(lines_h, 'LineStyle', 'none');
    avgLine_l = arrayfun(@(x) numel(x.XData)==1, ddLines);
    ddLines(avgLine_l) = [];
    for li = 1:numel(ddLines)

        set(ddLines(li), 'Color', col_m(li, :));
        set(ddLines(li), 'MarkerFaceColor', col_m(li, :));
    end
end