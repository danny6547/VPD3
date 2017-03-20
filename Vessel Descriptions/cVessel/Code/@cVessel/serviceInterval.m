function [obj, servStruct] = serviceInterval(obj, varargin)
%serviceInterval Service intervals in months
%   Detailed explanation goes here

% Output
servStruct = struct('ServiceInterval', [], 'Units', '');
sz = size(obj);
servStruct = repmat(servStruct, sz);

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
while ~obj.iterFinished
% for ii = 1:numel(obj)
   
   % Iterate
   [obj, ii] = obj.iter;
%    [idx_c{:}] = ind2sub(sz, ii);
%    currData = obj(ii);
   
   % Skip DDi if empty
   if obj(ii).isPerDataEmpty
       continue
   end
   
   % Get range of date numbers in days
   dates = obj(ii).DateTime_UTC; % datenum(currData.DateTime_UTC, 'dd-mm-yyyy');
   numdays = max(dates) - min(dates);
   dvec = datevec(numdays);
   
   % Convert to units
   switch units
       case 'days'
           interval = numdays;
       case 'weeks'
           interval = numdays / 7;
       case 'months'
           if calendar_l
               interval = dvec(1) * 12 + dvec(2);
           else
               avgMonth = 30.4375;
               interval = numdays / avgMonth;
           end
       case 'years'
           if calendar_l
               interval = dvec(1);
           else
               avgYear = 365.25;
               interval = avgYear / numdays;
           end
   end
   
   % Assign into output
   servStruct(ii).ServiceInterval = interval;
   servStruct(ii).Units = units;
   obj(ii).ServiceInterval = interval;
   
end
obj = obj.iterReset;
