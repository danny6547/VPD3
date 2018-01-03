classdef (Abstract) cModelName < cMySQL & handle
    %CMODELID Read from database all data for rows matching the model ID
    %   Detailed explanation goes here
    
    properties
        
        ModelID = [];
        Name = '';
    end
    
    properties(Hidden, Constant, Abstract)
        
        DBTable;
        FieldName;
        Type;
    end
    
    properties(Constant)
        
        ModelTable = 'Models'; 
    end
    
    properties(Hidden)
        
        Synched = true;
    end
    
    methods
    
       function obj = cModelID(varargin)
           
           % Input
           
           if nargin > 0
               
               sizeVect_v = varargin{1};
               nRows = sizeVect_v(1);
               nCols = sizeVect_v(2);
               class_ch = class(obj);
               obj(nRows, nCols) = eval(class_ch);
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
       
       function insertIntoTable(obj, tab, varargin)
       % insertIntoTable
       
%        % Assign model table parameters
%        tab = obj(1).ModelTable;
%        cols = {'ModelID', 'Name', 'Type'};
       
       for oi = 1:numel(obj)
       
           % All models must be named
           if isempty(obj(oi).Name)

              errid = 'mID:NameMissing';
              errmsg = 'Model name cannot be empty';
              error(errid, errmsg);
           end
           
%            % Delete pre-existing model data
%            where_sql = ['ModelID = ', num2str(obj.ModelID)];
%            tab = obj(ii).DBTable{ti};
%            obj(oi).delete(tab, where_sql);
           
           % Insert into "data table"
           insertIntoTable@cMySQL(obj(oi), tab, varargin{:});
           
           % Insert into "model table"
           obj = obj.insertIntoModels();
%            vals = {obj(oi).ModelID, obj(oi).Name, obj(oi).Type};
%            obj(oi).insertValuesDuplicate(tab, cols, vals);
       end
       end
       
%        function obj = readFromTable(obj, varargin)
%        % readFromTable
%        
%        for oi = 1:numel(obj)
%        
%            % Check modelID before
%            oldModel = obj(oi).ModelID;
%            
%            % Read from table
%            obj = readFromTable@cMySQL(obj, varargin{:});
%            
%            % Release if new model
%            newModel = obj(oi).ModelID;
%            if ~isequal(oldModel, newModel)
%            
%                obj(oi) = obj(oi).releaseModelID;
%            end
%        end
%        end
    end
    
    methods(Access = protected)
        
        function obj = releaseModelID(obj)
        % releaseModelID Remove modelID rows from table when empty
        
        % Determine if table has only written ModelID, not any other data
%         selectIdRows_sql = ['SELECT * FROM ', obj.DBTable, ' WHERE ', ...
%             obj.FieldName ' = ', num2str(obj.ModelID)];
        for oi = 1:numel(obj)
            
            nameEmpty_l = isempty(obj(oi).Name);
            
            for ti = 1:numel(obj(oi).DBTable)
                
%                 [~, tbl] = obj(1).select(obj(oi).DBTable{ti}, {}, [obj(oi).FieldName ' = ', num2str(obj(oi).ModelID)]);
%         %         [q, w, tbl] = obj.execute(selectIdRows_sql);
%                 tblCols_c = tbl.Properties.VariableNames;
%                 idCols_c = lower([{'id'}, obj(oi).FieldName]);
%                 idCol_l = ismember(tblCols_c, idCols_c);
%                 tbl = tbl(:, ~idCol_l);
%                 nonIdTbl = table2cell(tbl);
%                 allDataNull_l = all(cellfun(@isnan, nonIdTbl(:)));
%                 tableModelEmpty_l = size(tbl, 1) == 1 && allDataNull_l;
                
                % Delete ModelID from table
%                 if tableModelEmpty_l
                if nameEmpty_l
                    
                    id = num2str(obj(oi).ModelID);
                    sql = ['DELETE FROM ' obj(oi).DBTable{ti} ' WHERE '...
                        obj(oi).FieldName ' = ' id];
                    obj(oi).execute(sql);
                end
            end
        end
        end
        
        function [obj, id] = idFromName(obj, name)
        % modelIDFromName Get ModelID corresponding to Name from table
        
            % Select ID based on type
            tab = obj.ModelTable;
            col = obj.FieldName;
            where_sql = ['Type = ''', obj.Type, ''' AND Name = ''', name, ''''];
            [obj, tbl] = obj.select(tab, col, where_sql);
            
            % Reserve this modelID 
            if isempty(tbl)
                
                obj = obj.reserveModelID();
                id = obj.ModelID;
                
            else
                
                obj = obj.releaseModelID();
                id = [tbl{:, :}];
            end
        end
        
        function [obj, name] = nameFromID(obj, id)
        % modelIDFromName Get ModelID corresponding to Name from table
        
            % Select ID based on type
            tab = obj.ModelTable;
            col = obj.FieldName;
            where_sql = ['Type = ', obj.Type, ' AND ModelID = ', id];
            [obj, ~, tbl] = obj.select(tab, col, where_sql);
            name = [tbl{:}];
            
            % Reserve this modelID 
            obj.Name = name;
%             if isempty(name)
%                 
%                 obj = obj.reserveModelID();
%                 id = obj.ModelID;
%             end
        end
        
        function obj = insertIntoModels(obj)
            
           tab = obj(1).ModelTable;
           cols = {'ModelID', 'Name', 'Type'};
           
           for oi = 1:numel(obj)
               
               vals = {obj(oi).ModelID, obj(oi).Name, obj(oi).Type};
               obj(oi).insertValuesDuplicate(tab, cols, vals);
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
            try [obj, diff_l] = obj.readFromTable(obj.DBTable{ti}, obj.FieldName);
                
            catch ee
                
                if ~strcmp(ee.identifier, 'readTable:IdentifierDataMissing')
                    rethrow(ee);
                end
            end
        end
        
%         % Issure warnings if different to existing data
%         if any(different_l)
%             
%             obj.warnAboutOverwrite();
%         end
        
        % Read Name from Models table
        modelID_ch = num2str(modelID, '%u');
        type_ch = ['''', obj.Type, ''''];
        where_sql = ['ModelID = ', modelID_ch, ' AND Type = ', type_ch];
        [~, tbl] = obj.select('Models', 'Name', where_sql);
        if ~isempty(tbl)
            
            name = tbl.name{1};
            obj.Name = name;
        end
        
        end
        
%         function obj = set.FieldName(obj, fie)
%             
%             validateattributes(fie, {'char'}, {'vector', 'row'});
%             obj.FieldName = fie;
%             
%         end
%         
%         function obj = set.DBTable(obj, tab)
%             
%             validateattributes(tab, {'char'}, {'vector', 'row'});
%             obj.DBTable = tab;
%             
%         end
%         
        function obj = set.Name(obj, name)
        % Ensure Name is char vector
        
            % Input
            validateattributes(name, {'char'}, {}, ...
                'cModelID.Name', 'Name', 1);
            
            % Get corresponding modelID
            [~, id] = obj.idFromName(name);
            
            % Assign
            obj.Name = name;
            obj.ModelID = id;
        end
    end
end