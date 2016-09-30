function avgStruct = movingAverages( perStruct, durations )
%movingAverages Calculate moving averages of time-series data
%   avgStruct = movingAverages(perStruct, duration) will return in 
%   AVGSTRUCT a struct with field names 'Average', 'StartDate' and 
%   'EndDate' containing the corresponding data over the durations given by
%   vector DURATION for the data in struct PERSTRUCT. AVGSTRUCT will be the
%   same size as PERSTRUCT, and PERSTRUCT must have fields 'Date' and 
%   'Performance_Index'. The numerical arrays contained in it's fields will
%   have as many rows as durations in the 'Performance_Index' data and as
%   many columns as elements in DURATION.

% Iterate over elements of array
sizeStruct = size(perStruct);
avgStruct = struct('Duration', []); 

for si = 1:numel(perStruct)
    
    % Skip if empty
    currStruct = perStruct(si);
    if any(isnan(currStruct.IMO))
        continue
    end
    
    % Index into input and get dates
    currDate = datenum(char(currStruct.Date), 'dd-mm-yyyy');
    currPerf = currStruct.Performance_Index;
    [ri, ci] = ind2sub(sizeStruct, si);
    
    % NB. TAKE THE DRY-DOCK DATE FROM SERIES
    
    % If first DDi, calculate from end backwards
%     dd = currDate(end);
    
    % Initialise output struct
    Duration_st = struct('Average', [], 'StartDate', [], 'EndDate', []);
    
    for di = 1:length(durations)
        
        % Build matrix of dates
        currDur = durations(di);
        rangeDates = max(currDate) - min(currDate);
        numColumns = ceil(rangeDates / currDur);
        numRows = ceil(currDur);
        numRowsDown = floor(currDur);
        durationPI = nan(numRows, numColumns);
        
        dayOfDuration = nan(numRows, numColumns);
        dayOfDuration(1:numRowsDown, :) = repmat((1:numRowsDown)', 1,...
            size(dayOfDuration, 2));
        
        delimDates = min(currDate):currDur:...
            min(currDate)+(numColumns*currDur);
        delimDates(delimDates > max(currDate)) = max(currDate);
        delimDates = unique(delimDates);
        startDates = delimDates(1:end-1); 
        endDates = delimDates(2:end);
        startDates_c = num2cell(startDates);
        endDates_c = num2cell(endDates);
%         currDate_c = repmat({currDate}, size(startDates_c));
%         currPerf_c = repmat({currPerf}, size(endDates_c));
%         
        
        output = cellfun(@(start, endd) ...
            nanmean(currPerf(currDate >= start & currDate < endd)),...
            startDates_c, endDates_c);
        nanFilt_l = isnan(output);
        output(nanFilt_l) = [];
        nanFilt_l = nanFilt_l(1:length(endDates));
        startDates(nanFilt_l) = [];
        endDates(nanFilt_l) = [];
        
        % Assign into outputs
        Duration_st(di).Average = output;
        Duration_st(di).StartDate = startDates;
        Duration_st(di).EndDate = endDates;
        
%         % Get indices to "leap" columns 
%         remainder = currDur - floor(currDur);
%         leap_l = remainder ~= 0;
%         if leap_l
%             
%             
%             [numer, denom] = rat(remainder);
%             
%             leapStarts = 1:denom:numColumns;
%             leapEnds = denom:denom:denom + numColumns;
%             leapEnds(leapEnds == numColumns) = [];
%             
%             leapColi_c = arrayfun(@(x, y) round(linspace(x, y, numer)), ...
%                 leapStarts, leapEnds, 'Uni', 0);
%             leapColi = [leapColi_c{:}];
%             leapColi(leapColi > numColumns) = [];
%             
%             % Get indices to final day of each duration
%             endDatesRows = repmat(numRowsDown, [1, numColumns]);
%             endDatesRows(leapColi) = numRows;
%             endDatesCols = 1:numColumns;
%             endDatesi = sub2ind([numRowsDown, numColumns], endDatesRows,...
%                 endDatesCols);
%             leapColi_l = ~ismember(1:numColumns, leapColi);
%             endDatesi(~leapColi_l) = endDatesi(~leapColi_l) + 1;
%             endDatesi(endDatesi > numel(currDate)) = numel(currDate);
%             endDatesi = unique(endDatesi);
%             
%             startDatesRows = ones(1, numColumns);
%             startDatesCols = 1:numColumns;
%             startDatesi = sub2ind([numRowsDown, numColumns], startDatesRows, ...
%                 startDatesCols);
%             startDatesi(~leapColi_l) = startDatesi(~leapColi_l) + 1;
%             startDatesi(startDatesi > numel(currDate)) = [];
%             
%             startDate = min(inputDates):numRowsDown:
%             
%             endDates = min(inputDates)+numRowsDown:numRowsDown:numRowsDown*numColumns;
%             endDates(~leapColi_l) = endDates(~leapColi_l) + 1;
%             
%             
%             durData_c = arrayfun(...
%                 @(start, endd, dates) dates(dates >= start & dates < endd),...
%                 startDates, endDates, inputDates, 'Uni', 0);
%             
% %             anyLeaps_l = any(~leapColi_l);
% %             if numel(leapColi_l) ~= ( numel(startDatesi) - 1 )
% %                 
% %                 diffNum = numel(leapColi_l) - numel(startDatesi);
% %                 leapColi_l(end-diffNum:end) = [];
% %             end
% %             
% %             endDatesi(2:end) = endDatesi(2:end) - leapColi_l;
% %             startDatesi(2:end) = startDatesi(2:end) - leapColi_l;
%             dayOfDuration(end, leapColi) = numRows;
%         end
%         
%         dayOfDuration = dayOfDuration(~isnan(dayOfDuration));
%         dayOfDuration = dayOfDuration(1:length(currStruct.Performance_Index));
%         
%         durationIndex = nan(numRows, numColumns);
%         durationIndex(1:numRowsDown, :) = repmat(1:numColumns, numRowsDown, 1);
%         durationVect = 1:numColumns;
%         
%         if leap_l
%             
%             durationIndex(end, leapColi) = durationVect(leapColi);
%         end
%         
%         durationIndex = durationIndex(~isnan(durationIndex));
%         durationIndex = durationIndex(1:length(currStruct.Performance_Index));
%         
%         durationInd = sub2ind(size(durationPI), dayOfDuration, durationIndex);
%         
% %         %% Build matrix of dates
% %         [yeari, ~] = datevec(currDate);
% %         
% %         % uniYears = unique(yeari);
% %         numYearsData = numel(unique(yeari));
% % 
% %         dayOfYear = nan(366, numYearsData);
% %         dayOfYear(1:365, :) = repmat((1:365)', 1, size(dayOfYear, 2));
% %         dayOfYear(end, 4:4:end) = 366;
% %         dayOfYear = dayOfYear(~isnan(dayOfYear));
% %         dayOfYear = dayOfYear(1:length(currStruct.Performance_Index));
% %         
% %         yearsPI = nan(366, numYearsData);
% %         
% %         yearIndex = nan(366, numYearsData);
% %         yearIndex(1:365, :) = repmat(1:numYearsData, 365, 1);
% %         yearVect = 1:numYearsData;
% %         yearIndex(end, 4:4:end) = yearVect(4:4:end);
% %         yearIndex = yearIndex(~isnan(yearIndex));
% %         yearIndex = yearIndex(1:length(currStruct.Performance_Index));
% %         
% %         yearInd = sub2ind(size(yearsPI), dayOfYear, yearIndex);
%         
%         
% %         if ri == 1
% % 
% %             % If first DD, calculate from end backwards
% %             durationPI(durationInd) = currStruct.Performance_Index(end:-1:1);
% % 
% %         else
% %             
%             % Otherwise last DDi, calculate from start forwards
%             durationPI(durationInd) = currStruct.Performance_Index;
% %         end
%         
%         % Calculate averages
%         durAverage = nanmean(durationPI);
%         
%         % Filter any years that had no data
% %         if ri == 1
% %             currDate = currDate(end:-1:1);
% %         end
%         
%         endDates = currDate(endDatesi);
%         startDates = currDate(startDatesi);
% 
% %         enddates = currDate(dayOfDuration == 1);
%         nanFilt_l = isnan(durAverage);
%         durAverage(nanFilt_l) = [];
%         nanFilt_l = nanFilt_l(1:length(endDates));
%         startDates(nanFilt_l) = [];
%         endDates(nanFilt_l) = [];
% %         
% %         startdates = currDate(startDatesi);
%         
%         % Assign into outputs
%         Duration_st(di).Average = durAverage;
%         Duration_st(di).StartDate = startDates(:)';
%         Duration_st(di).EndDate = endDates(:)';
%         
        
    end
    
        
    % Re-assign into OUTPUTs
    avgStruct(ri, ci).Duration = Duration_st;
%     perStruct(si) = currStruct;
    
end