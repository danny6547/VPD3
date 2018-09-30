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

% Plot all dry dock intervals for each vessel
sz = size(obj);
nDDi = sz(1);
if ismatrix(obj)
    szOut = [1, sz(2)];
else
    szOut = sz(2:end);
end

% figHandles = nan(szOut);

lineColours_m = get(groot, 'defaultAxesColorOrder');
numColours = size(lineColours_m, 1);
DDColourOrder = repmat(1:numColours, [1, ceil(nDDi/numColours)]);

nFigs = numel(obj);
figHandles = arrayfun(@(x) figure, nan(1, nFigs), 'Uni', 0);
figHandles = [figHandles{:}];
ax_c = arrayfun(@(x) axes('Parent', x), figHandles, 'Uni', 0);
ax_v = [ax_c{:}];
set(ax_v, 'NextPlot', 'add');

while obj.iterateDD
   
    [currDD_tbl, currVessel, ddi, vi] = obj.currentDD;
    currAx = ax_v(vi);

    % Skip DDi if empty
    varname = currVessel.InServicePreferences.Variable;
    if currVessel.isPerDataEmpty(ddi)
       continue
    end

    avg_l = false;
    numDur = 1;
    if ~isempty(currVessel.Report(ddi).MovingAverage)

        avg_l = true;
        avgStruct = currVessel.Report(ddi).MovingAverage; % varargin{1};
        validateattributes(avgStruct, {'struct'}, {}, 'plotPerformanceData',...
            'avgStruct', 2);
        numDur = numel(avgStruct(1).Duration);
    end

    regr_l = false;
    if ~isempty(currVessel.Report(ddi).Regression)

        regr_l = true;
        regri = 1;
        regrStruct = currVessel.Report(ddi).Regression; %varargin{2};
        validateattributes(regrStruct, {'struct'}, {}, 'plotPerformanceData',...
            'regrStruct', 3);
    end

    % Get data series colour
    currColour = lineColours_m(DDColourOrder(ddi), :);

    % Plot data
    xdata = currDD_tbl.timestamp;
    convFact = 1;
    if ismember(varname, {'speed_loss', 'speed_index'})
       convFact = 1e2;
    end
    ydata = currDD_tbl.(varname) * convFact;
    pi_line = line(currAx, xdata, ydata);
    pi_line.LineStyle = 'none';
    pi_line.Marker = 'o';
    pi_line.Color = currColour;
    pi_line.MarkerFaceColor = pi_line.Color;
    dataLines(end+1) = pi_line;

    % Plot averages
    if avg_l

%        currAvg_st = avgStruct(ddi);

       % Make average colors a series of increasingly light orange
       whiteLimit = 0.8;
       avgColours = [ones(numDur, 1), linspace(0.5, whiteLimit, numDur)',...
           linspace(0, whiteLimit, numDur)'];

       for di = 1:numDur

           currDur = avgStruct.Duration(di);
           currStart = currDur.StartDate;
           currEnd = currDur.EndDate;
           currAvg = currDur.Average * convFact;

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

           hold off
       end
    end

    % Plot regressions
    if regr_l

       for oi = 1:numel(currVessel.Report(ddi).Regression)

           currRegr_st = currVessel.Report(ddi).Regression(oi);
           coeffs = currRegr_st.Coefficients;

           % Figure out plotting any order later...
           if numel(coeffs) == 2

                m = coeffs(1);
                c = coeffs(2);

                x1 = linspace(min(xdata), max(xdata), 1e3);
                y1 = ( m*x1 + c ) * convFact;

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
end

for vi = 1:nFigs
    
   currAx = ax_v(vi);
   
   % Labels
   labFontsz = 12;
   varname = obj(vi).InServicePreferences.Variable;
   ylabel(currAx, [strrep(varname, '_', ' '), ' ( % )'], 'fontsize', labFontsz);
   
   % Get vessel name
   titleFontsz = 13;
   vesselName_ch = obj(vi).Name;
   if isempty(vesselName_ch)
       vesselNum = obj(vi).IMO;
       vesselName_ch = ['Vessel ', num2str(vesselNum)];
   end
   
   % Title
   titleStr = [strrep(varname, '_', ' '), ' against Time for ' vesselName_ch];
   title(currAx, titleStr, 'fontsize', titleFontsz);
   
   % Axis tick labels
   datetick(currAx, 'x');
end

% Return graphics objects' behaviour to defaults
set(ax_v, 'NextPlot', 'add');