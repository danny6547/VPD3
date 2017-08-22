function [ obj, filters ] = updateFilters(obj, varargin)
%updateFilters Update values in table filters based on thresholds
%   Detailed explanation goes here

if nargin > 1
    
    p = inputParser();
    p.addParameter('SpeedPower_Lower', [], @isnumeric);
    p.addParameter('SpeedPower_Upper', [], @isnumeric);
%     p.addParameter('SpeedPower_Trim_Width', [], @isnumeric);
%     p.addParameter('SpeedPower_Disp_Width', [], @isnumeric);
    p.addParameter('Reference_Seawater_Temp_Lower', [], @isnumeric);
    p.addParameter('Reference_Wind_Speed_Upper', [], @isnumeric);
    p.addParameter('Reference_Water_Depth_Lower', [], @isnumeric);
    p.addParameter('Reference_Rudder_Angle_Upper', [], @isnumeric);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    filters_st = p.Results;
    lengths_v = structfun(@length, filters_st);
    length_v = unique(lengths_v);
    
    if numel(length_v) > 1
        
        errid = 'ISOFilters:ThresholdSizeMismatch';
        errmsg = 'The size of all input thresholds must be the same';
        error(errid, errmsg);
    end
    
    % If nothing requested, go back to caller
    if length_v == 0
        
        return
    end
    
    % Check input logicals are same length as OBJ
    if length_v ~= numel(obj)
        
        errid = 'ISOFilters:ThresholdObjectSizeMismatch';
        errmsg = 'The number of input thresholds must be the same as that of OBJ';
        error(errid, errmsg);
    end
else
    
    % No Inputs
    errid = 'ISOFilters:InsufficientInput';
    errmsg = 'Threshold values must tbe input. See ''help updateFilters'' for details.';
    error(errid, errmsg);
end

% Generate look-up matrix of values columns for each filter
ref_m = {'SpeedPower_Lower', 'Delivered_Power', '<'...
    'SpeedPower_Upper', 'Delivered_Power', '>'...
%     'SpeedPower_Trim_Width', [], @isnumeric);
%     'SpeedPower_Disp_Width', [], @isnumeric);
    'Reference_Seawater_Temp_Lower', 'Seawater_Temperatue', '<' ...
    'Reference_Wind_Speed_Upper', 'Relative_Wind_Speed', '>' ...
    'Reference_Water_Depth_Lower', 'Water_Depth', '<', ...
    'Reference_Rudder_Angle_Upper', 'Rudder_Angle', '>'};

% Index into current vessel
oi = 1; % obj.CurrIter;
tab = 'Filters';
[obj, whereVessel_sql] = obj.combineSQL('IMO_Vessel_Number =', ...
    num2str(obj(oi).IMO_Vessel_Number), 'AND');

% Iterate over thresholds, 
filters_c = fieldnames(filters_st);
update_c = cell(1, numel(filters_c));
cols_c = cell(1, numel(filters_c));
for fi = 1:numel(filters_c)
    
    currFilter_ch = filters_c{fi};
    currThreshold_v = filters_st.(currFilter_ch);
    if isempty(currThreshold_v)
        
        continue
    end
    
    % Generate update command
    currThreshold = currThreshold_v(oi);
    currCol = strcat('Filter_', currFilter_ch);
    cols_c{fi} = currCol;
    [~, ti] = ismember(currFilter_ch, ref_m(:, 1));
    valueCol = ref_m{ti, 2};
    operator = ref_m{ti, 3};
    [obj, expr_sql] = obj.combine('TRUE WHERE', whereVessel_sql, ...
        valueCol, operator, currThreshold);
    [obj, update_c{fi}] = obj.update(tab, currCol, expr_sql);
end

% Combine update commands and execute
update_c(cellfun(@isempty, update_c)) = [];
cols_c(cellfun(@isempty, cols_c)) = [];
[~, update_sql] = obj.terminateSQL(update_c);
update_c = cellstr(update_sql);
[obj, update_sql] = obj.combineSQL(update_c{:});
obj.execute(update_sql);

% Insert from tempRawISO into Filters
tabFrom = 'tempRawISO';
cols_c = [{'IMO_Vessel_Number', 'DateTime_UTC'}, cols_c];
obj = obj.insertSelectDuplicate(tabFrom, cols_c, tab, cols_c);
filters = cols_c;