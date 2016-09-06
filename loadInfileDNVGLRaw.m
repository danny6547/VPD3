function loadInfileDNVGLRaw(csvfile, database, table)
% loadInfileDNVGLRaw Load raw file from DNVGL into table in database
% loadInfileDNVGLRaw(csvfile, database, table) will call SQL function LOAD
% INFILE on the CSV file csvfile into the table TABLE in the database
% DATABASE, where csvfile is a full file path and TABLE and DATABASE are
% strings. CSVFILE must be a "raw data" file downloaded from DNVGL
% EcoInsight.

% Connect to Database
conn_ch = ['driver=MySQL ODBC 5.3 ANSI Driver;', ...
    'Server=localhost;',  ...
    'Database=', database, ';',  ...
    'Uid=root;',  ...
    'Pwd=HullPerf2016;'];
a = adodb_connect(conn_ch);

% Parse Colunm Headers
q = textscan(fopen(csvfile), '%s', 220, 'Delimiter', ',');
ColumnHeaders_c = [q{:}];

% Build strings to set NULL if blank and convert date, time formats
date_l = cellfun(@(x) isequal(x, 'Date_UTC'), ColumnHeaders_c);
time_l = cellfun(@(x) isequal(x, 'Time_UTC'), ColumnHeaders_c);
dateOrtime_l = date_l | time_l;

atVars_c = strcat('@', ColumnHeaders_c);
e = sprintf('%s, ', atVars_c{:});
e(end-1:end) = [];

ColumnHeaders_c(dateOrtime_l) = [];
setnullif_c = cellfun(@(x) [x, ' = nullif(@' x ', '''')'], ColumnHeaders_c, 'Uni', 0);
setnullif_ch = sprintf('%s, ', setnullif_c{:});
setnullif_ch(end-1:end) = [];

% Build MySQL code string
sqlstr = ['LOAD DATA LOCAL INFILE ''', ...
    strrep(csvfile, '\', '\\'), ...
    ''' INTO TABLE ' table, ...
    ' FIELDS TERMINATED BY '',''', ...
    ' IGNORE 1 LINES (' e ')' ...
    ' SET Date_UTC = STR_TO_DATE(@Date_UTC, ''%d/%m/%Y''), ', ...
    'Time_UTC = STR_TO_DATE(@Time_UTC, '' %H:%i''), ', ...
    setnullif_ch];

% Call MySQL
adodb_query(a, sqlstr);