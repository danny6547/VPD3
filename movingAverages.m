function avgStruct = movingAverages( perStruct, durations, varargin)
%movingAverages Calculate moving averages of time-series data
%   avgStruct = movingAverages(perStruct, duration) will return in 
%   AVGSTRUCT a struct with field names 'Average', 'StartDate' and 
%   'EndDate' containing the corresponding data over the durations given by
%   vector DURATION for the data in struct PERSTRUCT. AVGSTRUCT will be the
%   same size as PERSTRUCT, and PERSTRUCT must have fields 'Date' and 
%   'Performance_Index'. The numerical arrays contained in it's fields will
%   have as many rows as durations in the 'Performance_Index' data and as
%   many columns as elements in DURATION. Note that the number of durations
%   found in the data is based on the contents of the 'Date' field in
%   PERSTRUCT.
%   avgStruct = movingAverages(perStruct, duration, reverse) will, in
%   addition to the above, return the averages over the durations
%   calculated from the end of the data in PERSTRUCT backwards when logical
%   REVERSE is TRUE and vice versa. REVERSE can be either scalar, in which
%   case the same value is applied to all data, or an array, in which case
%   it must be the same size as PERSTRUCT. The default value is FALSE.
%   avgStruct = movingAverages(perStruct, duration, reverse, trim) will, in
%   addition to the above, trim the outputs for durations which do not
%   fully overlap with those of non-nan data in PERSTRUCT so that their
%   'StartDate' and/or 'EndDate' values match those of the lowest and/or
%   highest date values which they overlap. TRIM can be either scalar, in 
%   which case the same value is applied to all data, or an array, in which
%   case it must be the same size as PERSTRUCT. The default value is FALSE.
%   avgStruct = movingAverages(perStruct, duration, reverse, trim, remove)
%   will, in addition to the above, remove outputs for durations which are
%   not fully within the range of the date values input in PERSTRUCT. TRIM 
%   can be either scalar, in which case the same value is applied to all 
%   data, or an array, in which case it must be the same size as PERSTRUCT.
%   The default value is FALSE.

% Initialise Outpus
avgStruct = struct('Duration', []);
sizeStruct = size(perStruct);

% Inputs
reverse_l = false;
errorSizeMatch_f = @(varname) error('moveAvg:InputSizeMismatch', ...
    ['If input ' varname ' is not a scalar, it must be the same size as '...
    'input PERSTRUCT']);
resizeMatch_f = @(match, this) repmat(match, size(this));

if nargin > 2
    validateattributes(varargin{1}, {'logical'}, {}, ...
        'movingAverages', 'reverse', 3);
    
    if ~isscalar(varargin{1}) && ~isequal(size(varargin{1}), sizeStruct)
       errid = 'moveAvg:InputSizeMismatch';
       errmsg = ['If input REVERSE is not a scalar, it must be the same '...
           'size as input PERSTRUCT'];
       error(errid, errmsg);
    end
    
    reverse_l = varargin{1};
end
if isscalar(reverse_l)
    reverse_l = resizeMatch_f(reverse_l, perStruct);
end

trim_l = false;
if nargin > 3
    
    validateattributes(varargin{2}, {'logical'}, {}, ...
        'movingAverages', 'trim', 4);
    
    if ~isscalar(varargin{2}) && ~isequal(size(varargin{2}), sizeStruct)
        errorSizeMatch_f('trim')
    end
    trim_l = varargin{2};
end
if isscalar(trim_l)
    trim_l = resizeMatch_f(trim_l, perStruct);
end
    
remove_l = false;
if nargin > 4
    ci = 3;
    validateattributes(varargin{ci}, {'logical'}, {}, ...
        'movingAverages', 'remove', 5);
    
    if ~isscalar(varargin{ci}) && ~isequal(size(varargin{ci}), sizeStruct)
        errorSizeMatch_f('remove')
    end
    remove_l = varargin{ci};
end
if isscalar(remove_l)
    remove_l = resizeMatch_f(remove_l, perStruct);
end

% Iterate over elements of data array
for si = 1:numel(perStruct)
    
    % Skip if empty
    currStruct = perStruct(si);
    if all(isnan(currStruct.Performance_Index))
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
        
        % Get dates for start and end of durations
        if trim_l(si) && ~remove_l(si)
            filtCurrDate_l = ~isnan(currPerf);
            currDate = currDate(filtCurrDate_l);
            currPerf = currPerf(filtCurrDate_l);
        end
        
        currDur = durations(di);
        rangeDates = max(currDate) - min(currDate);
        numDurations = ceil(rangeDates / currDur);
        
        if reverse_l(si)
            delimDates = max(currDate):-currDur:...
                max(currDate)-(numDurations*currDur);
%             delimDates(delimDates < min(currDate)) = min(currDate);
        else
            delimDates = min(currDate):currDur:...
                min(currDate)+(numDurations*currDur);
%             delimDates(delimDates > max(currDate)) = max(currDate);
        end
        delimDates = unique(delimDates);
        startDates = delimDates(1:end-1); 
        endDates = delimDates(2:end);
        startDates_c = num2cell(startDates);
        endDates_c = num2cell(endDates);
        
        % Get result over durations and filter
        output = cellfun(@(start, endd) ...
            nanmean(currPerf(currDate >= start & currDate < endd)),...
            startDates_c, endDates_c);
        nanFilt_l = isnan(output);
        output(nanFilt_l) = [];
        nanFilt_l = nanFilt_l(1:length(endDates));
        startDates(nanFilt_l) = [];
        endDates(nanFilt_l) = [];
        
        % Remove outputs not within range
        if remove_l(si)
            startDates(startDates < min(currDate)) = [];
            startDates(startDates > max(currDate)) = [];
            endDates(endDates < min(currDate)) = [];
            endDates(endDates > max(currDate)) = [];
        else
            if reverse_l
                startDates(startDates < min(currDate)) = min(currDate);
            else
                endDates(endDates > max(currDate)) = max(currDate);
            end
        end
        
        % Trim start, end dates
        if trim_l(si)
            startDates(startDates < min(currDate)) = min(currDate);
            startDates(startDates > max(currDate)) = max(currDate);
            endDates(endDates < min(currDate)) = min(currDate);
            endDates(endDates > max(currDate)) = max(currDate);
        end
        
        % Remove from all outputs if any corresponding have been removed
        outLength = min([length(output), length(startDates), ...
            length(endDates)]);
        
        % Assign into outputs
        Duration_st(di).Average = output(1:outLength);
        Duration_st(di).StartDate = startDates(1:outLength);
        Duration_st(di).EndDate = endDates(1:outLength);
        
    end
    
    % Re-assign into Outputs
    avgStruct(ri, ci).Duration = Duration_st;
    
end