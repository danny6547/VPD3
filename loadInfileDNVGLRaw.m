function loadInfileDNVGLRaw(csvfile)
% loadInfileDNVGLRaw Load raw file from DNVGL into table in database
% loadInfileDNVGLRaw(csvfile, database, table) will call SQL function LOAD
% INFILE on the CSV file given by string CSVFILE into the table TABLE in 
% the database DATABASE, where csvfile is a full file path and TABLE and 
% DATABASE are strings. CSVFILE must be a "raw data" file downloaded from 
% DNVGL EcoInsight.
% loadInfileDNVGLRaw(csvfile, database, table) where CSVFILE is a cell
% array of strings giving the paths to files of the type described above
% will add the data in all these files to the database.


database = 'test2';

% Connect to Database
conn_ch = ['driver=MySQL ODBC 5.3 ANSI Driver;', ...
    'Server=localhost;',  ...
    'Database=', database, ';',  ...
    'Uid=root;',  ...
    'Pwd=HullPerf2016;'];
sqlConn = adodb_connect(conn_ch);

% Drop temp loading table if exists
tempTable = 'tempraw';
drop_s = ['DROP TABLE IF EXISTS `' tempTable '`;'];
adodb_query(sqlConn, drop_s);

% Create temp table
filename = ['C:\Users\damcl\Documents\SQL\tests\EcoInsight Test Scripts\',...
    'Create Tables\createDNVGLRawTempTable.sql'];
create_s = fscanf(fopen(filename), '%c');
create_s(1:130) = [];
adodb_query(sqlConn, create_s);

% Load data into temp table
loadInfileCSV(csvfile, 'test2', tempTable);

% Call procedure to add time into DateTime
addTime_s = ['CALL addTimeDNVGLRaw(' '''' tempTable ''');'];
adodb_query(sqlConn, addTime_s);

% Call procedute to remove any all-null rows from temp table
noNulls_s = 'CALL removeNullRows';
adodb_query(sqlConn, noNulls_s);

% Move data to final table, ignoring non-unique values
final_s = 'CALL insertWithoutDuplicates';
adodb_query(sqlConn, final_s);

% Close connection
sqlConn.Close;