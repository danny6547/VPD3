function loadInfile(filename, database, table, varargin)
% loadInfile Load raw file from DNVGL into table in database
% loadInfile(filename, database, table) will call SQL function LOAD DATA
% INFILE on the CSV file filename into the table TABLE in the database
% DATABASE, where filename is a full file path and TABLE and DATABASE are
% strings. filename must be a "raw data" file downloaded from DNVGL
% EcoInsight.
% loadInfile(filename, database, table, delimiter) will, in addition, 
% load the data in file delimited by string DELIMITER. The default is comma
% (',').
% loadInfile(filename, database, table, delimiter, ignore) will, in
% addition, ignore the first N lines specified by numeric scalar IGNORE.
% The default is 1.
% loadInfile(filename, database, table, delimiter, ignore, set) will, in
% addition, call the LOAD INFILE function with the string SET which
% contains the set clause inputs for that function. See the MySQL
% documentation for LOAD DATA INFILE function for more information. This
% may currently be found here: 
% http://dev.mysql.com/doc/refman/5.7/en/load-data.html
% loadInfile(filename, database, table, delimiter, ignore, set, setnull)
% will, in addition, set the values for columns in string or cell array of 
% strings SETNULL to NULL in rows corresponding to those with empty strings
% in file FILENAME.

% Inputs
validateattributes(filename, {'cell', 'char'}, {'vector'}, 'loadInfile',...
    'filename', 1);
if iscell(filename)
    cellfun(@(x) validateattributes(x, {'char'}, {'vector'}, ...
        'loadInfile', 'filename', 1), filename);
end

delimiter_s = ',';
if nargin > 3
    delimiter_s = varargin{1};
    validateattributes(delimiter_s, {'char'}, {'scalar'}, ...
        'loadInfile', 'delimiter', 4);
end

ignore_s = 1;
if nargin > 4
    ignore = varargin{2};
    validateattributes(ignore, {'numeric'}, {'scalar'}, ...
        'loadInfile', 'ignore', 5);
    ignore_s = num2str(ignore);
end

set_s = '';
if nargin > 5
    set_s = varargin{3};
    validateattributes(set_s, {'char'}, {'vector'}, ...
        'loadInfile', 'set', 6);
end

setnull_c = {};
if nargin > 6
    setnull_c = varargin{4};
    
    validateattributes(setnull_c, {'char', 'cell'}, {'vector'},...
        'loadInfile', 'setnull', 7);
    
    try setnull_c = cellstr(setnull_c);
        
    catch ColumnsList
        
        if strcmp(ColumnsList.identifier, 'MATLAB:cellstr:InputClass')
            
            errid = 'loadIn:SetNull:CellStrOnly';
            errmsg = ['Input SETNULL must be either string or a cell array ',...
                'of strings.'];
            error(errid, errmsg);
            
        else
            
            rethrow(ColumnsList);
        end
    end
    
    cellfun(@(x) validateattributes(x, {'char'}, {'vector'},...
        'loadInfile', 'setnull', 7), setnull_c);
end

filename = cellstr(filename);

% Connect to Database
conn_ch = ['driver=MySQL ODBC 5.3 ANSI Driver;', ...
    'Server=localhost;',  ...
    'Database=', database, ';',  ...
    'Uid=root;',  ...
    'Pwd=HullPerf2016;'];
a = adodb_connect(conn_ch);

for ci = 1:numel(filename)
    
    % Iterate files
    currFile = filename{ci};
    
    % Parse Colunm Headers
    q = textscan(fopen(currFile), '%s', 220, 'Delimiter', ',');
    ColumnHeaders_c = [q{:}];
    
    % Build comma-separated list of column headers to load
    atVars_c = strcat('@', ColumnHeaders_c);
    ColumnsList = sprintf('%s, ', atVars_c{:});
    ColumnsList(end-1:end) = [];
    
    % Build delimiter
    sqlDelim_s = [' FIELDS TERMINATED BY ''', delimiter_s ,''''];
    
    % Build ignore N lines
    sqlIgnore_s = [' IGNORE ', ignore_s , ' LINES ']; 
    
    % Build set null
%     date_l = cellfun(@(x) isequal(x, 'Date_UTC'), ColumnHeaders_c);
%     time_l = cellfun(@(x) isequal(x, 'Time_UTC'), ColumnHeaders_c);
    null_l = ismember(ColumnHeaders_c, setnull_c);
    % dateOrtime_l = date_l | time_l;
    ColumnHeaders_c(null_l) = [];
    setnullif_c = cellfun(@(x) [x, ' = nullif(@' x ', '''')'],...
        ColumnHeaders_c, 'Uni', 0);
    setnullif_ch = sprintf('%s, ', setnullif_c{:});
    setnullif_ch(end-1:end) = [];
    
    % Build MySQL code string
    sqlstr = ['LOAD DATA LOCAL INFILE ''', ...
        strrep(currFile, '\', '\\'), ...
        ''' INTO TABLE ' table, ...
        sqlDelim_s, ...
        sqlIgnore_s, ...
        '(' ColumnsList ') ', ...
        set_s, ...
        setnullif_ch, ...
        ';' ];
    
%     % Build MySQL code string
%     sqlstr = ['LOAD DATA LOCAL INFILE ''', ...
%         strrep(currFile, '\', '\\'), ...
%         ''' INTO TABLE ' table, ...
%         ' FIELDS TERMINATED BY '',''', ...
%         ' IGNORE 1 LINES (' ColumnsList ')' ...
%         ' SET Date_UTC = STR_TO_DATE(@Date_UTC, ''%d/%m/%Y''), ', ...
%         'Time_UTC = STR_TO_DATE(@Time_UTC, '' %H:%i''), ', ...
%         setnullif_ch];
    
    % Call MySQL
    adodb_query(a, sqlstr);
    
end

% Close connection
a.Close;