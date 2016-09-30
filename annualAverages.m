function avgStruct = annualAverages( perStruct )
%annualAverages Calculate the annual averages of performance per dry dock
%   Detailed explanation goes here

% Iterate over elements of array
sizeStruct = size(perStruct);
avgStruct = struct('AnnualAverage', [], 'EndDate', []);

for si = 1:numel(perStruct)
    
    % Skip if empty
    currStruct = perStruct(si);
    if any(isnan(currStruct.IMO))
        continue
    end
    
    % Index into input and get dates
    currDate = datenum(char(currStruct.Date), 'dd-mm-yyyy');
    [ri, ci] = ind2sub(sizeStruct, si);
    
    % NB. TAKE THE DRY-DOCK DATE FROM SERIES
    
    % If first DDi, calculate from end backwards
%     dd = currDate(end);
    
    % Build matrix of dates
    [yeari, ~] = datevec(currDate);

    % uniYears = unique(yeari);
    numYearsData = numel(unique(yeari));

    dayOfYear = nan(366, numYearsData);
    dayOfYear(1:365, :) = repmat((1:365)', 1, size(dayOfYear, 2));
    dayOfYear(end, 4:4:end) = 366;
    dayOfYear = dayOfYear(~isnan(dayOfYear));
    dayOfYear = dayOfYear(1:length(currStruct.Performance_Index));

    yearsPI = nan(366, numYearsData);
    
    yearIndex = nan(366, numYearsData);
    yearIndex(1:365, :) = repmat(1:numYearsData, 365, 1);
    yearVect = 1:numYearsData;
    yearIndex(end, 4:4:end) = yearVect(4:4:end);
    yearIndex = yearIndex(~isnan(yearIndex));
    yearIndex = yearIndex(1:length(currStruct.Performance_Index));
    
    yearInd = sub2ind(size(yearsPI), dayOfYear, yearIndex);
    
    if ri == 1
        
        % If first DD, calculate from end backwards
        yearsPI(yearInd) = currStruct.Performance_Index(end:-1:1);
        
    else
        
        % Otherwise last DDi, calculate from start forwards
        yearsPI(yearInd) = currStruct.Performance_Index;
    end
    
%     currDate = currDate - dd;
%     
%     numdays = dd - datenum('20/11/08');
%     
%     numweeks = numdays / 7;  %and round() or floor() or ceil() as appropriate
%     
%     numdaysvec = datevec(numdays);
%     nummonths = numdaysvec(1) * 12 + numdaysvec(2) - 1;
% 
%     [yeari, moni, dayi] = datevec(currDate);
%     dayOfYear = moni .* dayi;
%     
%     numYears = numel(unique(yeari));
%     pipy = nan(366, numYears);
%     pipy(dayOfYear, yeari) = currStruct.Performance_Index;
%     
%     annualAverage = nanmean(pipy, 2);
%     yearEnds = dd + 1:numYears;
    
    % Calculate averages
    annualAverage = nanmean(yearsPI);
    
    % Filter any years that had no data
    if ri == 1
        currDate = currDate(end:-1:1);
    end
    
    enddates = currDate(dayOfYear == 1);
    nanFilt_l = isnan(annualAverage);
    annualAverage(nanFilt_l) = [];
    nanFilt_l = nanFilt_l(1:length(enddates));
    enddates(nanFilt_l) = [];
    
    % Assign into outputs
    avgStruct(ri, ci).AnnualAverage = annualAverage;
    avgStruct(ri, ci).EndDate = enddates(:)';
    
    % Re-assign into inputs
    perStruct(si) = currStruct;
    
end