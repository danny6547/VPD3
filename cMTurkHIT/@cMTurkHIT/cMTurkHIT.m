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
        FileData;
        InvalidData;
    end
    
    properties(Constant, Hidden)
        
        TrimName = 'Trim';
        DraftName = 'Draft';
        InputDirectory = 'Input';
        OutputDirectory = 'Output';
    end
    
    properties(Dependent)
        
        CSVFilePath = '';
        FilteredData;
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
        
        function filt = get.FilteredData(obj)
            
            file = obj.FileData;
            invalid = obj.InvalidData;
            
            if obj.IsGrid
                
                filter_l = ismember(file.Draft,  invalid(:, 1)) &...
                    ismember(file.Trim,  invalid(:, 2));
            else
                
                filter_l = ismember(file.Draft,  invalid);
            end
            
            filt = file(~filter_l, :);
        end
        
        function obj = set.InvalidData(obj, invalid)
            
            invalid = unique(invalid, 'rows');
            obj.InvalidData = invalid;
        end
        
    end
end