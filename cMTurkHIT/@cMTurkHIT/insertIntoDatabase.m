function obj = insertIntoDatabase(obj)
%insertIntoDatabase Insert data into database
%   Detailed explanation goes here

% Get SQL
[~, sql_c] = obj.printSQL;

% Connect to database
tsql = cTSQL('SavedConnection', 'hullperformance');

% Execute
for si = 1:numel(sql_c)
    
    tsql.execute(sql_c{si});
end