function [obj, inserv ] = inServicePerformance(obj, varargin)
%inServicePerformance In-service performance as defined by ISO 190303-2.
%   Detailed explanation goes here

% Outputs
servStruct = struct('InservicePerformance', [], 'ReferenceDuration', [],...
    'ReferenceValue', [], 'EvaluationDuration', [], 'EvaluationValue', []);
inserv = struct('DryDockInterval', servStruct);
% sizeStruct = size(obj);

% Inputs

% Convert dates
% obj = convertDate(obj); redundant function replaced with set method

% Iterate over elements of data array
% [obj.InServicePerformance] = deal(servStruct);
while obj.iterateDD
% while ~obj.iterFinished
    
%    [obj, ii] = obj.iter;
   [currDD_tbl, currVessel, ddi] = obj.currentDD;
% for si = 1:numel(obj)
    
%     % Skip if empty
%    if currVessel.isPerDataEmpty
%        continue
%    end
    
    % Index into input and get dates
%     currDate = datenum(char(currStruct.DateTime_UTC), 'dd-mm-yyyy');
    currDate = currDD_tbl.datetime_utc;
    currVar = currVessel.Variable;
    currPerf = currDD_tbl.(currVar);
%     [ri, ci] = ind2sub(sizeStruct, si);
    
    % Remove duplicate date data (redundant when no duplicates in db)
%     [currDate, udi] = unique(currDate);
%     currPerf = currPerf(udi);
%     
%     % Get dates filtered by nan in performance data
%     currDate = currDate(~isnan(currPerf));
    
    % NB. TAKE THE DRY-DOCK DATE FROM SERIES
    
    % If first DDi, calculate from end backwards
%     dd = currDate(end);
    
%     startDate(1) = min(currDate);
%     endTime(1) = startDate(1) + 365.25;
%     startDateI(1) = 1;
%     [endDate(1), endDateI(1)] = FindNearestInVector(endTime(1), currDate);
% 
%     startDateI(2) = find(currDate > startDate(1), 1);
%     startDate(2) = currDate(startDateI);
%     endDate(2) = max(currDate);
%     
%     output(1) = mean(currPerf(1:endDateI(1)));
%     output(2) = mean(currPerf(1:endDateI(1)));
    
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
        
        % Calculate Performance
        servStruct.ReferenceDuration = Duration_st(1).EndDate - Duration_st(1).StartDate;
        servStruct.ReferenceValue = Duration_st(1).Average;
        servStruct.EvaluationDuration = Duration_st(2).EndDate - Duration_st(2).StartDate;
        servStruct.EvaluationValue = Duration_st(2).Average;
        servStruct.InservicePerformance = servStruct.ReferenceValue - servStruct.EvaluationValue;
        inserv(ddi).DryDockInterval = servStruct;
        currVessel.Report.InServicePerformance(ddi) = servStruct;
%         
%         % Re-assign into Outputs
%         if ddi == currVessel.numDDIntervals
%             currVessel.InServicePerformance = [inserv.DryDockInterval];
%         end
    end
end
% obj = obj.iterReset;