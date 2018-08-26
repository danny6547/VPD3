function [obj, regStruct] = regression(obj, order)
%regressions Caluclate regression statistics for performance data.
%   Detailed explanation goes here

% Input
validateattributes(order, {'numeric'}, {'positive', 'integer'}, 'regressions',...
    'order', 2);

% Iterate over performance struct
while obj.iterateDD
    
    [currDD_tbl, currObj_cv, ddi] = obj.currentDD;
    x = datenum(currDD_tbl.datetime_utc);
    y = currDD_tbl.(currObj_cv.Variable);
    
    nany = isnan(y);
    y(nany) = [];
    x(nany) = [];
    
    for oi = 1:numel(order)
        
        p = polyfit(x, y, order(oi));
        
        % Assign outputs
        regStruct.Coefficients = p;
        regStruct.Order = order(oi);
        regStruct.Model = 'polynomial';
        currObj_cv.Report.Regression(ddi).Order(oi) = regStruct;
    end
end
end