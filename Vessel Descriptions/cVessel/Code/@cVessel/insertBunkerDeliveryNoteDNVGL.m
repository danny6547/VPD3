function obj = insertBunkerDeliveryNoteDNVGL(obj, filename)
%insertBunkerDeliveryNoteDNVGL Insert BDN into DNVGL Raw table for BDNs.
%   Detailed explanation goes here

    % Input
    validateCellStr(filename, 'insertBunkerDeliveryNoteDNVGL', 'filename',...
        2);
    
    % Connect to Database
%     conn_ch = ['driver=MySQL ODBC 5.3 ANSI Driver;', ...
%         'Server=localhost;',  ...
%         'Database=', 'test2', ';',  ...
%         'Uid=root;',  ...
%         'Pwd=HullPerf2016;'];
%     sqlConn = adodb_connect(conn_ch);
    
    % Call procedure to create temp table
    obj = obj.call('createTempBunkerDeliveryNote');
%     sqlCreateProc_s = 'CALL createTempBunkerDeliveryNote';
%     adodb_query(sqlConn, sqlCreateProc_s);
    
    % Load data from file into temp table
%     db = 'test2';
    tbl = 'TempBunkerDeliveryNote';
    delimiter = ';';
    ignore = 1;
    cols = {...
            'BDN_Number'
            'IMO_Vessel_Number'
            'Bunker_Delivery_Date'
            'Fuel_Type'
            'Mass'
            'Sulphur_Content'
            'Density_At_15dg'
            'Lower_Heating_Value'...
            };
    obj.loadInFile(filename, tbl, cols, delimiter, ignore);
    
    % Insert from temp table without duplicates
    finalTable = 'BunkerDeliveryNote';
    columns = {'BDN_Number'	'IMO_Vessel_Number'	'Bunker_Delivery_Date'...
        'Fuel_Type'	'Mass'	'Sulphur_Content'	'Density_At_15dg'...
        'Lower_Heating_Value'};
%     duplicateCols = {'BDN_Number', 'IMO_Vessel_Number'};
%     insertWithoutDuplicates(tbl, finalTable, columns, duplicateCols);
    
%     otherColumns = setdiff(columns, duplicateCols);
    
    obj.insertSelectDuplicate(tbl, columns, finalTable, columns);
    
%     insertWithoutDuplicates(tbl, finalTable, 'id', duplicateCols, otherColumns);
    
end