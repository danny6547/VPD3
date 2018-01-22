function [ obj, trigger ] = maintenanceTrigger( obj )
%maintenanceTrigger Maintenance Trigger KPI
%   Detailed explanation goes here

% Output
maintrig = struct('MaintenanceTrigger', [], ...
    'ReferenceAverage', [], ...
    'EvaluationAverage', [], ...
    'ReferenceDuration', [], ...
    'EvaluationDuration', []);
trigger = struct('DryDockInterval', maintrig);
% szIn = size(obj);
% nDDi = szIn(1);
% maintrig = repmat(maintrig, szIn);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);

% Get annual averages after dry-dockings
months3 = (365.25 * 3)/12;
[~, annualAvgRef] = movingAverage(obj, months3, true);
[~, months3AvgEvl] = movingAverage(obj, months3, true);

% Iterate over DD intervals, starting with second
% for ddi = 1:nDDi

while obj.iterateDD
    
    [~, currVessel, ddi, vi] = obj.currentDD;
    
    % Skip when less than 6 months data in DD interval
    if numel(annualAvgRef(vi).DryDockInterval(ddi).Average) < 2
        
        continue
    end
    
    % Take average first year of current DDi
    maintrig.ReferenceAverage = annualAvgRef(vi).DryDockInterval(ddi).Average(1);
    
    % Take average first year of previous DDi
    maintrig.EvaluationAverage = months3AvgEvl(vi).DryDockInterval(ddi).Average(end);
    
    % Subtract
    maintrig.MaintenanceTrigger = maintrig.EvaluationAverage - ...
        maintrig.ReferenceAverage;
    
    % Durations
    maintrig.ReferenceDuration = ...
        annualAvgRef(vi).DryDockInterval(ddi).EndDate(1) - ...
        annualAvgRef(vi).DryDockInterval(ddi).StartDate(1);
    
    maintrig.EvaluationDuration = ...
        months3AvgEvl(vi).DryDockInterval(ddi).EndDate(end) - ...
        months3AvgEvl(vi).DryDockInterval(ddi).StartDate(end);
    
    trigger(vi).DryDockInterval(ddi) = maintrig;
    
    % Assign into obj
    if ddi == currVessel.numDDIntervals
        
        currVessel.MaintenanceTrigger = trigger(vi).DryDockInterval;
    end
end