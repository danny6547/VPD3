function [obj, his, avg] = speedHistogram(obj, varargin)
%speedHistogram Create histograms of speed through water of the vessel
%   [obj, figHandles] = speedHistogram(obj) returns in his the handles to 
%   histograms representing the distribution of the speed through water of
%   the vessel in the most recent dry docking interval (in the first
%   element) and in the last quarter of that interval (in the second
%   element).

% Inputs
mps2knots = 1.943844;
avg = nan(1, 2);
% 
% if nargin > 1
%     
%     dates_v = varargin{1};
%     stw = varargin{2};
%     
% else

%     obj = obj.rawData();

while obj.iterateDD

    currDD_tbl = obj.currentDD;

    dates_v = currDD_tbl.timestamp;
    stw = currDD_tbl.speed_through_water*mps2knots;
    % end

    % Divide into quarters
    oneQuarter = 365.25/4;
    oneQuarterBack = max(dates_v) - oneQuarter;
    lastQuart_l = dates_v >= oneQuarterBack;
    stwQuart = stw(lastQuart_l);

    % Average speeds
    avg(1) = nanmean(stw);
    avg(2) = nanmean(stwQuart);

    % Plots
    binEdges = 1:4:25;

    figure();
    his(1) = histogram(stw, binEdges, 'Normalization', 'probability');
    figure();
    his(2) = histogram(stwQuart, binEdges, 'Normalization', 'probability');

    ax = [his.Parent];
    % title(ax(1), 'Speed Histogram', 'Fontweight', 'Normal', 'Fontsize', 9)
    % title(ax(2), 'Speed Histogram', 'Fontweight', 'Normal', 'Fontsize', 9)

    set(ax, 'XTick', [binEdges, 29]);
    set(ax, 'XTick', [binEdges, 29]);
    set(his, 'FaceAlpha', 1);
    set(his, 'FaceColor', [0.95, 0.2, 0.2]);
    set(his, 'EdgeColor', [1, 1, 1]);
    set(his, 'LineWidth', 0.1);
    set(ax, 'YLim', [0, 1]);
    set(ax, 'XLim', [0, 29]);
    set(ax, 'YTick', 0:0.2:1);
    set(ax, 'YTickLabel', 0:20:100);
    set(ax, 'XTick', 3:4:29);
    set(ax, 'XTicklabel', {'1 - 5', '5 - 9', '9 - 13', '13 - 17', '17 - 21',...
        '21 - 25', '> 25'});
    set(ax, 'XGrid', 'on');
    set(ax, 'YGrid', 'on');
    set(ax, 'XTickLabelRotation', 45);

    fig = get(ax, 'Parent');
    fig = [fig{:}];
    set(fig, 'Color', [1, 1, 1]);
    set(fig, 'Units', 'Normalized', 'Position', [0.5, 0.5, 0.12, 0.16]);

    set(ax, 'FontSize', 8);
    set(ax, 'Box', 'off');
end