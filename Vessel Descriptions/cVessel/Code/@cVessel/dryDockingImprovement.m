function [ obj, ddImprove ] = dryDockingImprovement( obj, varargin )
%dryDockingPerformance Performance improvement due to dry-docking.
%   Detailed explanation goes here

% Inputs
% varname = 'Performance_Index';
% if nargin > 1
%     
%     checkVarname( perStruct, varargin{1} );
% end

% Output
ddImp = struct('AvgPerPrior', [], 'AvgPerAfter', [], ...
    'AbsDDImprovement', [], 'RelDDImprovement', [], 'ReferenceCount', [],...
    'EvaluationCount', [], 'ReferenceStartDate', [], 'ReferenceEndDate', [],...
    'EvaluationStartDate', [], 'EvaluationEndDate', []);
ddImprove = struct('DryDockingInterval', ddImp);
% [obj.Report.DryDockingImprovement] = deal(ddImp);
% szIn = size(obj);
% szIn(1) = szIn(1) - 1;
% ddImp = repmat(ddImp, szIn);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);

% Get annual averages before and after dry-dockings
[~, annualAvgAft] = movingAverage(obj, (365.25)/4, false);
[~, annualAvgBef] = movingAverage(obj, (365.25)/4, true);

% Iterate over guarantee struct to get averages

while obj.iterateDD
% while ~obj.iterFinished
   
%       [obj, ii, afterDDi, beforeDDi, DDi] = obj.iterDD;
   
% idx_c = cell(1, ndims(obj));
% for ii = 1:nDDi:numel(obj)
%    
%    [idx_c{:}] = ind2sub(szIn, ii);
%    
%    % Plot each DDi separately
%    for ddi = 2:nDDi
%        
%        % Skip to end if fewer avg than vessels
%        if afterDDi > numel(annualAvgBef)
%            [obj.IterFinished] = deal(true);
%            break
%        end
%        % Skip DDi if empty
%        if isPerDataEmpty(obj(ii))
%            continue
%        end
    
    % 
    [~, currVessel, ddi, vi] = obj.currentDD;
    
    if ddi == 1
        continue
    end
    
    % If there are at least one years worth of data either side of DD
    if ~isempty(annualAvgBef(vi).DryDockInterval(ddi-1).Average) && ...
           ~isempty(annualAvgAft(vi).DryDockInterval(ddi).Average)
%         ~isempty(annualAvgBef(vi).DryDockInterval(ddi)) && ...
%            ~isempty(annualAvgAft(vi).DryDockInterval(ddi)) && ...
       
       % Compare with previous dry docking
       avgBefore = annualAvgBef(vi).DryDockInterval(ddi-1).Average(end);
       avgAfter = annualAvgAft(vi).DryDockInterval(ddi).Average(1);
       ddImpAbs = (avgAfter - avgBefore) * 100;
       ddImpRel = - ((avgBefore - avgAfter) / avgBefore) * 100;
       
       % Assign
       ddImp(1).AvgPerPrior = avgBefore;
       ddImp(1).AvgPerAfter = avgAfter;
       ddImp(1).AbsDDImprovement = ddImpAbs;
       ddImp(1).RelDDImprovement = ddImpRel;
       ddImp(1).ReferenceCount = annualAvgBef(vi).DryDockInterval(ddi-1).Count(end);
       ddImp(1).EvaluationCount = annualAvgAft(vi).DryDockInterval(ddi).Count(1);

       ddImp(1).ReferenceStartDate = datestr(annualAvgBef(vi).DryDockInterval(ddi-1).StartDate(end));
       ddImp(1).ReferenceEndDate = datestr(annualAvgBef(vi).DryDockInterval(ddi-1).EndDate(end));
       ddImp(1).EvaluationStartDate = datestr(annualAvgAft(vi).DryDockInterval(ddi).StartDate(1));
       ddImp(1).EvaluationEndDate = datestr(annualAvgAft(vi).DryDockInterval(ddi).EndDate(1));
       
       ddImprove(vi).DryDockingInterval(ddi-1) = ddImp;
       currVessel.Report.DryDockingImprovement(ddi-1) = ddImp;
%        obj(vi).DryDockingImprovement = ddImp(ddi);
    end
   
%    % Assign into vessel
%    if ddi == currVessel.numDDIntervals
%         currVessel.DryDockingImprovement = ddImp;
%    end
%    end
end

% obj.
% obj = obj.iterReset;