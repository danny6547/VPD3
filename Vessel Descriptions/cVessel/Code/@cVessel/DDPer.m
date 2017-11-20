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
nDDi = szIn(1);
szOut = szIn;
szOut(1) = szOut(1) - 1;
ddPer = repmat(ddPer, szOut);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);

% Get annual averages after dry-dockings
[~, annualAvgAft] = movingAverages(obj, 365.25, false);

% Iterate over DD intervals, starting with second
for ddi = 2:nDDi

    
    % Take average first year of current DDi
    ddPer(ddi-1).ReferenceAverage = annualAvgAft(ddi-1).Duration(1).Average;
    
    % Take average first year of previous DDi
    ddPer(ddi-1).EvaluationAverage = annualAvgAft(ddi).Duration(1).Average;
    
    % Subtract
    ddPer(ddi-1).DDPerformance = ddPer(ddi-1).EvaluationAverage - ...
        ddPer(ddi-1).ReferenceAverage;
    
    % Durations
    ddPer(ddi-1).ReferenceDuration = ...
        annualAvgAft(ddi-1).Duration(1).EndDate(1) - ...
        annualAvgAft(ddi-1).Duration(1).StartDate(1);
    
    ddPer(ddi-1).EvaluationDuration = ...
        annualAvgAft(ddi).Duration(1).EndDate(1) - ...
        annualAvgAft(ddi).Duration(1).StartDate(1);
end