function [ obj, ddPer ] = dryDockingPerformance( obj, varargin )
%dryDockingPerformance Performance improvement due to dry-docking.
%   Detailed explanation goes here

% Inputs
% varname = 'Performance_Index';
% if nargin > 1
%     
%     checkVarname( perStruct, varargin{1} );
% end

% Output
ddPer = struct('AvgPerPrior', [], 'AvgPerAfter', [], ...
    'AbsDDPerformance', [], 'RelDDPerformance', []);
szIn = size(obj);
nDDi = szIn(1);
szOut = szIn;
szOut(1) = szOut(1) - 1;
ddPer = repmat(ddPer, szOut);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);

% Get annual averages before and after dry-dockings
[~, annualAvgAft] = movingAverages(obj, 365.25, false);
[~, annualAvgBef] = movingAverages(obj, 365.25, true);

% Iterate over guarantee struct to get averages
idx_c = cell(1, ndims(obj));
for ii = 1:nDDi:numel(obj)
   
   [idx_c{:}] = ind2sub(szIn, ii);
   
   % Plot each DDi separately
   for ddi = 2:nDDi
       
       % Skip DDi if empty
       currData = obj(ddi, idx_c{2:end});
       if all(isnan(currData.(currData.Variable)))
           continue
       end
       
       % Compare with previous dry docking
       avgBefore = annualAvgBef(ddi - 1, idx_c{2:end}).Duration(1)...
           .Average(end);
       avgAfter = annualAvgAft(ddi, idx_c{2:end}).Duration(1).Average(1);
       ddPerAbs = (avgAfter - avgBefore) * 100;
       ddPerRel = - ((avgBefore - avgAfter) / avgBefore) * 100;
       
       % Assign
       ddPer(ddi - 1, idx_c{2:end}).AvgPerPrior = avgBefore;
       ddPer(ddi - 1, idx_c{2:end}).AvgPerAfter = avgAfter;
       ddPer(ddi - 1, idx_c{2:end}).AbsDDPerformance = ddPerAbs;
       ddPer(ddi - 1, idx_c{2:end}).RelDDPerformance = ddPerRel;
       obj(idx_c{:}).DryDockingPerformance = ddPer;
   end
end