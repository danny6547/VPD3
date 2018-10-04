function [obj, avgStruct] = movingAverage(obj, durations, varargin)
%movingAverages Calculate moving averages of time-series data
%   avgStruct = movingAverages(obj, duration) will return in 
%   AVGSTRUCT a struct with field names 'Average', 'StartDate' and 
%   'EndDate' containing the corresponding data over the durations given by
%   vector DURATION for the data in struct PERSTRUCT. AVGSTRUCT will be the
%   same size as PERSTRUCT, and PERSTRUCT must have fields 'Date' and 
%   'Performance_Index'. The numerical arrays contained in it's fields will
%   have as many rows as durations in the 'Performance_Index' data and as
%   many columns as elements in DURATION. Note that the number of durations
%   found in the data is based on the contents of the 'Date' field in
%   PERSTRUCT.
%   avgStruct = movingAverages(obj, duration, reverse) will, in
%   addition to the above, return the averages over the durations
%   calculated from the end of the data in PERSTRUCT backwards when logical
%   REVERSE is TRUE and vice versa. REVERSE can be either scalar, in which
%   case the same value is applied to all data, or an array, in which case
%   it must be the same size as PERSTRUCT. The default value is FALSE.
%   avgStruct = movingAverages(obj, duration, reverse, trim) will, in
%   addition to the above, trim the outputs for durations which do not
%   fully overlap with those of non-nan data in PERSTRUCT so that their
%   'StartDate' and/or 'EndDate' values match those of the lowest and/or
%   highest date values which they overlap. TRIM can be either scalar, in 
%   which case the same value is applied to all data, or an array, in which
%   case it must be the same size as PERSTRUCT. The default value is FALSE.
%   avgStruct = movingAverages(obj, duration, reverse, trim, remove)
%   will, in addition to the above, remove outputs for durations which are
%   not fully within the range of the date values input in PERSTRUCT. TRIM 
%   can be either scalar, in which case the same value is applied to all 
%   data, or an array, in which case it must be the same size as PERSTRUCT.
%   The default value is FALSE.

% Initialise Outpus
avgStruct = struct('DryDockInterval', []);
avgStruct.DryDockInterval = struct('Average', [], 'StartDate', [],...
    'EndDate', [], 'StdOfMean', [], 'Count', []);
sizeStruct = size(obj);

% Inputs
reverse_l = false;
errorSizeMatch_f = @(varname) error('moveAvg:InputSizeMismatch', ...
    ['If input ' varname ' is not a scalar, it must be the same size as '...
    'OBJ']);
resizeMatch_f = @(match, this) repmat(match, [this.numDDIntervals, numel(this)]);

if nargin > 2
    validateattributes(varargin{1}, {'logical'}, {}, ...
        'movingAverages', 'reverse', 3);
    
    if ~isscalar(varargin{1}) && ~isequal(size(varargin{1}), sizeStruct)
%        errid = 'moveAvg:InputSizeMismatch';
%        errmsg = ['If input REVERSE is not a scalar, it must be the same '...
%            'size as input PERSTRUCT'];
%        error(errid, errmsg);
       errorSizeMatch_f('reverse')
    end
    
    reverse_l = varargin{1};
end
if isscalar(reverse_l)
    reverse_l = resizeMatch_f(reverse_l, obj);
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
    trim_l = resizeMatch_f(trim_l, obj);
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
    remove_l = resizeMatch_f(remove_l, obj);
end

% Iterate over elements of data array
while obj.iterateDD

    [currDD_tbl, currObj, ddi, vi] = obj.currentDD;
    
    % Index into input and get dates
    currDate = currDD_tbl.timestamp;
    currPerf = currDD_tbl.(currObj.InServicePreferences.Variable);

    % Remove duplicate date data (redundant when no duplicates in db)
    [currDate, udi] = unique(currDate);
    currPerf = currPerf(udi);

    % Get dates filtered by nan in performance data
    filtDate = currDate(~isnan(currPerf));

    % NB. TAKE THE DRY-DOCK DATE FROM SERIES

    % Initialise output struct
    Duration_st = struct('Average', [], 'StartDate', [], 'EndDate', []);

    for di = 1:length(durations)

        % Get dates for start and end of durations
        currDur = durations(di);

        % Create timestep vector for current dates
        tstep = 1; % Replace with proper timestep value in DB later
        tstep_v = repmat(tstep, size(currDate));

        preDates = currDate - 0.5*tstep_v;
        postDates = currDate + 0.5*tstep_v;
        numDur = ceil( (max(postDates) - min(preDates)) / currDur);

        if reverse_l(ddi)

            delimDates = linspace(postDates(end) - (currDur*numDur), ...
                postDates(end), numDur + 1);
        else

            delimDates = linspace(preDates(1), preDates(1)+(currDur*numDur),...
                numDur + 1);
        end

        startDates = delimDates(1:end-1); 
        endDates  = delimDates(2:end);
        
        calendarDays_l = false;
        if calendarDays_l
            startDates = floor(startDates);
            endDates = ceil(endDates) - 1;
        end
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
        if remove_l(ddi)

            startFilt = startDates + 0.5*tstep < min(currDate);
            startDates(startFilt) = [];
            endDates(startFilt) = [];
            endFilt = endDates - 0.5*tstep > max(currDate);
            startDates(endFilt) = [];
            endDates(endFilt) = [];
        end

        % Trim start, end dates
        if trim_l(ddi)

            startDates(startDates < min(filtDate)) = min(filtDate);
            endDates(endDates > max(filtDate)) = max(filtDate);
        end

        % Remove from all outputs if any corresponding have been removed
        outLength = min([length(output), length(startDates), ...
            length(endDates)]);

        % Make all Row vectors
        output = output(:)';
        startDates = startDates(:)';
        endDates = endDates(:)';

        % Calculate additional values
        outnansem = cellfun(@(start, endd) ...
            nansem(currPerf(currDate >= start & currDate < endd)),...
            startDates_c, endDates_c);
        counts = cellfun(@(start, endd) ...
            numel(currPerf(currDate >= start & currDate < endd)),...
            startDates_c, endDates_c);

        % Assign into outputs
        Duration_st(di).Average = output(1:outLength);
        Duration_st(di).StartDate = startDates(1:outLength);
        Duration_st(di).EndDate = endDates(1:outLength);
        Duration_st(di).StdOfMean = outnansem(1:outLength);
        Duration_st(di).Count = counts(1:outLength);
    end

    % Re-assign into Outputs
    currObj.Report(ddi).MovingAverage.Duration = Duration_st;
    avgStruct(vi).DryDockInterval(ddi) = Duration_st;
end