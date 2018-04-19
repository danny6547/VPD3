function [obj, quart] = lastQuarterAverage(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

quart = struct('Average', [], ...
    'StartDate', [], ...
    'EndDate', []);
% szIn = size(obj);
% szOut = szIn;
% szOut(1) = szOut(1) - 1;
% ddPer = repmat(ddPer, szOut);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);

% Get annual averages after dry-dockings
% [~, annualAvgAft] = movingAverage(obj, 365.25, false);

% Iterate over DD intervals, starting with second
% for ddi = 2:nDDi

while obj.iterateDD
    
    [currTbl, ~, ddi, vi] = obj.currentDD;

    lastDate = max(currTbl.datetime_utc);
    lastDate_dt = datetime(lastDate, 'ConvertFrom', 'datenum');
    lastDateEnd_dt = lastDate_dt - calmonths(3);
    lastDateEnd = datenum(lastDateEnd_dt);
    lastQuarter_l = currTbl.datetime_utc > lastDateEnd;
    lastQuarter_tbl = currTbl(lastQuarter_l, :);
    lastQuarterAvg = nanmean(lastQuarter_tbl.speed_loss)*100;

    quart(vi, ddi).Average = lastQuarterAvg;
    quart(vi, ddi).StartDate = datenum(lastDateEnd_dt);
    quart(vi, ddi).EndDate = datenum(lastDate_dt);

end
end