function obj = isGrid(obj)
%isGrid Is data layout a grid?
%   Detailed explanation goes here

for oi = 1:numel(obj)
    
    % It's a grid if rows or columns have duplicate names
    rows = obj(oi).RowNames;
    cols = obj(oi).ColumnNames;
    if ~isempty(rows) && numel(rows) > numel(unique(rows)) || ...
            ~isempty(cols) && numel(cols) > numel(unique(cols))
        
        obj(oi).IsGrid = true;
    end
end