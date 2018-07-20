function [fig] = anonymiseUI(filename)
%anonymiseUI Anonymise image by overlaying identifying information
%   Detailed explanation goes here

fig = nan(1, numel(filename));

% Open images
for fi = 1:numel(filename)
    
    currFile = filename{fi};
    img = imread(currFile);
    imshow(img);
    con = false;
    fprintf(1, ['Create rectangles and other shapes from items under menu ''Annotations'' to block out any identifying text in image. Click ''Enter'' when done:\n']);

    while ~con

        % Plot rectangle with bottom-left at mouse click
        plottools('on', 'figurepalette')

        % Check if user has hit return key
        userin = input('', 's');
        con = isempty(userin);
    end
    
    fig(fi) = gcf;
    f = getframe(gca);
    img = frame2im(f);
    imwrite(img, currFile);
    plottools('off')
end