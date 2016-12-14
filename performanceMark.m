function [ markStruct ] = performanceMark(perData, varargin)
%performanceMark Assign performance mark to performance data
%   Detailed explanation goes here

% Output
markStruct = struct('PerformanceMark', '');
sz = size(perData);
markStruct = repmat(markStruct, sz);

% Input
validateattributes(perData, {'struct'}, {}, 'performanceMark', 'perData',...
    1);
grade = {-inf, 5, 'green'; 5, 10, 'yellow'; 10, inf, 'red'};
if nargin > 1
    grade = varargin{1};
    validateattributes(perData, {'cell'}, {'matrix'}, 'performanceMark',...
        'grade', 2);
end

% Get all "power increase over service interval"
guarStruct = guaranteeDurations(perData);

grade_m = cell2mat(grade(:, 1:2));
grade_c = grade(:, 3);

% Iterate over guarantee struct to get averages
idx_c = cell(1, ndims(guarStruct));
for ii = 1:numel(guarStruct)
   
   [idx_c{:}] = ind2sub(sz, ii);
   currData = guarStruct(idx_c{:});
   
   % Skip DDi if empty
   if all(isnan(currData.RelativeDifference))
       continue
   end
   
   % Get this "power increase over service interval"
    currRelDiff = currData.RelativeDifference;
    powerInc = currRelDiff(find(~isnan(currRelDiff), 1, 'last'));
    
    % Assign value based on grade
    grade_l = powerInc >= grade_m(:, 1) & powerInc < grade_m(:, 2);
    grade_s = [grade_c{grade_l}];
    markStruct(idx_c{:}).PerformanceMark = grade_s;
    
end