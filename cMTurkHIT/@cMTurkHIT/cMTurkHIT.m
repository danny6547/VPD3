classdef cMTurkHIT
    %CMTURKHIT Numeric data from image/document with Mechanical Turk
    %   Detailed explanation goes here
    
    properties
        
        Directory = '';
        ColumnLabels = '';
        RowLabels = '';
        ColumnNames = '';
        RowNames = '';
        NumColumns;
        NumRows;
        ImageURL = '';
        Instructions = {''};
        ModelName = '';
    end
    
    properties(Hidden)
        
        IsGrid;
        DeafaultRowName = 'row_';
        DeafaultColumnName = 'column_';
        CSVFileName = 'Input';
        OutFileName = '';
        FileData;
        InvalidData;
        FilteredData;
        InsertLimit = 1000;
        NaNFilter;
    end
    
    properties(Constant, Hidden)
        
        TrimName = 'Trim';
        DraftName = 'Draft';
        InputDirectory = 'Input';
        OutputDirectory = 'Output';
        ScriptDirectory = 'Script';
    end
    
    properties(Dependent, Hidden)
        
        CSVFilePath = '';
        Model_Id;
    end
    
    methods
    
       function obj = cMTurkHIT(varargin)
       
           if nargin == 0
               
               return
           end
       end
    end
    
    methods(Static, Hidden)
        
        [header, footer] = printHTMLTableHeaderFooter()
    end
    
    methods(Hidden)
        
        [obj, imageDir] = imageDir(obj)
        [files] = imageFiles(obj)
        [obj, tbl] = results(obj, varargin)
        [sql, sql_c] = printSQL(obj, varargin)
        obj = insertIntoDatabase(obj)
        [obj, nan_l] = nanFilter(obj)
        html = copyHTML(obj)
        html = printHTML(obj)
        table_c = printHTMLTable(obj)
        obj = printCSV(obj)
        sql = copySQL(obj)
        copyHTMLTable(obj)
        html = printInstructions(obj)
        obj = isGrid(obj)
        filename = outName(obj)
        prepareOutputFile(obj)
        html = print(obj)
        [inName, varargout] = inputName(obj, name, datalength, nameDim)
    end
    
    methods
        
        function obj = set.ImageURL(obj, img)
        
            img = validateCellStr(img);
            img = char(img);
            obj.ImageURL = img;
        end
        
        function path = get.CSVFilePath(obj)
            
            dirPath = obj.Directory;
            inputDirName = obj.InputDirectory;
            name = obj.CSVFileName;
            path = fullfile(dirPath, inputDirName, name);
            path = [path, '.csv'];
        end
        
        function obj = set.Instructions(obj, ins)
            
            ins = validateCellStr(ins);
            obj.Instructions = ins;
        end
        
        function filt = get.FilteredData(obj)
            
            file = obj.FileData;
            
            % Get invalid filter
            [obj, invalid_l] = obj.invalidFilter();
            
            % Get nan filter
            [~, nan_l] = obj.nanFilter;
            filter_l = invalid_l | nan_l;
            
            % Apply filters
            filt = file(~filter_l, :);
        end
        
        function obj = set.InvalidData(obj, invalid)
            
            invalid = unique(invalid, 'rows');
            obj.InvalidData = invalid;
        end
        
        function obj = set.InsertLimit(obj, lim)
            
            validateattributes(lim, {'numeric'}, ...
                {'real', 'scalar', 'positive'});
            obj.InsertLimit = lim;
        end
        
        function obj = set.ModelName(obj, name)
            
            % Check name is string
            validateattributes(name, {'char'}, {'vector'});
            
            % Check name is in database
            tsql = cTSQL('SavedConnection', 'hullperformance');
            where_sql = ['Name = ', tsql.encloseStringQuotes(name)];
            id_tbl = tsql.select('DisplacementModel', 'COUNT(*)',...
                where_sql);
            if isempty(id_tbl)
                
                errid = 'SetName:NameNotFound';
                errmsg = ['ModelName must be an existing DisplacementModel '...
                    'name in database'];
                error(errid, errmsg);
            end
            
            % Assign
            obj.ModelName = name;
        end
        
        function id = get.Model_Id(obj)
            
            % If name empty, return empty model
            id = [];
            name = obj.ModelName;
            if isempty(name)
                return
            end
            
            % Get model id from name
            tsql = cTSQL('SavedConnection', 'hullperformance');
            where_sql = ['Name = ', tsql.encloseStringQuotes(name)];
            [~, id_tbl] = tsql.select('DisplacementModel', 'Displacement_Model_Id',...
                where_sql);
            id = [id_tbl{:, :}];
            id = double(id);
        end
        
%         function obj = set.RowNames(obj, names)
%             
%             names = obj.validateNames(names);
%             obj.RowNames = names;
%         end
    end
end