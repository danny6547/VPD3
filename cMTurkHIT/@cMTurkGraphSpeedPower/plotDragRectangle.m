function [h] = plotDragRectangle(varargin)
%plotDragRectangle Plot a draggable rectangle
%   Detailed explanation goes here


% Input
if nargin == 0
    ax = gca;
end

if nargin > 0
    ax = varargin{1};
    validateattributes(ax, {'matlab.graphics.axis.Axes'}, {'scalar'},...
        'cMTurkGraphSpeedPower.plotDragRectangle', 'ax', 1);
end

xrange = xlim(ax);
yrange = ylim(ax);
defaultWidth = 0.1*(xrange(2) - xrange(1));
if isinf(defaultWidth)
    
    defaultWidth = 1;
end
defaultHeight = 0.1*(yrange(2) - yrange(1));
if isinf(defaultHeight)
    
    defaultHeight = 1;
end

rectpos = [0.45, 0.45, defaultWidth, defaultHeight];
if nargin > 1
    
    rectpos = varargin{2};
    try 
    validateattributes(rectpos, {'double'}, {'nonnegative',...
        'real', 'vector', 'row', 'numel', 4},...
        'cMTurkGraphSpeedPower.plotDragRectangle', 'rectpos', 2);
    catch ee
        
        if ~strcmp(ee.message, 'MATLAB:cMTurkGraphSpeedPower:plotDragRectangle:invalidType')
           
            validateattributes(rectpos, {'double'}, {'nonnegative',...
                'real', 'vector', 'row', 'numel', 2},...
                'cMTurkGraphSpeedPower.plotDragRectangle', 'rectpos', 2);
            rectpos = [varargin{2}, defaultWidth, defaultHeight];
        end
    end
end

% Get x,y of vertices
bl = rectpos(1:2);
tl = [rectpos(1), rectpos(2) + rectpos(4)];
br = [rectpos(1) + rectpos(3), rectpos(2)];
tr = [rectpos(1) + rectpos(3), rectpos(2) + rectpos(4)];

% hold on;
set(gca, 'NextPlot', 'add')

v1 = plot(ax, tl(1), tl(2));
v2 = plot(ax, tr(1), tr(2));
v3 = plot(ax, br(1), br(2));
v4 = plot(ax, bl(1), bl(2));
vv = [v1 v2 v3 v4];
set(vv,'Marker','o','MarkerSize',5,'Color',[0, 0, 1, 0.5]);
h = vv;

set(vv, 'UserData', 'draggableRectangle')

setappdata(gca,'vv',vv);
setappdata(gca,'p',[]);

draggable(v1,@redraw_poly);
draggable(v2,@redraw_poly);
draggable(v3,@redraw_poly);
draggable(v4,@redraw_poly);

redraw_poly;
% hold off;
end

    function redraw_poly(h)

    % Deleting the previous polygon

    currChild = get(gca, 'Children');
    userdata_c = get(currChild, 'UserData');
    otherChildren_l = ~cellfun(@(x) isequal(x, 'draggableRectangle'),...
        userdata_c);
%     otherChildren_l = ~cellfun(@(x) isequal(x, 'draggableRectangle'),...
%         userdata_c) & ~arrayfun(@(x) isa(x, 'matlab.graphics.primitive.Image'),...
%         currChild);
    otherChildren = currChild(otherChildren_l);
    
    delete(getappdata(gca,'p'));

    % Retrieving the vertex vector and corresponding xdata and ydata

    vv = getappdata(gca,'vv');
    xdata = cell2mat(get(vv,'xdata'));
    ydata = cell2mat(get(vv,'ydata'));

    % Plotting the new polygon and saving its handle as application data

    p = plot([xdata' xdata(1)],[ydata' ydata(1)], 'Color', 'k');
    pat = patch([xdata' xdata(1)],[ydata' ydata(1)], 'k', 'facealpha', 0.25);
    
    set(p, 'UserData', 'draggableRectangle')
    set(pat, 'UserData', 'draggableRectangle')
    setappdata(gca,'p',[p, pat]);

    % Putting the vertices on top of the polygon so that they are easier
    % to drag (or else, the polygone line get in the way)

    set(gca,'Children', [vv p pat otherChildren(:)']);
    end