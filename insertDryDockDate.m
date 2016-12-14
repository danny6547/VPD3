function [success, message] = insertDryDockDate(imo, startdate, enddate)
%insertDryDockDate Insert row of dry dock dates for ship if not duplicate
%   Detailed explanation goes here

% Output
success = false;
message = '';

% Input
validateattributes(imo, {'numeric'}, {'integer', 'vector'}, ...
    'insertDryDockDate', 'imo', 1);
validateattributes(startdate, {'numeric', 'char'}, {'vector'}, ...
    'insertDryDockDate', 'startdate', 2);
validateattributes(enddate, {'numeric', 'char'}, {'vector'}, ...
    'insertDryDockDate', 'enddate', 3);

% Create strings from numerical inputs
if isnumeric(imo)
    imo_s = num2str(imo(:));
end
sqlDateForm = 'yyyy-mm-dd HH:MM:SS';
if isnumeric(startdate)
    sqlstartdate_s = datestr(startdate, sqlDateForm);
end
if isnumeric(enddate)
    sqlenddate_s = datestr(enddate, sqlDateForm);
end

% Connect to Database
database = 'test2';
conn_ch = ['driver=MySQL ODBC 5.3 ANSI Driver;', ...
    'Server=localhost;',  ...
    'Database=', database, ';',  ...
    'Uid=root;',  ...
    'Pwd=HullPerf2016;'];
sqlConn = adodb_connect(conn_ch);

% Check if dates already in table
sqlselect_f = @(x, y, z) ['SELECT id FROM DryDockDates WHERE '...
            'IMO_Vessel_Number = ', x, ' AND ',...
            'StartDate = ', y, ' AND ',...
            'EndDate = ', z, ';'];
imo_c = cellstr(imo_s);
sqlstartdate_c = cellstr(strcat('''', sqlstartdate_s, ''''));
sqlenddate_c = cellstr(strcat('''', sqlenddate_s, ''''));

sqlRead_c = cellfun(sqlselect_f, imo_c, sqlstartdate_c, sqlenddate_c, ...
    'Uni', 0);
[~, id_c] = cellfun(@(x) adodb_query(sqlConn, x), sqlRead_c, 'Uni', 0);
nonDuplicates_l = cellfun(@(x) isempty(x), id_c);

imo_c = imo_c(nonDuplicates_l);
sqlstartdate_c = sqlstartdate_c(nonDuplicates_l);
sqlenddate_c = sqlenddate_c(nonDuplicates_l);

% Insert dates
if any(nonDuplicates_l)
    sqlinsert_f = @(x, y, z) ['INSERT INTO DryDockDates (IMO_Vessel_Number, ',...
        'StartDate, EndDate) VALUES (' x, ', ', y, ', ', z ');'];
    sqlinsert_c = cellfun(sqlinsert_f, imo_c, sqlstartdate_c, sqlenddate_c, ...
        'Uni', 0);
    cellfun(@(x) adodb_query(sqlConn, x), sqlinsert_c, 'Uni', 0);
    success = true;
end

if all(~nonDuplicates_l)
    message = 'All input values are duplicates.';
elseif any(~nonDuplicates_l)
    idxdup_v = find(~nonDuplicates_l);
    idxdup_s = strjoin(cellstr(num2str(idxdup_v(:))), ', ');
    message = ['Inputs at the following indices are duplicates; ' idxdup_s,...
        '.'];
end

end