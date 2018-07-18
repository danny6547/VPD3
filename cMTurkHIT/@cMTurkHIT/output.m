function [obj, sql] = output(obj)
%output Operations required to process output from mTurk API
%   Detailed explanation goes here

% Parse results
obj = obj.results();

% Write SQL insert statement
sql = obj.printSQL('Insert.sql');

% Write data to file
obj.printData('HydTable.csv', true);
end