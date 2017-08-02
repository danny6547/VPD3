% Plot from tmep ISO raw tables for UASC vessels
imo = [ ...
%         9445631 ...   % New Vanguard
%         9434632       % New Success
        9149756
        ];
speedThresh = [...
                0
                11];
windThresh = [...
    7.9,...
    10
    ];
annualDecrease = nan(size(imo));
decrease2Date = nan(size(imo));
inservPerf = nan(size(imo));

coatings = {'X7', ...
            'X7'};

numFilt_m = nan(numel(imo), 5);
propFilt_m = nan(numel(imo), 5);

for vi = 1:numel(imo)
    
    % Instantiate
    obj(vi) = cVessel();
    obj(vi).IMO_Vessel_Number = imo(vi);
    
    % Read table
    currTab = ['temprawiso_', num2str(obj(vi).IMO_Vessel_Number)]; %num2str(imo(vi))];
    minSpeed = speedThresh(vi); % 2.5;
    whereSTW = ['speed_through_water > ', num2str(minSpeed)];
    cols_c = {'speed_loss', 'filter_reference_wind_speed', 'filter_reference_rudder_angle',...
        'filter_reference_water_depth', 'filter_reference_seawater_temp', ...
        'validated', 'filter_speed_below', 'filter_speed_above',...
        'filter_power_below', 'filter_power_above', 'datetime_utc',...
        'speed_through_water', 'relative_wind_speed'};
    tic;
    try [~, tbl] = obj(1).select(currTab, cols_c, whereSTW);
        
    catch ee
        
        continue
    end
    toc;
    
    % Create time vector
    if isempty(tbl)
        continue
    end
    t = tbl.datetime_utc; 
    t_l = cellfun(@(x) length(x) == 10, t); 
    t(t_l) = cellfun(@(x) [x, ' 00:00:00'], t(t_l), 'Uni', 0);
    time_v = datenum(t, 'dd-mm-yyyy HH:MM:SS');
    if all(isnan(time_v))
        continue
    end
    
    % Create filters
    speedNotNull_l = ~isnan(tbl.speed_loss);
    stwPositive_l = tbl.speed_through_water > 0;
    refWind = ~tbl.filter_reference_wind_speed; %tbl.relative_wind_speed >= windThresh(vi);  %
    refRud = ~tbl.filter_reference_rudder_angle;
    refDepth = ~tbl.filter_reference_water_depth;
    refTemp = ~tbl.filter_reference_seawater_temp;
    valid = ~tbl.validated;
    speedInRange_l = ~tbl.filter_speed_below & ~tbl.filter_speed_above;
    powerInRange_l = ~tbl.filter_power_below & ~tbl.filter_power_above;
    speedAboveMin_l = tbl.speed_through_water > speedThresh(vi);
    
    siReasonable_l = tbl.speed_loss < 0.25 & tbl.speed_loss > -0.5;
    filt_l = speedNotNull_l & valid & refWind & refDepth & siReasonable_l; % & powerInRange_l & speedInRange_l;
    
%     % FILTER Time
%     tFilt_l = time_v < datenum('01-Jan-2017', 'dd-mmm-yyyy');
%     time_v = time_v(tFilt_l);
%     filt_l = filt_l(tFilt_l, :);
    
    tempFilt_m = [speedNotNull_l,  valid,  refWind,  refDepth, siReasonable_l]; %,  powerInRange_l,  speedInRange_l];
    numFilt_m(vi, :) = sum(~tempFilt_m, 1);
    propFilt_m(vi, :) = sum(~tempFilt_m, 1)./size(tempFilt_m, 1);
    
    % Assign to props
    obj(vi).DateTime_UTC = time_v(filt_l);
    obj(vi).Speed_Index = 1 + tbl.speed_loss(filt_l);
    obj(vi) = obj(vi).movingAverages(365.25, false, true);
    obj(vi) = obj(vi).regressions(1);
    
    % Generate plots
    [obj(vi), ~, currLine] = obj(vi).plotPerformanceData();
    
%     Save
%     saveas(gcf, [num2str(imo(vi)), '.fig']);
%     saveas(gcf, [num2str(imo(vi)), '.png']);
    
    % Append to table
    annualDecrease(vi) = obj(vi).Regression.Coefficients(1) * 365.25 * 1e2;
    obj(vi) = obj(vi).inServicePerformance();
    obj(vi) = obj(vi).serviceInterval('days');
    if isstruct(obj(vi).ServiceInterval)
        decrease2Date(vi) = annualDecrease(vi) * ...
            obj(vi).ServiceInterval.Duration / 365.25;
    end
    if isstruct(obj(vi).InServicePerformance)
        inservPerf(vi) = - (obj(vi).InServicePerformance(1).Average - ...
            obj(vi).InServicePerformance(2).Average) * 1e2;
    end
%     % Write coating into graphs
%     currCoating = coatings{vi};
%     currColor = get(currLine, 'Color');
%     currColor(2:3) = currColor(2:3) - 0.2;
%     str = [currCoating, ', ', num2str(annualDecrease(vi)), ' %'];
%     text(0.15, 0.15, str, 'Units', 'Normalized', 'FontSize', 12, ...
%         'FontWeight', 'bold', 'Color', currColor);
    
    str = [num2str(vi), ': ', num2str(imo(vi)), '. '];
    disp(str);
end