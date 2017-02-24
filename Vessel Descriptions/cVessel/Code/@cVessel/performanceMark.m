function [ obj, markStruct ] = performanceMark(obj, varargin)
%performanceMark Assign performance mark to performance data
%   Detailed explanation goes here

% Output
markStruct = struct('PerformanceMark', '');
sz = size(obj);
markStruct = repmat(markStruct, sz);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);
grade = {-inf, 5, 'green'; 5, 10, 'yellow'; 10, inf, 'red'};
if nargin > 1
    grade = varargin{1};
    validateattributes(obj, {'cell'}, {'matrix'}, 'performanceMark',...
        'grade', 2);
end

% Get all "power increase over service interval"
% guarStruct = guaranteeDurations(obj);

grade_m = cell2mat(grade(:, 1:2));
grade_c = grade(:, 3);

% Iterate over guarantee struct to get averages
idx_c = cell(1, ndims(obj));
for ii = 1:numel(obj)
   
   [idx_c{:}] = ind2sub(sz, ii);
   % currData = guarStruct(idx_c{:});
   currData = obj(idx_c{:}).GuaranteeDurations;
   
   % Skip DDi if empty
   if obj(ii).isPerDataEmpty
       continue
   end
   
   if all(isnan(currData.Difference)) || all(isnan(currData.RelativeDifference))
       continue
   end
   
   % Get this "power increase over service interval"
    currRelDiff = currData.RelativeDifference;
    powerInc = currRelDiff(find(~isnan(currRelDiff), 1, 'last'));
    
    % Assign value based on grade
    grade_l = powerInc >= grade_m(:, 1) & powerInc < grade_m(:, 2);
    grade_s = [grade_c{grade_l}];
    markStruct(idx_c{:}).PerformanceMark = grade_s;
    obj(idx_c{:}).PerformanceMark = grade_s;
end