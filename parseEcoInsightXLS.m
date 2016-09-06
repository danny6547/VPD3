function [ dates, pidx, regr, dataStartRow, ship] = parseEcoInsightXLS( filename )
%parseEcoInsightXLS Parse relevant data from EcoInsight time-series data
%   [dates, pidx, regr, dataStartRow, ship] = parseEcoInsightXLS(FILENAME)
%   will return from input FILENAME, a string giving the full path to a
%   .xlsx file downloaded from DNVGL's EcoInsight web graphical interface,
%   the values for the dates in the vector DATES, the corresponding 
%   performance index values in PIDX, the corresponding regression line 
%   values in REGR, the first row of the data in the file in scalar 
%   DATASTARTROW and all non-time-dependent data in struct SHIP.

% Read
[dat, txt] = xlsread(filename);
dataStartRow = find(cellfun(@(x) isequal(x, 'Date'), txt(:, 1)), 1) + 1;
date_c = txt(dataStartRow:end, 1);
pidx = dat(:, 1);
regr = dat(:, 3);

shipDataLength = 18;
shipdataEnd = dataStartRow - 3;
shipdataStart = shipdataEnd - shipDataLength;
shipdata = txt(shipdataStart : shipdataEnd, [1, 4]);
shipdata( cellfun(@isempty, shipdata(:, 1)), :) = [];
fnames_c = shipdata(:, 1);
fnames_c = regexprep(fnames_c, {' ', '[', '%', ']'}, repmat({'_'}, 1, 4));
ship = cell2struct(shipdata(:, 2), fnames_c, 1);

% Convert Date
date_c = cellfun(@(x) datenum(x, 'dd-mm-yyyy'), date_c, 'Uni', 0);
dates = [date_c{:}];
dates = dates(:);

end