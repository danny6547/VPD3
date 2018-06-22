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
    end
    
    properties(Hidden)
        
        IsGrid;
        DeafaultRowName = 'row_';
        DeafaultColumnName = 'column_';
    end
    
    properties(Constant, Hidden)
        
        TrimName = 'Trim';
        DraftName = 'Draft';
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
end