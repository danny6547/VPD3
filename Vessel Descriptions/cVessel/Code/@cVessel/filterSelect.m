function obj = filterSelect( obj, varargin )
%filterSelect Summary of this function goes here
%   Detailed explanation goes here
    
    % Apply filters
    obj = updateFilters(obj, varargin{:});
    obj = applyFilters(obj, varargin{:});
    
    % Read data with filter applied
    cols_c = {'DateTime_UTC', 'Speed_Loss'};
    [obj, data_tbl] = obj.select('tempRawISO', cols_c, 'Filter_All = TRUE');
    
    % Update object performance data based on filters
    obj = obj.assignPerformanceData(data_tbl);
end