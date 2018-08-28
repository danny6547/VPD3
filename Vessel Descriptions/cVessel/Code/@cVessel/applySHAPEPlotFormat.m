function applySHAPEPlotFormat(~, varargin)
%

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
currFig = get(gca, 'Parent');
set(gcf, 'Color', [1, 1, 1]);
datetick('x', 'QQ-YYYY');

set(get(ax, 'YLabel'), 'String', 'Speed Loss (%)');
set(get(ax, 'Title'), 'String', '');

set(ax, 'XGrid', 'on');
set(ax, 'YGrid', 'on');
set(ax, 'XColor', [0.35, 0.35, 0.35]);
set(ax, 'YColor', [0.35, 0.35, 0.35]);
set(ax, 'XAxisLocation', 'top');

axis tight;

set(gcf, 'Units', 'normalized', ...
    'Position', [0.5, 0.2, 0.5, 0.35]);

lines_h = findall(ax, 'Type', 'Line');
lines_h = lines_h(end:-1:1);

col_m = [0.1, 0.2, 0.7; 0.2, 0.7, 0.2];
for li = 1:numel(lines_h)
    
    set(lines_h(li), 'Color', col_m(li, :));
end