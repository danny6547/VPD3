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
szIn(1) = szIn(1) - 1;
ddPer = repmat(ddPer, szIn);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);

% Get annual averages before and after dry-dockings
[~, annualAvgAft] = movingAverages(obj, 365.25, false);
[~, annualAvgBef] = movingAverages(obj, 365.25, true);

% Iterate over guarantee struct to get averages

while ~obj.iterFinished
   
      [obj, ii, afterDDi, beforeDDi, DDi] = obj.iterDD;
   
% idx_c = cell(1, ndims(obj));
% for ii = 1:nDDi:numel(obj)
%    
%    [idx_c{:}] = ind2sub(szIn, ii);
%    
%    % Plot each DDi separately
%    for ddi = 2:nDDi
       
       % Skip DDi if empty
%        currData = obj(ii);
       if isPerDataEmpty(obj(ii)); % all(isnan(currData.(currData.Variable)))
           continue
       end
       
       % Compare with previous dry docking
       if ~isempty(annualAvgBef(beforeDDi).Duration(1).Average) && ...
               ~isempty(annualAvgAft(afterDDi).Duration(1).Average)
           
           avgBefore = annualAvgBef(beforeDDi).Duration(1)...
               .Average(end);
           avgAfter = annualAvgAft(afterDDi).Duration(1).Average(1);
           ddPerAbs = (avgAfter - avgBefore) * 100;
           ddPerRel = - ((avgBefore - avgAfter) / avgBefore) * 100;
       end
       
       % Assign
       ddPeri = DDi;
       ddPer(ddPeri).AvgPerPrior = avgBefore;
       ddPer(ddPeri).AvgPerAfter = avgAfter;
       ddPer(ddPeri).AbsDDPerformance = ddPerAbs;
       ddPer(ddPeri).RelDDPerformance = ddPerRel;
       obj(ii).DryDockingPerformance = ddPer(ddPeri);
%    end
end
obj = obj.iterReset;