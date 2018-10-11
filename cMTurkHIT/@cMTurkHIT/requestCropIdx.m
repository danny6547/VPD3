function [rows, cols] = requestCropIdx(img)
%requestCropIdx Request user input of indices to crop image with
%   Detailed explanation goes here

% Ask user for rows to keep
[nRows, nCol, ~] = size(img);
con = false;
while ~con

    imshow(img);
    set(gca, 'Visible', 'on');
    rows = input(['Enter guess at height to keep (index range between 1 and ',...
        num2str(nRows) ', enclosed in square brackets:\n']);

    % Update image
    imshow(img(rows, :, :));
    set(gca, 'Visible', 'on');
    set(gca,'XMinorTick','on');

    answer = input('Continue to width? [Y/N]:\n', 's');
    con = strcmpi(answer, 'y');
end
img = img(rows, :, :);

% Ask user for rows to keep
con = false;
while ~con

    imshow(img);
    set(gca, 'Visible', 'on');
    cols = input(['Enter guess at width to keep (index range between 1 and ',...
        num2str(nCol) ', enclosed in square brackets:\n']);

    % Update image
    imshow(img(:, cols, :));
    set(gca, 'Visible', 'on');
    set(gca,'XMinorTick','on');
    
    answer = input('Finished? [Y/N]:\n', 's');
    con = strcmpi(answer, 'y');
end
end