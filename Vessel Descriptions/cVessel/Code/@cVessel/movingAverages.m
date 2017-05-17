function [obj, avgStruct] = movingAverages(obj, durations, varargin)
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

% Assign
% obj = obj.(obj.Variable);

% Initialise Outpus
avgStruct = struct('Duration', []);
sizeStruct = size(obj);

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
while ~obj.iterFinished
    
   [obj, ii] = obj.iter;
% for si = 1:numel(obj)
    
    % Skip if empty
    currObj = obj(ii);
%     if all(isnan(currObj.Performance_Index))
%         continue
%     end
    
    % Index into input and get dates
%     currDate = datenum(char(currObj.DateTime_UTC), 'dd-mm-yyyy');
    currDate = currObj.DateTime_UTC;
    currPerf = currObj.(currObj.Variable);
%     [ri, ci] = ind2sub(sizeStruct, si);
    
    % Remove duplicate date data (redundant when no duplicates in db)
    [currDate, udi] = unique(currDate);
    currPerf = currPerf(udi);
    
    % Get dates filtered by nan in performance data
    filtDate = currDate(~isnan(currPerf));
    
    % NB. TAKE THE DRY-DOCK DATE FROM SERIES
    
    % If first DDi, calculate from end backwards
%     dd = currDate(end);
    
    % Initialise output struct
    Duration_st = struct('Average', [], 'StartDate', [], 'EndDate', []);
    
    for di = 1:length(durations)
        
        % Get dates for start and end of durations
%         if trim_l(si) && ~remove_l(si)
%             filtCurrDate_l = ~isnan(currPerf);
%             currDate = currDate(filtCurrDate_l);
%             currPerf = currPerf(filtCurrDate_l);
%         end
        
        currDur = durations(di);
%         rangeDates = max(currDate) - min(currDate);
%         numDurations = ceil(rangeDates / currDur);
        
        % Create timestep vector for current dates
        tstep = 1; % Replace with proper timestep value in DB later % unique(diff(currDate));
%         tstep(tstep==0) = [];
        tstep_v = repmat(tstep, size(currDate));
        
        preDates = currDate - 0.5*tstep_v;
        postDates = currDate + 0.5*tstep_v;
        numDur = ceil( (max(postDates) - min(preDates)) / currDur);
        
        if reverse_l(ii)
            
%             delimDates = postDates(1):currDur:preDates(1);
            delimDates = linspace(postDates(end) - (currDur*numDur), ...
                postDates(end), numDur + 1);
%             delimDates = unique([postDates(end):-currDur:preDates(1),...
%                 preDates(1)]);
%             delimDates = max(currDate):-currDur:...
%                 max(currDate)-(numDurations*currDur);
%             delimDates(delimDates < min(currDate)) = min(currDate);
        else
            
            delimDates = linspace(preDates(1), preDates(1)+(currDur*numDur),...
                numDur + 1);
            
%             delimDates = unique([preDates(1):currDur:postDates(end),...
%                 postDates(end)]);
%             delimDates = unique([preDates(1:currDur:end); postDates(end)]);
            
%             delimDates = unique([preDates(1:currDur:end); postDates(end)]);
%             startDates = delimDates(1:end-1); 
%             endDates = delimDates(2:end);
%             delimDates = currDate - 0.5*tstep_v;
%             delimDates = min(currDate):currDur:...
%                 min(currDate)+(numDurations*currDur);
%             delimDates(delimDates > max(currDate)) = max(currDate);
        end
        
%         delimDates = unique(delimDates);
        startDates = delimDates(1:end-1); 
        endDates  = delimDates(2:end);
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
        if remove_l(ii)
            startFilt = startDates + 0.5*tstep < min(currDate);
            startDates(startFilt) = [];
            endDates(startFilt) = [];
%             startDates(startDates > max(currDate)) = [];
%             endDates(endDates < min(currDate)) = [];
            endFilt = endDates - 0.5*tstep > max(currDate);
            startDates(endFilt) = [];
            endDates(endFilt) = [];
        else
%             if reverse_l
%                 startDates(startDates < min(currDate)) = min(currDate);
%             else
%                 endDates(endDates > max(currDate)) = max(currDate);
%             end
        end
        
        % Trim start, end dates
        if trim_l(ii)
            startDates(startDates < min(filtDate)) = min(filtDate);
%             startDates(startDates > max(currDate)) = max(currDate);
%             endDates(endDates < min(currDate)) = min(currDate);
            endDates(endDates > max(filtDate)) = max(filtDate);
        end
        
        % Remove from all outputs if any corresponding have been removed
        outLength = min([length(output), length(startDates), ...
            length(endDates)]);
        
        % Make all Row vectors
        output = output(:)';
        startDates = startDates(:)';
        endDates = endDates(:)';
        
        % Assign into outputs
        Duration_st(di).Average = output(1:outLength);
        Duration_st(di).StartDate = startDates(1:outLength);
        Duration_st(di).EndDate = endDates(1:outLength);
        
    end
    
    % Re-assign into Outputs
    avgStruct(ii).Duration = Duration_st;
    obj(ii).MovingAverages = avgStruct(ii);
end
obj = obj.iterReset;