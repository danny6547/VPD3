function [timedata, dataStartRow, ship] = parseEcoInsightXLS( filename )
%parseEcoInsightXLS Parse relevant data from EcoInsight time-series data
%   [dates, pidx, regr, dataStartRow, ship] = parseEcoInsightXLS(FILENAME)
%   will return from input FILENAME, a string giving the full path to a
%   .xlsx file downloaded from DNVGL's EcoInsight web graphical interface,
%   the values for the dates, the corresponding performance index values 
%   and the corresponding regression line values in struct TIMEDATA, the 
%   first row of the data in the file in scalar DATASTARTROW and all 
%   non-time-dependent data in struct SHIP. TIMEDATA will have the fields 
%   DATES, PIDX and REGR containing the above-mentioned data.

% Inputs
validateattributes(filename, {'char', 'cell'}, {'vector'}, ...
    'parseEcoInsightXLS', 'filename', 1);
filename = cellstr(filename);

% Initalise Outputs
numFiles = numel(filename);
timedata = struct('dates', [], 'pidx', [], 'sidx', [], 'regr', []);
% ship = repmat(struct(), [numFiles, 1]);
dataStartRow = nan(1, numFiles);

for fi = 1:numFiles
    
    % Read
    [dat, txt] = xlsread(filename{fi});
        version = 0;
    try dataStartRow(fi) = find(cellfun(@(x) isequal(x, 'Date'), txt(:, 1)), 1) + 1;
        
        version = 2;
        
    catch e
        
        try dataStartRow(fi) = find(cellfun(@(x) isequal(x, '     Date'), txt(:, 1)), 1) + 1;
        
            version = 1;
        catch ee
            
            rethrow(e);
            
        end
    end
    
    % Is data Performance or speed Index?
    if strcmpi(txt{dataStartRow(fi) - 1, 2}, 'Performance index')
        pidx = dat(:, 1);
        sidx = nan(size(dat(:, 1)));
    elseif strcmpi(txt{dataStartRow(fi) - 1, 2}, 'Speed deviation')
        sidx = dat(:, 1);
        pidx = nan(size(dat(:, 1)));
    end
    
    date_c = txt(dataStartRow(fi):end, 1);
    regr = dat(:, 3);
    
    if version == 2
        shipDataLength = 18;
        shipdataEnd = dataStartRow(fi) - 3;
        shipdataStart = shipdataEnd - shipDataLength;
        shipdata = txt(shipdataStart : shipdataEnd, [1, 4]);
        shipdata( cellfun(@isempty, shipdata(:, 1)), :) = [];
        fnames_c = shipdata(:, 1);
        fnames_c = regexprep(fnames_c, {' ', '[', '%', ']'}, repmat({'_'}, 1, 4));

        if fi == 1
            ship(fi) = cell2struct(cell(length(fnames_c), 1), fnames_c, 1);
            % ship = repmat(struct(), [numFiles, 1]);
        end

        ship(fi) = cell2struct(shipdata(:, 2), fnames_c, 1);
        
    else
        
        ship = struct();

    end
    
    % Convert Date
    date_c = cellfun(@(x) datenum(x, 'dd-mm-yyyy'), date_c, 'Uni', 0);
    dates = [date_c{:}];
    dates = dates(:);
    
    timedata(fi).dates = dates;
    timedata(fi).pidx = pidx;
    timedata(fi).sidx = sidx;
    timedata(fi).regr = regr;
    
end