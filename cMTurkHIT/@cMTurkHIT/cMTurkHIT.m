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
    end
    
    properties(Hidden)
        
        IsGrid;
        DeafaultRowName = 'row_';
        DeafaultColumnName = 'column_';
        CSVFileName = 'Input';
        OutFileName = '';
    end
    
    properties(Constant, Hidden)
        
        TrimName = 'Trim';
        DraftName = 'Draft';
        InputDirectory = 'Input';
        OutputDirectory = 'Output';
    end
    
    properties(Dependent)
        
        CSVFilePath = '';
    end
    
    methods
    
       function obj = cMTurkHIT(varargin)
       
           if nargin == 0
               
               return
           end
       end
    end
    
    methods(Static)
        
        [header, footer] = printHTMLTableHeaderFooter()
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
    end
end