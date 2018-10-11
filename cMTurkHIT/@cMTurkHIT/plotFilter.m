function obj = plotFilter(obj, varargin)
%plotFilter Plot and request user manually filter points
%   Detailed explanation goes here

% Error if no data found
if isempty(obj.FileData)
    
    errid = 'CannotFilter:NoData';
    errmsg = 'Output file must be processed before data can be filtered';
    error(errid, errmsg);
end

if nargin > 1
    
    ax = varargin{1};
    validateattributes(ax, {'matlab.graphics.axis.Axes'}, {'scalar'},...
        'cMTurkGraphSpeedPower.plotFilter', 'ax', 2);
else
    ax = obj.plot([], true);
end

set(ax, 'NextPlot', 'ReplaceChildren');

% Dock so user can find figure easier, turn on data brushing
set(get(ax, 'Parent'), 'WindowStyle', 'Docked');
brush on

% Clear windows clipboard
if ~isempty(clipboard('paste'))
    
    system('echo off | clip');
end

% Request user input for invalid points
fprintf(1, '%s\n', 'To filter data, click (and drag) to select invalid ');
fprintf(1, '%s\n', 'points, right click and select ''Copy Data to Clipboard'',');
fprintf(1, '%s\n', 'then hit return, and repeat as necessary. Enter the text ');
fprintf(1, '%s\n', '''undo'' to replace the most recently-removed points. ');
fprintf(1, '%s\n', 'Enter any other text to return.');

fin = false;
lastNRows = [];
while ~fin
    
%     xlim = get(ax, 'XLim');
%     ylim = get(ax, 'YLim');
%     zlim = get(ax, 'ZLim');
    
    % Check if user has entered any text
    answer = input('', 's');
    
    % Get current display properties
    view = get(ax, 'View');
    
    % Undo last
    undo_l = strcmpi(answer, 'undo');
    if undo_l
        
        obj.InvalidData(end-lastNRows+1:end, :) = [];
        lastNRows = [];
        system('echo off | clip');
        obj.plot(ax, true);
    end
    
    % Anything else entered, exit
    fin = ~isempty(answer) && ~undo_l;
    if fin
        
        break
    end
    
    % Read data copied from graph
    invalid = clipboard('paste');
    if ~isempty(invalid)
        
        % In either case of data being grid or not, the last column is removed
        invalid = str2num(invalid); %#ok<ST2NM>
        invalid(:, end) = [];
        lastNRows = size(invalid, 1);
        
        % Add input to filtered data and update image
        obj.InvalidData = [obj.InvalidData; invalid];
        obj.plot(ax, true);
    end
    
    % Assign current display properties
    set(ax, 'View', view);
%     set(ax, 'XLim', xlim);
%     set(ax, 'YLim', ylim);
%     set(ax, 'ZLim', zlim);
end

% Reset graphical properties to default
brush off
set(ax, 'NextPlot', 'Replace');
end