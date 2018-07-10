function [ax, h] = plot(obj, varargin)
%plot Plot hydrostatic table
%   Detailed explanation goes here

if nargin > 1
    
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
    else
        
        draft = tbl.Draft;
        lcf = tbl.LCF;
        tpc = tbl.TPC;
        disp = tbl.Displacement;
        ax = subplot(2, 1, 1);
        [~, h1, h2] = plotyy(ax, draft, disp, draft, tpc);
        set(h1, 'Color', 'b', 'Linestyle', '--');
        set(h2, 'Color', 'r', 'Linestyle', '-');
        ax = subplot(2, 1, 1);
        h3 = plot(ax, draft, lcf, 'Color', 'm', 'Linestyle', ':');
        h = [h1, h2, h3];
    end
end