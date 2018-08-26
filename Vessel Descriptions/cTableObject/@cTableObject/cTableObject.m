classdef cTableObject < handle
    %CTABLEOBJECT Relate MATLAB object to Database tables
    %   Detailed explanation goes here
    
    properties(Abstract, Hidden, Constant)
        
        DataProperty;
        TableIdentifier;
        EmptyIgnore;
    end
    
    properties(Hidden)
        
        SQL;
        Last_Update_Id = false;
        SavedConnection;
    end
    
    methods
    
        function obj = cTableObject(varargin)
            
           % Determine which cSQL sub-class to instantiate
           csql = cSQL.instantiateChildObj(varargin{:});
           obj.SQL = csql;
        end

        function obj = insert(obj, table, varargin)
        % insertIntoTable Insert object property values in table

        % Input
        dataObj = obj;
        if nargin > 2

            dataObj = varargin{1};
            if isempty(dataObj)
                dataObj = obj;
            end
        end
        
        identifier = obj(1).TableIdentifier;
        if nargin > 3 && ~isempty(varargin{2})

            identifier = varargin{2};
            validateattributes(identifier, {'char'}, {'vector'}, ....
                'cTableObject.insert', 'identifier', 4);
        end

        alias_c = obj.propertyAlias;
        if nargin > 4

            alias_c = varargin{3};
            if (~isempty(alias_c) && ~any(ismember(alias_c(:, 2), identifier))) ...
                || (isempty(alias_c) && isnumeric(alias_c))
                    
                alias_c = {};
            end
        end
        
        additionalFields_c = {};
        additionalData_c = arrayfun(@(x) {}, dataObj, 'Uni', 0)';
        numAdditional = 0;
        additionalInputs = {};
        if nargin > 5

            additionalInputs = varargin(4:end);
            [additionalFields_c, additionalData_c] = obj.parseAdditional(additionalInputs{:});
            
            % Put this into parseAdditional later?
            if size(additionalData_c, 1) == 1 && numel(dataObj) > 1
                
                additionalData_c = repmat(additionalData_c, [numel(dataObj), 1]);
            end
            
            numAdditional = numel(additionalFields_c);
        end
        
        % Get matching field names
        matchFields_c = obj(1).SQL.matchingFields(table, dataObj);

        duplicates_l = ismember(matchFields_c, additionalFields_c);
        matchFields_c(duplicates_l) = [];

        % Create cell matrix of data, repeating where necessary
        data_c = cell(0, numel(matchFields_c) + numAdditional);
        for oi = 1:numel(dataObj)


            currData_c = cell(1, numel(matchFields_c) + numAdditional);
            tempData_c = cell(1, numel(matchFields_c));
            for mi = 1:length(matchFields_c)

                currField = matchFields_c{mi};
                tempData_c{mi} = dataObj(oi).(currField);
            end

            numericData_l = cellfun(@isnumeric, tempData_c);
            tempData_c(numericData_l) = cellfun(@(x) x(:), ...
                tempData_c(numericData_l), 'Uni', 0);

            tempData_c = [tempData_c, additionalData_c{oi, :}];
            [currData_c{:}] = cVessel.repeatInputs(tempData_c);
            currData_c(~numericData_l) = tempData_c(~numericData_l);

            charData_l = cellfun(@ischar, currData_c);
            nonChar_c = currData_c(~charData_l);
            if isempty(nonChar_c)
                nRows = size(currData_c, 1);
            else
                nonChar_c = cellfun(@(x) x(:), nonChar_c, 'Uni', 0);
                nRows = unique(cellfun(@length, ...
                    nonChar_c(~cellfun(@isempty, nonChar_c))));
                if isempty(nRows)

                    nRows = size(currData_c(charData_l), 1) ;
                end
            end
            q = cell(nRows, size(currData_c, 2));
            for ci = 1:size(currData_c, 2)

                currCol = currData_c(ci);
                if ~all(cellfun(@isempty, currCol))
                    char_l = cellfun(@ischar, currCol);
                    if isscalar(char_l)
                        if char_l
                            q(:, ci) = currCol(:);
                        else
                            q(:, ci) = num2cell([currCol{:}]);
                        end
                    else
                        q(char_l, ci) = cellstr( currData_c(char_l, ci) ) ;
                        q(~char_l, ci) = num2cell([currData_c{~char_l, ci}]);
                    end
                end
            end
            currData_c = q;
            emptyNonChar_l = cellfun(@(x) isempty(x) && ~ischar(x), currData_c);
            currData_c(emptyNonChar_l) = {nan};
            data_c = [data_c; currData_c];
        end

        % Insert matrix of data into table
        matchFields_c = [matchFields_c(:); additionalFields_c(:)];
        lastUpdateColName = [];
        if obj(1).Last_Update_Id
            lastUpdateColName = identifier;
        end
        
        [~, height_tbl] = obj(1).SQL.select(table, 'COUNT(*)');
        nRowsBefore = [height_tbl{:, :}];
        
        obj(1).SQL.insertValuesDuplicate(table, matchFields_c, data_c, [], lastUpdateColName);

        [~, height_tbl] = obj(1).SQL.select(table, 'COUNT(*)');
        nRowsAfter = [height_tbl{:, :}];
        nRowsChange = ~isequal(nRowsAfter, nRowsBefore);
        
        % Select out data for vessel, to synchronise with DB
        emptyID_l = cellfun(@isempty, {obj.(identifier)});
        
        % Assume at this point that if one OBJ has empty id, they all do
        if all(emptyID_l) && nRowsChange
            
            id_v = obj.lastInsertID;
            
            if id_v ~= 0
                
                additionalInputs = [additionalInputs, {identifier}, {id_v}];
            end
        end
        
        obj = obj.select(table, identifier, [], alias_c, [], false, additionalInputs{:});
        end

        function empty = isempty(obj)
        % isempty True if object data properties are all empty
        
            if any(size(obj) == 0)
                empty = true;
                return
            end
            
            props = obj.DataProperty;
            
            % Exclude certain properties with default values
            emptyIgnore_c = obj.EmptyIgnore;
            props = setdiff(props, emptyIgnore_c);
            
            empty = false(numel(props), numel(obj));
            for oi = 1:numel(obj)
                for pi = 1:numel(props)
                    
                    prop = props{pi};
                    empty(pi, oi) = isempty(obj(oi).(prop));
                end
            end
            empty = all(all(empty));
        end
    end
    
    methods(Hidden)
       
       function [obj, inDB, inOBJ] = select(obj, table, identifier, varargin)
        % readFromTable Assign object properties from table column values

        % Output
        inDB = false;
        inOBJ = false;

        % Input
        validateattributes(table, {'char'}, {'vector'}, ...
            'cVessel.readFromTable', 'table', 2);
        validateattributes(identifier, {'char'}, {'vector'}, ...
            'cVessel.readFromTable', 'identifier', 3);

        cols2write = {};
        whereField = identifier; 
        idValInObj_l = true;
        
        prop_c = obj.DataProperty;
        prop_c = prop_c(:);
        identifierProp_ch = identifier;
        whereValue = {};
        aliasProp_ch = '';
        if nargin > 4 && ~isempty(varargin{2})

            alias_c = varargin{2};
            validateattributes(alias_c, {'cell'}, {'2d', 'ncols', 2}, ...
                'cMySQL.readFromTable', 'alias', 5);
            alias_c = validateCellStr(alias_c);

            identifier_l = ismember(alias_c(:, 2), identifier);
            identifierProp_ch = alias_c{identifier_l, 1};

            % Replace property names with aliases
            [isprop, propi] = ismember(alias_c(:, 1), prop_c);
            if any(~isprop)
                
                errid = 'readTable:AliasMissing';
                errmsg = ['The first column of input ALIAS must all be '...
                    'properties of OBJ'];
                error(errid, errmsg);
            end
            prop_c(propi) = alias_c(:, 2);
            whereValue = {obj.(identifierProp_ch)};
            aliasProp_ch = alias_c{identifier_l, 2};
        end
        
        whereValueInput = false;
        if nargin > 5 && ~isempty(varargin{3})
            
            whereValueInput = true;
            idValInObj_l = false;
            whereValue = varargin(3);
            
            % Append to properties and values
            prop_c = [prop_c; cellstr(identifier)];
        end
        
        expandArray_l = true;
        if nargin > 6 && ~isempty(varargin{4})
            
            expandArray_l = varargin{4};
            validateattributes(expandArray_l, {'logical'}, {'scalar'},...
                'cTableObject.select', 'expandArray', 8);
        end
        
        additionalFields_c = {};
        additionalCondition_ch = '';
        if nargin > 7 && ~isempty(varargin{5})
            
            additionalInputs_c = varargin(5:end);
            [additionalFields_c, additionalData_c] = ...
                obj.parseAdditional(additionalInputs_c{:});
            
            % Enclose any char values 
            additionalData_c = [additionalData_c{:}];
            additionalDataStr_c = cellfun(@num2str, additionalData_c, 'Uni', 0);
            additionalDataStr_c = additionalDataStr_c(:);
            eq_c = repmat({' = '}, size(additionalFields_c));
            addAll = strcat(additionalFields_c, eq_c, additionalDataStr_c);
            additionalCondition_ch = strjoin(addAll, ' AND ');
            
            if any(~cellfun(@isempty, additionalData_c))
                
                whereValueInput = true;
            end
            
            whereField = additionalFields_c{1};
            whereValue = additionalData_c(1);
            
            idValInObj_l = false;
        end
        
        if ~iscell(whereValue)
            whereValue = {whereValue};
        end
        
        % Get matching field names and object properties
        [~, temp_st] = obj(1).SQL.describe(table);
        fields_c = temp_st.field;
        matchField_c = intersect(fields_c, prop_c);
        matchField_c = union(matchField_c, additionalFields_c);

        % Error if identifier is not in both fields and properties
        if ~ismember(identifier, matchField_c)
            
            errid = 'readTable:IdentifierMissing';
            errmsg = ['Input IDENTIFIER must be both a property of OBJ '...
                'and a field of table TABLE.'];
            error(errid, errmsg);
        end

        % No need to read data for identifier, given in input
        matchField_c = intersect(matchField_c, fields_c);

        % Select table where rows match identifier values in object
        if whereValueInput
            
            whereValue = repmat(whereValue, size(obj));
        else
            
            whereValue = {obj.(identifier)};
        end
        
        % Get indices to OBJ identified in table
        if ~isempty(identifier)
            
            lowerId_ch = lower(identifier);
        else
            
            lowerId_ch = lower(obj(1).TableIdentifier);
        end
        
        % Return if no identifier data in OBJ...
        objIdentifierMissing = all(cellfun(@isempty, whereValue)) && ...
            isempty(additionalCondition_ch);
        if objIdentifierMissing
            
            return
        end
        
        inOBJ = true;
        
        objID_cs = cellfun(@num2str, whereValue, 'Uni', 0);
        objID_cs = obj(1).SQL.encloseStringQuotes(objID_cs);
        objIDvals_ch = obj(1).SQL.colList(objID_cs);
        
        [~, sqlWhereID_ch] = obj(1).SQL.combineSQL('WHERE', whereField, 'IN',...
            objIDvals_ch);
        [~, ~, sqlSelect] = obj(1).SQL.select(table, '*');
        [~, sqlSelect] = obj(1).SQL.determinateSQL(sqlSelect);
        [~, sqlSelectWhereIn_ch] = obj(1).SQL.combineSQL(sqlSelect, ...
            sqlWhereID_ch);
        [~, ~, table_st] = obj(1).SQL.executeIfOneOutput(1, sqlSelectWhereIn_ch);
        
        if isempty(table_st)

            return
        end
        
        % Object found in DB
        inDB = true;


        % Repeat table to match number of objects
        if ~isscalar(obj) && height(table_st) == 1

            table_st = repmat(table_st, numel(obj), 1);
        end

        if expandArray_l
            
            modCol_ch = lower(obj(1).TableIdentifier);
            obj = obj.matchArraySizeToSelect(modCol_ch, table_st);
            lowerId_ch = modCol_ch;
        end
        
        idVal_c = table_st.(lowerId_ch);
        if ~iscell(idVal_c)
            
            idVal_c = arrayfun(@(x) x, idVal_c, 'Uni', 0);
        end

        % Iterate over properties of matching obj and assign values
        for ii = 1:length(matchField_c)

            currField = matchField_c{ii};
            lowerField = lower(currField);
            currData = table_st.(lowerField);
            if ~iscell(currData)
                
                currData = num2cell(currData);
            end
            
            if strcmp(currField, aliasProp_ch)
                
                currField = identifierProp_ch;
            end
            
            for oi = 1:numel(obj)
                
                currData_l = table_st.(lowerId_ch) == idVal_c{oi};
                
                try obj(oi).(currField) = [currData{currData_l}];
                    
                catch e
                    
                    % Write some code here later...
                    % Error is attempt to write to dependent property
                    disp('hello');
                end
            end
        end
        end
       
       function [log, propDiff] = isequal(obj, obj2)
       % isequal True if object data and array are numerically equal.
       
       propDiff = {};
           if isempty(obj)

               log = false;
               return
           end
           
           if ~isa(obj2, 'cTableObject')
               
               log = false;
               return
           end
           
           if ~isequal(size(obj), size(obj2))
               
               log = false;
               return
           end
           
           props_c = sort(obj(1).DataProperty);
           props_c = props_c(:)';
           
           log = true(numel(obj), numel(obj(1).DataProperty));
           propDiff = repmat(props_c, [numel(obj), 1]);
           for oi = 1:numel(obj)
           
               sDP = props_c;
               sDP2 = sort(obj2(oi).DataProperty);
               if ~isequal(sDP, sDP2)

                   log = false;
                   return
               end

               eqf = @(x, y, tol) (isequal(size(x), size(y)) && all(isnan(x)) && all(isnan(y))) ...
                   || ((numel(x) == numel(y)) && all(abs(x(:) - y(:)) < tol));
               tolerance = 1e-15;

               % Iterate data properties and compare
               for pi = 1:numel(sDP)

                   currProp = sDP{pi};
                   if ~eqf(obj(oi).(currProp), obj2(oi).(currProp), tolerance)
                       log(pi) = false;
                   end
               end
           end
           propDiff(log) = {[]};
           log = all(all(log));
       end
    end
    
    methods(Hidden)
        
        function inDB = isModelInDB(obj, tab, field, modelID)
            
            if isempty(modelID)
                
                inDB = false;
                return;
            end
            
            % Inputs
            validateattributes(tab, {'char'}, {'vector'}, ...
                'cTableObject.isModelInDB', 'tab', 2);
            validateattributes(field, {'char'}, {'vector'}, ...
                'cTableObject.isModelInDB', 'field', 3);
            validateattributes(modelID, {'numeric'}, {'scalar'}, ...
                'cTableObject.isModelInDB', 'modelID', 4);
            
            % Detect if model in DB
            mid_ch = num2str(modelID);
            where_sql = [field, ' = ', mid_ch];
            [~, tbl] = obj.select(tab, field, where_sql);
            inDB = ~isempty(tbl);
        end
        
        function id = lastInsertID(obj)
        % lastInsertID Return the last auto-incremented identifier value
        
        [~, id_c] = obj(1).SQL.execute('SELECT LAST_INSERT_ID()');
        id = str2double([id_c{:}]);
            
        end
        
       function obj = copySQLToArray(obj)
       % copySQLToArray Copy SQL of first obj to full array if empty
       
       % Check criteria
       array_l = ~isempty(obj) && ~isscalar(obj);
       if ~array_l
           
           return
       end
       
       firstSQLNonEmpty = ~isempty(obj(1).SQL);
       if ~firstSQLNonEmpty
           
           return
       end
       
       allOtherSQLEmpty = all(isempty(obj(2:end).SQL));
       if ~allOtherSQLEmpty
           
           return
       end
       
       % Copy
       [obj(2:end).SQL] = deal(obj(1).SQL);
       
       end
    end
    
    methods(Hidden, Static)
        
        function [fields, data] = parseAdditional(varargin)
        % parseAdditional
            
            paramValues = varargin;
            p = inputParser();
            p.KeepUnmatched = true;
            p.parse(paramValues{:});
            results = p.Unmatched;

            additionalFields_c = fieldnames(results);
            resData_st = structfun(@cellstr, results, 'Uni', 0, ...
                'Err', @(x, y) num2cell(y));
            resData_c = struct2cell(resData_st);
            resData_c = cellfun(@(x) x(:), resData_c, 'Uni', 0);
            additionalData_c = [resData_c{:}];
            [nRows, nCols] = size(additionalData_c);
            additionalData_c = mat2cell(additionalData_c, ones(1, nRows),...
                nCols);
            fields = additionalFields_c;
            data = additionalData_c;
        end
    end
    
    methods
        
        function set.SQL(obj, sql)
        % 
            validateattributes(sql, {'cSQL'}, {'scalar'});
            obj.SQL = sql;
        end
        
        function obj = set.SavedConnection(obj, save)
        % Construct new SQL and assign saved connection properties
        
           csql = obj.SQL.instantiateChildObj(save);
           obj.SQL = csql;
        end
    end
end