function [ obj ] = select(obj, cv, varargin)
%selectInService Select InService data from database
%   Detailed explanation goes here

    % Input
    validateattributes(cv, {'cVessel'}, {'scalar'}, ...
        'cVesselInService.select', 'cv', 1);
    
    % Find current database's in-service parameters
    dbname = obj.SQL.Database;
    [params, tabFound] = obj.tableParameters(dbname);
    
    if ~tabFound
        
        return
    end
    
    calcCols = params.PerformanceVariable; % '*';
    if nargin > 2 && ~isempty(varargin{1})
        
        calcCols = varargin{1};
    end
    calcCols = validateCellStr(calcCols, 'cVessel.selectInService', 'calcCols', 2);
    
    rawCols = '';
    if nargin > 3 && ~isempty(varargin{2})
        
        rawCols = varargin{2};
    end
    rawCols = validateCellStr(rawCols, 'cVessel.selectInService', 'rawCols', 3);
    
    rawtable = 1;
    if nargin > 4 && ~isempty(varargin{3})
        
        rawtable = varargin{3};
        validateattributes(rawtable, {'numeric'}, ...
            {'scalar', 'positive', 'integer', 'real'}, ...
            'cVessel.selectInService', 'rawtable', 2);
    end
    
    % Select raw data table based on input
    if rawtable > numel(params.Raw)
        
        errid = 'selIns:RawTableIdxInvalid';
        errmsg = ['Raw data table index ', num2str(rawtable), ' exceeds '...
            'number of raw data tables for database ', dbname, '. Value '...
            'must be between 1 and ', num2str(numel(params.Raw))];
        error(errid, errmsg);
    end
    rawTabParams = params.Raw(rawtable);
    
    % Call join method
    calcTab = params.InServiceTable;
    calcJoin = params.InServiceJoinCols;
    rawTab = rawTabParams.RawTable;
    rawJoin = rawTabParams.JoinCols;
    
    % Build where SQL
    propName = params.InServiceIdentifierProperty;
    if strcmpi(propName, 'Vessel_Configuration_Id')
        
        idVal = cv.Configuration.Vessel_Configuration_Id;
    else
        
        idVal = cv.(propName);
    end
    
    if isempty(idVal)
        
        return
    end
    idVal_ch = num2str(idVal);
    [~, where] = obj.SQL.combineSQL(['t1.',params.InServiceIdentifierColumn], '=', idVal_ch);
    
    % Check time column is being selected
    timeName = params.InServiceTimeCol;
    colWithoutAlias = '';
    if ~ismember(timeName, calcCols) && ~ismember(timeName, rawCols)
        
        colWithoutAlias = timeName;
    end
    
    % Call SQL join method
    tbl = obj.SQL.join(calcTab, calcCols, calcJoin, rawTab, rawCols, ...
        rawJoin, where, colWithoutAlias);
    
    if isempty(tbl)
        
        % Check for data in raw table if none found in calcualted
        whereId = rawTabParams.RawIdentifierProperty;
        whereIdVal = cv.(whereId);
        whereIdVal_ch = num2str(whereIdVal);
        whereCol = rawTabParams.RawColumn;
        [~, where_sql] = obj.SQL.combineSQL(whereCol, '=', whereIdVal_ch);
        
        limit = obj.Limit;
        rawCols = '*';
        [~, tbl] = obj.SQL.select(rawTab, rawCols, where_sql, limit);
    end
    
    % Assign table and variable
    obj.Data = tbl;
    obj.Variable = params.PerformanceVariable;
end