function [obj] = loadXLSX(obj, filename, sheet, firstRow, fileColID, fileColName, tab, tabColNames, varargin)
%loadXLSX Call LOAD IN FILE on .xlsx file with associated table columns
%   Detailed explanation goes here

    % Input
    filename = validateCellStr(filename, 'cVessel.loadXLSX', 'filename', 2);
    validateattributes(sheet, {'char'}, {'vector'}, ...
        'cVessel.loadXLSX', 'filename', 3);
    validateattributes(firstRow, {'numeric'}, {'scalar'}, ...
        'cVessel.loadXLSX', 'filename', 4);
    validateattributes(fileColID, {'numeric', 'cell'}, {'vector'}, ...
        'cVessel.loadXLSX', 'filename', 5);
    validateCellStr(fileColName, 'cVessel.loadXLSX', 'fileColName', 6);
    validateattributes(tab, {'char'}, {'vector'}, ...
        'cVessel.loadXLSX', 'tab', 7);
    tabColNames = validateCellStr(tabColNames, 'cVessel.loadXLSX', ...
        'tabColNames', 8);
    set_c = {''};
    if nargin > 8
        
        set_c = varargin{1};
        validateCellStr(set_c, 'cVessel.loadXLSX', 'set', 9);
    end
    
    dateCols_c = {''};
    if nargin > 9
        
        dateForm_c = varargin{2};
        validateCellStr(dateForm_c, 'cVessel.loadXLSX', 'dateForm', 10);
        
        dateCols_c = dateForm_c(:, 1);
        dateFormats_c = dateForm_c(:, 2);
        
    end
    
    readCols_l = iscellstr(fileColID);
    
    % Append set SQL
    if ~isempty(set_c)

        % Generate default set statement
        [~, ~, defSet_c] = obj.setNullIfEmpty(tabColNames);
        cutAtEquals_f = @(x) x(1:strfind(x, ' = ')-1);
        inDefaultNames_c = cellfun(cutAtEquals_f, defSet_c, 'Uni', 0);

        % Find which columns are in input set statement
        inSetNames_c = cellfun(cutAtEquals_f, set_c, 'Uni', 0);

        % Replace those in default with those in input
        cols2replace_l = ismember(inDefaultNames_c, inSetNames_c);
        x_l = ismember(inSetNames_c, inDefaultNames_c);
        defSet_c(cols2replace_l) = set_c(x_l);
        set_c = [defSet_c, set_c(~x_l)];
    end
    set_ch = ['SET ', obj.colSepList(set_c)];

    % Get IMO number for insertion into RawData
    imo_ch = '';
    setNames_c = cellfun(cutAtEquals_f, set_c, 'Uni', 0);
    [isIMO, idxIMO] = ismember('IMO_Vessel_Number', setNames_c);

    if isIMO

        imoNum_ch = set_c{idxIMO}(strfind(set_c{idxIMO}, ' = ')+3:end);
        fileColName = [fileColName,{'IMO_Vessel_Number'}];
        tabColNames = [tabColNames, {'IMO_Vessel_Number'}];
    end

    
    % Iterate over files
    for fi = 1:numel(filename)
        
        % Read only specified columns from file
        currFile = filename{fi};
        file_tbl = readtable(currFile, 'Sheet', sheet, ...
            'ReadVariableNames', readCols_l);
        file_tbl = file_tbl(firstRow:end, fileColID);
        
        % Convert any date and time columns before writing to file
        [isDate, idxDate] = ismember('Date_UTC', fileColName);
        if isDate
            
            invalidDate = cellfun(@isempty, file_tbl{:, idxDate});
            
            
            file_tbl(invalidDate, :) = [];
            file_tbl(:, idxDate) = cellstr(datestr(datenum(file_tbl{:, idxDate}, 'dd-mm-yyyy'), 'yyyy-mm-dd'));
        end
        
        [isTime, idxTime] = ismember('Time_UTC', fileColName);
        if isTime
            
            invalidTime = cellfun(@isempty, file_tbl{:, idxTime});
            file_tbl(invalidTime, :) = [];
            file_tbl(:, idxTime) = cellstr(datestr(str2num(char(file_tbl{:, idxTime})), 'HH:MM:SS'));
        end
        
        [isDT, idxDT] = ismember('DateTime_UTC', fileColName);
        if isDT
            dateForm_ch = 'dd-mm-yyyy HH:MM:SS';
            [dInput, dIdx] = ismember('DateTime_UTC', dateCols_c);
            if dInput
                dateForm_ch = dateFormats_c{dIdx};
            end
            file_tbl(:, idxDT) = cellstr(datestr(datenum(file_tbl{:, idxDT}, dateForm_ch), 'yyyy-mm-dd HH:MM:SS'));
        end
        
        for ti = 1:width(file_tbl)
            
            try tempTable = varfun(@str2double, file_tbl(:, ti));
                
                if numel(find(isnan(tempTable{:, 1}))) < 0.5*height(tempTable)
                    file_tbl = [file_tbl(:, 1:ti-1), tempTable, file_tbl(:, ti+1:end)];
                end
            end
        end
        
        % Write table as csv
        tempFile = 'tempCSVLoadFile.csv';
        matDir = [getenv('HOMEDRIVE') getenv('HOMEPATH') '\OneDrive - Hempel Group\Documents\MATLAB'];
        tempFile = fullfile(matDir, tempFile);
            tempTab = 'tempCSVLoad';
        writetable(file_tbl, tempFile, 'WriteVariableNames', false);
        
        % Prepare outpus
        if isIMO
           
            imo_v = repmat(str2double(imoNum_ch), [height(file_tbl), 1]);
            file_tbl.IMO_Vessel_Number = imo_v; 
        end
        
        % Load in CSV file
        try obj = obj.loadInFileDuplicate(tempFile, fileColName, tempTab, tab,...
                ',', 0, set_ch, tabColNames);
            
        catch ee
            
            delete(tempFile);
            rethrow(ee);
        end
        
        delete(tempFile);
        
        % Insert this files data into table
%         obj.insertValuesDuplicate(tab, tabColNames, file_c, set_c);
    end
end