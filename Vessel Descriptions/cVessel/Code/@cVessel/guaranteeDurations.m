function [ obj, guarStruct ] = guaranteeDurations(obj, varargin)
%guaranteeDurations Calculate values relevant to performance guarantees
%   Detailed explanation goes here

% Output
guarStruct = struct('StartMonth', [1, 13, 13, 13, 13], ...
                    'EndMonth', 12:12:60, ...
                    'Average', [], ...
                    'Difference', [], ...
                    'RelativeDifference', []);
guarStruct = repmat(guarStruct, size(obj));

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

while ~obj.iterFinished

% for ii = 1:numel(obj)
   
   % Iterate
   [obj, ii] = obj.iter;
   
%    [idx_c{:}] = ind2sub(sz, ii);
%    currData = obj(idx_c{:});
   
   % Skip DDi if empty
   if obj(ii).isPerDataEmpty
       continue
   end
   
   % Indices to data
   dat = obj(ii).DateTime_UTC; % unique(datenum(currData.DateTime_UTC, 'dd-mm-yyyy'));
   per = obj(ii).(obj(ii).Variable) * 100;
   [dat, dati] = sort(dat);
   per = per(dati);
   relStartDates = ( guarStruct(ii).StartMonth - 1)*avgMonthDuration;
   relEndDates = ( guarStruct(ii).EndMonth) * avgMonthDuration;
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
    tstep = obj(ii).TimeStep;
    tstep_v = repmat(tstep, [1, size(absStartDates, 2)]);
    
    preStartDates = absStartDates - 0.5*tstep_v;
    postEndDates = absEndDates - 0.5*tstep_v;
    
%     startDates = preStartDates;
%     endDates = [preStartDates(2:end), postEndDates(end)];
%    
%    [~, starti, ~] = FindNearestInVector(preStartDates, dat);
%    [~, endi, ~] = FindNearestInVector(postEndDates, dat);
   
   % Averages and differences
   avg = nan(1, numel( guarStruct(ii).StartMonth ));
   avg(~outOfRange_l) = arrayfun(@(x, y) nanmean(per(dat >= x & dat < y)),...
       preStartDates, postEndDates);
   baseline = repmat(avg(1), [1, numel(avg) - 1]);
   evaluations = avg(2:end);
   dif = baseline - evaluations;
   reldif = ( dif ./ baseline ) * 100;
   
   % Output
   guarStruct(ii).Average = avg;
   guarStruct(ii).Difference = dif;
   guarStruct(ii).RelativeDifference = reldif;
   obj(ii).GuaranteeDurations = guarStruct(ii);
end
obj = obj.iterReset;