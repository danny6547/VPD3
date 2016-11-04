function insertBunkerDeliveryNoteDNVGL(filename)
%insertBunkerDeliveryNoteDNVGL Insert BDN into DNVGL Raw table for BDNs.
%   Detailed explanation goes here

    % Input
    validateattributes(filename, {'char'}, {'vector'}, ...
        'insertBunkerDeliveryNoteDNVGL', 'filename', 1);
    
    % Connect to Database
    conn_ch = ['driver=MySQL ODBC 5.3 ANSI Driver;', ...
        'Server=localhost;',  ...
        'Database=', 'test2', ';',  ...
        'Uid=root;',  ...
        'Pwd=HullPerf2016;'];
    sqlConn = adodb_connect(conn_ch);
    
    % Call procedure to create temp table
    sqlCreateProc_s = 'CALL createTempBunkerDeliveryNote';
    adodb_query(sqlConn, sqlCreateProc_s);
    
    % Load data from file into temp table
    db = 'test2';
    tbl = 'TempBunkerDeliveryNote';
    delimiter = ',';
    ignore = 1;
    loadInfile(filename, db, tbl, delimiter, ignore);
    
    % Insert from temp table without duplicates
    finalTable = 'BunkerDeliveryNote';
    columns = {'BDN_Number'	'IMO_Vessel_Number'	'Bunker_Delivery_Date'...
        'Fuel_Type'	'Mass'	'Sulphur_Content'	'Density_At_15dg'...
        'Lower_Heating_Value'};
    duplicateCols = {'BDN_Number', 'IMO_Vessel_Number'};
    insertWithoutDuplicates(tbl, finalTable, columns, duplicateCols);
    
end