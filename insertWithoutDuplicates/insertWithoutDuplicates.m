function [ varargout ] = insertWithoutDuplicates(data, toTable, key, uniqueColumns, otherColumns, varargin)
%insertWithoutDuplicates Remove duplicates, insert without duplicates.
%   Detailed explanation goes here

% Input
validateattributes(data, {'char', 'numeric', 'cell'}, {}, ...
    'insertWithoutDuplicates', 'fromTable', 1);
validateattributes(key, {'char'}, {'vector'}, 'insertWithoutDuplicates', ...
    'key', 3);
uniqueColumns = validateCellStr(uniqueColumns, ...
    'insertWithoutDuplicates', 'uniqueColumns', 4);
otherColumns = validateCellStr(otherColumns, ...
    'insertWithoutDuplicates', 'otherColumns', 5);

format_c = {};
if nargin > 5
    
    format_c =  varargin(1) ;
    validateattributes(varargin{1}, {'char'}, {'vector'}, ...
        'insertWithoutDuplicates', 'format', 6);
end

callSQL = true;
if nargout > 0
    
    callSQL = false;
end

fromTable = 'tempTable';
createTable_l = true;
if ischar(data)
    
    fromTable = data;
    createTable_l = false;
end

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

% Create fromTable if doesn't exist
% dropTable_s = 'DROP TABLE IF EXISTS tempSPC';
% adodb_query(conn, dropTable_s);
% createTemp_s = 'CREATE TABLE tempSPC LIKE speedPowerCoefficients';
% adodb_query(conn, createTemp_s);
% insertTemp_s = ['INSERT INTO tempSPC (IMO_Vessel_Number,Displacement,Trim,'...
%     'Exponent_A,Exponent_B,R_Squared) VALUES '];

% insertValues_s = sprintf('(%u, %f, %f, %f, %f, %f),\n', ...
%     [uniImoDispTrim(:, 1), uniImoDispTrim(:, 2), uniImoDispTrim(:, 3), fo, R2]');
% insertValues_s(end-1:end) = [];
% insertTempCommand_s = [insertTemp_s, insertValues_s];
% adodb_query(conn, insertTempCommand_s);

uniqueColumns = uniqueColumns(:)';
otherColumns = otherColumns(:)';
allCols_c = unique([uniqueColumns, otherColumns]);
allColsComma_s = strjoin(allCols_c, ', ');

% Remove duplicates in from table
removeDuplicates_s = ['DELETE FROM ' fromTable ' WHERE ' key ' NOT IN (SELECT cid FROM '...
    '(SELECT MIN(' key ') AS cid FROM ' fromTable ' GROUP BY ' allColsComma_s ') AS c);'];

% Transfer from table to table
whereEquals_c = strcat('aa.', uniqueColumns, ' = bb.', uniqueColumns);
whereCond_s = ['WHERE ', strjoin(whereEquals_c, ' AND ')];

insertWithout_s = ['INSERT INTO ' toTable ' (' allColsComma_s ')'...
    ' SELECT ' allColsComma_s ...
        ' FROM ' fromTable ' as aa'...
            ' WHERE NOT EXISTS(Select ' allColsComma_s ' FROM ' toTable ' as bb '...
                whereCond_s, ...
                ');' ];

% Call SQL if requested
if callSQL
    
    if createTable_l
        
        dropIfTemp_s = 'DROP TABLE IF EXISTS tempTable';
        adodb_query(conn, dropIfTemp_s);
        createTemp_s = ['CREATE TABLE tempTable LIKE ' toTable];
        adodb_query(conn, createTemp_s);
        if isnumeric(data)
            data = num2cell(data);
        end
        insertIntoTable('tempTable', [uniqueColumns, otherColumns], data, format_c{:});
    end
    
    adodb_query(conn, removeDuplicates_s);
    adodb_query(conn, insertWithout_s);
    
    if createTable_l
        
        dropTemp_s = 'DROP TABLE tempTable';
        adodb_query(conn, dropTemp_s); 
    end
end
conn.release;

% Assign outputs
varargout{1} = removeDuplicates_s;
varargout{2} = insertWithout_s;

end