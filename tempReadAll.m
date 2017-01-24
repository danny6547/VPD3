allIMO = [9454448 9454450 9450648 9410765 9280603 9450624 9674517 9410791 9705055 9454436 9198288 9457737 9455870 9198276 9516117 9537745 9377420 9398084];

fig_h = [];
for si = 1:length(allIMO)
    out = performanceData(allIMO(si), 0);
    avgStruct = movingAverages(out, [365.25], true', true);
    fig_h(si) = plotPerformanceData(out, avgStruct);
    
    
    for oi = 1:length(out)
        try x = datenum(out(oi).Date, 'dd-mm-yyyy');
            y = out(oi).Performance_Index;

            allNan = isnan(x) | isnan(y);
            x(allNan) = [];
            y(allNan) = [];

            p = polyfit(x, y, 1);
            c = p(2);
            m = p(1);

            x1 = linspace(min(x), max(x), 1e3);
            y1 = m*x1 + c;
            y1 = y1.*100;

            % Get figure to plot into
            % [r, c] = ind2sub(size(out), si);
            hold on;
            plot(x1, y1, 'b--', 'LineWidth', 1.5);
            hold off;

        catch ee

        end
    end
end

% % Regression Lines
% for si = 1:numel(out)
%     
%     x = out.Date;
%     y = out.Performance_Index;
%     
%     p = polyfit(x, y, 1);
%     m = p(2);
%     c = p(1);
%     
%     x1 = linspace(min(x), max(x), 1e3);
%     y1 = m*x1 + c;
%     
%     % Get figure to plot into
%     [r, c] = ind2sub(size(out), si);
%     
%     figure(figi);
%     
% end