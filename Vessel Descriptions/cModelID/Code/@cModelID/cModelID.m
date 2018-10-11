classdef (Abstract) cModelID < cTableObject & handle
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
        NameAlias;
        OtherTable;
        OtherTableIdentifier;
    end
    
    properties(Hidden)
        
        Sync logical = true;
    end
    
    methods
    
       function obj = cModelID(varargin)
           
           % Assign Connection properties
           obj = obj@cTableObject(varargin{:});
           
           p = inputParser();
            p.addParameter('Size', []);
            p.addParameter('ModelID', []);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            res = p.Results;
           
           % Expand scalar into matrix if requested
           if ~ismember('Size', p.UsingDefaults)
               
               sizeVect_v = res.Size;
               size_c = num2cell(sizeVect_v);

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
           if ~ismember('ModelID', p.UsingDefaults)
               
               mid_c = res.ModelID;
               cellfun(@(x) validateattributes(x, {'numeric'}, {'scalar',...
                  'real', 'integer', 'positive'}, 'cModelID.cModelID',...
                  'ModelID', 2), mid_c);
               [obj.Model_ID] = deal(mid_c{:});
           end
           
       end
       
       function obj = insert(obj, varargin)
       % insertIntoTable Insert object data into specified DB tables
       
       [obj.Sync] = deal(false);
       
       for oi = 1:numel(obj)
           
           alias_c = obj(oi).propertyAlias;
           aliasIdx = 1;
           model = obj(oi).ModelTable;

            % Concat model id alias and value to inputs
            mid = [obj(oi).Model_ID];
            mid_c = {};
            if ~isempty(mid)

                name = alias_c{1, 2};
                value = mid;
                mid_c = {name, value};
            end
            
            % Insert into model table
           obj(oi) = insert@cTableObject(obj(oi), model, [], [],...
               alias_c(aliasIdx, :), mid_c{:});
           
           tables = obj(oi).ValueTable;
           modelField = obj(oi).ModelField;
           if isscalar(modelField)
               
               numValTable = numel(obj(oi).ValueTable);
               modelField = repmat(modelField, [1, numValTable + 1]);
           end
           
%            alias_c = obj.propertyAlias;
           for ti = 1:numel(tables)
               
               % Insert into "data table"
               tab = tables{ti};
               currField = modelField{ti+1};
               currFieldVal = obj(oi).Model_ID;
               
               if isempty(obj(oi).ValueObject)
                   
                   inObj = obj(oi);
               else
                   
                   inObjName = obj(oi).ValueObject{ti};
                   inObj = obj(oi).(inObjName);
               end
               aliasIdx = min([aliasIdx + 1, size(alias_c, 1)]);
               insert@cTableObject(inObj, tab, '',  [], alias_c(aliasIdx, :), currField,...
                   currFieldVal);
           end
       end
       
       [obj.Sync] = deal(true);
       end
       
       function obj = selectByName(obj, name)
       % selectByName Return first model found in DB with given name
           
       % Input
       validateattributes(name, {'char'}, {'vector'}, 'cModelID', 'name', 2);
       
       % Find name in DB
       if isempty(obj(1).OtherTable)
           
           tab = obj(1).ModelTable;
           col = obj(1).ModelField{1};
       else
           
           tab = obj(1).OtherTable{1};
           col = obj(1).OtherTableIdentifier{1};
       end
       
       % Account for obj whose Name property has different column in DB
       nameCol = 'Name';
       if ~isempty(obj(1).NameAlias)
           
           nameCol = obj(1).NameAlias;
       end
       
       % Select
       where = [nameCol, ' = ', obj(1).SQL.encloseStringQuotes(name)];
       [~, id_tbl] = obj.SQL.select(tab, col, where);
       
       % Error if name not found
       if isempty(id_tbl)
           errid = 'selectModel:NameNotFound';
           errmsg = ['Model named ', name, ' not found in table ', tab];
           error(errid, errmsg)
       end
       
       % Assign id
       id = double(id_tbl{1, 1});
       [obj.Model_ID] = id;
       end
       
       function [varargout] = getModels(obj, varargin)
       % getModels Get model names and id of this type from database
       
       % Input
       where = '';
       if nargin > 1 && ~isempty(varargin{1})
           
           where = varargin{1};
           validateattributes(where, {'char'}, ...
               {'vector'}, 'cModelID.showModels', 'where', 1);
       end
       
       lim = 1000;
       if nargin > 2  && ~isempty(varargin{2})
           
           lim = varargin{2};
           validateattributes(lim, {'numeric'}, ...
               {'positive', 'scalar', 'integer'}, 'cModelID.showModels',...
               'lim', 2);
       end
       
       varargout = cell(1, numel(obj));
       for oi = 1:numel(obj)
           
           tab = obj(oi).ModelTable;
           sql = obj(oi).SQL;
           [~, temp_st] = sql.describe(tab);
           tabCols = temp_st.field;
           cols = intersect(tabCols, [obj(oi).DataProperty, obj(oi).TableIdentifier]);
           [~, modelIDi] = ismember(obj(oi).TableIdentifier, cols);
           if modelIDi == 0
               
               tab = obj(oi).OtherTable{1};
               [~, temp_st] = sql.describe(tab);
               tabCols = temp_st.field;
               cols = intersect(tabCols, obj(oi).DataProperty);
               [~, modelIDi] = ismember(obj(oi).OtherTableIdentifier, cols);
           end
           orderI = 1:numel(cols);
           orderI(modelIDi) = 1;
           orderI(1) = modelIDi;
           cols = cols(orderI);
           [~, currTbl] = sql.select(tab, cols, where, lim);
           if ~isempty(currTbl)
               
               currTbl.Properties.VariableNames{1} = 'Model_ID';
           end
           varargout{oi} = currTbl;
       end
       end
    end
    
    methods(Access = protected, Hidden)

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
        [~, id_c] = obj(1).SQL.execute(sql);
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
            
        if isempty(obj(1).ValueObject)
            
            alias = [repmat({'Model_ID'}, [size(obj(1).ModelField, 2), 1]),...
                obj(1).ModelField'];
        else
            
            aliasL = repmat({'Model_ID'}, [size(obj(1).ModelField, 2), 1]);
            aliasR = cell(numel(obj(1).ValueObject)+1, 1);
            aliasR(1) = obj(1).ModelField(1);
            for vi = 1:numel(obj(1).ValueObject)
                
                currValObj = obj(1).ValueObject{vi};
                currAlias = obj(1).(currValObj).ModelField;
                aliasR(vi+1) = currAlias;
            end
            
            alias = [aliasL, aliasR];
        end
        end
        
        function obj = migrate(obj, db)
        % migrate Migrate model data to new database
        
        % Input
        validateattributes(db, {'char'}, {'vector'}, 'cModelID.migrate',...
            'db', 2);
        
        % Check non-empty
        if isempty(obj)
            
            errid = 'cMID:migrateEmpty';
            errmsg = ['Database migration cannot be performed on empty ',...
                'object cannot be empty'];
            error(errid, errmsg);
        end
        
        for oi = 1:numel(obj)
            
            obji = obj(oi);
            
            % Check non-empty
            if isempty(obji)
                
                continue
            end
            
            % Remove current model id and change database
            obji.Sync = false;
%             obji.Model_ID = [];
            obji.SavedConnection = db;
            obji.Sync = true;
            
            % Insert into new database
            obji.insert;
        end
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
        
        function [obj, inDB, allObj] = select(obj, tab, field, varargin)
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
        
        assignOut_l = true;
        dataObj_c = num2cell(obj);
        if nargin > 5 && ~isempty(varargin{3})
            
            dataObj_c = varargin{3};
            validateattributes(dataObj_c, {'cell'}, {}, ...
                'cModelID.select', 'dataObj_c', 6);
            assignOut_l = false;
        end
        dataObj_c = dataObj_c(:)';
        
        expand_l = [];
        if nargin > 6 && ~isempty(varargin{4})
            
            expand_l = varargin{4};
        end

        additional = {};
        if nargin > 7 && ~isempty(varargin{5})
            
            additional = varargin(5:end);
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
        
        if isempty(alias_c)
            
            alias_c = cell([lenVect_v, 1]);
        elseif size(alias_c, 1) == 1 && lenVect_v ~= 1
            
            alias_c = repmat(alias_c, [lenVect_v, 1]);
        end
        
        allObj = cell(1, numel(dataObj_c));
        for oi = 1:numel(dataObj_c)

            % Index
            currObj = dataObj_c{oi};
            currTab = tab{oi};
            currField = field{oi};

            currAlias_c = alias_c(oi, :);
            midi = mid{oi};
            expand_l = true;
            
            [currObj.Sync] = deal(false);
            [currObj, inDB] = select@cTableObject(currObj, currTab,...
                        currField, '', currAlias_c, midi, expand_l, additional{:});
            [currObj.Sync] = deal(true);

            % Assign
            allObj{oi} = currObj;
        end
        
        % Assign
        if assignOut_l
           
            obj = currObj;
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
                obj(oi) = obj(oi).select(currTab, currIdName, currIdVal,...
                    {currIdName, currIdName});
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
            
                % Get nested objects, if available
                obj2Name_c = obj.ValueObject;
                obj3_c = cellfun(@(x) obj.(x), obj2Name_c, 'Uni', 0)';
                obj2_c = [num2cell(obj); obj3_c];
                
                % Clear object property data before assigning new data
                obj.deleteData(obj3_c);

                % Assign again after data deleted
                obj.Model_ID = mid;
                
                % Check model
                tab = [cellstr(obj.ModelTable), obj.ValueTable];
                field = obj.ModelField;
                alias_c = obj.propertyAlias;

                % Select data matching Model ID value
                [~, ~, obj_c] = obj.select(tab, field, mid, alias_c, obj2_c);
                
                % Assign child objects
                for ci = 1:numel(obj2Name_c)
                    
                    currProp = obj2Name_c{ci};
                    obj.(currProp) = obj_c{ci+1};
                end
            end
        end
    end
    
    methods
        
        function set.Deleted(obj, del)
            
            if isempty(del) && isnumeric(del)
                
                obj.Deleted = del;
                return
            end
            
            if isnumeric(del)
                
                validateattributes(del, {'numeric', 'logical'}, ...
                    {'scalar', 'real', 'integer', '>=', 0, '<=', 1});
                del = logical(del);
            else
                
                validateattributes(del, {'logical'}, {'scalar'});
            end
            obj.Deleted = del;
        end
        
        function set.Sync(obj, sync)
           
            validateattributes(sync, {'logical'}, {'scalar'});
            obj.Sync = sync;
            
        end
    end
end