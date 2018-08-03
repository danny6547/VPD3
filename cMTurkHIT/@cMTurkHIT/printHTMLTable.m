function table_c = printHTMLTable(obj)
%printHTMLTable Print HTML tags representing rows and columns of table
%   Detailed explanation goes here

% Make rows with input fields
if ~isempty(obj.RowNames)
    
    names = obj.RowNames;
    if ~isempty(obj.NumColumns)

        nCol = obj.NumColumns;
        nRow = numel(names);
        nameDim = 1;
        datalength = nCol;
    else

        errid = 'MakeTable:NeedNumCols';
        errmsg = ['To find the number of columns either property ColumnNames or'...
            ' NumColumns must be given'];
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
        
        errid = 'MakeTable:NeedNumRows';
        errmsg = ['To find the number of rows either property ColumnNames or '...
            'NumColumns must be given'];
        error(errid, errmsg);
    end
end

% Assign into Names
obj.Names = names;

% Create basic table cell
cell_ch = '<td align="center"><input id="INPUTID" name="INPUTNAME" size="10" type="text"/></td>';

% Input names
[inName_c, edge_c] = obj.inputName(names, datalength, nameDim);

% Write inputId
nCells = numel(inName_c);
startId = obj.StartInputId;
endId = startId + nCells - 1;
obj.EndInputId = endId;
inputId_m = reshape(startId:endId, size(inName_c));
inputId_c = arrayfun(@num2str, inputId_m, 'Uni', 0);
cell_c = cellfun(@(x) strrep(cell_ch, 'INPUTID', x), inputId_c, 'Uni', 0);
cell_c = cellfun(@(x, y) strrep(x, 'INPUTNAME', y), cell_c, inName_c,...
    'Uni', 0);

% Combine edge and names
% Create empty column/row
dataDim = find(1:2 ~= nameDim);
if ~isempty(edge_c)
    
    edge_ch = '<td align="center"></td>';
    if isrow(edge_c)
        edgeSz = [1, numel(names)];
    else
        edgeSz = [numel(names), 1];
    end
    edgeHtml_c = repmat({edge_ch}, edgeSz);

    % Assign edge vector
    edge_l = ismember(names, obj.CoordinateName2);
    edgeHtml_c(edge_l) = {'<td align="center"><input id="INPUTID" name="INPUTNAME" size="10" type="text"/></td>'};
    edgeHtml_c(~edge_l) = {'<td align="center"></td>'};
    edgeHtml_c(edge_l) = cellfun(@(x, y) strrep(x, 'INPUTNAME', y), ...
        edgeHtml_c(edge_l), edge_c, 'Uni', 0);

    % Append to left/top side
    cell_c = cat(dataDim, edgeHtml_c, cell_c);
end

% Assign labels
colLabels = obj.ColumnLabels;
tabHeader_ch = '<th align="center">HEADER</th>';
% labelRow_c = {};
if ~isempty(colLabels)
    
    labelRow_c = cellfun(@(x) strrep(tabHeader_ch, 'HEADER', x), colLabels, 'Uni', 0);
    cell_c = [labelRow_c; cell_c];
end
rowLabels = obj.RowLabels;
% labelCol_c = {};
if ~isempty(rowLabels)
    
    labelCol_c = cellfun(@(x) strrep(tabHeader_ch, 'HEADER', x), rowLabels, 'Uni', 0);
    labelCol_c = labelCol_c(:);
    cell_c = [labelCol_c, cell_c];
end
% cell_c = cat(nameDim, labelRow_c, cell_c);
% cell_c = cat(dataDim, labelCol_c, cell_c);

% Assign row values if any given
if ~isempty(obj.RowValues)
    
    rowVal_c = cell_c(:, 1);
    startIdx_c = regexp(rowVal_c, '(<input id=){1,1}', 'start');
    endIdx_c = regexp(rowVal_c, '(/>){1,1}', 'end');
    dataCell_l = ~cellfun(@isempty, startIdx_c) & ~cellfun(@isempty, endIdx_c);
    
    % Check number of row values matches number of data rows
    if ~isequal(sum(dataCell_l), numel(obj.RowValues))
        
        errid = 'ReplaceRows:SizeMismatch';
        errmsg = ['To print values into the first column of each row, '...
            'the number of elements of property ''RowValues'' must match '...
            'the number of rows in the table.'];
        error(errid, errmsg);
    end
    val_c = arrayfun(@num2str, obj.RowValues(:), 'Uni', 0);
    val_c = obj.text(val_c);
    val_c = val_c(:);
    
    % Replace current rows with new rows
    rowVal_c = rowVal_c(dataCell_l);
    startIdx_c = startIdx_c(dataCell_l);
    endIdx_c = endIdx_c(dataCell_l);
    rowVal_c = cellfun(@(x, si, ei, y) strrep(x, x(si:ei), y), ...
        rowVal_c, startIdx_c, endIdx_c, val_c, 'Uni', 0);
    
    cell_c(dataCell_l, 1) = rowVal_c;
end

% Define rows
rowOpen_c = repmat({'<tr>'}, size(cell_c, 1), 1);
rowClose_c = repmat({'</tr>'}, size(cell_c, 1), 1);
cell_c = [rowOpen_c, cell_c, rowClose_c]';
cell_c = cell_c(:);
[header, footer] = obj.printHTMLTableHeaderFooter;
table_c = [{header}; cell_c; {footer}];

% Create page input
if ~isempty(obj.PageName) && ~isempty(obj.PageLabel)
    
    cell_ch = '<td align="center"><input id="INPUTID" name="INPUTNAME" size="10" type="text"/></td>';
    inputIdPage = max(inputId_m(:)) + 1;
    cell_ch = strrep(cell_ch, 'INPUTID', num2str(inputIdPage));
    cell_ch = strrep(cell_ch, 'INPUTNAME', obj.PageName);
    pageHeader_ch = ['<th align="center">', obj.PageLabel ,'</th>'];
    pageHeaderRight_ch = '';
    if ~isempty(obj.PageLabelRight)
        pageHeaderRight_ch = ['<th align="center">', obj.PageLabelRight ,'</th>'];
    end
    pageTable_c = {pageHeader_ch, cell_ch, pageHeaderRight_ch};
    
    rowOpen_c = {'<tr>'};
    rowClose_c = {'</tr>'};
    page_c = [rowOpen_c, pageTable_c, rowClose_c];
    page_c = [{header}, page_c, {footer}];
    table_c = [page_c'; table_c];
end