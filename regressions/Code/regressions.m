function [regStruct] = regressions(perStruct, order)
%regressions Caluclate regression statistics for performance data.
%   Detailed explanation goes here

% Output
regStruct = struct('Coefficients', []);

% Input
validateattributes(perStruct, {'struct'}, {}, 'regressions', 'perStruct', 1);
validateattributes(order, {'numeric'}, {'scalar', 'integer'}, 'regressions',...
    'order', 2);

regStruct = repmat(regStruct, size(perStruct));

szPer = size(perStruct);

% Iterate over performance struct
for pi = 1:numel(perStruct)
    
    currStruct = perStruct(pi);
    
    if isnan(currStruct.IMO_Vessel_Number)
        continue;
    end
    
    x = datenum(currStruct.DateTime_UTC, 'dd-mm-yyyy');
    y = currStruct.Performance_Index;
    
    nany = isnan(y);
    y(nany) = [];
    x(nany) = [];
    
    p = polyfit(x, y, order);
    
    % Get output index to assign
    [r, c] = ind2sub(szPer, pi);
    regStruct(r, c).Coefficients = p;
    
end
end