function tbl = readVeinlandFile(obj, filename)
%loadVeinland Load data from Veinland XML file
%   Detailed explanation goes here

filename = validateCellStr(filename, 'cVessel.loadVeinland', 'filename', 2);
% validateattributes(filename, {'char'},{'vector'},...
%     'cVessel.loadVeinland', 'filename', 2);
nFile = numel(filename);

% Create table for Veinland files
veinlandNames = obj.variableNames;
tbl = cell2table(cell(0, numel(veinlandNames)), 'VariableNames', veinlandNames);

% tbl_c = cell(1, nFile);
for fi = 1:nFile

    currFile = filename{fi};
    
    % Open file and pre-allocate array
    file_xml = xmlread(currFile);
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

    % Convert to table
    charNames_c = {...
        'fld_upd'
        'wind_reference'
        'wind_speed_unit'
        'true_wind_speed_unit'
        'report_date'
        'report_time'
        'wind_speed_unit'
        'true_wind_speed_unit'
        'position_lat'
        'position_long'
        };
    charCols_l = ismember(names, charNames_c);
    out_c(:, ~charCols_l) = cellfun(@str2double, out_c(:, ~charCols_l), 'Uni', 0);
    out_c(:, charCols_l) = cellfun(@char, out_c(:, charCols_l), 'Uni', 0);
    
    % Index found names into table
    [tblColIdx_l, tblColIdx_v] = ismember(names, veinlandNames);
    if any(~tblColIdx_l)
        
        % Error
        errid = 'loadVeinland:NameUnknown';
        errmsg = ['File ', currFile, ' contains names not found returned '...
            'by method variableNames'];
        error(errid, errmsg);
    end
    tbl(end+1:end+nRows, tblColIdx_v) = cell2table(out_c, 'VariableNames', names);
%     names = genvarname(names);
%     tbl_c{fi} = cell2table(out_c, 'VariableNames', names);
end
% tbl = vertcat(tbl_c{:});