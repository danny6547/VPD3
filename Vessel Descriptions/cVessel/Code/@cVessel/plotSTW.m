function plotSTW(obj, varargin)
%plotSTW Plot Speed Through Water as in Section 5 of Hempel ISO Report
%   Detailed explanation goes here

if nargin > 1 && ~isempty(varargin{1})
    
    dates = varargin{1};
else
    
    dates = obj.InService.timestamp;
end

if nargin > 2 && ~isempty(varargin{2})
    
    stw = varargin{2};
else
    
    stw = obj.InService.speed_through_water;
end

convert_l = true;
if nargin > 3
    
    convert_l = varargin{3};
end

if convert_l
mps2knots = 1.943844;
stw = stw*mps2knots;
end

y = stw;
x = dates;

% Filter
low_l = y < 2;
high_y = y > 30;
y(low_l | high_y) = [];
x(low_l | high_y) = [];

% Plot
fig = figure;
ax = axes;
plot(ax, x, y, 'r-');
datetick('x', 'QQ - YYYY', 'keeplimits');
set(ax, 'YGrid', 'on');
set(ax, 'XGrid', 'on');
set(ax, 'YTick', floor(min(y)):ceil(max(y)));
datetick('x', 'QQ-YYYY');
set(get(gca, 'YLabel'), 'String', 'Speed (knots)');
set(gcf, 'Color', [1, 1, 1]);
xtickangle(45);
set(ax, 'Box', 'off');
set(ax, 'XColor', [0.35, 0.35, 0.35]);
set(ax, 'YColor', [0.35, 0.35, 0.35]);
axis tight;

set(fig, 'Units', 'normalized',...
         'Position', [0.1, 0.5, 0.61, 0.25]);
% set(ax, 'Color', [0.5, 0.5, 0.5]);

end