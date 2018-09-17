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
% szIn = size(obj);
% szIn(1) = szIn(1) - 1;
% ddPer = repmat(ddPer, szIn);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);

% Get annual averages before and after dry-dockings
[~, annualAvgAft] = obj.movingAverage(365.25, false);
[~, annualAvgBef] = obj.movingAverage(365.25, true);

% Iterate over guarantee struct to get averages

while obj.iterateDD
   
%       [obj, ii, afterDDi, beforeDDi, DDi] = obj.iterDD;
      [~, currVessel, DDi, vi] = obj.currentDD;
      
      if DDi == 1
          
          continue
      end
      beforeDDi = DDi - 1;
      afterDDi = DDi;
   
% idx_c = cell(1, ndims(obj));
% for ii = 1:nDDi:numel(obj)
%    
%    [idx_c{:}] = ind2sub(szIn, ii);
%    
%    % Plot each DDi separately
%    for ddi = 2:nDDi
       
       % Skip to end if fewer avg than vessels
       if afterDDi > numel(annualAvgBef)
           [obj.IterFinished] = deal(true);
           break
       end

       % Skip DDi if empty
       if isPerDataEmpty(obj(vi))
           continue
       end
       
       % If there are at least one years worth of data either side of DD
       if ~isempty(annualAvgBef(beforeDDi).Duration) && ...
               ~isempty(annualAvgAft(afterDDi).Duration) && ...
                   ~isempty(annualAvgBef(beforeDDi).Duration(1).Average) && ...
                       ~isempty(annualAvgAft(afterDDi).Duration(1).Average)
           
           % Compare with previous dry docking
           avgBefore = annualAvgBef(beforeDDi).Duration(1).Average(end);
           avgAfter = annualAvgAft(afterDDi).Duration(1).Average(1);
           ddPerAbs = (avgAfter - avgBefore) * 100;
           ddPerRel = - ((avgBefore - avgAfter) / avgBefore) * 100;
        
           % Assign
           ddPeri = DDi;
           ddPer(ddPeri).AvgPerPrior = avgBefore;
           ddPer(ddPeri).AvgPerAfter = avgAfter;
           ddPer(ddPeri).AbsDDPerformance = ddPerAbs;
           ddPer(ddPeri).RelDDPerformance = ddPerRel;
           currVessel.Report(ddPeri).DryDockingPerformance = ddPer(ddPeri);
       end
%    end
end
% obj = obj.iterReset;