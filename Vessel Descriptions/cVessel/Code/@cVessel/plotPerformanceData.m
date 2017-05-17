function [obj, figHandles, dataLines, avgLines, regrLines ] = plotPerformanceData(obj, varargin)
%plotPerformanceData Plot performance against time, with statistics.
%   figHandles = plotPerformanceData(obj) will return in FIGHANDLES an
%   array of figure handles to graphs containing the data in the
%   corresponding elements of PERFDATA. FIGHANDLES will be the same size as
%   PERFDATA.


% Inputs
dataLines = [];
avgLines = [];
regrLines = [];
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

figHandles = nan(szOut);

% idx_c = cell(1, ndims(obj));
lineColours_m = get(groot, 'defaultAxesColorOrder');
numColours = size(lineColours_m, 1);
DDColourOrder = repmat(1:numColours, [1, ceil(nDDi/numColours)]);

% for ii = 1:nDDi:numel(obj)
figCount = length(findall(0,'type','figure')) + ...
    length(findobj(0,'type','figure'));
while ~obj.iterFinished
   
   [obj, ~, vesselI] = obj.iterVessel;
   figCount = figCount + 1;
   
   currFig = figure;
   currAx = axes('Parent', currFig);
   currVessel = obj(vesselI(1));
   
   % Find indices into input struct
%    [idx_c{:}] = ind2sub(sz, ii);
   
   % Plot each DDi separately
   for ddii = 1:numel(vesselI) % nDDi
       
       ddi = vesselI(ddii);
       
       % Skip DDi if empty
       currData = obj(ddi);
       varname = currData.Variable;
       if obj(ddi).isPerDataEmpty
           continue
       end
      
        avg_l = false;
        numDur = 1;
        if ~isempty(currData.MovingAverages)

            avg_l = true;
            avgStruct = currData.MovingAverages; % varargin{1};
            validateattributes(avgStruct, {'struct'}, {}, 'plotPerformanceData',...
                'avgStruct', 2);
            numDur = numel(avgStruct(1).Duration);
        end

        regr_l = false;
        if ~isempty(currData.Regression)

            regr_l = true;
            regri = 1;
            regrStruct = currData.Regression; %varargin{2};
            validateattributes(regrStruct, {'struct'}, {}, 'plotPerformanceData',...
                'regrStruct', 3);
        end

        % varname = obj.Variable; %'Performance_Index';
       
       % Get data series colour
       currColour = lineColours_m(DDColourOrder(ddii), :);
       
       % Plot data
       hold on
       xdata = currData.DateTime_UTC; % datenum(currData.DateTime_UTC, 'dd-mm-yyyy');
       pi_line = plot(currAx, xdata, ...
           currData.(varname) * 100, 'o', 'Color', currColour);
       hold off
       pi_line.MarkerFaceColor = pi_line.Color;
       
       vesselNum = unique(currVessel.IMO_Vessel_Number);
       
       % Plot averages
       if avg_l
           
           currAvg_st = avgStruct; %(ddi);
           
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
       
       % Plot regressions
       if regr_l
           
           currRegr_st = currData.Regression;
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
                   line(x1, y1,...
                       'Color', currColour,...
                       'LineWidth', 2);
                hold off
                regri = regri + 1;
           end
       end
   end
   
   % Vertical starts at zero
%    oldy = get(currAx, 'YLim'); 
%    set(currAx, 'YLim', [0, oldy(2)]);

   % Put ticks on axis keeping horizontal ticks and limits
%    oldxlim = get(currAx, 'XLim');
%    oldxtick = get(currAx, 'XTick');
   datetick('x');
%    set(currAx, 'XLim', oldxlim); 
%    set(currAx, 'XTick', oldxtick);
   
   % Assign figure handle into outputs
   figHandles(figCount) = currFig;
   
   % Labels
   labFontsz = 12;
   ylabel([strrep(varname, '_', ' '), ' ( % )'], 'fontsize', labFontsz);
   
   titleFontsz = 13;
   vesselName_ch = vesselName(vesselNum);
   if isempty(vesselName_ch)
       vesselName_ch = num2str(vesselNum);
   end
   titleStr = [strrep(varname, '_', ' '), ' against Time for Vessel ' vesselName_ch];
   title(titleStr, 'fontsize', titleFontsz);
   
end
obj = obj.iterReset;