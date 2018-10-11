function html = printHTML(obj)
%printHTML HTML for HIT
%   Detailed explanation goes here

% Print Instructions
htmlIns = obj.printInstructions();

% Print speed, power tables
htmlSpeedPower_cc = cell(1, obj.NCurve);
allLabels = obj.ColumnLabels;
odd_v = 1:2:obj.NCurve*2;
tempObjArray = cell(1, obj.NCurve);
startInputId = 1;
for si = 1:obj.NCurve
    
    currCols = odd_v(si):odd_v(si)+1;
    currLabels = allLabels(:, currCols);
    currName = obj.CurveName{si};
    
    tempObj = cMTurkGraphSpeedPower();
    colNames = genvarname(strcat({'Speed', 'Power'}, '_', currName));
    tempObj.ColumnNames = colNames;
    tempObj.CoordinateName1 = colNames{1};
    tempObj.ColumnLabels = currLabels;
%     tempObj.NumRows = obj.NumRows;
    tempObj.StartInputId = startInputId;
    tempObj.RowValues = obj.RowValues;
    htmlSpeedPower_cc{si} = tempObj.printHTMLTable();
    tempObjArray{si} = tempObj;
    startInputId = tempObj.EndInputId + 1;
end
obj.CurveObj = [tempObjArray{:}];
obj.ColumnLabels = allLabels;
htmlSpeedPower = [htmlSpeedPower_cc{:}];
htmlSpeedPower = htmlSpeedPower(:);
htmlImg1 = obj.printHTMLImageInput(1);
htmlGraph = [htmlImg1; htmlSpeedPower];
htmlGraph = obj.encloseDiv(htmlGraph);

% Print x-axis limits table
speedRangeObj = cMTurkGraphSpeedPower();
speedRangeObj.ColumnNames = {obj.MinSpeedName, obj.MaxSpeedName};
speedRangeObj.CoordinateName1 = obj.MinSpeedName;
speedRangeObj.ColumnLabels = {'Lowest Value', 'Highest Value'};
speedRangeObj.NumRows = 1;
speedRangeObj.StartInputId = tempObj.EndInputId + 1;
obj.CurveObj = [obj.CurveObj, speedRangeObj];
htmlXAxis = speedRangeObj.printHTMLTable();
htmlImg2 = obj.printHTMLImageInput(2);
% htmlXAxis = encloseDiv(htmlXAxis, 'left');
htmlX = [htmlImg2; htmlXAxis];
htmlX = obj.encloseDiv(htmlX);

% Primt y-axis limits table
powerRangeObj = cMTurkGraphSpeedPower();
powerRangeObj.ColumnNames = {obj.MinPowerName, obj.MaxPowerName};
powerRangeObj.CoordinateName1 = obj.MinPowerName;
powerRangeObj.ColumnLabels = {'Lowest Value', 'Highest Value'};
powerRangeObj.NumRows = 1;
powerRangeObj.StartInputId = speedRangeObj.EndInputId + 1;
obj.CurveObj = [obj.CurveObj, powerRangeObj];
htmlYAxis = powerRangeObj.printHTMLTable();
htmlImg3 = obj.printHTMLImageInput(3);
% htmlYAxis = encloseDiv(htmlYAxis, 'left');
htmlY = [htmlImg3; htmlYAxis];
htmlY = obj.encloseDiv(htmlY);

% Concatenate output
html = {htmlIns;...
        htmlX;...
        htmlGraph;...
        htmlY};
html = cellfun(@(x) x(:)', html, 'Uni', 0);
html = [html{:}]';

[html] = concatTemplateHTML(obj, html);
end