classdef (Abstract) cModelID < cTableObject & cMySQL & handle
    %CMODELID Read from database all data for rows matching the model ID
    %   Detailed explanation goes here
    
    properties
        
        Model_ID = [];
        Name = '';
        Description = '';
        Deleted = false;
    end
    
    properties(Hidden, Constant, Abstract)
        
        ValueTable;
        ModelTable; 
        ModelField;
    end
    
    properties(Hidden)
        
        Sync logical = true;
    end
    
    methods
    
       function obj = cModelID(varargin)
           
           % Assign Connection properties
%            paramValue_c = {};
%            if nargin > 2 && ~isempty(varargin{3})
%                
%                paramValue_c = varargin(3:end);
%            end
           obj = obj@cMySQL(varargin{:});
           
           p = inputParser();
            p.addParameter('Size', []);
            p.addParameter('ModelID', []);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            res = p.Results;
           
           % Expand scalar into matrix if requested
           if ~ismember('Size', p.UsingDefaults) %  nargin > 0 && ~isempty(varargin{1})
               
               sizeVect_v = res.Size; % varargin{1};
               size_c = num2cell(sizeVect_v);
%                nRows = sizeVect_v(1);
%                nCols = sizeVect_v(2);

               % Remove inputs already applied, pass other inputs to OBJ
               input_st = p.Unmatched;
               input_c = [fieldnames(input_st)'; struct2cell(input_st)'];
               input_c = strcat('''', input_c, '''');
               input_ch = strjoin(input_c, ', ');
                   
               class_ch = class(obj);
               constructor_ch = [class_ch, '(', input_ch, ');'];
               obj(size_c{:}) = eval(constructor_ch);
           end
           
           % Assign model id values if input
           if ~ismember('ModelID', p.UsingDefaults) % nargin > 1 && ~isempty(varargin{2})
               
               mid_c = res.ModelID; % varargin{2};
               cellfun(@(x) validateattributes(x, {'numeric'}, {'scalar',...
                  'real', 'integer', 'positive'}, 'cModelID.cModelID',...
                  'ModelID', 2), mid_c);
               [obj.Model_ID] = deal(mid_c{:});
           end
           
       end
       
%        function delete(obj)
%        % delete Delete object and remove any reserved models from DB
%        
%        % Iterate over DB tables and check if model missing from any
%        where_sql = [obj.ModelField, ' = ', num2str(obj.Model_ID)];
%        
%        if isempty(obj.Model_ID)
%            
%            return;
%        end
%        
%        % Iterate over DB tables and check if model missing from all
%        empty_l = true(size(obj.ValueTable));
%        for ti = 1:numel(obj.ValueTable)
%            
%            currTab = obj.ValueTable{ti};
%            [~, dataTbl] = obj.select(currTab, '*', where_sql);
%            empty_l(ti) = isempty(dataTbl);
%        end
%        
%        if all(empty_l)
%            
%            % Release a reserved row in DB if no other data was input
% %            obj.releaseModelID();
%        end
%        end
       
       function obj = insert(obj, varargin)
       % insertIntoTable Insert object data into specified DB tables
       
       [obj.Sync] = deal(false);
       idFieldValue_c = {};
       if nargin > 1
           
           idFieldValue_c = varargin;
       end
       
       for oi = 1:numel(obj)
           
%            % Reserve a model id, if none assigned
%            masterModelField = obj(oi).ModelField{1};
%            if isempty(obj(oi).Model_ID)
%                
%                id = obj(oi).nextUniqueID('', masterModelField);
%                obj(oi).Model_ID = id;
%            end
           
           % Insert into Model Table, so Name etc are inserted
%            masterModelField = obj(oi).ModelField{1};
%            if ~isempty(obj(oi).(masterModelField))
%                
%                masterModelFieldVal_c = [obj(oi).ModelField{1}, {obj(oi).(masterModelField)}];
%            else
%                
%                masterModelFieldVal_c = {};
%            end
           alias_c = obj(oi).propertyAlias;
%            idFieldValue_c = [idFieldValue_c, masterModelFieldVal_c];
           model = obj(oi).ModelTable;
           modelValue = obj(oi).ModelField{1};
           id = obj.incrementID(model, modelValue);
           obj(oi).Model_ID = id;
           insert@cTableObject(obj(oi), model);
%            insert@cTableObject(obj(oi), obj(oi).ModelTable, '', [], alias_c); %, idFieldValue_c{:});
           
           tables = obj(oi).ValueTable;
           
           modelField = obj(oi).ModelField;
           if isscalar(modelField)
               
               numValTable = numel(obj(oi).ValueTable);
               modelField = repmat(modelField, [1, numValTable + 1]);
           end
           
           alias_c = obj.propertyAlias;
           for ti = 1:numel(tables)
               
               % Insert into "data table"
               tab = tables{ti};
               currField = modelField{ti+1};
%                currFieldVal = obj(oi).(currField);
               currFieldVal = obj(oi).Model_ID;
               
               if isempty(obj(oi).ValueObject)
                   
                   inObj = obj(oi);
               else
                   
                   inObjName = obj(oi).ValueObject{ti};
                   inObj = obj(oi).(inObjName);
               end
               insert@cTableObject(inObj, tab, '',  [], alias_c, currField, currFieldVal);
%                insertIntoTable@cMySQL(obj(oi), tab, '', modelFieldVal_c{:});
           end
       end
       
       [obj.Sync] = deal(true);
       end
       
    end
    
    methods(Access = protected, Hidden)
%         %         function obj = releaseModelID(obj)
%         % releaseModelID Remove modelID rows from table when empty
%         
%         table = obj(1).ModelTable;
%         for oi = 1:numel(obj)
%             
%             mid_ch = num2str(obj.Model_ID);
%             where_sql = [obj.ModelField, ' = ', mid_ch];
%             
%             obj(oi).deleteSQL(table, where_sql);
%         end
%         end
%         
%         function obj = insertIntoModels(obj)
%         % insertIntoModels Insert model into DB table 'Models'
%            
%            tab = obj(1).ModelTable;
%            col = obj.ModelField;
%            
%            for oi = 1:numel(obj)
%                
%                % Get current highest model id
%                [~, mid_t] = obj.select(tab, ['MAX(', obj.ModelField, ')']);
%                currMaxModel = [mid_t{:, :}];
%                
%                % If NaN, no models created yet
%                if isnan(currMaxModel)
%                    
%                    currMaxModel = 0;
%                end
%                
%                % Get next unique model id
%                redundnatModelID = currMaxModel + 1;
%                vals = redundnatModelID;
%                
%                % Write into table
% %                obj(oi).insertIntoTable(tab);
%                obj(oi).insertValuesDuplicate(tab, col, vals);
%            end
%         end
%         
        function id = incrementID(obj, varargin)
        % nextUniqueID Get the next unique ID in DB
        
        % Input
        tableName = obj.ModelTable;
        if nargin > 1 && ~isempty(varargin{1})
            
            tableName = varargin{1};
            validateattributes(tableName, {'char'}, {'vector'}, ...
                'cModelID.nextUniqueID', 'tableName', 1);
        end
        
        fieldName = obj.ModelField;
        if nargin > 2
            
            fieldName = varargin{2};
            validateattributes(fieldName, {'char'}, {'vector'}, ...
                'cModelID.nextUniqueID', 'fieldName', 2);
        end
        
        sql = ['SELECT MAX(', fieldName, ')+1 FROM ', tableName];
        [~, id_c] = obj(1).execute(sql);
        id_ch = id_c{1};
        id = str2double(id_ch);
        
           % Account for case where table was empty or column was all null
           if isnan(id)
               id = 1;
           end
        end
        
    end
    
    methods(Hidden)
        
        function alias = propertyAlias(obj)
        % propertyAlias Alias to relate table fields with object properties
            
%             alias{1, 1} = 'Model_ID';
%             alias{1, 2} = obj.ModelField;
            
            alias = [repmat({'Model_ID'}, [size(obj(1).ModelField, 2), 1]),...
                obj(1).ModelField'];
        end
        
    end
    
    methods(Static, Access = protected)
        
        function warnAboutOverwrite()
        % warnAboutOverwrite Warn that data overwritten from database
        
            warnID = 'cMID:Overwrite';
            warnMsg = 'Data overwritten when identifier changed';
            warning(warnID, warnMsg);
        end
    end
    
    methods(Hidden)
        
        function [obj, inDB] = select(obj, tab, field, varargin)
        % checkModel Check if model in DB and read

        % Input
        tab = validateCellStr(tab, 'cTableObject.checkModel', 'tab', 2);
        field = validateCellStr(field, 'cTableObject.checkModel', 'field', 3);
        tab = tab(:);
        field = field(:);
        
        mid = [obj.Model_ID];
        if nargin > 3
            
            mid = varargin{1};
            validateattributes(mid, {'numeric'}, {'positive',...
                'integer', 'real'}, 'cModelID.select', 'mid', 4);
        end
        if isempty(mid)

            mid = {[]};
        else
            
            mid = num2cell(mid);
        end

        alias_c = obj.propertyAlias;
        if nargin > 4

            alias_c = varargin{2};
        end
        
        dataObj_c = num2cell(obj);
        if nargin > 5 && ~isempty(varargin{3})
            
            dataObj_c = varargin{3};
            validateattributes(dataObj_c, {'cell'}, {}, ...
                'cModelID.select', 'dataObj_c', 6);
        end
        dataObj_c = dataObj_c(:)';
        
        additional = {};
        if nargin > 6 && ~isempty(varargin{4})
            
            additional = varargin(4:end);
        end
        
        nMID = numel(mid);
        nObj = numel(dataObj_c);
        nTab = numel(tab);
        nField = numel(field);
        numAll = [nMID, nObj, nTab, nField];
        nonScalar_l = numAll ~= 1;
        lenVect_v = unique(numAll(nonScalar_l));
        if isempty(lenVect_v)
            
            lenVect_v = 1;
        end
        
%         validInput_l = isvector(tab) && isscalar(obj_c) && isscalar(field)...
%             || ...
%             ~isscalar(tab) && ~isscalar(obj_c) && ~isscalar(field) && ...
%             isequal(size(tab), size(obj_c)) && isequal(size(tab), size(field));
        if numel(lenVect_v) > 1

           errid = 'chkModel:InputSizeMismatch';
           errmsg = ['Inputs MID, OBJ, TAB and FIELD can all be the same size '...
               'or any can be scalar while the others are vectors of the same length.'];
           error(errid, errmsg);
        end
        
        % Repeat inputs to same size if required
        if lenVect_v > 1 && nMID == 1
            
            mid = repmat(mid, [1, lenVect_v]);
        end
        if lenVect_v > 1 && nObj == 1
            
            dataObj_c = repmat(dataObj_c, [1, lenVect_v]);
        end
        if lenVect_v > 1 && nTab == 1
            
            tab = repmat(tab, [1, lenVect_v]);
        end
        if lenVect_v > 1 && nField == 1
            
            field = repmat(field, [1, lenVect_v]);
        end
        
%         if isempty(alias_c)
%             
%             alias_c = obj.propertyAlias;
%         end
        
        if isempty(alias_c)
            
            alias_c = cell([lenVect_v, 1]);
        else
            
            alias_c = repmat({alias_c}, [lenVect_v, 1]);
        end
        
%         % Repeat inputs to same size if required
%         if ~(isequal(size(tab), size(obj_c)) && isequal(size(tab), size(field)))
% 
% %             obj = repmat(obj, size(tab));
%             field = repmat(field, size(tab));
%         end
%         
%         if isequal(size(tab), size(field)) && ~isequal(size(tab), size(obj_c))
%             
%             obj_c = num2cell(repmat(obj, size(field)));
%             mid = (repmat(mid, size(field)));
%         end
%         
%         if size(alias_c, 1) ~= size(tab, 1)
%             
%             alias_c = repmat(alias_c, [size(tab, 1), 1]);
%         end

        for oi = 1:numel(dataObj_c)

            % Index
            currObj = dataObj_c{oi};
            currTab = tab{oi};
            currField = field{oi};

            % Read out data, if model already in DB
%             inDB = currObj.isModelInDB(currTab, currField, mid);

            % Assign now so that Models_id can be read out later
        %             obj.Model_ID = mid;
        % 
        %             if inDB

                % If Model already in DB, read data out
        %                 for ti = 1:numel(obj.ValueTable)
% 
%             if inDB

                % Read object data from Value Tables
            currAlias_c = alias_c{oi, :};
%             if isempty(alias_c)
% 
%                 currAlias_c = {};
%             else
% 
%                 currAlias_c = alias_c(oi, :);
%             end
%              mid = currObj.Model_ID;
            midi = mid{oi};
            currObj.Sync = false;
            [~, inDB] = select@cTableObject(currObj, currTab,...
                        currField, '', currAlias_c, midi, additional{:});
            currObj.Sync = true;
% 
%                 catch ee
% 
%                     if ~strcmp(ee.identifier, 'readTable:IdentifierDataMissing')
%                         rethrow(ee);
%                     end
%                 end
%                 
%             else
%                 
%             end
        %                 % Read additional data from Models Table
        %                 try obj = obj.readFromTable(obj.ModelTable,...
        %                         obj.ModelField, '', alias_c);
        % 
        %                 catch ee
        % 
        %                     if ~strcmp(ee.identifier, 'readTable:IdentifierDataMissing')
        %                         rethrow(ee);
        %                     end
        %                 end
        %                 end
        %             else
        % 
        %                 % If model not in DB, reserve Name in Model table
        %                 currObj.reserveModelID(currTab, currField);
        %             end

            % Assign
%             obj(oi) = currObj;
        end
        end
    end
    
    methods(Access = protected)
        
        function obj = readOtherIfExist(obj)
        % readOtherIfExist Read other tables if they exist
        
        for oi = 1:numel(obj)
            for ti = 1:numel(obj.OtherTable)
                
                % If other tables are given and found in DB
                currTab = obj.OtherTable{ti};
                [~, tblExist_l] = obj(oi).isTable(currTab);
                if ~tblExist_l

                    continue
                end

                % Read from table
                currIdName = obj(oi).OtherTableIdentifier{ti};
                currIdVal = obj(oi).(currIdName);
%                 alias_c = obj.propertyAlias;
                obj(oi) = obj(oi).select(currTab, currIdName, currIdVal, {currIdName, currIdName});
            end
        end
        end
    end
    
    methods
        
        function set.Model_ID(obj, mid)
        % Ensure Name is char vector
            
            % This could be bad...
            if isempty(mid)
                
                obj.Model_ID = [];
                return
            end
            
            if ~isscalar(mid) && numel(unique(mid)) == 1
                
                mid = unique(mid);
            end
        
            % Input
            validateattributes(mid, {'numeric'}, {'scalar', 'positive',...
                'real', 'integer'}, 'cModelID.Model_ID', 'Model_ID', 1);
            
            % Assign now so that Models_id can be read out later
            obj.Model_ID = mid;
            
            if obj.Sync
            
%                 obj.readOtherIfExist();
                
                % Check model
                tab = [cellstr(obj.ModelTable), obj.ValueTable];
                field = obj.ModelField;
                alias_c = obj.propertyAlias;

                % Get nested objects, if available
                obj2Name_c = obj.ValueObject;
                obj2_c = [num2cell(obj); cellfun(@(x) obj.(x), obj2Name_c, 'Uni', 0)'];

                obj.select(tab, field, mid, alias_c, obj2_c);

            end
%             if ~inDB
%                 
%                 % If model not in DB, reserve Name in Model table
%                 obj.reserveModelID(obj.ModelTable, obj.ModelField);
%             end
%             % Read out data, if model already in DB
%             mid_ch = num2str(mid);
%             where_sql = [obj.ModelField, ' = ', mid_ch];
%             [~, tbl] = obj.select(obj.ModelTable, obj.ModelField, where_sql);
%             modelInDB_l = ~isempty(tbl);
%             
%             if modelInDB_l
%                 
%                 % If Model already in DB, read data out
%                 for ti = 1:numel(obj.ValueTable)
%                     
%                     % Read object data from Value Tables
%                     try obj = obj.readFromTable(obj.ValueTable{ti},...
%                             obj.ModelField, '', alias_c);
%                         
%                     catch ee
%                         
%                         if ~strcmp(ee.identifier, 'readTable:IdentifierDataMissing')
%                             rethrow(ee);
%                         end
%                     end
%                     
%                     % Read additional data from Models Table
%                     try obj = obj.readFromTable(obj.ModelTable,...
%                             obj.ModelField, '', alias_c);
%                         
%                     catch ee
%                         
%                         if ~strcmp(ee.identifier, 'readTable:IdentifierDataMissing')
%                             rethrow(ee);
%                         end
%                     end
%                 end
%                 
%             else
%                 
%                 % If model not in DB, reserve Name in Model table
%                 obj.reserveModel();
%             end
        end
%         function set.Deleted(obj, del)
%             
%             validateattributes(del, {'numeric'}, {'scalar', 'real', ...
%                 'integer', '>=', 0, '<=', 1});
%             obj.Deleted = del;
%         end
    end
    
%     methods(Hidden, Access=protected)
%         
%         function obj = reserveModelID(obj, tab, field)
%         % reserveModelID Create entry for model in DB without writing data
%         
% %             obj = obj.insertIntoModels();
%            
% %            tab = obj(1).ModelTable;
% %            col = obj.ModelField;
%            
% %            field2write = {field, 'Deleted'};
%            for oi = 1:numel(obj)
%                
%                % Get current highest model id
%                currObj = obj(oi);
%                [~, mid_t] = currObj.select(tab, ['MAX(', field, ')']);
%                currMaxModel = [mid_t{:, :}];
%                
%                % If NaN, no models created yet
%                if isnan(currMaxModel)
%                    
%                    currMaxModel = 0;
%                end
%                
%                % Get next unique model id
%                redundnatModelID = currMaxModel + 1;
%                val = redundnatModelID;
%                
%                % Write into table
% %                obj(oi).insertIntoTable(tab);
% %                obj(oi).insertValuesDuplicate(tab, field2write, vals);
% %                insertIntoTable@cTableObject(currObj, tab, [], field, val);
%                currObj.insertIntoTable(tab, [], field, val);
%            end
%         end
%         
%         function obj = releaseModelID(obj, tab, field)
%         % releaseModelID Remove modelID rows from table when empty
%         
% %         table = obj(1).ModelTable;
%         for oi = 1:numel(obj)
%             
%             mid_ch = num2str(obj.Model_ID);
%             where_sql = [field, ' = ', mid_ch];
%             
%             obj(oi).deleteSQL(tab, where_sql);
%         end
%         end
%     end
%     
    methods
       
        function set.Deleted(obj, del)
            
            if isnumeric(del)
                
                validateattributes(del, {'numeric', 'logical'}, ...
                    {'scalar', 'real', 'integer', '>=', 0, '<=', 1});
                del = logical(del);
            else
                
                validateattributes(del, {'logical'}, {'scalar'});
            end
            obj.Deleted = del;
        end
    end
end