function [tbl, fails, err] = readVeinlandFile(obj, filename)
%loadVeinland Load data from Veinland XML file
%   Detailed explanation goes here

filename = validateCellStr(filename, 'cVessel.loadVeinland', 'filename', 2);
nFile = numel(filename);

% Create table for Veinland files
[tbl, veinlandNames, veinlandTypes] = obj.veinlandFileTable;
fails = cell(1, nFile);
err = cell(1, nFile);

% tbl_c = cell(1, nFile);
for fi = 1:nFile
    
    currFile = filename{fi};
    
    % Open file and pre-allocate array
    try file_xml = xmlread(currFile);
        
    catch ee
        
        fails(fi) = {currFile};
        err(fi) = {ee};
    end
    report_xml = file_xml.getElementsByTagName('REPROW');
    nRows = report_xml.getLength;

    row_xml = report_xml.item(0).getAttributes;
    names = cell(1, row_xml.getLength);
    for ci = 0:row_xml.getLength - 1
        names(ci+1) = { row_xml.item(ci).getName };
    end
    names = cellfun(@char, names, 'Uni', 0);

    nCols = numel(names);
    out_c = cell(nRows, nCols);

    % Iterate report rows
    for ri = 0:report_xml.getLength - 1

        % Iterate columns
        row_xml = report_xml.item(ri).getAttributes;
        for ci = 0:row_xml.getLength - 1

            out_c(ri+1, ci+1) = { row_xml.item(ci).getValue };
        end
    end
    
    % Index found names into table
    [tblColIdx_l, tblColIdx_v] = ismember(names, veinlandNames);
    
    % Allow for columns found in file, not in spec, for now
    tblColIdx_v(~tblColIdx_l) = [];
    names(~tblColIdx_l) = [];
    out_c(:, ~tblColIdx_l) = [];
    
    % Convert from java to specified MATLAB type
    fileTypes = veinlandTypes(tblColIdx_v);
    charCols_l = ismember(fileTypes, 'char');
    out_c(:, ~charCols_l) = cellfun(@str2double, out_c(:, ~charCols_l), 'Uni', 0);
    out_c(:, charCols_l) = cellfun(@char, out_c(:, charCols_l), 'Uni', 0);
    
%     if any(~tblColIdx_l)
%         
%         % Error
%         errid = 'loadVeinland:NameUnknown';
%         errmsg = ['File ''%s'' contains names not found returned '...
%             'by method variableNames.'];
%         error(errid, errmsg, currFile);
%     end

    warning('off',  'MATLAB:table:RowsAddedExistingVars');
    tbl(end+1:end+nRows, tblColIdx_v) = cell2table(out_c, 'VariableNames',...
        names);
    warning('on',  'MATLAB:table:RowsAddedExistingVars');
end

% Remove empty elements of outputs
% fails(cellfun(@isempty, fails)) = [];
fails = [fails{:}];
% err(isempty(err)) = [];
err = [err{:}];