%% Input

imo = 9732565;
activityFileName = '';
obj = cVessel('SavedConnection', 'hullperformance');
filename = '\\hempelgroup.sharepoint.com@SSL\DavWWWRoot\sites\HullPerformanceManagementTeam\Vessel Library\Euronav\Time series data\Aquitaine\EI2123 Speed deviation - Single vessel timeline.xlsx';
obj = obj.loadDNVGLPerformance(filename, imo);

%% Create Report

% Get Vessel from SHAPE
obj.IMO = imo;

% Connect to local DNVGL DB
objdnv = cVessel('SavedConnection', 'dnvgl');

% Read data from local DNVGL DB into object
imo_ch = num2str(9732565);
[~, dnvtbl] = objdnv.SQL.select('PerformanceData', ...
        {'date_format(DateTime_UTC, ''%Y-%m-%d %T.%f'') AS Timestamp',...
                            'Performance_Index', 'Speed_Index'},...
        ['IMO_Vessel_Number = ', imo_ch]);
obj.InService = dnvtbl;

% Do report stuff
obj.Variable = 'speed_index';
obj = obj.inServicePerformance;
obj = obj.plotPerformanceData;
[obj, avgQuarter_st] = obj.movingAverage(365.25/4, true, false, false);
dd = datetime(obj.DryDock(1).End_Date, 'InputFormat', 'yyyy-mm-dd');
[tbl5, idleDD_tbl, ~, speed_tbl] = obj.activityFromVesselTrackerXLSX(activityFileName, dd);
stw = speed_tbl.speed;
dates = speed_tbl.datetime;
obj.speedHistogram(dates, stw);
obj.plotSTW(dates, stw);