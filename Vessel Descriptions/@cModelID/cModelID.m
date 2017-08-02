classdef cModelID < cMySQL & handle
    %CMODELID Read from database all data for rows matching the model ID
    %   Detailed explanation goes here
    
    properties
        
        ModelID = [];
        Name = '';
    end
    
    properties(Hidden)
        
        DBTable = {'speedpowercoefficients', 'speedpower'};
        FieldName = 'ModelID';
    end
    
    methods
    
       function obj = cModelID(varargin)
           
           % Input
           
           if nargin > 0
               
               sizeVect_v = varargin{1};
%                sizeVect_c = num2cell(sizeVect_v);
               nRows = sizeVect_v(1);
               nCols = sizeVect_v(2);
               class_ch = class(obj);
               obj(nRows, nCols) = eval(class_ch);
%                obj = repmat(obj, sizeVect_v);
           end
           
           
           if nargin > 1
               
               names_c = varargin{2};
               names_c = validateCellStr(names_c, 'cModelID.cModelID', ...
                   'Name', 2);
               
               % Error if number of names doesn't match size of OBJ
               
               [obj.Name] = deal(names_c{:});
           else
               
               % Create new row in database with ModelID
               obj = obj.reserveModelID();
           end
           
       end
       
       function delete(obj)
           
           % Release a reserved row in DB if no other data was input
           obj.releaseModelID();
       end
    end
    
    methods(Access = protected)
        
        function obj = releaseModelID(obj)
        % releaseModelID Remove modelID rows from table when empty
        
        % Determine if table has only written ModelID, not any other data
%         selectIdRows_sql = ['SELECT * FROM ', obj.DBTable, ' WHERE ', ...
%             obj.FieldName ' = ', num2str(obj.ModelID)];
        for oi = 1:numel(obj)
            for ti = 1:numel(obj(oi).DBTable)
                
                [~, tbl] = obj(1).select(obj(oi).DBTable{ti}, {}, [obj(oi).FieldName ' = ', num2str(obj(oi).ModelID)]);
        %         [q, w, tbl] = obj.execute(selectIdRows_sql);
                tblCols_c = tbl.Properties.VariableNames;
                idCols_c = lower([{'id'}, obj(oi).FieldName]);
                idCol_l = ismember(tblCols_c, idCols_c);
                tbl = tbl(:, ~idCol_l);
                nonIdTbl = table2cell(tbl);
                allDataNull_l = all(cellfun(@isnan, nonIdTbl(:)));
                tableModelEmpty_l = size(tbl, 1) == 1 && allDataNull_l;
                
                % Delete ModelID from table
                if tableModelEmpty_l
                    
                    id = num2str(obj(oi).ModelID);
                    sql = ['DELETE FROM ' obj(oi).DBTable{ti} ' WHERE ' obj(oi).FieldName ...
                        ' = ' id];
                    obj(oi).execute(sql);
                end
            end
        end
        end
        
        function obj = modelIDFromName(obj)
        % modelIDFromName Get ModelID corresponding to Name from table
        
        
        end
    end
    
    methods(Access = private)
        
        function obj = reserveModelID(obj)
        % reserveModelID Get unique modelID and write into DB
        
        for oi = 1:numel(obj)
            
            if ~isempty(obj(oi).ModelID)
               continue 
            end
            
            id = nextUniqueID(obj(oi));
            
            for ti = 1:numel(obj(oi).DBTable)
                
                table = obj(oi).DBTable{ti};
                columns = obj(oi).FieldName;
                tab = obj(oi).DBTable{ti};
                obj(oi).ModelID = id;
                
                % Get any default values and concat
    %             [obj, sql, defs] = defaultValues(obj, tab);
                
                obj(oi).insertValues(table, columns, id);
            end
        end
        end
        
        function id = nextUniqueID(obj)
        % nextUniqueID Get the next unique ID in DB
        
        sql = ['SELECT MAX(', obj.FieldName, ')+1 FROM ', obj.DBTable{1}];
        [~, id_c] = obj.execute(sql);
        id_ch = id_c{1};
        id = str2double(id_ch);
        
           % Account for case where table was empty or column was all null
           if isnan(id)
               id = 1;
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
        for ti = 1:numel(obj.DBTable)
            try obj.readFromTable(obj.DBTable{ti}, obj.FieldName);
                
            catch ee
                
                if ~strcmp(ee.identifier, 'readTable:IdentifierDataMissing')
                    rethrow(ee);
                end
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
        
        function obj = set.Name(obj, name)
        % Ensure Name is char vector
        
            % Input
            validateattributes(name, {'char'}, {'vector'}, ...
                'cModelID.Name', 'Name', 1);
            
            % Assign
            obj.Name = name;
        end
    end
end