function [ obj, guarantee ] = guaranteeDurations(obj, varargin)
%guaranteeDurations Calculate values relevant to performance guarantees
%   obj = guaranteeDurations(obj) will return in property
%   'GuaranteeDurations' a struct giving average performance values over
%   durations defined by start and end months, the difference between these
%   averages and that of the reference period and the corresponding 
%   relative differences. These data are contained in appropriately named
%   fields.
%   obj = guaranteeDurations(obj, remove) will not calculate values for
%   durations for which there is insufficient data when REMOVE is TRUE. The
%   default is FALSE.
%   [obj, guarStruct] = guaranteeDurations(obj, ...) will, in addition to
%   the above, also return in GUARSTRUCT the same struct as was assigned to
%   property 'GuaranteeDurations'.

% Output
guarStruct = struct('StartMonth', [1, 13, 13, 13, 13], ...
                    'EndMonth', 12:12:60, ...
                    'Average', [], ...
                    'Difference', [], ...
                    'RelativeDifference', []);
guarantee = struct('DryDockInterval', guarStruct);
% guarStruct = repmat(guarStruct, size(obj));

% Input
% validateattributes(obj, {'struct'}, {});

remove_l = false;
if nargin > 1
    remove_l = varargin{1};
    validateattributes(remove_l, {'logical'}, {'scalar'});
end

% idx_c = cell(1, ndims(obj));
% sz = size(obj);
avgMonthDuration = 365.25 / 12;

% while ~obj.iterFinished
while obj.iterateDD

% for ii = 1:numel(obj)
   
   % Iterate
   [currTable, currVessel, ddi, vi] = obj.currentDD;
    
%    % Iterate
%    [obj, ii] = obj.iter;
%    [idx_c{:}] = ind2sub(sz, ii);
%    currData = obj(idx_c{:});
   
%    % Skip DDi if empty
%    if obj(ii).isPerDataEmpty
%        continue
%    end
   
   % Indices to data
   dat = currTable.DateTime_UTC; % unique(datenum(currData.DateTime_UTC, 'dd-mm-yyyy'));
   per = currTable.(currVessel.Variable) * 100;
   [dat, dati] = sort(dat);
   per = per(dati);
   relStartDates = ( guarStruct.StartMonth - 1)*avgMonthDuration;
   relEndDates = ( guarStruct.EndMonth) * avgMonthDuration;
   absStartDates = min(dat) + relStartDates;
   absEndDates = min(dat) + relEndDates;
   
   % Filter dates after end, before start
   tooLate_l = absEndDates > max(dat);
   
   if ~remove_l
       tooLate_l(find(tooLate_l, 1)) = false;
   end
   
   tooEarly_l = absStartDates < min(dat);
   outOfRange_l = tooLate_l | tooEarly_l;
   absStartDates(outOfRange_l) = [];
   absEndDates(outOfRange_l) = [];
   
%     tstep = unique(diff(dat));
%     tstep(tstep==0) = [];
    tstep = currVessel.TimeStep;
    tstep_v = repmat(tstep, [1, size(absStartDates, 2)]);
    
    preStartDates = absStartDates - 0.5*tstep_v;
    postEndDates = absEndDates - 0.5*tstep_v;
    
%     startDates = preStartDates;
%     endDates = [preStartDates(2:end), postEndDates(end)];
%    
%    [~, starti, ~] = FindNearestInVector(preStartDates, dat);
%    [~, endi, ~] = FindNearestInVector(postEndDates, dat);
   
   % Averages and differences
   avg = nan(1, numel( guarStruct.StartMonth ));
   avg(~outOfRange_l) = arrayfun(@(x, y) nanmean(per(dat >= x & dat < y)),...
       preStartDates, postEndDates);
   baseline = repmat(avg(1), [1, numel(avg) - 1]);
   evaluations = avg(2:end);
   dif = baseline - evaluations;
   reldif = ( dif ./ baseline ) * 100;
   
   guarStruct.Average = avg;
   guarStruct.Difference = dif;
   guarStruct.RelativeDifference = reldif;
   
   % Output
%    guarantee(vi).DryDockInterval(ddi).Average = avg;
%    guarantee(vi).DryDockInterval(ddi).Difference = dif;
%    guarantee(vi).DryDockInterval(ddi).RelativeDifference = reldif;
   guarantee(vi).DryDockInterval(ddi) = guarStruct;
   if ddi == currVessel.numDDIntervals
       
       currVessel.GuaranteeDurations = guarantee(vi).DryDockInterval;
   end
end
% obj = obj.iterReset;