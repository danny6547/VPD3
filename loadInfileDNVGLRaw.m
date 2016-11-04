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

% Load infile defaults for DNVGL raw table
delimiter_s = ',';
ignore_s = 1;
set_s = ['SET Date_UTC = STR_TO_DATE(@Date_UTC, ''%d/%m/%Y''), ', ...
         'Time_UTC = STR_TO_DATE(@Time_UTC, '' %H:%i''), '];
setnull_c = {'Date_UTC', 'Time_UTC'};

% Load data into temp table
loadInfile(csvfile, 'test2', tempTable, delimiter_s, ignore_s, set_s,...
    setnull_c);

% Call procedute to remove any all-null rows from temp table
noNulls_s = 'CALL removeNullRows';
adodb_query(sqlConn, noNulls_s);

% Call procedure to add time into DateTime
addTime_s = 'CALL addTimeDNVGLRaw;';
adodb_query(sqlConn, addTime_s);

% Call procedure to add time into DateTime
convertRaw_s = 'CALL convertDNVGLRawToRawData;';
adodb_query(sqlConn, convertRaw_s);

% Move data to final table, ignoring non-unique values
toTable = 'rawdata';
columns =   {
            'DateTime_UTC'
            'IMO_Vessel_Number'
            'Relative_Wind_Speed'
            'Relative_Wind_Direction'
            'Speed_Over_Ground'
            'Shaft_Revolutions'
            'Static_Draught_Fore'
            'Static_Draught_Aft'
            'Water_Depth'
            'Seawater_Temperature'
            'Air_Temperature'
            'Air_Pressure'
            'Speed_Through_Water'
            'Mass_Consumed_Fuel_Oil'
            'Lower_Caloirifc_Value_Fuel_Oil'
            'Density_Fuel_Oil_15C'
            % 'Density_Change_Rate_Per_C'
            % 'Temp_Fuel_Oil_At_Flow_Meter'
            % 'Wind_Resistance_Relative'
            % %'Air_Resistance_No_Wind'
            % 'Expected_Speed_Through_Water'
            % 'Displacement'
            % 'Speed_Loss'
            % 'Transverse_Projected_Area_Current'
            % 'Wind_Resistance_Correction'
            % 'Corrected_Power'
            };
duplicateCols = {'DateTime_UTC', 'IMO_Vessel_Number'};
insertWithoutDuplicates(tempTable, toTable, columns, duplicateCols)

% final_s = 'CALL insertWithoutDuplicates';
% adodb_query(sqlConn, final_s);

% Close connection
sqlConn.Close;