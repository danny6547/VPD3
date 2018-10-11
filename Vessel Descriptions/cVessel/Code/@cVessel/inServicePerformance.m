function [obj, inserv, dur ] = inServicePerformance(obj, varargin)
%inServicePerformance In-service performance as defined by ISO 190303-2.
%   Detailed explanation goes here

% Outputs
servStruct = struct('InservicePerformance', [], 'ReferenceDuration', [],...
    'ReferenceValue', [], 'EvaluationDuration', [], 'EvaluationValue', [],...
    'ReferenceDates', [], 'ReferenceValues', [],...
    'EvaluationDates', [], 'EvaluationValues', []...
    );
inserv = struct('DryDockInterval', servStruct);
dur = struct('Average', [], 'StartDate', [], 'EndDate', [],...
    'StdOfMean', [], 'Count', []);

while obj.iterateDD
    
   [currDD_tbl, currVessel, ddi, vi] = obj.currentDD;
   
    % Index into input and get dates
    currDate = currDD_tbl.timestamp;
    currVar = currVessel.Report(ddi).Variable;
    currPerf = currDD_tbl.(currVar);
    
    % Initialise output struct
    Duration_st = struct('Average', [], 'StartDate', [], 'EndDate', []);
    
    % Separate first and second years
    firstYear_l = currDate <= ( min(currDate) + 365.25);
    remainingYears_l = currDate > ( min(currDate) + 365.25);
    
    if any(remainingYears_l)
        
        output(1) = nanmean(currPerf(firstYear_l));
        output(2) = nanmean(currPerf(remainingYears_l));
        outnansem(1) = nansem(currPerf(firstYear_l));
        outnansem(2) = nansem(currPerf(remainingYears_l));
        counts(1) = numel(currPerf(firstYear_l));
        counts(2) = numel(currPerf(remainingYears_l));
        
        startDate(1) = min(currDate(firstYear_l));
        startDate(2) = min(currDate(remainingYears_l));
        endDate(1) = max(currDate(firstYear_l));
        endDate(2) = max(currDate(remainingYears_l));
        
        % Make all Row vectors
        output = output(:)';
        startDate = startDate(:)';
        endDate = endDate(:)';
        outnansem = outnansem(:)';
        counts = counts(:)';
        
        % Assign into outputs
        Duration_st(1).Average = output(1);
        Duration_st(1).StdOfMean = outnansem(1);
        Duration_st(1).Count = counts(1);
        Duration_st(1).StartDate = startDate(1);
        Duration_st(1).EndDate = endDate(1);
        Duration_st(2).Average = output(2);
        Duration_st(2).StdOfMean = outnansem(2);
        Duration_st(2).Count = counts(2);
        Duration_st(2).StartDate = startDate(2);
        Duration_st(2).EndDate = endDate(2);
        dur(end+1:end+2) = Duration_st;
        
        % Calculate Performance
        servStruct.ReferenceDuration = Duration_st(1).EndDate - Duration_st(1).StartDate;
        servStruct.ReferenceValue = Duration_st(1).Average;
        servStruct.EvaluationDuration = Duration_st(2).EndDate - Duration_st(2).StartDate;
        servStruct.EvaluationValue = Duration_st(2).Average;
        
        servStruct.InservicePerformance = servStruct.EvaluationValue - servStruct.ReferenceValue;
        inserv(vi).DryDockInterval(ddi) = servStruct;
        currVessel.Report(ddi).InServicePerformance = servStruct;
    end
end
dur(1) = [];