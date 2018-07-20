function [rows, cols] = requestCropIdx(img)
%requestCropIdx Request user input of indices to crop image with
%   Detailed explanation goes here

% Ask user for rows to keep
[nRow, nCol, ~] = size(img);
con = false;
imshow(img);
set(gca, 'Visible', 'on');
set(gca, 'NextPlot', 'replacechildren');
bottomleft = input(['Enter indices of bottom-left of graph area in square brackets ([x, y]) and enter the text ''break'' when done:\n'], 's');
while ~con
    
    bottomleft = eval(bottomleft);

    % Update image
    grey = 25;
    bottomWidth = nRow - bottomleft(2);
    leftWidth = bottomleft(1);
    
    tempImg = img;
    grey_m = repmat(uint8([grey, grey, grey]'), 1, bottomWidth, nCol);
    grey_m = permute(grey_m, [2, 3, 1]);
    tempImg(end-bottomWidth+1:end, :, :) = ...
        tempImg(end-bottomWidth+1:end, :, :) - grey_m;
    
    grey_m = repmat(uint8([grey, grey, grey]'), 1, nRow, leftWidth);
    grey_m = permute(grey_m, [2, 3, 1]);
    tempImg(:, 1:leftWidth, :) = ...
        tempImg(:, 1:leftWidth, :) - grey_m;
    
    imshow(tempImg);
    set(gca, 'Visible', 'on');
    set(gca,'XMinorTick','on');
    set(gca, 'NextPlot', 'replacechildren');

    bottomleft = input('', 's');
    con = strcmpi(bottomleft, 'break');
end
cropImg = tempImg;

topright = input(['Enter indices of the top-right of the graph area in square brackets ([x, y]) and enter the text ''break'' when done:\n'], 's');
con = false;
while ~con
    
    topright = eval(topright);
    
    % Update image
    grey = 25;
    topWidth = topright(2);
    rightWidth = nCol - topright(1);
    
    tempImg = cropImg;
    grey_m = repmat(uint8([grey, grey, grey]'), 1, topWidth, nCol);
    grey_m = permute(grey_m, [2, 3, 1]);
    tempImg(1:topWidth, :, :) = ...
        tempImg(1:topWidth, :, :) - grey_m;
    
    grey_m = repmat(uint8([grey, grey, grey]'), 1,  nRow, rightWidth);
    grey_m = permute(grey_m, [2, 3, 1]);
    tempImg(:, end-rightWidth+1:end, :) = ...
        tempImg(:, end-rightWidth+1:end, :) - grey_m;
    
    imshow(tempImg);
    set(gca, 'Visible', 'on');
    set(gca,'XMinorTick','on');
    set(gca, 'NextPlot', 'replacechildren');

    topright = input('', 's');
    con = strcmpi(topright, 'break');
end

% Rows and columns to keep from those to remove
rows = 1:nRow;
rows = rows(topWidth:nRow-bottomWidth);
cols = 1:nCol;
cols = cols(leftWidth:nCol-rightWidth);
imshow(img(rows, cols, :));

end