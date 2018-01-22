function [obj, servStruct] = serviceInterval(obj, varargin)
%serviceInterval Service intervals in months
%   Detailed explanation goes here

% Output
interval = struct('Duration', [], 'Units', [], 'StartDate', [], 'EndDate', []);
% servStruct = struct('Duration', [], 'Units', [], 'StartDate', [], 'EndDate', []);
servStruct = struct('DryDockInterval', interval);
% sz = size(obj);
% servStruct = repmat(servStruct, sz);

% Input
units = 'months';
if nargin > 1
    units = varargin{1};
    validateattributes(units, {'char'}, {'vector'}, 'serviceInterval', ...
        'units', 2);
end
calendar_l = true;
if nargin > 2
    calendar_l = varargin{2};
    validateattributes(calendar_l, {'logical'}, {'scalar'}, 'serviceInterval', ...
        'calendar', 3);
end

% idx_c = cell(1, ndims(obj));
% while ~obj.iterFinished
[obj.ServiceInterval] = deal(servStruct);

while obj.iterateDD
% for ii = 1:numel(obj)
   
   % Iterate
%    [obj, ii] = obj.iter;
   [currTable, currVessel, ddi, vi] = obj.currentDD;
%    [idx_c{:}] = ind2sub(sz, ii);
%    currData = obj(ii);
   
%    % Skip DDi if empty
%    if obj(ii).isPerDataEmpty
%        continue
%    end
   
   % Get range of date numbers in days
%    dates = obj(ii).DateTime_UTC; % datenum(currData.DateTime_UTC, 'dd-mm-yyyy');
   dates = currTable.DateTime_UTC;
   numdays = max(dates) - min(dates);
   dvec = datevec(numdays);
   
   % Convert to units
   switch units
       case 'days'
           duration = numdays;
       case 'weeks'
           duration = numdays / 7;
       case 'months'
           if calendar_l
               duration = dvec(1) * 12 + dvec(2);
           else
               avgMonth = 30.4375;
               duration = numdays / avgMonth;
           end
       case 'years'
           if calendar_l
               duration = dvec(1);
           else
               avgYear = 365.25;
               duration = avgYear / numdays;
           end
   end
   
   % Start and End dates
   interval = struct('Duration', [], 'Units', [], 'StartDate', [], 'EndDate', []);
   interval.Duration = duration;
   interval.Units = units;
   interval.StartDate = datestr(min(dates), currVessel.DateFormStr);
   interval.EndDate = datestr(max(dates), currVessel.DateFormStr);
   
   % Assign into output
   servStruct(vi).DryDockInterval(ddi) = interval;
   
   % Assign into obj
   if ddi == currVessel.numDDIntervals
       
       currVessel.ServiceInterval = servStruct(vi).DryDockInterval;
   end
end

% obj = obj.iterReset;