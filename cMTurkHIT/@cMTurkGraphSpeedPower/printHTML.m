function html = printHTML(obj)
%printHTML HTML for HIT
%   Detailed explanation goes here

% Print x-axis limits table
tempObj = cMTurkGraphSpeedPower();
tempObj.ColumnLabels = {'Lowest Value', 'Highest Value'};
tempObj.ColumnNames = {'MinSpeed', 'MaxSpeed'};
tempObj.NumRows = 1;
htmlXAxis = tempObj.printHTMLTable();
htmlImg1 = printHTMLImageInput(1);

% Primt y-axis limits table
tempObj.ColumnLabels = {'Lowest Value', 'Highest Value'};
tempObj.ColumnNames = {'MinPower', 'MaxPower'};
htmlYAxis = tempObj.printHTMLTable();
htmlImg2 = printHTMLImageInput(2);

% Print speed, power tables
htmlSpeedPower_cc = cell(1, obj.NCurves);
obj.NumRows = 25;
for si = 1:obj.NCurves
    
    htmlSpeedPower_cc{si} = obj.printHTMLTable();
end
htmlSpeedPower = [htmlSpeedPower_cc{:}];
htmlImg3 = printHTMLImageInput(3);

% Concatenate output
html = {htmlXAxis;...
        htmlImg1;...
        htmlYAxis;...
        htmlImg2;...
        htmlSpeedPower;...
        htmlImg3};
end