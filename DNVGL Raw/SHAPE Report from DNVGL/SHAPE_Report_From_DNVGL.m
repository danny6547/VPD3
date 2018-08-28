%% Input

imo = 9290086;
activityFileName = '';
filename = 'C:\Users\martu\OneDrive - Hempel Group\Documents\TEMP\TI Hellas\TI Hellas.xlsx';
readfile = true;

%% Create Report

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
obj = obj.inServicePerformance;
obj = obj.plotPerformanceData;
[obj, avgQuarter_st] = obj.movingAverage(365.25/4, true, false, false);
dd = datetime(obj.DryDock(1).End_Date, 'InputFormat', 'yyyy-mm-dd');
if isempty(activityFileName)
    
    [tbl5, idleDD_tbl, ~, speed_tbl] = ...
        obj.activityFromVesselTrackerXLSX(activityFileName, dd);
    stw = speed_tbl.speed;
    dates = speed_tbl.datetime;
    obj.speedHistogram(dates, stw);
    obj.plotSTW(dates, stw);
end