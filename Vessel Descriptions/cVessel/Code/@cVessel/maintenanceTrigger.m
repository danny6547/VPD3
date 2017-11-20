function [ obj, maintrig ] = maintenanceTrigger( obj )
%maintenanceTrigger Maintenance Trigger KPI
%   Detailed explanation goes here

% Output
maintrig = struct('MaintenanceTrigger', [], ...
    'ReferenceAverage', [], ...
    'EvaluationAverage', [], ...
    'ReferenceDuration', [], ...
    'EvaluationDuration', []);
szIn = size(obj);
nDDi = szIn(1);
maintrig = repmat(maintrig, szIn);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);

% Get annual averages after dry-dockings
months3 = (365.25 * 3)/12;
[~, annualAvgRef] = movingAverages(obj, months3, true);
[~, months3AvgEvl] = movingAverages(obj, months3, true);

% Iterate over DD intervals, starting with second
for ddi = 1:nDDi
    
    % Take average first year of current DDi
    maintrig(ddi).ReferenceAverage = annualAvgRef(ddi).Duration(1).Average(1);
    
    % Take average first year of previous DDi
    maintrig(ddi).EvaluationAverage = months3AvgEvl(ddi).Duration(1).Average(end);
    
    % Subtract
    maintrig(ddi).MaintenanceTrigger = maintrig(ddi).EvaluationAverage - ...
        maintrig(ddi).ReferenceAverage;
    
    % Durations
    maintrig(ddi).ReferenceDuration = ...
        annualAvgRef(ddi).Duration(1).EndDate(1) - ...
        annualAvgRef(ddi).Duration(1).StartDate(1);
    
    maintrig(ddi).EvaluationDuration = ...
        months3AvgEvl(ddi).Duration(1).EndDate(end) - ...
        months3AvgEvl(ddi).Duration(1).StartDate(end);
end