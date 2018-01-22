classdef (Abstract) cModelName < cMySQL & handle
    %CMODELID Read from database all data for rows matching the model ID
    %   Detailed explanation goes here
    
    properties
        
        Name = '';
        Description = '';
    end
    
    properties(Hidden, Constant, Abstract)
        
        DBTable;
        Type;
    end
    
    properties(Constant, Hidden)
        
        FieldName = 'Models_id';
        ModelTable = 'Models'; 
    end
    
    properties(Dependent)
        
        Models_id = [];
    end
    
    methods
    
       function obj = cModelName(varargin)
           
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
               names_c = validateCellStr(names_c, 'cModelName.cModelName', ...
                   'Name', 2);
               
               [obj.Name] = deal(names_c{:});
           end
       end
       
       function delete(obj)
       % delete Delete object and remove any reserved models from DB
           
       % Check object is not empty
       if isempty(obj.Name)

           return
       end
           
       % Iterate over DB tables and check if model missing from any
       where_sql = [obj.FieldName, ' = ', num2str(obj.Models_id)];
       ti = 1;
       while ti <= numel(obj.DBTable)

           currTab = obj.DBTable{ti};
           [~, dataTbl] = obj.select(currTab, '*', where_sql);
           if isempty(dataTbl)

               % Release a reserved row in DB if no other data was input
               obj.releaseModelID();

               return
           end
           ti = ti + 1;
       end
       end
       
       function insertIntoTable(obj, varargin)
       % insertIntoTable Insert object data into specified DB tables
       
       for oi = 1:numel(obj)
       
           % All models must be named
           if isempty(obj(oi).Name)

              errid = 'cMN:NameMissing';
              errmsg = 'Model name cannot be empty';
              error(errid, errmsg);
           end
           
           tables = obj(oi).DBTable;
           for ti = 1:numel(tables)
               
               % Insert into "data table"
               tab = tables{ti};
               insertIntoTable@cMySQL(obj(oi), tab, varargin{:});
           end
       end
       end
      
    end
    
    methods(Access = protected, Hidden)
        
        function obj = releaseModelID(obj)
        % releaseModelID Remove modelID rows from table when empty
        
        table = obj(1).ModelTable;
        for oi = 1:numel(obj)
            
            where_sql = ['Name = ', ...
                cMySQL.encloseStringQuotes(obj(oi).Name)];
            obj(oi).deleteSQL(table, where_sql);
        end
        end
        
        function [obj, id] = idFromName(obj, name)
        % modelIDFromName Get Models_id corresponding to Name from table
        
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
                
                id = [tbl{:, :}];
            end
        end
        
        function obj = insertIntoModels(obj, name)
        % insertIntoModels Insert model into DB table 'Models'
           
           tab = obj(1).ModelTable;
           cols = {'Name', 'Type'};
           
           for oi = 1:numel(obj)
               
               % Get current highest model id
               [~, mid_t] = obj.select(tab, ['MAX(', obj(oi).FieldName, ')']);
               currMaxModel = [mid_t{:, :}];
               
               % If NaN, no models created yet
               if isnan(currMaxModel)
                   
                   currMaxModel = 0;
               end
               
               % Get next unique model id
               redundnatModelID = currMaxModel + 1;
               
               % Write into table
               vals = {redundnatModelID, name, obj(oi).Type};
               obj(oi).insertValuesDuplicate(tab, [{obj.FieldName}, cols], vals);
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
        % reserveModelID Create entry for model in DB without writing data
        
            obj = obj.insertIntoModels(name);
        end
    end
    
    methods(Hidden)
       
       function length = maxNameLength(obj)
       % maxNameLength Maximum length of model Name allowed by DB
           
           show_sql = ['SHOW COLUMNS FROM ', obj.ModelTable, ...
               ' WHERE Field = ''Name'''];
           show_t = obj.execute(show_sql);
           type_ch = show_t.type;
           length_i = regexp(type_ch, '[^varchar()]');
           length = str2double(type_ch(length_i));
       end
       
       function length = maxDescriptionLength(obj)
       % maxNameLength Maximum length of model Description allowed by DB
           
           show_sql = ['SHOW COLUMNS FROM ', obj.ModelTable, ...
               ' WHERE Field = ''Description'''];
           show_t = obj.execute(show_sql);
           type_ch = show_t.type;
           length_i = regexp(type_ch, '[^varchar()]');
           length = str2double(type_ch(length_i));
       end
    end
    
    methods
        
        function set.Name(obj, name)
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
            where_sql = ['Name = ', obj.encloseStringQuotes(name), ...
                ' AND Type = ', obj.encloseStringQuotes(obj.Type)];
            [~, tbl] = obj.select('Models', 'Name', where_sql);
            modelInDB_l = ~isempty(tbl);
            
            % Assign now so that Models_id can be read out later
            obj.Name = name;
            
            if modelInDB_l
                
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
                obj.reserveModelName(name);
            end
            
        end
        
        function mid = get.Models_id(obj)
        % Get method for depenedent property Models_id
            
            name = obj.Name;
            if isempty(name)
                mid = [];
            else
                [~, mid] = obj.idFromName(name);
            end
        end
        
        function set.Models_id(~, ~)
            
            msg = 'Property ''Models_id'' cannot be assigned to.';
            error('cMN:ModelIDReadOnly', msg)
        end
        
        function set.Description(obj, desc)
            
            validateattributes(desc, {'char'}, {'vector'}, ...
               'cModelName.set.Description');
           
            % Error if too long
            maxlength = obj.maxDescriptionLength;
            if numel(desc) > maxlength
                
                errid = 'cMN:NameTooLong';
                errmsg = ['Length of property ''Description'' cannot exceed the '...
                    'limit of field ''Description'' in DB table ''Models'', i.e. ',...
                    num2str(maxlength), ' characters.'];
                error(errid, errmsg);
            end
            
            obj.Description = desc;
        end
    end
end