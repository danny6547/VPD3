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

% Drop temp loading table if exists, then re-create 
tempTable = 'tempDNVGLRaw';
drop_s = ['DROP TABLE IF EXISTS `' tempTable '`;'];
adodb_query(sqlConn, drop_s);

create_s = 'CALL createDNVGLRawTempTable';
adodb_query(sqlConn, create_s);

addTimeCol_s = 'ALTER TABLE tempDNVGLRaw ADD DateTime_UTC DATETIME AFTER Date_UTC;';
adodb_query(sqlConn, addTimeCol_s);

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
addTime_s = 'UPDATE tempDNVGLRaw SET DateTime_UTC = ADDTIME(Date_UTC, Time_UTC);';
adodb_query(sqlConn, addTime_s);

% Move data to final table, ignoring non-unique values
toTable = 'DNVGLRaw';
columns =   {
            'AE_1_Charge_Air_Inlet_Temp'
            'AE_1_Charge_Air_Pressure'
            'AE_1_Consumption'
            'AE_1_Current_Consumption'
            'AE_1_Exh_Gas_Temperature'
            'AE_1_Load'
            'AE_1_Pcomp'
            'AE_1_Pmax'
            'AE_1_Running_Hours'
            'AE_1_SFOC'
            'AE_1_SFOC_ISO_Corrected'
            'AE_1_TC_Speed'
            'AE_1_Work'
            'AE_2_Charge_Air_Inlet_Temp'
            'AE_2_Charge_Air_Pressure'
            'AE_2_Consumption'
            'AE_2_Current_Consumption'
            'AE_2_Exh_Gas_Temperature'
            'AE_2_Load'
            'AE_2_Pcomp'
            'AE_2_Pmax'
            'AE_2_Running_Hours'
            'AE_2_SFOC'
            'AE_2_SFOC_ISO_Corrected'
            'AE_2_TC_Speed'
            'AE_2_Work'
            'AE_3_Charge_Air_Inlet_Temp'
            'AE_3_Charge_Air_Pressure'
            'AE_3_Consumption'
            'AE_3_Current_Consumption'
            'AE_3_Exh_Gas_Temperature'
            'AE_3_Load'
            'AE_3_Pcomp'
            'AE_3_Pmax'
            'AE_3_Running_Hours'
            'AE_3_SFOC'
            'AE_3_SFOC_ISO_Corrected'
            'AE_3_TC_Speed'
            'AE_3_Work'
            'AE_4_Charge_Air_Inlet_Temp'
            'AE_4_Charge_Air_Pressure'
            'AE_4_Consumption'
            'AE_4_Current_Consumption'
            'AE_4_Exh_Gas_Temperature'
            'AE_4_Load'
            'AE_4_Pcomp'
            'AE_4_Pmax'
            'AE_4_Running_Hours'
            'AE_4_SFOC'
            'AE_4_SFOC_ISO_Corrected'
            'AE_4_TC_Speed'
            'AE_4_Work'
            'AE_5_Charge_Air_Inlet_Temp'
            'AE_5_Charge_Air_Pressure'
            'AE_5_Consumption'
            'AE_5_Current_Consumption'
            'AE_5_Exh_Gas_Temperature'
            'AE_5_Load'
            'AE_5_Pcomp'
            'AE_5_Pmax'
            'AE_5_Running_Hours'
            'AE_5_SFOC'
            'AE_5_SFOC_ISO_Corrected'
            'AE_5_TC_Speed'
            'AE_5_Work'
            'AE_6_Charge_Air_Inlet_Temp'
            'AE_6_Charge_Air_Pressure'
            'AE_6_Consumption'
            'AE_6_Current_Consumption'
            'AE_6_Exh_Gas_Temperature'
            'AE_6_Load'
            'AE_6_Pcomp'
            'AE_6_Pmax'
            'AE_6_Running_Hours'
            'AE_6_SFOC'
            'AE_6_SFOC_ISO_Corrected'
            'AE_6_TC_Speed'
            'AE_6_Work'
            'AE_Air_Intake_Temp'
            'AE_Barometric_Pressure'
            'AE_Charge_Air_Coolant_Inlet_Temp'
            'AE_Consumption'
            'AE_Fuel_BDN'
            'AE_Projected_Consumption'
            'Air_Compr_1_Running_Time'
            'Air_Compr_2_Running_Time'
%             'Air_Pressure'
%             'Air_Temperature'
            'Apparent_Slip'
            'Boiler_1_Consumption'
            'Boiler_1_Feed_Water_Flow'
            'Boiler_1_Operation_Mode'
            'Boiler_1_Running_Hours'
            'Boiler_1_Steam_Pressure'
            'Boiler_2_Consumption'
            'Boiler_2_Feed_Water_Flow'
            'Boiler_2_Operation_Mode'
            'Boiler_2_Running_Hours'
            'Boiler_2_Steam_Pressure'
            'Boiler_Consumption'
            'Cargo_CEU'
            'Cargo_Mt'
            'Cargo_Reefer_TEU'
            'Cargo_Total_Full_TEU'
            'Cargo_Total_TEU'
            'Cleaning_Event'
            'Cooling_Water_System_Pressure_Drop_Over_Heat_Exchanger'
            'Cooling_Water_System_Pump_Pressure'
            'Cooling_Water_System_SW_Inlet_Temp'
            'Cooling_Water_System_SW_Outlet_Temp'
            'Cooling_Water_System_SW_Pumps_In_Service'
            'Crew'
            'Current_Dir'
            'Current_Speed'
            'Date_Local'
            'Date_UTC'
%             'Density_Fuel_Oil_15C'
            'Distance'
            'Draft_Actual_Aft'
            'Draft_Actual_Fore'
            'Draft_Ballast_Actual'
            'Draft_Ballast_Optimum'
            'Draft_Displacement_Actual'
            'Draft_Recommended_Aft'
            'Draft_Recommended_Fore'
            'Entry_Made_By_1'
            'Entry_Made_By_2'
            'ER_Ventilation_Fans_In_Service'
            'ER_Ventilation_Waste_Air_Temp'
            'Event'
            'Latitude_Degree'
            'Latitude_Minutes'
            'Latitude_North_South'
            'Longitude_Degree'
            'Longitude_East_West'
            'Longitude_Minutes'
%             'Lower_Caloirifc_Value_Fuel_Oil'
            'Lube_Oil_System_Type_Of_Pump_In_Service'
%             'Mass_Consumed_Fuel_Oil'
            'ME_1_Aux_Blower'
            'ME_1_Charge_Air_Inlet_Temp'
            'ME_1_Consumption'
            'ME_1_Current_Consumption'
            'ME_1_Cylinder_Oil_Consumption'
            'ME_1_Exh_Temp_After_TC'
            'ME_1_Exh_Temp_Before_TC'
            'ME_1_Load'
            'ME_1_Pcomp'
            'ME_1_Pmax'
            'ME_1_Pressure_Drop_Over_Scav_Air_Cooler'
            'ME_1_Running_Hours'
            'ME_1_Scav_Air_Pressure'
            'ME_1_SFOC'
            'ME_1_SFOC_ISO_Corrected'
            'ME_1_Shaft_Gen_Power'
            'ME_1_Shaft_Gen_Running_Hours'
            'ME_1_Shaft_Power'
            'ME_1_Speed_RPM'
            'ME_1_System_Oil_Consumption'
            'ME_1_TC_Speed'
            'ME_1_Work'
            'ME_2_Aux_Blower'
            'ME_2_Charge_Air_Inlet_Temp'
            'ME_2_Consumption'
            'ME_2_Current_Consumption'
            'ME_2_Cylinder_Oil_Consumption'
            'ME_2_Exh_Temp_After_TC'
            'ME_2_Exh_Temp_Before_TC'
            'ME_2_Load'
            'ME_2_Pcomp'
            'ME_2_Pmax'
            'ME_2_Pressure_Drop_Over_Scav_Air_Cooler'
            'ME_2_Running_Hours'
            'ME_2_Scav_Air_Pressure'
            'ME_2_SFOC'
            'ME_2_SFOC_ISO_Corrected'
            'ME_2_Shaft_Gen_Power'
            'ME_2_Shaft_Gen_Running_Hours'
            'ME_2_Shaft_Power'
            'ME_2_Speed_RPM'
            'ME_2_System_Oil_Consumption'
            'ME_2_TC_Speed'
            'ME_2_Work'
            'ME_Air_Intake_Temp'
            'ME_Barometric_Pressure'
            'ME_Charge_Air_Coolant_Inlet_Temp'
            'ME_Consumption'
            'ME_Cylinder_Oil_Consumption'
            'ME_Fuel_BDN'
            'ME_Projected_Consumption'
            'ME_System_Oil_Consumption'
            'Mode'
            'Nominal_Slip'
            'Passengers'
            'People'
            'Prop_1_Pitch'
            'Prop_2_Pitch'
%             'Relative_Wind_Direction'
%             'Relative_Wind_Speed'
            'Remarks'
            'Sea_state_Dir'
            'Sea_state_Force_Douglas'
%             'Seawater_Temperature'
%             'Shaft_Revolutions'
            'Speed_GPS'
%             'Speed_Over_Ground'
            'Speed_Projected_From_Charter_Party'
            'Speed_Through_Water'
%             'Static_Draught_Aft'
%             'Static_Draught_Fore'
            'Swell_Dir'
            'Swell_Force'
            'Temperature_Ambient'
            'Temperature_Water'
            'Thruster_1_Running_Time'
            'Thruster_2_Running_Time'
            'Thruster_3_Running_Time'
            'Time_Elapsed_Loading_Unloading'
            'Time_Elapsed_Maneuvering'
            'Time_Elapsed_Sailing'
            'Time_Elapsed_Waiting'
            'Time_Local'
            'Time_Since_Previous_Report'
            'Time_UTC'
            'Voyage_From'
            'Voyage_Number'
            'Voyage_To'
            'Water_Depth'
            'Wind_Dir'
            'Wind_Force_Bft'
            'Wind_Force_Kn'
            };
duplicateCols = {'DateTime_UTC'; 'IMO_Vessel_Number'};
% format = '%s, %u, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f';

allCols = [duplicateCols; columns];
obj_sql = cMySQL();
obj_sql = obj_sql.insertSelectDuplicate(tempTable, allCols, toTable, allCols);
obj_sql.disconnect;

% insertWithoutDuplicates(tempTable, toTable, 'id', duplicateCols, columns, format);

% final_s = 'CALL insertWithoutDuplicates';
% adodb_query(sqlConn, final_s);

% Close connection
sqlConn.Close;