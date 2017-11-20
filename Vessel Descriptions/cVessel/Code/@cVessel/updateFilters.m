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
%     lengths_v = structfun(@length, filters_st);
    values_c = struct2cell(filters_st);
    fieldsInput_l = ~ismember(p.Parameters, p.UsingDefaults);
    lengths_v = cellfun(@length, values_c(fieldsInput_l));
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
    errmsg = 'Threshold values must be input. See ''help updateFilters'' for details.';
    error(errid, errmsg);
end

% Generate look-up matrix of values columns for each filter
ref_m = {'SpeedPower_Lower', 'Corrected_Power', '<'; ...
    'SpeedPower_Upper', 'Corrected_Power', '>';...
%     'SpeedPower_Trim_Width', [], @isnumeric);
%     'SpeedPower_Disp_Width', [], @isnumeric);
    'Reference_Seawater_Temp_Lower', 'Seawater_Temperature', '<';...
    'Reference_Wind_Speed_Upper', 'Relative_Wind_Speed', '>';...
    'Reference_Water_Depth_Lower', 'Water_Depth', '<';...
    'Reference_Rudder_Angle_Upper', 'Rudder_Angle', '>'};

% Index into current vessel
oi = 1; % obj.CurrIter;
tab = 'tempRawISO';
[obj, whereVessel_sql] = obj.combineSQL('IMO_Vessel_Number =', ...
    num2str(obj(oi).IMO_Vessel_Number), 'AND');

% Iterate over thresholds, 
filters_c = fieldnames(filters_st);
updateTrue_c = cell(1, numel(filters_c));
updateFalse_c = cell(1, numel(filters_c));
cols_c = cell(1, numel(filters_c));
for fi = 1:numel(filters_c)
    
    currFilter_ch = filters_c{fi};
    currThreshold_v = filters_st.(currFilter_ch);
    if isempty(currThreshold_v)
        
        continue
    end
    
    % Generate update command
    currThreshold = currThreshold_v(oi);
    currThreshold_ch = num2str(currThreshold);
    if ~isempty(findstr(currFilter_ch, 'SpeedPower'))
        
        if ~isempty(findstr(currFilter_ch, 'Lower'))
            
            repStr = '_Below';
        else
            
            repStr = '_Above';
        end
            
    else
        
        repStr = '';
    end
    
    currFilterSQL_ch = strrep(currFilter_ch, '_Upper', repStr);
    currFilterSQL_ch = strrep(currFilterSQL_ch, '_Lower', repStr);
    currCol = strcat('Filter_', currFilterSQL_ch);
    cols_c{fi} = currCol;
    [~, ti] = ismember(currFilter_ch, ref_m(:, 1));
    valueCol = ref_m{ti, 2};
    operator = ref_m{ti, 3};
    [obj, exprTrue_sql] = obj.combineSQL('TRUE WHERE', whereVessel_sql, ...
        valueCol, operator, currThreshold_ch);
    [obj, updateTrue_c{fi}] = obj.update(tab, currCol, exprTrue_sql);
    
    [obj, exprFalse_sql] = obj.combineSQL('FALSE WHERE ', whereVessel_sql, ...
        'NOT (', valueCol, operator, currThreshold_ch, ')');
    [obj, updateFalse_c{fi}] = obj.update(tab, currCol, exprFalse_sql);
end

% Combine update commands and execute
update_c = [updateTrue_c, updateFalse_c];
update_c(cellfun(@isempty, update_c)) = [];
cols_c(cellfun(@isempty, cols_c)) = [];
[~, update_sql] = obj.terminateSQL(update_c);
update_c = cellstr(update_sql);

% [obj, update_sql] = obj.combineSQL(update_c{:});
for fi = 1:numel(update_c)
    
    obj.execute(update_c{fi});
end

% % Insert from tempRawISO into Filters
% tabFrom = 'tempRawISO';
% cols_c = [{'IMO_Vessel_Number', 'DateTime_UTC'}, cols_c];
% obj = obj.insertSelectDuplicate(tabFrom, cols_c, tab, cols_c);
% filters = cols_c;

% % Create update call to set any NULL values to FALSE
% for fi = 1:numel(cols_c)
%     
%     currCol = cols_c{fi};
%     [~, expr_sql] = obj.combineSQL('FALSE WHERE ', currCol, 'IS NULL');
%     obj = obj.update(tab, currCol, expr_sql);
% end