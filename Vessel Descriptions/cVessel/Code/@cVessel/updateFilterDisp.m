function obj = updateFilterDisp(obj, lowerDiff, upperDiff)
%updateFilterDisp Displacement filter based on relative difference range
%   updateFilterDisp(obj, lowerDiff, upperDiff) updates the values for 
%   filter column 'Filter_SpeedPower_Disp' to TRUE when the displacement of
%   the nearest speed, power curve is less than LOWERDIFF times the current
%   displacement or greater than UPPERDIFF times the current displacement,
%   and FALSE otherwise. LOWERDIFF and UPPERDIFF are positive, numeric
%   scalars.

% Inputs
validateattributes(lowerDiff, {'numeric'}, {'scalar', 'real', 'positive'},...
    'updateFilterDisp', 'lowerDiff', 1);
validateattributes(upperDiff, {'numeric'}, {'scalar', 'real', 'positive'},...
    'updateFilterDisp', 'upperDiff', 2);

% Build expression
lower_ch = ['1-' num2str(lowerDiff), '*Displacement'];
upper_ch = ['1+' num2str(upperDiff), '*Displacement'];

[~, expr] = obj.combineSQL('`Nearest_Displacement` < ', lower_ch, ...
                        'OR `Nearest_Displacement` > ', upper_ch);

% Update table with new filter values
tab = 'tempRawISO';
col = 'Filter_SpeedPower_Disp';
obj = obj.update(tab, col, expr);

end