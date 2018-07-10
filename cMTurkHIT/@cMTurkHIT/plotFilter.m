function obj = plotFilter(obj)
%plotFilter Plot and request user manually filter points
%   Detailed explanation goes here

ax = obj.plot;
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
fprintf(1, '%s\n', 'points, right click  and select ''Copy to Clipboard'',');
fprintf(1, '%s\n', 'then hit return. When finished, enter any text below:');

fin = false;
while ~fin
    
    % Check if user has entered any text, and continue
    answer = input('', 's');
    fin = ~isempty(answer);
    if fin
        
        break
    end
    
    % Read data copied from graph
    invalid = clipboard('paste');
    if ~isempty(invalid)
        
        % In either case of data being grid or not, the last column is removed
        invalid = str2num(invalid); %#ok<ST2NM>
        invalid(:, end) = [];
        
        % Add input to filtered data and update image
        obj.InvalidData = [obj.InvalidData; invalid];
        obj.plot(ax, true);
    end
end

% Reset graphical properties to default
brush off
set(ax, 'NextPlot', 'Replace');
end