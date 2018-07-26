function ax = concatPixelAxes(filename)
%concatPixelAxes concatenate image of axes with tick marks at pixel indices
%   Detailed explanation goes here

% Read
for fi = 1:numel(filename)
    
    currFile = filename{fi};
    img = imread(currFile);

    % Create new axes for image
    f1 = figure('Visible', 'off');
    ax1 = axes('Parent', f1);
    warning('off', 'images:initSize:adjustingMag');
    imshow(img, 'Parent', ax1);
    set(ax1, 'Visible', 'on')

    % Create second axes and image
    f2 = figure('Visible', 'off');
    ax2 = axes('Parent', f2);
    imshow(img, 'Parent', ax2);
    warning('on', 'images:initSize:adjustingMag');
    set(ax2, 'Visible', 'on')

    % Assign both axes to same figure
    set(ax2, 'Parent', get(ax1, 'Parent'))
    linkaxes([ax1, ax2], 'xy');
    delete(f2);

    % Set second axis to top right
    set(ax2, 'YAxisLocation', 'right');
    set(ax2, 'XAxisLocation', 'top');

    % Format axes
    set(ax1, 'XTick', 50:50:size(ax1.Children.CData, 2));
    set(ax2, 'XTick', 50:50:size(ax1.Children.CData, 2));
    set(ax1, 'YTick', 50:50:size(ax1.Children.CData, 1));
    set(ax2, 'YTick', 50:50:size(ax1.Children.CData, 1));
    xtickangle(ax1, 45)
    xtickangle(ax2, 45)
    set(gcf, 'Color', [1, 1, 1])
    set(gcf, 'WindowStyle', 'normal',...
                'units', 'normalized'); %,...
                % 'Position', [0, 0, 0.5, 1])

    % Save 
    frm = getframe(f1);
    imwrite(frm.cdata, currFile);
	close(f1);

    % Output
    ax = [ax1, ax2];
end