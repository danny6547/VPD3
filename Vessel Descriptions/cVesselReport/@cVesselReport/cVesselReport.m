classdef cVesselReport
    %CVESSELREPORT Data used in reporting and visualisation
    %   Detailed explanation goes here
    
    properties
        
        Variable char = '';
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
        CoatingTable;
    end
    
    methods
    
       function obj = cVesselReport(varargin)
            
           if nargin > 0
               
               sz = varargin{1};
               obj_c = cell(sz);
               obj_c = cellfun(@(x) cVesselReport, obj_c, 'Uni', 0);
               obj = [obj_c{:}];
               obj = reshape(obj, sz);
           end
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
           if ~isempty(fuel)
               fuelpc = savings.DryDockInterval(end).Fuelpc*1e2;
               jf=java.text.DecimalFormat;
               jfdec = get(jf, 'DecimalFormatSymbols');
               set(jfdec, 'DecimalSeparator', '.');
               set(jfdec, 'GroupingSeparator', ',');
               set(jf, 'DecimalFormatSymbols', jfdec);
               set(jf, 'MaximumFractionDigits', 0);
               fuel_ch = char(jf.format(fuel));
    %            fuel_ch(end-2:end) = [];
               fuel_ch = [fuel_ch, ' $'];
               fuelPC_ch = sprintf(' (%3.2f%%)', fuelpc);
               fuel_ch = [fuel_ch, fuelPC_ch];
              
               co2 = savings.DryDockInterval(end).CO2;
               co2_ch = char(jf.format(co2));
               co2_ch = [co2_ch, ' tn'];
           else
               
               fuel_ch = '';
               co2_ch = '';
           end
           
           
           % Get last quarter average
           [~, avgQuarter_st] = cv.movingAverage(365.25/4, true, false, false);
           val = avgQuarter_st.DryDockInterval.Average(end);
           avgQuart_ch = sprintf('%3.2f%%', val*1e2);
           
           % Get average
           [~, avg_st] = cv.movingAverage(10*365);
           val = avg_st.DryDockInterval.Average;
           avg_ch = sprintf('%3.2f%%', val*1e2);
           
           % Get text for savings assumptions
           leg_ch = ['*Input:', sprintf(' %2.0f%% activity, ', varargin{3}),...
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
       
       function [obj, tbl] = coatingTable(obj, cv)
           
           dd = cv.DryDock(end);
           if isempty(dd)
               
               tbl = table();
               return
           end
           
           coating_c = cell(2, 3);
           coating_c{1, 1} = dd.Bot_Top_Coating;
           coating_c{2, 1} = dd.Bot_Top_Surface_Prep;
           coating_c{1, 2} = dd.Vertical_Bottom_Coating;
           coating_c{2, 2} = dd.Vertical_Bottom_Surface_Prep;
           coating_c{1, 3} = dd.Flat_Bottom_Coating;
           coating_c{2, 3} = dd.Flat_Bottom_Surface_Prep;
           
           tbl = cell2table(coating_c, 'VariableNames', ...
               {'Boottop', 'Vertical_Bottom', 'Flat_Bottom'}, 'RowNames', ...
               {'Coating_Type', 'Surface_Preparation'});
           obj.CoatingTable = tbl;
       end
       
       function [obj, c] = shipDataTable(obj, cv)
           
           dd = cv.DryDock(end);
           if isempty(dd)
               
               c = cell();
               return
           end
           
           c = {'Build date:', '', 'Date of last dry docking:', dd.End_Date};
           c = sprintf('%s ', c{:});
           obj.CoatingTable = c;
       end
       
       function [obj, ins, ref] = dataInformationTable(obj, cv)
           
           vid_ch = num2str(cv.Vessel_Id);
           [~, type_tbl] = cv.SQL.select('ImportJob', {'Type', 'Frequency'},...
               ['Vessel_Id = ' vid_ch], 1);
           type_tbl.Uncertainty = {''};
           ins = cell2table([type_tbl{:, :}], ...
               'VariableNames', {'Type', 'Frequency', 'Uncertainty'},...
               'RowNames', {'In service data'});
           ref = table();
       end
    end
    
%     methods(Hidden)
%         
%         function log = isempty(obj)
%             
%             [~, sqlInput_c] = obj.connectionData;
%             emptyReport = cVesselReport(sqlInput_c{:});
%             emptyReport.Variable = obj.Variable;
%             log = isequal(obj, emptyReport);
%         end
%     end
end