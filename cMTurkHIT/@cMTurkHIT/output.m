function [obj, sql] = output(obj, varargin)
%output Operations required to process output from mTurk API
%   Detailed explanation goes here

% Input
ui = true;
if nargin > 1
    
    ui = varargin{1};
    validateattributes(ui, {'logical'}, {'scalar'}, ...
        'cMTurkHIT.output', 'ui', 2);
end

% Parse results
obj = obj.results();

% Filter
if ui
    
    obj = obj.plotFilter;
end

% Write SQL insert statement
sql = obj.printSQL('Insert.sql');

% Write data to file
obj.printData('HydTable.csv', true);
end