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
    
    properties(Constant, Hidden)
        
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
       
       function insertIntoTable(obj, varargin)
       % insertIntoTable
       
%        % Assign model table parameters
%        tab = obj(1).ModelTable;
%        cols = {'ModelID', 'Name', 'Type'};
        
       for oi = 1:numel(obj)
       
           % All models must be named
           if isempty(obj(oi).Name)

              errid = 'cMN:NameMissing';
              errmsg = 'Model name cannot be empty';
              error(errid, errmsg);
           end
%            % Delete pre-existing model data
%            where_sql = ['ModelID = ', num2str(obj.ModelID)];
%            obj(oi).delete(tab, where_sql);
          
           tables = obj(oi).DBTable;
           for ti = 1:numel(tables)
               
               % Insert into "data table"
               tab = tables{ti};
               insertIntoTable@cMySQL(obj(oi), tab, varargin{:});
           end
           
%            % Insert into "model table"
%            obj = obj.insertIntoModels();
%            vals = {obj(oi).ModelID, obj(oi).Name, obj(oi).Type};
%            obj(oi).insertValuesDuplicate(tab, cols, vals);
       end
       end
       
       function length = maxNameLength(obj)
           
           show_sql = ['SHOW COLUMNS FROM ', obj.ModelTable, ...
               ' WHERE Field = ''Name'''];
           show_t = obj.execute(show_sql);
           type_ch = show_t.type;
           length_i = regexp(type_ch, '[^varchar()]');
           length = str2double(type_ch(length_i));
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
    
    methods(Access = protected, Hidden)
        
        function obj = releaseModelID(obj)
        % releaseModelID Remove modelID rows from table when empty
        
        % Determine if table has only written ModelID, not any other data
%         selectIdRows_sql = ['SELECT * FROM ', obj.DBTable, ' WHERE ', ...
%             obj.FieldName ' = ', num2str(obj.ModelID)];
        table = obj(1).ModelTable;
        for oi = 1:numel(obj)
            
            nameEmpty_l = isempty(obj(oi).Name);
            
            if ~nameEmpty_l
                
                where_sql = ['Name = ', ...
                    cMySQL.encloseStringQuotes(obj(oi).Name)];
                obj(oi).deleteSQL(table, where_sql);
            end
            
%             for ti = 1:numel(obj(oi).DBTable)
%                 
% %                 [~, tbl] = obj(1).select(obj(oi).DBTable{ti}, {}, [obj(oi).FieldName ' = ', num2str(obj(oi).ModelID)]);
% %         %         [q, w, tbl] = obj.execute(selectIdRows_sql);
% %                 tblCols_c = tbl.Properties.VariableNames;
% %                 idCols_c = lower([{'id'}, obj(oi).FieldName]);
% %                 idCol_l = ismember(tblCols_c, idCols_c);
% %                 tbl = tbl(:, ~idCol_l);
% %                 nonIdTbl = table2cell(tbl);
% %                 allDataNull_l = all(cellfun(@isnan, nonIdTbl(:)));
% %                 tableModelEmpty_l = size(tbl, 1) == 1 && allDataNull_l;
%                 
%                 % Delete ModelID from table
% %                 if tableModelEmpty_l
%                 if nameEmpty_l
%                     
%                     id = num2str(obj(oi).ModelID);
%                     sql = ['DELETE FROM ' obj(oi).DBTable{ti} ' WHERE '...
%                         obj(oi).FieldName ' = ' id];
%                     obj(oi).execute(sql);
%                 end
%             end
        end
        end
        
        function [obj, id] = idFromName(obj, name)
        % modelIDFromName Get ModelID corresponding to Name from table
        
            % Select ID based on type
            tab = obj.ModelTable;
            col = obj.FieldName;
            where_sql = ['Type = ''', obj.Type, ''' AND Name = ''', name, ''''];
            [obj, tbl] = obj.select(tab, col, where_sql);
            
            % Error if not found
            if isempty(tbl)
                
                errid = 'cMN:NameNotFound';
                errmsg = ['Model id cannot be returned because the given '...
                    'name was not found.'];
                error(errid, errmsg);
            else
                
%                 obj = obj.releaseModelID();
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
        
        function obj = insertIntoModels(obj, name)
           
           tab = obj(1).ModelTable;
           cols = {'Name', 'Type'};
           
           for oi = 1:numel(obj)
               
               [~, mid_t] = obj.select(tab, 'MAX(ModelID)');
               redundnatModelID = [mid_t{:, :}] + 1;
               vals = {redundnatModelID, name, obj(oi).Type};
               obj(oi).insertValuesDuplicate(tab, [{'ModelID'}, cols], vals);
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
    
    methods(Access = protected, Hidden)
        
        function obj = reserveModelName(obj, name)
        % reserveModelID Get unique modelID and write into DB
        
%         for oi = 1:numel(obj)
            
%             if ~isempty(obj(oi).Name)
%                continue 
%             end
            
%             id = nextUniqueID(obj(oi));
            
%             for ti = 1:numel(obj(oi).DBTable)
%                 
%                 table = obj(oi).DBTable{ti};
%                 columns = obj(oi).FieldName;
%                 tab = obj(oi).DBTable{ti};
%                 obj(oi).ModelID = id;
%                 
%                 % Get any default values and concat
%     %             [obj, sql, defs] = defaultValues(obj, tab);
%                 obj(oi).insertValues(table, columns, id);
%             end
            
            obj = obj.insertIntoModels(name);


%         end
        end
        
%         function id = nextUniqueID(obj)
%         % nextUniqueID Get the next unique ID in DB
%         
%         sql = ['SELECT MAX(', obj.FieldName, ')+1 FROM ', obj.DBTable{1}];
%         [~, id_c] = obj.execute(sql);
%         id_ch = id_c{1};
%         id = str2double(id_ch);
%         
%            % Account for case where table was empty or column was all null
%            if isnan(id)
%                id = 1;
%            end
%         end
    end
    
    methods
        
%         function obj = set.ModelID(obj, modelID)
%         % set.ModelID Update values with those from DB
%         
%         % Check integer scalar
%         validateattributes(modelID, {'numeric'}, ...
%             {'scalar', 'integer', 'real'}, ...
%             'cModelID.set.ModelID', 'modelID', 1);
%         
%         % If value unchanged, do nothing
%         if isequal(modelID, obj.ModelID)
%             return
%         end
%         
%         % If current modelID in DB, check if it should be released
%         if ~isempty(obj.ModelID)
%             obj = obj.releaseModelID;
%         end
%         
%         % Assign
%         obj.ModelID = modelID;
%         
%         % If ModelID already in DB, read data out
%         for ti = 1:numel(obj.DBTable)
%             try [obj, diff_l] = obj.readFromTable(obj.DBTable{ti}, obj.FieldName);
%                 
%             catch ee
%                 
%                 if ~strcmp(ee.identifier, 'readTable:IdentifierDataMissing')
%                     rethrow(ee);
%                 end
%             end
%         end
%         
% %         % Issure warnings if different to existing data
% %         if any(different_l)
% %             
% %             obj.warnAboutOverwrite();
% %         end
%         
%         % Read Name from Models table
%         modelID_ch = num2str(modelID, '%u');
%         type_ch = ['''', obj.Type, ''''];
%         where_sql = ['ModelID = ', modelID_ch, ' AND Type = ', type_ch];
%         [~, tbl] = obj.select('Models', 'Name', where_sql);
%         if ~isempty(tbl)
%             
%             name = tbl.name{1};
%             obj.Name = name;
%         end
%         
%         end
        
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
            
            % Error if too long
            maxlength = obj.maxNameLength;
            if numel(name) > maxlength
                
                errid = 'cMN:NameTooLong';
                errmsg = ['Length of property ''Name'' cannot exceed the '...
                    'limit of field ''Name'' in DB table ''Models'', i.e. ',...
                    num2str(maxlength), ' characters.'];
                error(errid, errmsg);
            end
            
            % Read out data, if model already in DB
%             type_ch = ['''', obj.Type, ''''];
            where_sql = ['Name = ', obj.encloseStringQuotes(name), ...
                ' AND Type = ', obj.encloseStringQuotes(obj.Type)];
            [~, tbl] = obj.select('Models', 'Name', where_sql);
            modelInDB_l = ~isempty(tbl);
            if modelInDB_l
                
                % Get corresponding modelID and assign
                [~, ID] = obj.idFromName(name);
                obj.ModelID = ID;
                
                % If Model already in DB, read data out
                for ti = 1:numel(obj.DBTable)
                    try obj = obj.readFromTable(obj.DBTable{ti},...
                            obj.FieldName);
                        
                    catch ee
                        
                        if ~strcmp(ee.identifier, 'readTable:IdentifierDataMissing')
                            rethrow(ee);
                        end
                    end
                end
                
            else
                
                % If model not in DB, reserve Name in Model table
                obj = obj.reserveModelName(name);
                
                % Get corresponding modelID and assign
                [~, ID] = obj.idFromName(name);
                obj.ModelID = ID;

            end
            
            % Assign to OBJ
            obj.Name = name;
        end
    end
end