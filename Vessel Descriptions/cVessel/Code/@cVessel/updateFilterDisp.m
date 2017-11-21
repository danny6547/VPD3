function obj = updateFilterDisp(obj, lowerDiff, upperDiff)
%updateFilterDisp Displacement filter based on relative difference range
%   Detailed explanation goes here

% Inputs
validateattributes(lowerDiff, {'numeric'}, {'scalar', 'real', 'positive'},...
    'updateFilterDisp', 'lowerDiff', 1);
validateattributes(upperDiff, {'numeric'}, {'scalar', 'real', 'positive'},...
    'updateFilterDisp', 'upperDiff', 2);

% Build expression
lower_ch = [num2str(lowerDiff), '*Displacement'];
upper_ch = [num2str(upperDiff), '*Displacement'];

[~, expr] = obj.combineSQL('`Nearest_Displacement` < ', lower_ch, ...
                        'OR `Nearest_Displacement` > ', upper_ch);

% Update table with new filter values
tab = 'tempRawISO';
col = 'Filter_SpeedPower_Disp';
obj = obj.update(tab, col, expr);

end