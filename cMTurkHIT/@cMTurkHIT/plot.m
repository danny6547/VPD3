function [ax, h] = plot(obj, varargin)
%plot Plot hydrostatic table
%   Detailed explanation goes here

if nargin > 1 && ~isempty(varargin{1})
    
    ax = varargin{1};
    validateattributes(ax, {'matlab.graphics.axis.Axes'}, {'scalar'},...
        'cMTurkHIT.plot', 'h', 2);
else
    
    ax = gca;
end

filtered = false;
if nargin > 2
    
    filtered = varargin{2};
    validateattributes(filtered, {'logical'}, {'scalar'}, ...
        'cMTurkHIT.plot', 'filtered', 3);
end

% Error if data not loaded
tbl = obj.FileData;
if ~isempty(tbl)
    
    if filtered
        
        tbl = obj.FilteredData;
    end
    
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
        varNames = tbl.Properties.VariableNames;
        nVar = numel(varNames);
        ax = subplot(nVar, 1, 1);
        h = nan(1, nVar);
        for vi = 1:nVar
            
            ax = subplot(nVar, 1, vi);
            currVarName = varNames{vi};
            currVarData = tbl.(currVarName);
            h1 = plot(ax, draft, currVarData, 'Linestyle', 'none',...
                'Marker', '.', 'MarkerSize', 7);
            xlabel(ax, 'Draft (m)');
            ylabel(ax, currVarName);
            h(vi) = h1;
        end
    end
end