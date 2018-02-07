function [obj, figHandles, dataLines, avgLines, regrLines, semLines ] = plotPerformanceData(obj, varargin)
%plotPerformanceData Plot performance against time, with statistics.
%   figHandles = plotPerformanceData(obj) will return in FIGHANDLES an
%   array of figure handles to graphs containing the data in the
%   corresponding elements of PERFDATA. FIGHANDLES will be the same size as
%   PERFDATA.


% Inputs
dataLines = [];
avgLines = [];
regrLines = [];
semLines = [];
% if nargin > 3
%     
%     varname = varargin{3};
%     validateattributes(varname, {'char'}, {'vector'}, 'plotPerformanceData',...
%         'varname', 4);
% end

% Plot all dry dock intervals for each vessel
sz = size(obj);
nDDi = sz(1);
if ismatrix(obj)
    szOut = [1, sz(2)];
else
    szOut = sz(2:end);
end

% figHandles = nan(szOut);

% idx_c = cell(1, ndims(obj));
lineColours_m = get(groot, 'defaultAxesColorOrder');
numColours = size(lineColours_m, 1);
DDColourOrder = repmat(1:numColours, [1, ceil(nDDi/numColours)]);

% for ii = 1:nDDi:numel(obj)
% figCount = length(findall(0,'type','figure')) + ...
%     length(findobj(0,'type','figure'));

nFigs = numel(obj);
figHandles = arrayfun(@(x) figure, nan(1, nFigs));
ax_v = arrayfun(@(x) axes('Parent', x), figHandles);
set(ax_v, 'NextPlot', 'add');

% while ~obj.iterFinished
while obj.iterateDD
   
%    [obj, ~, vesselI] = obj.iterVessel;
%    figCount = figCount + 1;

   [currDD_tbl, currVessel, ddi, vi] = obj.currentDD;
   
%    currFig = figHandles(vi);
   currAx = ax_v(vi);
   
%    currFig = figure;
%    currAx = axes('Parent', currFig);
   
%    % Temp code until I figure out how to iterate these things properly
%    if vesselI(1) > numel(obj)
%        break
%    end
%    currVessel = obj(vesselI(1));
   
   % Find indices into input struct
%    [idx_c{:}] = ind2sub(sz, ii);
   
%    % Plot each DDi separately
%    for ddii = 1:numel(vesselI) % nDDi
%        
%        ddi = vesselI(ddii);
       
       % Skip DDi if empty
%        currData = obj(ddi);
       varname = currVessel.Variable;
       if currVessel.isPerDataEmpty
           continue
       end
      
        avg_l = false;
        numDur = 1;
        if ~isempty(currVessel.Report.MovingAverage)

            avg_l = true;
            avgStruct = currVessel.Report.MovingAverage; % varargin{1};
            validateattributes(avgStruct, {'struct'}, {}, 'plotPerformanceData',...
                'avgStruct', 2);
            numDur = numel(avgStruct(1).Duration);
        end

        regr_l = false;
        if ~isempty(currVessel.Report.Regression)

            regr_l = true;
            regri = 1;
            regrStruct = currVessel.Report.Regression; %varargin{2};
            validateattributes(regrStruct, {'struct'}, {}, 'plotPerformanceData',...
                'regrStruct', 3);
        end

        % varname = obj.Variable; %'Performance_Index';
       
       % Get data series colour
       currColour = lineColours_m(DDColourOrder(ddi), :);
       
       % Plot data
%        hold on
       xdata = currDD_tbl.datetime_utc; % datenum(currData.DateTime_UTC, 'dd-mm-yyyy');
       ydata = currDD_tbl.(varname) * 100;
       pi_line = line(currAx, xdata, ydata);
%        hold off
        pi_line.LineStyle = 'none';
        pi_line.Marker = 'o';
        pi_line.Color = currColour;
       pi_line.MarkerFaceColor = pi_line.Color;
       dataLines(end+1) = pi_line;
       
%        %  
%        t = annotation('textbox');
%         sz = t.FontSize;
%         t.FontSize = 12;
%         t.String = 'DD Props';
       
       % Plot averages
       if avg_l
           
           currAvg_st = avgStruct(ddi); %(ddi);
           
           % Make average colors a series of increasingly light orange
%            numDur = numel(currAvg.Duration);
           whiteLimit = 0.8;
           avgColours = [ones(numDur, 1), linspace(0.5, whiteLimit, numDur)',...
               linspace(0, whiteLimit, numDur)'];
           
           for di = 1:numDur
               
               currDur = currAvg_st.Duration(di);
               currStart = currDur.StartDate;
               currEnd = currDur.EndDate;
               currAvg = currDur.Average * 100;
               
               hold on
               avgLines(end+1:end+numel(currAvg)) = ...
                   line(currAx, [currStart; currEnd], [currAvg; currAvg],...
                   'Color', avgColours(di, :),...
                   'LineWidth', 2);
               avgLines(end+1:end+numel(currAvg)) = ...
                   line(currAx, currEnd(:), currAvg(:), 'Color', avgColours(di, :),...
                   'LineStyle', 'none',...
                   'Marker', 'o',...
                   'MarkerFaceColor', avgColours(di, :),...
                   'MarkerSize', 10);
               
%                % Plot standard errors of mean
%                if isfield(currDur, 'StdOfMean')
%                    
%                    currSem = currDur.StdOfMean * 100;
%                    currTop = currAvg + currSem;
%                    currBot = currAvg - currSem;
%                    semLines(end+1:end+numel(currAvg)) = ...
%                        line([currStart; currEnd], [currBot; currBot],...
%                        'Color', avgColours(di, :),...
%                        'LineWidth', 2);
%                    semLines(end+1:end+numel(currAvg)) = ...
%                        line([currStart; currEnd], [currTop; currTop],...
%                        'Color', avgColours(di, :),...
%                        'LineWidth', 2);
%                end
               hold off
           end
       end
       
       % Plot regressions
       if regr_l
           
           for oi = 1:numel(currVessel.Report.Regression(ddi))
           
               currRegr_st = currVessel.Report.Regression(ddi).Order(oi);
    %            currRegr_st = regrStruct(ddi, idx_c{2:end});
               coeffs = currRegr_st.Coefficients;

               % Figure out plotting any order later...
               if numel(coeffs) == 2

                    m = coeffs(1);
                    c = coeffs(2);

                    x1 = linspace(min(xdata), max(xdata), 1e3);
                    y1 = ( m*x1 + c ) * 100;

                    % Regression lines are slightly darker than data points
                    currColour = currColour - 0.2;
                    currColour(currColour < 0) = 0;

                    hold on
                    regrLines(regri) = ...
                       line(currAx, x1, y1,...
                           'Color', currColour,...
                           'LineWidth', 2);
                    hold off
                    regri = regri + 1;
               end
           end
       end
%    end
   
   % Vertical starts at zero
%    oldy = get(currAx, 'YLim'); 
%    set(currAx, 'YLim', [0, oldy(2)]);

   % Put ticks on axis keeping horizontal ticks and limits
%    oldxlim = get(currAx, 'XLim');
%    oldxtick = get(currAx, 'XTick');
   
%    set(currAx, 'XLim', oldxlim); 
%    set(currAx, 'XTick', oldxtick);
   
%    % Assign figure handle into outputs
%    figHandles(vi) = currFig;
   
end
% obj = obj.iterReset;

for vi = 1:nFigs
    
   currAx = ax_v(vi);
   
   % Labels
   labFontsz = 12;
   varname = obj(vi).Variable;
   ylabel(currAx, [strrep(varname, '_', ' '), ' ( % )'], 'fontsize', labFontsz);
   
   % Get vessel name
   titleFontsz = 13;
   vesselName_ch = obj(vi).Name;
%    vesselName_ch = []; % vesselName(vesselNum);
   if isempty(vesselName_ch)
       vesselNum = obj(vi).IMO_Vessel_Number;
       vesselName_ch = ['Vessel ', num2str(vesselNum)];
   end
   
   % Title
   titleStr = [strrep(varname, '_', ' '), ' against Time for ' vesselName_ch];
   title(currAx, titleStr, 'fontsize', titleFontsz);
   
   % Axis tick labels
   datetick(currAx, 'x');
   
%    % Coarings etc
%    if ~isempty(obj(oi).DryDockDates)
end

% Return graphics objects' behaviour to defaults
set(ax_v, 'NextPlot', 'add');