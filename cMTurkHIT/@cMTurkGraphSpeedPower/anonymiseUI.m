function [fig, ax] = anonymiseUI(filename)
%anonymiseUI Anonymise image by overlaying identifying information
%   Detailed explanation goes here

fig = gobjects(1, numel(filename));
ax = gobjects(1, numel(filename));

% Open images
for fi = 1:numel(filename)
    
    currFile = filename{fi};
    img = imread(currFile);
    imshow(img);
    con = false;
    fprintf(1, '%s\n','Create rectangles and other shapes from items under menu');
    fprintf(1, '%s\n','''Annotations'' to block out any identifying text in image.'); 
    fprintf(1, '%s\n','Right-click on the shapes you create and click "Face Color"');
    fprintf(1, '%s\n','from the drop-down menu to choose a fill colour. Click the ');
    fprintf(1, '%s\n','text box icon and label the curves with the same names as ');
    fprintf(1, '%s\n','given in object property ''CurveName'', and, if necessary, ');
    fprintf(1, '%s\n','use arrows to idenitfy the curves. Press the ''Enter'' key ');
    fprintf(1, '%s\n','when done.');

    while ~con

        % Plot rectangle with bottom-left at mouse click
        plottools('on', 'figurepalette')
        plottools('on', 'propertyeditor')

        % Check if user has hit return key
        userin = input('', 's');
        con = isempty(userin);
    end
    
    fig(fi) = gcf;
    ax(fi) = gca;
    f = getframe(gca);
    img = frame2im(f);
    imwrite(img, currFile);
%     plottools('off')
end