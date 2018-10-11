%% Input

imo = [];
activityFileName = '';
filename = '';
readfile = true;
consumptionPerDay = [];
costOfFuel = [];

%% Get Data

% Get Vessel from SHAPE
obj = cVessel('SavedConnection', 'hullperformance');
obj.IMO = imo;

% Connect to local DNVGL DB
objdnv = cVessel('SavedConnection', 'dnvgl');
if readfile
    objdnv = objdnv.loadDNVGLPerformance(filename, imo);
end

% Read data from local DNVGL DB into object
imo_ch = num2str(imo);
[~, dnvtbl] = objdnv.SQL.select('PerformanceData', ...
        {'date_format(DateTime_UTC, ''%Y-%m-%d %T.%f'') AS Timestamp',...
                            'Performance_Index', 'Speed_Index'},...
        ['IMO_Vessel_Number = ', imo_ch]);
obj.InService = dnvtbl;

% Do report stuff
obj.Variable = 'speed_index';
dd = datetime(obj.DryDock(1).End_Date, 'InputFormat', 'yyyy-mm-dd');
if~isempty(activityFileName)
    
    [tbl5, idleDD_tbl, ~, speed_tbl] = ...
        obj.activityFromVesselTrackerXLSX(activityFileName, dd, true);
    stw = speed_tbl.speed;
    dates = speed_tbl.datetime;
    obj.speedHistogram(dates, stw);
    obj.plotSTW(dates, stw, false);
end

%% Create Report
report = obj.Report;
act = tbl5.Actual_in_DD_interval(2);

obj = obj.plotPerformanceData;
obj.applySHAPEPlotFormat;
[report, tbl2] = report.performanceTable(obj, consumptionPerDay, costOfFuel, act);
[report, tbl3] = report.coatingTable(obj);
[report, tbl4] = report.shipDataTable(obj);
[report, tbl6] = report.dataInformationTable(obj);