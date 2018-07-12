function [sql, sql_c] = printSQL(obj, varargin)
%printSQL Print SQL statement to insert data into database
%   Detailed explanation goes here

sql_c = {};

file_l = false;
if nargin > 1
    
    filename = varargin{1};
    validateattributes(filename, {'char'}, {'vector'}, ...
        'cMTurkHIT.printSQL', 'filename', 2);
%     [pth, nm, ext] = fileparts(filename);
%     if isempty(pth)
%         
%         filename = fullfile(obj.Directory, obj.ScriptDirectory, [nm, ext]);
%     end
    filename = obj.prependScriptPath(filename);
    file_l = true;
end

insertLimit = obj.InsertLimit;

% Error if filtered data not given
% Remove columns not found database 
tbl = obj.databaseTable;
if isempty(tbl)
    return;
end

% Error if model id not given
name = obj.ModelName;
if isempty(name)
    
    return;
end
id = obj.Model_Id;

% Create matrix of data from table
data_m = table2array(tbl);
id_v = repmat(id, height(tbl), 1);
data_m = [data_m, id_v];

% Split input data by insert limit
nRows = size(data_m, 1);
starti_v = 1:insertLimit:nRows;
endi_v = insertLimit:insertLimit:nRows;
if ~isequal(endi_v(end), nRows)

    endi_v(end+1) = nRows;
end
sql_c = cell(size(starti_v));

% Iterate splits of data and write insert statements
msql = cMySQL();
tab = 'dbo.DisplacementModelValue';
cols = tbl.Properties.VariableNames; 
cols = strrep(cols, 'Draft', 'Draft_Mean');
cols = [cols, {'Displacement_Model_Id'}];
for si = 1:numel(starti_v)
    
    s = starti_v(si);
    e = endi_v(si);
    [~, sql_c{si}] = msql.insertValues(tab, cols, data_m(s:e, :));
end
sql = strjoin(sql_c, '; ');

% Print to file if file name given
if file_l
    
    fid = fopen(filename, 'a+');
    fprintf(fid, '%s\n', sql_c{:});
    fclose(fid);
end