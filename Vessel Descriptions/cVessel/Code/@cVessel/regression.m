function [obj, regStruct] = regression(obj, order)
%regressions Caluclate regression statistics for performance data.
%   Detailed explanation goes here

% Input
validateattributes(order, {'numeric'}, {'positive', 'integer'}, 'regressions',...
    'order', 2);
regStruct = struct('Coefficients', [], 'Order', [], 'Model', '');

% Iterate over performance struct
while obj.iterateDD
    
    [currDD_tbl, currObj_cv, ddi, vi] = obj.currentDD;
    x = datenum(currDD_tbl.timestamp);
    y = currDD_tbl.(currObj_cv.Variable);
    
    nany = isnan(y);
    y(nany) = [];
    x(nany) = [];
    
    currObj_cv.Report(ddi).Regression = regStruct;
    
    for oi = 1:numel(order)
        
        p = polyfit(x, y, order(oi));
        
        % Assign outputs
        regStruct(vi).DryDockInterval(ddi).Order(oi).Coefficients = p;
        regStruct(vi).DryDockInterval(ddi).Order(oi).Order = order(oi);
        regStruct(vi).DryDockInterval(ddi).Order(oi).Model = 'polynomial';
        currObj_cv.Report(ddi).Regression(oi) = regStruct(vi).DryDockInterval(ddi).Order(oi);
    end
end
end