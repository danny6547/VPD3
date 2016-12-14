function servStruct = serviceInterval(perData, varargin)
%serviceInterval Service intervals in months
%   Detailed explanation goes here

% Output
servStruct = struct('ServiceInterval', [], 'Units', '');
sz = size(perData);
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

idx_c = cell(1, ndims(perData));
for ii = 1:numel(perData)
   
   % Iterate
   [idx_c{:}] = ind2sub(sz, ii);
   currData = perData(idx_c{:});
   
   % Skip DDi if empty
   if all(isnan(currData.Performance_Index))
       continue
   end
   
   % Get range of date numbers in days
   dates = datenum(currData.DateTime_UTC, 'dd-mm-yyyy');
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
   servStruct(idx_c{:}).ServiceInterval = interval;
   servStruct(idx_c{:}).Units = units;
   
end