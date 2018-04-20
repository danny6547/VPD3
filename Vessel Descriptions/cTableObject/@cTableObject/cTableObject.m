classdef cTableObject < cMySQL
    %CTABLEOBJECT Relate MATLAB object to Database tables
    %   Detailed explanation goes here
    
    properties(Abstract, Hidden, Constant)
        
        DataProperty;
    end
    
    methods
    
        function obj = cTableObject(varargin)

           obj = obj@cMySQL(varargin{:});
        end

        function insert(obj, table, varargin)
        % insertIntoTable Insert object property values in table

        % Input
        dataObj = obj;
        if nargin > 2

            dataObj = varargin{1};
            if isempty(dataObj)
                dataObj = obj;
            end
        end

        additionalFields_c = {};
        additionalData_c = cell(numel(dataObj), 1);
        additionalData_cc = {};
        numAdditional = 0;
        if nargin > 3

            paramValues = varargin(2:end);
            p = inputParser();
            p.KeepUnmatched = true;
            p.parse(paramValues{:});
            results = p.Unmatched;

            additionalFields_c = fieldnames(results);
            numAdditional = numel(additionalFields_c);

        %             additionalData_c = struct2cell(results')';

        %             numericCols_l = all(cellfun(@isnumeric, additionalData_c));
        %             additionalData_cc = mat2cell(additionalData_c, nRows, ones(1, nCols));
        %             additionalData_cc(numericCols_l) = cellfun(...
        %                 @(x) [x{:}], additionalData_cc(numericCols_l), 'Uni', 0);

            resData_st = structfun(@cellstr, results, 'Uni', 0, ...
                'Err', @(x, y) num2cell(y));
            resData_c = struct2cell(resData_st);
            resData_c = cellfun(@(x) x(:), resData_c, 'Uni', 0);
            additionalData_c = [resData_c{:}];
            [nRows, nCols] = size(additionalData_c);
            additionalData_c = mat2cell(additionalData_c, ones(1, nRows),...
                nCols);
        %             additionalData_c = cellfun(@num2cell, additionalData_c, 'Uni', 0);

        %             resData_c = struct2cell(results);
        %             resData_c = cellfun(@(x) x(:), resData_c, 'Uni', 0);
        %             additionalData_c = num2cell(cell2mat(resData_c));
        end

        % Get matching field names
        matchFields_c = matchingFields(obj, table, dataObj);

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
        %             tempData_c(cellfun(@isempty, tempData_c)) = {nan};
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
        %                 nRows = size(nonChar_c{1}, 1);
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

        %             currData_c = cellfun(@num2cell, currData_c, 'Uni', 0);
        %             currData_c = num2cell(cell2mat(...
        %                 currData_c));
        %             currData_c(~charData_l) = ...
        %                 cellfun(@(x) x(:), currData_c(~charData_l), 'Uni', 0);
            emptyNonChar_l = cellfun(@(x) isempty(x) && ~ischar(x), currData_c);
            currData_c(emptyNonChar_l) = {nan};
        %             currData_c(~charData_l) = num2cell(cell2mat(...
        %                 currData_c(~charData_l)));
            data_c = [data_c; currData_c];
        end

        % Insert matrix of data into table
        matchFields_c = [matchFields_c(:); additionalFields_c(:)];
        %         data_c = [data_c, additionalData_c];
        obj(1).insertValuesDuplicate(table, matchFields_c, data_c);

        end

        function empty = isempty(obj)
        % isempty True if object data properties are all empty
        
            if any(size(obj) == 0)
                empty = true;
                return
            end
            
            props = obj.DataProperty;
            
            % Exclude certain properties with default values
            props = setdiff(props, 'Deleted');
            
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
    
    methods(Access=protected)
        
        function [obj, inDB] = select(obj, table, identifier, varargin)
        % readFromTable Assign object properties from table column values

        % Output
        inDB = false;
        %         objdiff = true;
        %         fielddiff = true;

        % Input
        validateattributes(table, {'char'}, {'vector'}, ...
            'cVessel.readFromTable', 'table', 2);
        validateattributes(identifier, {'char'}, {'vector'}, ...
            'cVessel.readFromTable', 'identifier', 3);

        cols2write = properties(obj);
        if nargin > 3 && ~isempty(varargin{1})

            cols2write = varargin{1};
            validateCellStr(cols2write, 'cMySQL.readFromTable',...
                'cols2write', 1);
        end

        prop_c = properties(obj);
        identifierProp_ch = identifier;
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

        end
        
        identifierValueInput = false;
        if nargin > 5 && ~isempty(varargin{3})
            
            identifierValueInput = true;
            identifierValue = varargin{3};
            
            % Append to properties and values
            prop_c = [prop_c; cellstr(identifier)];
        end

        % Get matching field names and object properties
        temp_st = obj(1).execute(['DESCRIBE ', table]);
        fields_c = temp_st.field;
        %         prop_c = properties(obj);
        matchField_c = intersect(fields_c, prop_c);

        % Error if identifier is not in both fields and properties
        if ~ismember(identifier, matchField_c)
            
            errid = 'readTable:IdentifierMissing';
            errmsg = ['Input IDENTIFIER must be both a property of OBJ '...
                'and a field of table TABLE.'];
            error(errid, errmsg);
        end

        % No need to read data for identifier, given in input
        matchField_c = intersect(prop_c, cols2write);
        matchField_c = intersect(matchField_c, fields_c);
        matchField_c = setdiff(matchField_c, identifier);

        % Select table where rows match identifier values in object
        if identifierValueInput
            
            objID_c = repmat({identifierValue}, size(obj));
        else
            
            objID_c = {obj.(identifierProp_ch)};
        end
        objID_cs = cellfun(@num2str, objID_c, 'Uni', 0);
        objIDvals_ch = obj(1).colList(objID_cs);
        [obj(1), sqlWhereIn_ch] = obj(1).combineSQL('WHERE', identifier, 'IN',...
            objIDvals_ch);
        [obj(1), ~, sqlSelect] = select@cMySQL(obj(1), table, '*');
        [obj(1), sqlSelect] = obj(1).determinateSQL(sqlSelect);
        [obj(1), sqlSelectWhereIn_ch] = obj(1).combineSQL(sqlSelect, sqlWhereIn_ch);
        %         table_st = obj(1).execute(sqlSelectWhereIn_ch);
        [~, ~, q] = obj(1).executeIfOneOutput(1, sqlSelectWhereIn_ch);

        [obj(1), sqlWhereIn_ch] = obj(1).combineSQL(identifier, 'IN',...
            objIDvals_ch);
        [obj(1), table_st] = select@cMySQL(obj(1), table, '*', sqlWhereIn_ch);
        if isempty(table_st)

            return
%             errid = 'readTable:IdentifierDataMissing';
%             errmsg = 'No data could be read for the values of IDENTIFIER.';
%             error(errid, errmsg);
        end
        
        % Object found in DB
        inDB = true;

        % Get indices to OBJ identified in table
        lowerId_ch = lower(identifier);
        tableID_c = table_st.(lowerId_ch);
        if iscell(tableID_c)
        %             [obj_l, obj_i] = ismember([tableID_c{:}], [objID_c{:}]);
            [~, obj_i] = ismember([objID_c{:}], [tableID_c{:}]);

        %             nID = sum(obj_l);
        else
        %             nID = 1;
            [~, obj_i] = ismember([objID_c{:}], tableID_c);
        %             obj_i = 1;
        %             obj_l = true;
        end

        % Create arrays to track whether object data has changed by read
        %         fielddiff = true(length(matchField_c), numel(obj));

        % Iterate over properties of matching obj and assign values
        for ii = 1:length(matchField_c)

            currField = matchField_c{ii};
            lowerField = lower(currField);
            currData = table_st.(lowerField);
            if ~iscell(currData)
        %                 currData = {currData};
                currData = num2cell(currData);
            end

            for oi = 1:numel(obj)

                if obj_i(oi) == 0
                    continue
                end
        %                 currObji = obj_i(oi);
%                 currTablei = obj_i(oi);
                
                if ~identifierValueInput
                    identifierValue = obj(oi).(identifierProp_ch);
                end
                currData_l = q.(lowerId_ch) == identifierValue; %obj(oi).(identifierProp_ch);

                % Check if different
        %                 fielddiff(ii, oi) = ...
        %                     ~isequal(obj(oi).(currField), currData{currData_l}) || ...
        %                     (isequal(size(obj(oi).(currField)), size(currData{currData_l})) && ...
        %                 isnan(obj(oi).(currField)) && isnan(currData{currData_l}));

                try
        %                     obj(oi).(currField) = currData{currTablei};
                    obj(oi).(currField) = [currData{currData_l}];
                catch e
                    % Write some code here later...
                    % Error is attempt to write to dependent property
                    disp('hello');
                end
            end
        end

        % Return which objects are different
        %         objdiff = any(fielddiff);
        %         objDifferent_l = all(objDifferent_l);

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
    end
end