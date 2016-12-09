function insertIntoTable(table, columns, data, varargin)
%insertIntoTable Insert data into existing table.
%   Detailed explanation goes here

% Input
columns = validateCellStr(columns, 'insertIntoTable', 'columns', 2);
validateattributes(data, {'cell', 'numeric'}, {'ncols', length(columns), ...
    'nonempty', 'ndims', 2}, 'insertIntoTable', 'data', 3);

formStrInner = repmat('%f ,', [1, size(data, 2)]);
formStrInner(end-2:end) = [];
if nargin > 3
    formStrInner = varargin{1};
    validateattributes(formStrInner, {'char'}, {'vector'}, 'insertIntoTable',...
        'format', 4);
end

% Build string containing values
formatStr = strcat('(', formStrInner, '),\n');
insertValues_s = sprintf(formatStr, data');
insertValues_s(end-1:end) = [];

allColsComma_s = [' (', strjoin(columns, ', '), ') '];

% Build string to insert into table
insertTemp_s = ['INSERT INTO ', table, allColsComma_s 'VALUES '];

% Connect
Server = 'localhost';
Database = 'test2';
Uid = 'root';
Pwd = 'HullPerf2016';
conn_ch = ['driver=MySQL ODBC 5.3 ANSI Driver;', ...
            'Server=' Server ';',  ...
            'Database=', Database, ';',  ...
            'Uid=' Uid ';',  ...
            'Pwd=' Pwd ';'];
conn = adodb_connect(conn_ch);

% Call SQL
insertTempCommand_s = [insertTemp_s, insertValues_s];
adodb_query(conn, insertTempCommand_s);

end