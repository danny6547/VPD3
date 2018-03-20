classdef cVesselReport < cMySQL
    %CVESSELREPORT Data used in reporting and visualisation
    %   Detailed explanation goes here
    
    properties
        
        MovingAverage = [];
        Regression = [];
        ServiceInterval = struct('Duration', [], 'Units', [],...
                                'StartDate', [], 'EndDate', []);
        GuaranteeDurations = struct('StartMonth', [1, 13, 13, 13, 13], ...
                    'EndMonth', 12:12:60, ...
                    'Average', [], ...
                    'Difference', [], ...
                    'RelativeDifference', []);
        PerformanceMark = struct('PerformanceMark', '');
        DryDockingPerformance = struct('DDPerformance', [], ...
                                        'ReferenceAverage', [], ...
                                        'EvaluationAverage', [], ...
                                        'ReferenceDuration', [], ...
                                        'EvaluationDuration', []);
        InServicePerformance = struct('InservicePerformance', [],...
                                        'ReferenceDuration', [],...
                                        'ReferenceValue', [],...
                                        'EvaluationDuration', [],...
                                        'EvaluationValue', []);
        MaintenanceTrigger = struct('MaintenanceTrigger', [], ...
                                    'ReferenceAverage', [], ...
                                    'EvaluationAverage', [], ...
                                    'ReferenceDuration', [], ...
                                    'EvaluationDuration', []);
        DryDockingImprovement = struct('AvgPerPrior', [],...
                                        'AvgPerAfter', [], ...
                                        'AbsDDImprovement', [],...
                                        'RelDDImprovement', [],...
                                        'ReferenceCount', [],...
                                        'EvaluationCount', []);
        AnnualSavingsDD = struct('Savings_MUSD', [], 'Savings_mt', []);
        EstimatedFuelConsumption = struct('Fuel', [],...
                                        'Fuelpc', [],...
                                        'Cost', [],...
                                        'CO2', [],...
                                        'FuelPenalty', [],...
                                        'FuelPenaltyMarket', []);
        Activity double = nan;
    end
    
    methods
    
       function obj = cVesselReport()
            
       end
    end
end