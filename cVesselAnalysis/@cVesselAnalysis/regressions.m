function [obj, regStruct] = regressions(obj, order)
%regressions Caluclate regression statistics for performance data.
%   Detailed explanation goes here

% Output
regStruct = struct('Coefficients', []);
regStruct = repmat(regStruct, size(obj));

% Input
% validateattributes(obj, {'struct'}, {}, 'regressions', 'obj', 1);
validateattributes(order, {'numeric'}, {'scalar', 'integer'}, 'regressions',...
    'order', 2);

szPer = size(obj);

% Iterate over performance struct
for pi = 1:numel(obj)
    
    currStruct = obj(pi);
    
    if isnan(currStruct.IMO_Vessel_Number)
        continue;
    end
    
    x = currStruct.DateTime_UTC;
    y = currStruct.(currStruct.Variable);
    
    nany = isnan(y);
    y(nany) = [];
    x(nany) = [];
    
    p = polyfit(x, y, order);
    
    % Get output index to assign
%     [r, c] = ind2sub(szPer, pi);
    
    % Assign outputs
    regStruct(pi).Coefficients = p;
    regStruct(pi).Order = order;
    regStruct(pi).Model = 'polynomial';
    obj(pi).Regression = regStruct(pi);
end
end