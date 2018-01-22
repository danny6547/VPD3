function [ obj, ddPer ] = DDPer( obj )
%DDPer Dry-Docking Performance KPI
%   Detailed explanation goes here

% Output
ddPer = struct('DDPerformance', [], ...
    'ReferenceAverage', [], ...
    'EvaluationAverage', [], ...
    'ReferenceDuration', [], ...
    'EvaluationDuration', []);
szIn = size(obj);
szOut = szIn;
szOut(1) = szOut(1) - 1;
ddPer = repmat(ddPer, szOut);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);

% Get annual averages after dry-dockings
[~, annualAvgAft] = movingAverage(obj, 365.25, false);

% Iterate over DD intervals, starting with second
% for ddi = 2:nDDi

while obj.iterateDD
    
    [~, currVessel, ddi, vi] = obj.currentDD;
    
    if ddi < 3
        
        continue
    end
    
    % Take average first year of current DDi
    ddPer(ddi-1).ReferenceAverage = annualAvgAft(vi).DryDockInterval(ddi-1).Average(1);
    
    % Take average first year of previous DDi
    ddPer(ddi-1).EvaluationAverage = annualAvgAft(vi).DryDockInterval(ddi).Average(1);
    
    % Subtract
    ddPer(ddi-1).DDPerformance = ddPer(ddi-1).EvaluationAverage - ...
        ddPer(ddi-1).ReferenceAverage;
    
    % Durations
    ddPer(ddi-1).ReferenceDuration = ...
        annualAvgAft(vi).DryDockInterval(ddi-1).EndDate(1) - ...
        annualAvgAft(vi).DryDockInterval(ddi-1).StartDate(1);
    
    ddPer(ddi-1).EvaluationDuration = ...
        annualAvgAft(vi).DryDockInterval(ddi).EndDate(1) - ...
        annualAvgAft(vi).DryDockInterval(ddi).StartDate(1);
    
    % Assign into obj when all DD done
    if ddi == currVessel.numDDIntervals
        
        currVessel.Report.DryDockingPerformance = ddPer;
    end
end