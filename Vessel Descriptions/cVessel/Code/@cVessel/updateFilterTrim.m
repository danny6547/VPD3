function obj = updateFilterTrim(obj, lowerTrim, upperTrim)
%updateFilterTrim Trim filter based on relative difference range on LBP
%   Detailed explanation goes here

% Inputs
validateattributes(lowerTrim, {'numeric'}, {'scalar', 'real', 'positive'},...
    'updateFilterDisp', 'lowerDiff', 1);
validateattributes(upperTrim, {'numeric'}, {'scalar', 'real', 'positive'},...
    'updateFilterDisp', 'upperDiff', 2);

% Build expression
[~, imo_tbl] = obj.select('tempRawISO', 'DISTINCT(IMO_Vessel_Number)');
imo_v = [imo_tbl{:, :}];
imo_ch = num2str(imo_v);
lower_ch = ['Trim - ' num2str(lowerTrim), ...
    '*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = ', imo_ch, ')'];
upper_ch = ['Trim + ' num2str(upperTrim), ...
    '*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = ', imo_ch, ')'];

[~, expr] = obj.combineSQL('`NearestTrim` < ', lower_ch, ...
                        'OR `NearestTrim` > ', upper_ch);

% Update table with new filter values
tab = 'tempRawISO';
col = 'Filter_SpeedPower_Trim';
obj.update(tab, col, expr);

end