function [ out ] = performanceData( imo, varargin )
%performanceData Read ship performance data from database, over time range
%   [out] = performanceData(imo) will read all data for the ship
%   identified by numeric vector IMO from the database into output 
%   structure OUT. OUT will have fields Date, PerformanceIndex and 
%   SpeedIndex. The size of OUT will match the size of IMO.
%   [out] = performanceData(imo, ddi) will, in addition to the above,
%   filter the data returned in OUT to that of the dry-dock interval given
%   by DDI, where DDI is a numeric scalar or vector containing only
%   integers. OUT will have as many rows as elements in IMO and as many 
%   columns as elements in DDI. If DDI is zero, all dry-dock intervals will
%   be returned.

% Initialise Outputs
out = struct();

% Inputs
validateattributes(imo, {'numeric'}, {'vector', 'integer', 'positive'},...
    'performanceData', 'IMO', 1);
ddi_l = false;

if nargin > 1
    ddi_l = true;
    ddi = varargin{1};
    validateattributes(ddi, {'numeric'}, {'vector', 'integer', '>=', 0},...
        'performanceData', 'DDi', 2)
end

% Build SQL commands from basic statements
sqlPerformanceDataBase = {'SELECT ', ' FROM test2.PerformanceDataDNVGL'};

% SQL command for Column Names
PerformanceDataColumnsNames_c = {'IMO_Vessel_Number', 'DateTime_UTC',...
    'Performance_Index', 'Speed_Index'};
sqlPerformanceDataColumnsNames = sprintf('`%s`, ', ...
    PerformanceDataColumnsNames_c{:});
sqlPerformanceDataColumnsNames(end-1:end) = [];
PerformanceData_c = [sqlPerformanceDataBase(1), {sqlPerformanceDataColumnsNames}, ...
    sqlPerformanceDataBase(2)];
sqlPerformanceData = [PerformanceData_c{:}];

% SQL command to select only relevant IMO
IMOFilter_c = ' WHERE IMO_Vessel_Number = ';
sqlSingle = sprintf([sqlPerformanceData, IMOFilter_c, '%u\n'], imo);

% Remove trailing "\n"
sqlSingle(end) = [];
sqlMulti_c = strsplit(sqlSingle, '\n');

% Connect to Database
conn = adodb_connect(['driver=MySQL ODBC 5.3 ANSI Driver;',...
    'Server=localhost;',...
    'Database=test2;',...
    'Uid=root;',...
    'Pwd=HullPerf2016;']);

if ddi_l
    
    % Refine by Dry Dock interval
    
    
    % Get all DD dates per IMO
    sqlDDDates = ['SELECT `StartDate`, `EndDate` FROM test2.`DryDockDates` WHERE ',...
        'IMO_Vessel_Number = '];
    sqlDDDatesSingle = sprintf([sqlDDDates, '%u', ' ORDER BY StartDate;\n'], imo);
    sqlDDDatesSingle(end) = [];
    sqlDDDatesMulti = strsplit(sqlDDDatesSingle, '\n');
    
    [~, dddates] = cellfun(@(x) adodb_query(conn, x), sqlDDDatesMulti, 'Uni', 0);
    
    % Replicate statements for each interval
    a = cellfun(@(x) rot90(x'), dddates, 'Uni', 0);
    b = cellfun(@(x) [{'31-12-9999'}, x(:)', ...
        {'01-01-1000'}], a, 'Uni', 0);
    b = cellfun(@(x) cellfun(@(y) ['"' datestr(datenum(y, 'dd-mm-yyyy'),...
        'yyyy-mm-dd') '"'], x, 'Uni', 0), b, 'Uni', 0);
    intervalDates_c = cellfun(@(x, y) reshape(fliplr(x), size(y, 1)+1, 2),...
        b, dddates, 'Uni', 0);
    
    % Remove unwanted Dry-Docking intervals
    if ~isequal(ddi, 0)
        
        numIntervals = cellfun(@(x) size(x, 1), intervalDates_c);
        numIntervals(numIntervals > max(ddi)) = numIntervals;
        numIntervals_c = num2cell(numIntervals);
        
        intervalDates_c = cellfun(@(x, y) x(y, :), intervalDates_c,...
            numIntervals_c, 'Uni', 0);
    end
    
    numShips = numel(imo);
    numDocks = cellfun(@(x) size(x, 1), intervalDates_c, 'Uni', 0);
    maxNumDocks = max([numDocks{:}]);
    e = cellfun(@(x, y) repmat({x}, y, 1), sqlMulti_c, numDocks, 'Uni', 0);
    eprime = cellfun(@(x) [x; cell(maxNumDocks - length(x), 1)], e, 'Uni', 0);
%     r = cat(2, e{:});
    r = cat(2, eprime{:});
%     t = cat(2, intervalDates_c{:});
    
    y = cellfun(@(x) num2cell(x, 2),  intervalDates_c, 'Uni', 0);
    yprime = cellfun(@(x) [x; cell(maxNumDocks - length(x), 1)], y, 'Uni', 0);
%     u = cat(2, y{:});
    u = cat(2, yprime{:});
    
    o = cellfun(@(x, y) [x ' AND DateTime_UTC > ' y{1} ' AND DateTime_UTC < ' y{2}], r, u,...
        'Uni', 0, 'ErrorHandler', @(strct, a, b) (''));
    sqlMulti_c = o;
end

% Execute SQL
[~, w] = cellfun(@(x) adodb_query(conn, x), sqlMulti_c, 'Uni', 0, ...
    'ErrorHandler', @(strct, a) deal('', ''));

% 
s = cellfun(@isempty, w);
if any(s)
    [row,col] = find(~s);
    first = accumarray(col, row, [], @min);
    col_l = first ~= 1;
    starts = first(col_l);
    x = arrayfun(@(x) circshift((1:size(s, 1))', [-x + 1, 0]), starts, 'Uni', 0);
    c = [x{:}]';
    repr = sub2ind(size(s), c, repmat(find(col_l), size(c, 1), size(c, 2)));
    orig = sub2ind(size(s), repmat(1:size(s, 1), size(c, 1), 1), ...
        repmat(find(col_l), size(c, 1), size(c, 2)));
    w(orig) = w(repr);
end

% Assemble outputs into struct
fieldnames_c = strrep(PerformanceDataColumnsNames_c, ' ', '_');

w(cellfun(@isempty, w)) = { num2cell(nan(1, 4)) };

t = cellfun(@(x) num2cell(cell2mat(x(:, 1)), 1), w, 'Uni', 0);
u = cellfun(@(x) { x(:, 2) }, w, 'Uni', 0);
e = cellfun(@(x) num2cell(cell2mat(x(:, 3:4)), 1), w, 'Uni', 0);

d = cellfun(@(x, y, z) [x, y, z], t, u, e, 'Uni', 0);

% SQL syntax ensures each column corresponds to different IMO, so vector of
% IMO can be reduced to scalar
out = cellfun(@(x) cell2struct(x, fieldnames_c, 2), d);
out = arrayfun(@(x, y) setfield(y, 'IMO_Vessel_Number', unique(x.IMO_Vessel_Number)), out, out);

end