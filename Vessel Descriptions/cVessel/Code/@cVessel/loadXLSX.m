function [obj, numWarnings, warnings] = loadXLSX(obj, filename, sheet, firstRow, fileColID, fileColName, varargin)
%loadXLSX Call LOAD IN FILE on .xlsx file with data interpretation
%   obj = loadXLSX(obj, filename, sheet, firstRow, fileColID, fileColName) 
%	will load into database table 'RawData' the row, columns data in the 
%	XLSX file FILENAME, in sheet SHEET, whose first row is given by 
%	FIRSTROW, and whose column indices are given by FILECOLID and 
%   corresponding column names by FILECOLNAME. FILENAME can be a file path
%   string or a cell array of such strings. SHEET can be a string or cell
%   array of strings containing the worksheet names. FIRSTROW must be a 
%   positive, scalar integer. FILECOLID is a vector of positive integers
%   and FILECOLNAME is a cell array of strings of equal length to FILECOLID
%   and whose elements correspond to those of FILECOLID.
%   obj = loadXLSX(..., tab) will do as above but load the data into
%   database table given by string TAB. The default value for TAB is
%   'RawData'.
%   obj = loadXLSX(..., set) will do as above but also apply the SQL SET
%   statment given by string cell array of strings SET within the SQL LOAD
%   IN FILE statement.
%   obj = loadXLSX(..., datecols) will do as above but will also use cell
%   array of strings DATECOLS to identify and parse the date and time
%   columns. DATECOLS has two columns and as many rows as date and time
%   columns in the file. The first column contains the column header names
%   and the second column contains the corresponding date format strings.
%   See 'help datestr' for the definition of these strings. Note that this
%   input is used only by MATLAB for date recognition and that the SQL LOAD
%   IN FILE statement will require it's own date interpretation input.
%   obj = loadXLSX(..., lastrow) will do as above but only read data down
%   to the row index given by scalar integer LASTROW.
%   [obj, numWarnings] = loadXLSX(obj, ...) will do as above but return in
%   numerical scalar NUMWARNINGS the number of warning returned in loading
%   the data.
%   [..., warnings] = loadXLSX(obj, ...) will do as above but return in 
%   WARNINGS a struct containing a number of the first warnings. WARNINGS
%   has fields 'Leve', 'Code' and 'Message' corresponding to that returned
%   by the SQL statement SHOW WARNINGS.

    % Input
    filename = validateCellStr(filename, 'cVessel.loadXLSX', 'filename', 2);
    sheet = validateCellStr(sheet, 'cVessel.loadXLSX', 'filename', 3);
    validateattributes(firstRow, {'numeric'}, {'scalar'}, ...
        'cVessel.loadXLSX', 'firstRow', 4);
    validateattributes(fileColID, {'numeric', 'cell'}, {'vector'}, ...
        'cVessel.loadXLSX', 'fileColID', 5);
    validateCellStr(fileColName, 'cVessel.loadXLSX', 'fileColName', 6);
	
	tab = 'RawData';
	if nargin > 6 && ~isempty(varargin{1})
	
        tab = varargin{1};
		validateattributes(tab, {'char'}, {'vector'}, ...
			'cVessel.loadXLSX', 'tab', 7);
	end
	
%     tabColNames = validateCellStr(tabColNames, 'cVessel.loadXLSX', ...
%         'tabColNames', 8);
    set_c = {''};
    if nargin > 7 && ~isempty(varargin{2})
        
        set_c = varargin{2};
        validateCellStr(set_c, 'cVessel.loadXLSX', 'set', 9);
    end
    
    dateCols_c = {''};
    if nargin > 8
        
        dateForm_c = varargin{3};
        if ~isempty(dateForm_c)
            
            validateCellStr(dateForm_c, 'cVessel.loadXLSX', 'dateForm', 10);
            dateCols_c = dateForm_c(:, 1);
            dateFormats_c = dateForm_c(:, 2);
        end
    end
    
    lastRow_l = false;
    if nargin > 9
        
        lastRow = varargin{4};
        validateattributes(lastRow, {'numeric'}, {'vector'}, ...
            'cVessel.loadXLSX', 'lastRow', 11);
        lastRow_l = ~isempty(lastRow);
        
        if isscalar(lastRow)
            
            lastRow = repmat(lastRow, [1, numel(sheet)]);
        end
        
        if ~isequal(numel(sheet), numel(lastRow))
           
            errid = 'loadXLSX:SheetRowNumberMismatch';
            errmsg = ['When LASTROW is a vector, it must have as many '...
                'elements as SHEET'];
            error(errid, errmsg);
        end
        
        % Reduce by one to fit data in Berge Blanc 2017 xlsx
        lastRow = lastRow - 1;
    end
    
    readCols_l = iscellstr(fileColID);
    
    % Append set SQL
    [~, tabColNames] = obj.colNames('RawData');
    if ~isequal(set_c, {''})

        % Generate default set statement
        tabColNames = setdiff(tabColNames, 'id');
        [~, ~, defSet_c] = obj.setNullIfEmpty(tabColNames);
        cutAtEquals_f = @(x) x(1:strfind(x, ' = ')-1);
        inDefaultNames_c = cellfun(cutAtEquals_f, defSet_c, 'Uni', 0);

        % Find which columns are in input set statement
        inSetNames_c = cellfun(cutAtEquals_f, set_c, 'Uni', 0);

        % Replace those in default with those in input
        cols2replace_l = ismember(inDefaultNames_c, inSetNames_c);
        x_l = ismember(inSetNames_c, inDefaultNames_c);
        defSet_c(cols2replace_l) = set_c(x_l);
%         set_c = [defSet_c, set_c(~x_l)];
        
%         % Set NaN in file to NULL in DB, for columns without explicit set
%         % statement
%         [~, ~, nanSet_c] = obj.setNullIfEmpty(tabColNames, false, '''Nan''');
%         nanSet_c(cols2replace_l) = [];
%         set_c = [defSet_c(:)', set_c(~x_l), nanSet_c(:)'];
        set_c = [defSet_c(:)', set_c(~x_l)];
        set_ch = ['SET ', obj.colSepList(set_c)];
        
        % Get IMO number for insertion into RawData
        imo_ch = '';
        setNames_c = cellfun(cutAtEquals_f, set_c, 'Uni', 0);

    else
        
        set_ch = '';
        setNames_c = {''};
    end

    [isIMO, idxIMO] = ismember('IMO_Vessel_Number', setNames_c);
    if isIMO

        imoNum_ch = set_c{idxIMO}(strfind(set_c{idxIMO}, ' = ')+3:end);
        imo = str2double(imoNum_ch);
        
    elseif ~isempty(obj.IMO_Vessel_Number)
        
        imo = obj.IMO_Vessel_Number;
    else
        
        % Error, need IMO somewhere to insert data 
    end
    fileColName = [fileColName,{'IMO_Vessel_Number'}];

    % Iterate over files
    for fi = 1:numel(filename)
        
        % Iterate over sheets
        for si = 1:numel(sheet)
        
        % Read only specified columns from file
        currFile = filename{fi};
        currSheet = sheet{si};
        file_tbl = readtable(currFile, 'Sheet', currSheet, ...
            'ReadVariableNames', readCols_l);
        if ~lastRow_l
            lastRow = height(file_tbl);
        end
        file_tbl = file_tbl(firstRow:lastRow, fileColID);
        
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
            file_tbl(:, idxDT) = cellstr(datestr(datenum(file_tbl{:, idxDT}, dateForm_ch), 'yyyy-mm-dd HH:MM:SS.FFF'));
        end
        
%         for ti = 1:width(file_tbl)
%             
%             try tempTable = varfun(@str2double, file_tbl(:, ti));
%                 
%                 if numel(find(isnan(tempTable{:, 1}))) < 0.5*height(tempTable)
%                     file_tbl = [file_tbl(:, 1:ti-1), tempTable, file_tbl(:, ti+1:end)];
%                 end
%             end
%         end
        
        % Prepare outpus
%         if isIMO
            
            imo_v = repmat(imo, [height(file_tbl), 1]);
            file_tbl.IMO_Vessel_Number = imo_v; 
%         end

        % Write table as csv
        tempFile = 'tempCSVLoadFile.csv';
        matDir = [getenv('HOMEDRIVE') getenv('HOMEPATH') '\OneDrive - Hempel Group\Documents\MATLAB'];
        tempFile = fullfile(matDir, tempFile);
        tempTab = 'tempCSVLoad';
        writetable(file_tbl, tempFile, 'WriteVariableNames', false,...
                'QuoteStrings',false);
        
        
        % Load in CSV file
        try obj = obj.loadInFileDuplicate(tempFile, fileColName, tempTab, tab,...
                ',', 0, set_ch, tabColNames, '', {'none'});
           
		   % Get warnings from load infile statement
% 		   [obj, warnCount_tbl] = obj.warnings;
% 		   numWarnings = [warnCount_tbl{:}];
% 		   [obj, warn_tbl] = obj.warnings(false, 0, 10);
% 		   warnings = warn_tbl;
		   
           [obj, numWarnings] = obj.warnings;
           warnings = struct();
           if numWarnings ~= 0
               [obj, warn_st] = obj.warnings(false, 0, 10);
               warnings = warn_st;
           end
           
        catch ee
            
			% Remove file
            delete(tempFile);
            rethrow(ee);
			
        end
        
        delete(tempFile);
        
        % Insert this files data into table
%         obj.insertValuesDuplicate(tab, tabColNames, file_c, set_c);
        end
    end
end