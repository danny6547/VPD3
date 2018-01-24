obj = cVessel('IMO', [9280603, 9410791]);

obj = obj.regression(1);
obj = obj.movingAverage(365.25);

filename = ['L:\Project\MWB-Fuel efficiency\Hull and propeller performance'...
    '\Vessels\CMA CGM\Seaweb\seaweb.txt'];
obj = obj.activityFromSeaWeb(filename);

obj = obj.dryDockingImprovement;
obj = obj.annualSavingsDD;
obj = obj.serviceInterval;
obj = obj.guaranteeDurations;
obj = obj.performanceMark;
obj = obj.inServicePerformance;
obj = obj.estimatedFuelConsumption;

obj = obj.rawData;