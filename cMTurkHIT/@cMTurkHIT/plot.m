function [ax, h] = plot(obj, varargin)
%plot Plot hydrostatic table
%   Detailed explanation goes here

% Check if data filtered first to get appropriate data for axes input
filtered = false;
if nargin > 2
    
    filtered = varargin{2};
    validateattributes(filtered, {'logical'}, {'scalar'}, ...
        'cMTurkHIT.plot', 'filtered', 3);
end
if filtered

    tbl = obj.FilteredData;
else

    tbl = obj.FileData;
end

% Find number of plots required
varNames = tbl.Properties.VariableNames;
nVar = numel(varNames);
maxPlotsPerFig = 3;
if nargin > 1 && ~isempty(varargin{1})
    
    ax = varargin{1};
    validateattributes(ax, {'matlab.graphics.axis.Axes'}, {},...
        'cMTurkHIT.plot', 'ax', 2);
    
    % If axis input, assume that number of axes matches number of variables
    % required
    if numel(ax) ~= nVar
        
        errid = 'cMTurkPlot:AxesVariableSizeMismatch';
        errmsg = ['If input AX is given, it must have as many elements '...
            'as there are variables in OBJ.'];
        error(errid, errmsg);
    end
else
    
    if obj.IsGrid
        
        ax = gca;
    else
        
        % Generate figures and axes
        [~, ax] = genFigsAxes(nVar, maxPlotsPerFig);
    end
end

% Error if data not loaded
if ~isempty(tbl)
    
    if obj.IsGrid
        
        draft = tbl.Draft;
        trim = tbl.Trim;
        disp = tbl.Displacement;
        plot3(ax, draft, trim, disp, '*');
        xlabel(ax, 'Draft (m)');
        ylabel(ax, 'Trim (m)');
        zlabel(ax, 'Displacement (tn)');
    else
        
        draft = tbl.Draft;
        h = nan(1, nVar);
        for vii = 1:nVar
            
            currAx = ax(vii);
            currVarName = varNames{vii};
            currVarData = tbl.(currVarName);
            h1 = plot(currAx, draft, currVarData, 'Linestyle', 'none',...
                'Marker', '.', 'MarkerSize', 7);
            xlabel(currAx, 'Draft (m)');
            ylabel(currAx, currVarName);
            h(vii) = h1;
        end
    end
end

function [fig, ax] = genFigsAxes(nVar, maxPlotsPerFig)

    nFig = ceil(nVar/maxPlotsPerFig);
    fig = arrayfun(@(x) figure, nan(1, nFig));
    ax = arrayfun(@(x) axes, nan(1, nFig));
    
    axi = 1;
    for vi = 1:nVar
        
        currFig = ceil(vi/3);
        ax(vi) = subplot(maxPlotsPerFig, 1, axi, 'Parent', fig(currFig));
        axi = axi + 1;
        if axi == 4
            axi = 1;
        end
    end
end
end