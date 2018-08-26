function [trading_tbl, idleDD_tbl, idleQuart_tbl] = activityFromVesselTrackerXLSX(filename, dd, varargin)
%activityFromVesselTrackerXLSX Activity data from XLSX file containing AIS
%   Detailed explanation goes here
% Idle times are when speed is below 2 knots

% Input
validateattributes(filename, {'char'}, {'vector'}, ...
    'cVessel.activityFromVesselTrackerXLSX', 'filename', 1);
validateattributes(dd, {'datetime'}, {'scalar'}, ...
    'cVessel.activityFromVesselTrackerXLSX', 'dd', 2);

format_l = false;
if nargin > 2
    
    format_l = varargin{1};
    validateattributes(format_l, {'logical'}, {'scalar'}, ...
        'cVessel.activityFromVesselTrackerXLSX', 'format', 3);
end

% Get separate tables for dry-docking interval and previous quarter
f = readtable(filename, 'FileType', 'spreadsheet',...
                        'Sheet', 'Average Hourly Speed');
[~, timeSortI] = sort(f.datetime);
f = f(timeSortI, :);
f.idle = f.speed < 2;
dd_l = f.datetime >= dd;
dd_tbl = f(dd_l, :);
quart_l = f.datetime >= f.datetime(end) - 365.25/4;
quart_tbl = f(quart_l, :);

% Average speed in each duration, after filtering idle times
avgDD = varfun(@mean, dd_tbl(~dd_tbl.idle, :), ...
    'InputVariables', 'speed', 'OutputFormat', 'Uniform');
avgQuart = varfun(@mean, quart_tbl(~quart_tbl.idle, :), ...
    'InputVariables', 'speed', 'OutputFormat', 'Uniform');

% Activity in each duration is proportion of time non-idle
actDD = varfun(@(x) 100 - mean(x)*100, dd_tbl, ...
    'InputVariables', 'idle', 'OutputFormat', 'Uniform');
actQuart = varfun(@(x) 100 - mean(x)*100, quart_tbl, ...
    'InputVariables', 'idle', 'OutputFormat', 'Uniform');

% Idle
[idleDurDD, idleStartDD, idleEndDD] = idle(dd_tbl);
[idleDurQuart, idleStartQuart, idleEndQuart] = idle(quart_tbl);
idleDD = days(max(idleDurDD));

% If idle period overlaps start of previous quarter, count all of it in to 
% previous quarter
if idleStartQuart(1) == quart_tbl.datetime(1)
    
    idleStartQuart_i = find(idleStartDD < quart_tbl.datetime(1), 1, 'last');
    idleDurQuart(1) = idleDurDD(idleStartQuart_i);
    idleStartQuart(1) = idleStartDD(idleStartQuart_i);
    idleEndQuart(1) = idleEndDD(idleStartQuart_i);
end
idleQuart = days(max(idleDurQuart));

% Create output table
trading_tbl = table([avgDD; actDD; idleDD], [avgQuart; actQuart; idleQuart], ...
    'VariableNames', {'Actual_in_DD_interval', 'Actual_last_quarter'},...
    'RowNames', {'Average speed [knots]', 'Activity [%]', ...
                'Longest idle period [days]'});
idleDD_tbl = table(idleStartDD, idleEndDD, round(days(idleDurDD), 1), 'VariableNames',...
    {'IdlePeriodStart', 'IdlePeriodEnd', 'IdlePeriodDays'});
idleQuart_tbl = table(idleStartQuart, idleEndQuart, round(days(idleDurQuart), 1), 'VariableNames',...
    {'IdlePeriodStart', 'IdlePeriodEnd', 'IdlePeriodDays'});

% Format tables for report
if format_l
    
    trading_tbl(1, :) = varfun(@(x) round(x, 1), trading_tbl(1, :));
    trading_tbl(2:end, :) = varfun(@(x) round(x), trading_tbl(2:end, :));
end

    function [idleDur, idleStart, idleEnd] = idle(t)
        
        % Idle periods start and end where DIFF of logical vector is non-zero
        idleStarts_l = diff(t.idle) == 1;
        idleStart = t.datetime(idleStarts_l);
        idleEnds_l = diff(t.idle) == -1;
        idleEnd = t.datetime(idleEnds_l);
        
        % Idle period starts before start of data
        if t.idle(1)
            
            idleStart = [t.datetime(1); idleStart];
        end
        
        % Account for case where idle period doesn't end before data ends
        if length(idleStart) > length(idleEnd)
            
            idleStart(end) = [];
        end
        
        % Idle period duration is time diff between start and end
        idleDur = idleEnd - idleStart;
    end
end