function [rows, cols] = areaFromExtents(bl, tr, sz)
%areaFromExtents Indices of area of image from bottom-left and top-right
%   Detailed explanation goes here

nRow = sz(1);
nCol = sz(2);

bottomWidth = nRow - bl(2);
leftWidth = bl(1);
topWidth = tr(2);
rightWidth = nCol - tr(1);

% Rows and columns to keep from those to remove
rows = 1:nRow;
rows = rows(topWidth:nRow-bottomWidth);
cols = 1:nCol;
cols = cols(leftWidth:nCol-rightWidth);
end