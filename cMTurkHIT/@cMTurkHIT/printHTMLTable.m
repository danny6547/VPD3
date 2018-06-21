function table_c = printHTMLTable(obj)
%printHTMLTable Print HTML tags representing rows and columns of table
%   Detailed explanation goes here

% Make header row with column labels, if any given
colLabels = obj.ColumnLabels;
tabHeaderRow_c = {};
if ~isempty(colLabels)
    
    tabHeader_ch = '<td align="center">HEADER</td>';
    % tabHeader_c = repmat({tabHeader_ch}, length(headers), 1);
    tabHeader_c = cellfun(@(x) strrep(tabHeader_ch, 'HEADER', x), colLabels, 'Uni', 0);
    tabHeaderRow_c = [{'<tr>'}, tabHeader_c, {'</tr>'}];
end

% Make rows with input fields
if ~isempty(obj.RowNames)
    
    names = obj.RowNames;
    if ~isempty(obj.NumColumns)

        nCol = obj.NumColumns;
        nRow = numel(names);
        nameDim = 1;
        datalength = nCol;
    else

        errid = 'MakeTable:NeedNumRows';
        errmsg = ['To find the number of rows either property RowNames or '...
            'NumRows must be given'];
        error(errid, errmsg);
    end
end

if ~isempty(obj.ColumnNames)
    
    names = obj.ColumnNames;
    if ~isempty(obj.NumRows)
        
        nRow = obj.NumRows;
        nCol = numel(obj.NumColumns);
        nameDim = 2;
        datalength = nRow;
    else
        
        errid = 'MakeTable:NeedNumCols';
        errmsg = ['To find the number of columns either property ColumnNames or'...
            ' NumColumns must be given'];
        error(errid, errmsg);
    end
end

% Create basic table cell
cell_ch = '<td align="center"><input id="INPUTID" name="INPUTNAME" size="25" type="text"/>';

% Write inputId
nCells = nRows*nCols;
inputId_m = reshape(1:nCells, nRows, nCols);
inputId_c = arrayfun(@num2str, inputId_m, 'Uni', 0);
cell_c = cellfun(@(x) strrep(cell_ch, 'INPUTID', x), inputId_c, 'Uni', 0);

% Determine if grid
obj = obj.isGrid;

% Write input names
if obj.IsGrid
    
    % Input names are combinations of grid row and column indices
%     rowNames = obj.RowNames;
    inName_c = obj.inputName(names, datalength, nameDim);
else
    
    % Input names are columns concatenated with index
    inName_c = obj.inputName(colLabels, datalength, nameDim);
end

cell_c = cellfun(@(x, y) strrep(x, 'INPUTNAME', y), cell_c, inName_c,...
    'Uni', 0);

% Concatenate
table_c = [tabHeaderRow_c; cell_c];
[header, footer] = obj.printHTMLTableHeaderFooter;
table_c = [header; table_c; footer];
end