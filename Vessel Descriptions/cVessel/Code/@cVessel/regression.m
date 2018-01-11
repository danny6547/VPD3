function [obj, regStruct] = regression(obj, order)
%regressions Caluclate regression statistics for performance data.
%   Detailed explanation goes here

% Output
% regStruct = struct('Coefficients', [], 'Order', [], 'Model', 'polynomial');
% regStruct = repmat(regStruct, size(obj));

% Input
% validateattributes(obj, {'struct'}, {}, 'regressions', 'obj', 1);
validateattributes(order, {'numeric'}, {'positive', 'integer'}, 'regressions',...
    'order', 2);

% szPer = size(obj);

% Iterate over performance struct
% while ~obj.iterFinished
while obj.iterateDD
% for pi = 1:numel(obj)
    
    [currDD_tbl, currObj_cv, ddi] = obj.currentDD;
    
%     [obj, ii] = obj.iter;
%     currStruct = obj(ii);
    
    if isnan(currObj_cv.IMO_Vessel_Number)
        continue;
    end
    
    x = currDD_tbl.DateTime_UTC;
    y = currDD_tbl.(currObj_cv.Variable);
    
%     x = currStruct.DateTime_UTC;
%     y = currStruct.(currStruct.Variable);
    
    nany = isnan(y);
    y(nany) = [];
    x(nany) = [];
    
    for oi = 1:numel(order)
        
        p = polyfit(x, y, order(oi));

        % Get output index to assign
    %     [r, c] = ind2sub(szPer, pi);

        % Assign outputs
        regStruct.Coefficients = p;
        regStruct.Order = order(oi);
        regStruct.Model = 'polynomial';
        currObj_cv.Regression(ddi).Order(oi) = regStruct;
    end
end
% obj = obj.iterReset;
end