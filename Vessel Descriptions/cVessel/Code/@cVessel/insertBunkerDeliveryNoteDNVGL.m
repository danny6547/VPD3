function obj = insertBunkerDeliveryNoteDNVGL(obj, filename)
%insertBunkerDeliveryNoteDNVGL Insert BDN into DNVGL Raw table for BDNs.
%   Detailed explanation goes here

    % Input
    validateCellStr(filename, 'insertBunkerDeliveryNoteDNVGL', 'filename',...
        2);
    
    % Call procedure to create temp table
    obj.SQL = obj.SQL.call('createTempBunkerDeliveryNote');
    
    % Load data from file into temp table
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
    obj.SQL.loadInFile(filename, tbl, cols, delimiter, ignore);
    
    % Insert from temp table without duplicates
    finalTable = 'BunkerDeliveryNote';
    columns = {'BDN_Number'	'IMO_Vessel_Number'	'Bunker_Delivery_Date'...
        'Fuel_Type'	'Mass'	'Sulphur_Content'	'Density_At_15dg'...
        'Lower_Heating_Value'};
    obj.SQL.insertSelectDuplicate(tbl, columns, finalTable, columns);
    
    % Drop temp table
    obj.SQL.drop('table', tbl);
end