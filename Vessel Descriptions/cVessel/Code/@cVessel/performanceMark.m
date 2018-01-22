function [ obj, perfMark ] = performanceMark(obj, varargin)
%performanceMark Assign performance mark to performance data
%   obj = performanceMark(obj) will generate a structure with field
%   'PerformanceMark' in the PerformanceMark property of OBJ, containing a
%   string which corresponds to a range of values for the relative 
%   difference in performance between the first year of the dry-docking 
%   interval and the remaining years. This method requires 
%   'guaranteeDurations' to have been run first. The strings are 'green' 
%   for below 5, 'yellow' for between 5 and 10, and 'red' for above 10.
%   obj = performanceMark(obj, grade) will return in property 
%   'PerformanceMark' the strings contained in the third column of cell
%   array GRADE, where the first column contains the corresponding minimum
%   performance difference and the second the corresponding maximum.

% Output
markStruct = struct('PerformanceMark', '');
perfMark = struct('DryDockInterval', markStruct);
% sz = size(obj);
% markStruct = repmat(markStruct, sz);

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
% while ~obj.iterFinished
while obj.iterateDD
    
%    [obj, ii] = obj.iter;
    [~, currVessel, ddi, vi] = obj.currentDD;
% idx_c = cell(1, ndims(obj));
% for ii = 1:numel(obj)
   
%    % Skip DDi if empty
%    if obj(ii).isPerDataEmpty
%        continue
%    end

%    [idx_c{:}] = ind2sub(sz, ii);
   % currData = guarStruct(idx_c{:});
%    currData = obj(ii).GuaranteeDurations;
   currData = currVessel.GuaranteeDurations(ddi);
   
   if all(isnan(currData.Difference)) || all(isnan(currData.RelativeDifference))
       continue
   end
   
    % Get this "power increase over service interval"
    currRelDiff = currData.RelativeDifference;
    powerInc = currRelDiff(find(~isnan(currRelDiff), 1, 'last'));
    
    % Assign value based on grade
    grade_l = powerInc >= grade_m(:, 1) & powerInc < grade_m(:, 2);
    grade_s = [grade_c{grade_l}];
    markStruct.PerformanceMark = grade_s;
    
    perfMark(vi).DryDockInterval(ddi) = markStruct;
%     obj(ii).PerformanceMark = grade_s;
    
    if ddi == currVessel.numDDIntervals
        
        currVessel.PerformanceMark = perfMark(vi).DryDockInterval;
    end
end
% obj = obj.iterReset;