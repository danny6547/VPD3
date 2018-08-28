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
    
    properties(Hidden)
    
        PerformanceTable;
    end
    
    methods
    
       function obj = cVesselReport(varargin)
            
           obj = obj@cMySQL(varargin{:});
       end
       
       function [obj, tbl] = performanceTable(obj, cv, varargin)
           
           % Get In-service perf
           [~, ins] = cv.inServicePerformance;
           val = ins.DryDockInterval(end).InservicePerformance;
           ins_ch = sprintf('%3.2f%%', val*1e2);
           
           % Get DD Improvement
           [~, ddimp] = cv.dryDockingImprovement;
           val = ddimp.DryDockingInterval(end).AbsDDImprovement;
           imp_ch = sprintf('%3.2f%%', val*1e2);
           
           % Get Savings estimate
           [~, savings] = cv.estimatedFuelConsumption(varargin{:});
           fuel = savings.DryDockInterval(end).Fuel;
           fuelpc = savings.DryDockInterval(end).Fuelpc*1e2;
           jf=java.text.DecimalFormat;
           jfdec = get(jf, 'DecimalFormatSymbols');
           set(jfdec, 'GroupingSeparator', ',');
           set(jf, 'DecimalFormatSymbols', jfdec);
           fuel_ch = char(jf.format(fuel));
           fuel_ch = [fuel_ch, ' $'];
           fuelPC_ch = sprintf(' (%3.2f%%)', fuelpc);
           fuel_ch = [fuel_ch, fuelPC_ch];
           
           co2 = savings.DryDockInterval(end).CO2;
           co2_ch = char(jf.format(co2));
           co2_ch = [co2_ch, ' tn'];
           
           % Get last quarter average
           [~, avgQuarter_st] = cv.movingAverage(365.25/4, true, false, false);
           val = avgQuarter_st.DryDockInterval.Average(end);
           avgQuart_ch = sprintf('%3.2f%%', val*1e2);
           
           % Get average
           [~, avg_st] = cv.movingAverage(10*365);
           val = avg_st.DryDockInterval.Average;
           avg_ch = sprintf('%3.2f%%', val*1e2);
           
           % Get text for savings assumptions
           leg_ch = ['*Input:', sprintf(' %u%% activity, ', varargin{3}),...
               'daily fuel cons.', sprintf(' %u tonnes/day, ', varargin{1}),...
               'bunker price', sprintf(' %u USD/ton', varargin{2})];
           
           % Create table
           tbl = cell2table({ins_ch; imp_ch; avg_ch; avgQuart_ch; fuel_ch;...
               co2_ch; leg_ch}, ...
                'VariableNames', {'Value'},...
                'RowNames', {'In-Service Performance (preliminary)',...
                            'Dry-Docking Improvement', ...
                            'Average Speed Loss', ...
                            'Average Speed Loss in last Quarter', ...
                            'Estimated Fuel Savings Compared to Market Average*',...
                            'Estimated CO2 Savings Compared to Market Average*',...
                            '.'
                            });
           obj.PerformanceTable = tbl;
       end
       
       function tbl = coatingsTable(cv)
           
           
           
       end
       
       function tbl = shipDataTable(cv)
           
           
       end
       
       function tbl = dataInformationTable(cv)
           
           
       end
    end
end