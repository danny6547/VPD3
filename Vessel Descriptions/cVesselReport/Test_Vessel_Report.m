% Load in vessel data into static from files, not require access to DB
% Set up
imo_v = [9036442
        9280603
        9500728];
obj = cVessel('DatabaseStatic', 'static',...
            'DatabaseInService', 'hullperformance',...
            'IMO', imo_v);

% Execute each report method
filename = fullfile(fileparts(mfilename('fullpath')), 'all_analytics.xlsx');
dd = datetime(2017, 6, 5);
tbl = obj.activityFromVesselTrackerXLSX(filename, dd);
obj = obj.activity();
obj = obj.annualSavingsDD();
obj = obj.DDPer();
obj = obj.dryDockingImprovement();
obj = obj.dryDockingPerformance();
obj = obj.estimatedFuelConsumption(70, 350, 0.8);
obj = obj.guaranteeDurations();
obj = obj.inServicePerformance();
obj = obj.maintenanceTrigger();
obj = obj.movingAverage(365.25);
obj = obj.movingAverage(365.25, true);
obj = obj.movingAverage(365.25, true, true);
obj = obj.movingAverage(365.25, true, true, true);
obj = obj.performanceMark();
obj = obj.regression(1);
obj = obj.serviceInterval();
obj = obj.plotPerformanceData();
obj.applySHAPEPlotFormat();
obj = obj.speedHistogram();