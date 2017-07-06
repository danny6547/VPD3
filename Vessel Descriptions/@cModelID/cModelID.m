classdef cModelID < cMySQL
    %CMODELID Read from database all data for rows matching the model ID
    %   Detailed explanation goes here
    
    properties
        
        ModelID = [];
        Direction = [];
        Coefficient = [];
    end
    
    properties(Hidden)
        
        DBTable = 'WindCoefficientDirection';
        FieldName = 'ModelID';
    end
    
    methods
    
       function obj = cModelID()
           
           % Create new row in database with ModelID
           obj = obj.reserveModelID();
       end
       
       function obj = delete(obj)
           
           % Release a reserved row in DB if no other data was input
           obj = obj.releaseModelID();
       end
       
    end
    
    methods(Access = private)
        
        function obj = reserveModelID(obj)
        % reserveModelID Get unique modelID and write into DB
            
            table = obj.DBTable;
            columns = obj.FieldName;
            id = nextUniqueID(obj);
            obj.ModelID = id;
            
            % Get any default values and concat
            [obj, sql, defs] = defaultValues(obj, tab, varargin);
            
            obj.insertValues(table, columns, id);
        end
        
        function id = nextUniqueID(obj)
        % nextUniqueID Get the next unique ID in DB
        
        sql = ['SELECT MAX(', obj.FieldName, ')+1 FROM ', obj.DBTable];
        [~, id_c] = obj.execute(sql);
        id_ch = id_c{1};
        id = str2double(id_ch);
            
        end
        
        function obj = releaseModelID(obj)
        % releaseModelID Remove modelID rows from table when empty
        
        % Determine if table has only written ModelID, not any other data
        selectIdRows_sql = ['SELECT * FROM ', obj.DBTable, ' WHERE ', ...
            obj.FieldName ' = ', num2str(obj.ModelID)];
        [~, ~, tbl] = obj.execute(selectIdRows_sql);
        tblCols_c = tbl.Properties.VariableNames;
        idCol_l = ismember(tblCols_c, obj.FieldName);
        tbl = tbl(:, ~idCol_l);
        nonIdTbl = table2cell(tbl);
        allDataNull_l = all(cellfun(@isnan, nonIdTbl(:)));
        tableModelEmpty_l = size(tbl, 1) == 1 && allDataNull_l;
        
        % Delete ModelID from table
        if tableModelEmpty_l
            
            id = num2str(obj.ModelID);
            sql = ['DELETE FROM ' obj.DBTable ' WHERE ' obj.FieldName ...
                ' = ' id];
            obj.execute(sql);
        end
        
        end
    end
    
    methods
        
        function obj = set.ModelID(obj, modelID)
        % set.ModelID Update values with those from DB
        
        % Check integer scalar
        validateattributes(modelID, {'numeric'}, ...
            {'scalar', 'integer', 'real'}, ...
            'cModelID.set.ModelID', 'modelID', 1);
        
        % If value unchanged, do nothing
        if isequal(modelID, obj.ModelID)
            return
        end
        
        % If current modelID in DB, check if it should be released
        if ~isempty(obj.ModelID)
            obj = obj.releaseModelID;
        end
        
        % Assign
        obj.ModelID = modelID;
        
        % If ModelID already in DB, read data out
        try obj.readFromTable(obj.DBTable, obj.FieldName);
            
        catch ee
            
            if ~strcmp(ee.identifier, 'readTable:IdentifierDataMissing')
                rethrow(ee);
            end
        end
        end
        
        function obj = set.FieldName(obj, fie)
            
            validateattributes(fie, {'char'}, {'vector', 'row'});
            obj.FieldName = fie;
            
        end
        
        function obj = set.DBTable(obj, tab)
            
            validateattributes(tab, {'char'}, {'vector', 'row'});
            obj.DBTable = tab;
            
        end
    end
end