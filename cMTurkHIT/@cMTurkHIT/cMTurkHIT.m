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
        PageName = '';
        PageValue = [];
        PageLabel = '';
        PageLabelRight = '';
        DataFunc = {};
    end
    
    properties(Hidden)
        
        IsGrid;
        FileData;
        InvalidData;
        FilteredData;
        InsertLimit = 1000;
        NaNFilter;
        DeafaultRowName = 'row_';
        DeafaultColumnName = 'column_';
        CSVFileName = 'Input';
        TemplateSite = 'Transcription From Image';
        nDraft;
        nTrim;
%         OutFileName = '';
    end
    
    properties(Constant, Hidden)
        
        TrimName = 'Trim';
        DraftName = 'Draft';
        InputDirectory = 'Input';
        OutputDirectory = 'Output';
        ScriptDirectory = 'Script';
        ImageDirectory = 'Images';
    end
    
    properties(Dependent, Hidden)
        
        CSVFilePath = '';
        Model_Id;
    end
    
    methods
    
       function obj = cMTurkHIT(varargin)
       
           obj = obj.defaultInstructions;
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
        obj = isGrid(obj, names)
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
        
        function obj = set.DataFunc(obj, funccell)
            
            validateattributes(funccell, {'cell'}, {'ncols', 2});
            
            errid = 'MTurkDataFunc:FuncFormatIncorrect';
            errmsg = ['Property ''DataFunc'' must have a cell array whose '...
                'first column contains only strings and whose second '...
                'column contains only function handles'];
            
            err_f = @(errStruct, inputs) error(errid, errmsg);
            cellfun(@(x) validateattributes(x, {'char'},...
                {'vector'}), funccell(:, 1), 'ErrorHandler', err_f);
            cellfun(@(x) validateattributes(x, {'function_handle'},...
                {'scalar'}), funccell(:, 2), 'ErrorHandler', err_f);
            
            obj.DataFunc = funccell;
        end
    end
end