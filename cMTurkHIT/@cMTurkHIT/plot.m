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
        lcf = tbl.LCF;
        tpc = tbl.TPC;
        disp = tbl.Displacement;
        ax = subplot(3, 1, 1);
        h1 = plot(ax, draft, disp, 'Linestyle', 'none', 'Marker', '.', 'MarkerSize', 7);
        xlabel(ax, 'Draft (m)');
        ylabel(ax, 'Disp (tn)');
        ax = subplot(3, 1, 2);
        h2 = plot(ax, draft, tpc, 'Linestyle', 'none', 'Marker', '.', 'MarkerSize', 7);
        xlabel(ax, 'Draft (m)');
        ylabel(ax, 'TPC (tn/mc)');
        ax = subplot(3, 1, 3);
        h3 = plot(ax, draft, lcf, 'Linestyle', 'none', 'Marker', '.', 'MarkerSize', 7);
        xlabel(ax, 'Draft (m)');
        ylabel(ax, 'LCF (m)');
        h = [h1, h2, h3];
    end
end