function [obj, act, maxIdle] = activity(obj, varargin)
%activity Calculate activity from in-service data
%   Detailed explanation goes here

% Output
maxIdle = nan;
act = nan;
% maxIdleStart = nan;

% Input
dur_l = false;
if nargin > 1
    
    dur_l = true;
    dur = varargin{1};
    validateattributes(dur, {'numeric'}, {'real', 'scalar', 'positive'});
end

% Raw data
obj = obj.rawData;

while obj.iterateDD
    
    [currDD_tbl, currObj, ddi] = obj.currentDD;
    
    % Detect frequency
%     dates_v = currDD_tbl.datetime_utc;
%     diff_v = diff(dates_v);
%     uniDiff_v = unique(diff_v);
%     uniDiffCount_v = arrayfun(@(x) sum(diff_v == x), uniDiff_v);
%     [~, mostCommonDiff_i] = max(uniDiffCount_v);
%     dataTimeStep = uniDiff_v(mostCommonDiff_i);
    
    % Calculate for specified duration only
    dates_v = currDD_tbl.datetime_utc;
    if dur_l
        
        minTime = max(dates_v) - dur;
        time2rm_l = dates_v < minTime;
        dates_v(time2rm_l) = [];
        currDD_tbl(time2rm_l, :) = [];
    end
    
    % Duration covered by data is timestep times number of steps
    idleThreshold = 1.02889;
    stw = currDD_tbl.speed_through_water;
    idle_l = isnan(stw);
    sei = find(diff(idle_l));
    
    starts_dt = datetime(dates_v(1:end-1), 'ConvertFrom', 'datenum');
    ends_dt =   datetime(dates_v(2:end),   'ConvertFrom', 'datenum');
    dur_dt = ends_dt - starts_dt;
    idle_l = idle_l | stw < idleThreshold;
    idle_l(1) = [];
    
    if isempty(sei)
        
        maxIdle(ddi) = nan();
        activity(ddi) = nan();
    else
    
        if sei(1) ~= 1

            sei = [1; sei];
        end
        if sei(end) ~= length(idle_l)

            sei = [sei; length(idle_l)];
        end

        idleDur_du = duration();
        if isequal(round(length(sei)/2), length(sei)/2)
            maxIter = length(sei)/2 - 1;
        else
            maxIter = length(sei)/2;
        end

        idleStartsi = find(diff(idle_l) == 1) + 1;
        idleEndsi = find(diff(idle_l) == -1);
        
        changes = diff(idle_l);
        firstChangei = find(changes, 1, 'first');
        firstChange = changes(firstChangei);
        if isequal(firstChange, -1)
            
            idleStartsi = [1; idleStartsi];
        end
        lastChangei = find(changes, 1, 'last');
        lastChange = changes(lastChangei);
        if isequal(lastChange, 1)
            
            idleEndsi = [idleEndsi; length(dur_dt)];
        end
        
        for si = 1:numel(idleStartsi)
            
            curri = idleStartsi(si):idleEndsi(si);
            currDur_du = dur_dt(curri);
            idleDur_du(end+1) = sum(currDur_du);
        end
        
%         for si = 1:2:maxIter
% 
%             curri = (sei(si)+1:sei(si+1)) - 1;
%             currDur_du = dur_dt(curri);
%             idleDur_du(end+1) = sum(currDur_du);
%         end
        idleDur_du(1) = [];
    %     dates_v(isnan(stw)) = [];
    %     stw(isnan(stw)) = [];

        idleDuration = sum(idleDur_du);
        totalDruation = sum(dur_dt);

        % Maximum continuous idle periods
        maxIdle_du = max(idleDur_du);
        maxIdle = days(maxIdle_du);
    %     maxIdleStart_dt = starts_dt(maxIdlei);
    %     maxIdleStart = datenum(maxIdleStart_dt);

    %     dataDuration = dataTimeStep*height(currDD_tbl);

        % Activity is duration covered by data over total duration
    %     totalDruation = max(dates_v) - min(dates_v);
    %     activity = dataDuration/totalDruation;
        activity(ddi) = 1 - idleDuration/totalDruation;
    end
    
    % Assign
    currObj.Report.Activity(ddi) = activity(ddi);
    act = activity(ddi);
end
