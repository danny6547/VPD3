function [ figHandles, dataLines, avgLines ] = plotPerformanceData(perfData, varargin)
%plotPerformanceData Plot performance against time, with statistics.
%   figHandles = plotPerformanceData(perfData) will return in FIGHANDLES an
%   array of figure handles to graphs containing the data in the
%   corresponding elements of PERFDATA. FIGHANDLES will be the same size as
%   PERFDATA.


% Inputs
dataLines = [];
avgLines = [];

avg_l = false;
numDur = 1;
if nargin > 1
    avg_l = true;
    avgStruct = varargin{1};
    validateattributes(avgStruct, {'struct'}, {}, 'plotPerformanceData',...
        'avgStruct', 2);
    numDur = numel(avgStruct(1).Duration);
end


% Plot all dry dock intervals for each vessel
sz = size(perfData);
nDDi = sz(1);
if ismatrix(perfData)
    szOut = [1, sz(2)];
else
    szOut = sz(2:end);
end

figHandles = nan(szOut);

idx_c = cell(1, ndims(perfData));
lineColours_m = get(groot, 'defaultAxesColorOrder');
numColours = size(lineColours_m, 1);
DDColourOrder = repmat(1:numColours, [1, ceil(nDDi/numColours)]);

for ii = 1:nDDi:numel(perfData)
   
   currFig = figure;
   currAx = axes('Parent', currFig);
   
   % Find indices into input struct
   [idx_c{:}] = ind2sub(sz, ii);
   
   % Plot each DDi separately
   for ddi = 1:nDDi
       
       % Skip DDi if empty
       currData = perfData(ddi, idx_c{2:end});
       if all(isnan(currData.Performance_Index))
           continue
       end
       
       % Get data series colour
       currColour = lineColours_m(DDColourOrder(ddi), :);
       
       % Plot data
       hold on
       pi_line = plot(currAx, datenum(currData.Date, 'dd-mm-yyyy'), ...
           currData.Performance_Index * 100, 'o', 'Color', currColour);
       hold off
       pi_line.MarkerFaceColor = pi_line.Color;
       
       vesselNum = unique(currData.IMO);
       
       % Plot averages
       if avg_l
           
           currAvg_st = avgStruct(ddi, idx_c{2:end});
           
           % Make average colors a series of increasingly light orange
%            numDur = numel(currAvg.Duration);
           whiteLimit = 0.8;
           avgColours = [ones(numDur, 1), linspace(0.5, whiteLimit, numDur)',...
               linspace(0, whiteLimit, numDur)'];
           
           for di = 1:numDur;
               
               currDur = currAvg_st.Duration(di);
               currStart = currDur.StartDate;
               currEnd = currDur.EndDate;
               currAvg = currDur.Average * 100;
               
               hold on
               avgLines(end+1:end+numel(currAvg)) = ...
                   line([currStart; currEnd], [currAvg; currAvg],...
                   'Color', avgColours(di, :),...
                   'LineWidth', 2);
               avgLines(end+1:end+numel(currAvg)) = ...
                   line(currEnd(:), currAvg(:), 'Color', avgColours(di, :),...
                   'LineStyle', 'none',...
                   'Marker', 'o',...
                   'MarkerFaceColor', avgColours(di, :),...
                   'MarkerSize', 10);
               hold off
           end
       end
   end
   
   % Vertical starts at zero
   oldy = get(currAx, 'YLim'); 
   set(currAx, 'YLim', [0, oldy(2)]);

   % Put ticks on axis keeping horizontal ticks and limits
%    oldxlim = get(currAx, 'XLim');
%    oldxtick = get(currAx, 'XTick');
   datetick('x');
%    set(currAx, 'XLim', oldxlim); 
%    set(currAx, 'XTick', oldxtick);
   
   % Assign figure handle into outputs
   figHandles(idx_c{2:end}) = currFig;
   
   % Labels
   labFontsz = 12;
   ylabel('Performance Index ( % )', 'fontsize', labFontsz);
   
   titleFontsz = 13;
   vesselName_ch = vesselName(vesselNum);
   titleStr = ['Performance Index against Time for Vessel ' vesselName_ch];
   title(titleStr, 'fontsize', titleFontsz);
   
end