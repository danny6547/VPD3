function [obj, raw] = selectRaw(obj)
%selectRaw Select data for this vessel from raw data table
%   Detailed explanation goes here

    % Input
%     validateattributes(cv, {'cVessel'}, {'scalar'}, ...
%         'cVesselInService.select', 'cv', 1);
    
    rawtable = 1;
    dbname = obj.SQL.Database;
    [params, tabFound] = obj.tableParameters(dbname);
    rawTabParams = params.Raw(rawtable);

    % Check for data in raw table if none found in calcualted
    whereId = rawTabParams.RawIdentifierProperty;
    whereIdVal = obj.(whereId);
    whereIdVal_ch = num2str(whereIdVal);
    whereCol = rawTabParams.RawColumn;
    [~, where_sql] = obj.SQL.combineSQL(whereCol, '=', whereIdVal_ch);

    limit = obj.Limit;
    rawCols = '*';
    rawTab = rawTabParams.RawTable;
    [~, raw] = obj.SQL.select(rawTab, rawCols, where_sql, limit);
    
    % Synchronise raw data table with existing table
    obj.Data = raw;
end