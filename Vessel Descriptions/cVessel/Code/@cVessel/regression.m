function [obj, regStruct] = regression(obj, order)
%regressions Caluclate regression statistics for performance data.
%   Detailed explanation goes here

% Input
validateattributes(order, {'numeric'}, {'positive', 'integer'}, 'regressions',...
    'order', 2);
regStruct = struct('Coefficients', [], 'Order', [], 'Model', '');
vStruct = struct('DryDockInterval', []);

% Iterate over performance struct
while obj.iterateDD
    
    [currDD_tbl, currObj_cv, ddi, vi] = obj.currentDD;
    x = datenum(currDD_tbl.timestamp);
    y = currDD_tbl.(currObj_cv.Report(ddi).Variable);
    
    nany = isnan(y);
    y(nany) = [];
    x(nany) = [];
    
    currObj_cv.Report(ddi).Regression = regStruct;
    
    for oi = 1:numel(order)
        
        p = polyfit(x, y, order(oi));
        
        % Assign outputs
        vStruct(vi).DryDockInterval(ddi).Order(oi) = regStruct;
        vStruct(vi).DryDockInterval(ddi).Order(oi).Coefficients = p;
        vStruct(vi).DryDockInterval(ddi).Order(oi).Order = order(oi);
        vStruct(vi).DryDockInterval(ddi).Order(oi).Model = 'polynomial';
        currObj_cv.Report(ddi).Regression(oi) = vStruct(vi).DryDockInterval(ddi).Order(oi);
    end
end
end