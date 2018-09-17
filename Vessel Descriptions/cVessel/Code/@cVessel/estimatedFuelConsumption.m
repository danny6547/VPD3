function [obj, savings] = estimatedFuelConsumption(obj, varargin)
%fuelSavings Summary of this function goes here
%   Detailed explanation goes here

% Output
savings_st = struct('Fuel', [], 'Fuelpc', [], 'Cost', [], 'CO2', [],...
                                        'FuelPenalty', [],...
                                        'FuelPenaltyMarket', []);
savings = struct('DryDockInterval', savings_st);

% Input
speed2fuel = 3;
daysPerYear = 365.25;

consumptionPerDay = 70;
if nargin > 1
    
    consumptionPerDay = varargin{1};
    validateattributes(consumptionPerDay, {'numeric'}, {'scalar', 'positive', 'real'}, ...
        'cVessel.estimatedFuelConsumption', 'consumptionPerDay', 2);
end

fuelCost = 350;
if nargin > 2
    
    fuelCost = varargin{2};
    validateattributes(fuelCost, {'numeric'}, {'scalar', 'positive', 'real'}, ...
        'cVessel.estimatedFuelConsumption', 'fuelCost', 3);
end

activityInput_l = false;
if nargin > 3 && ~isempty(varargin{3})
    
    activityInput_l = true;
    activity = varargin{3};
    validateattributes(activity, {'numeric'}, {'scalar', 'positive', 'real'}, ...
        'cVessel.estimatedFuelConsumption', 'activity', 4);
end

siliconeCoating_l = false;
if nargin > 4
    
    siliconeCoating_l = varargin{4};
    validateattributes(siliconeCoating_l, {'logical'}, {'scalar'}, ...
        'cVessel.estimatedFuelConsumption', 'siliconeCoating', 5);
end

% Get activity
if ~activityInput_l
    obj = obj.activity;
end
obj = obj.serviceInterval('days');

% Get in-service performance
obj = obj.inServicePerformance;

% [obj.EstimatedFuelConsumption] = deal(savings_st);
while obj.iterateDD
    
    [~, currVessel, ddi, vi] = obj.currentDD;
%     obj = obj.regressions(1);
    
    if isempty(currVessel.Report(ddi).InServicePerformance) % numel(currVessel.Report.InServicePerformance) < ddi %isempty(currPerf)
        continue
    end
    
    % Get current activity
    if ~activityInput_l
        activity = currVessel.Report(ddi).Activity;
    end
    
%     currPerf = currVessel.Report.InServicePerformance(ddi);
%     marketAverage = 0.059;
%     speedDiff = marketAverage - currPerf.InservicePerformance;
    
%     % Second DDi is evaluation, first is reference
%     muRef = 0.059; % nanmean(obj(1).Speed_Index);
%     muEval = obj.Regression.Coefficients(1) * daysPerYear; % nanmean(obj(2).Speed_Index);
%     fuelSavings = speedDiff * speed2fuel * consumptionPerDay * daysPerYear * activity;
    
    speedloss_ma = 0.059;
    siliconeEffect = 0.06;
    inservice = currVessel.Report(ddi).ServiceInterval.Duration;
    speedloss_act = currVessel.Report(ddi).InServicePerformance.InservicePerformance;
    fuelSavings = consumptionPerDay*activity * ((inservice - daysPerYear)*(speed2fuel*speedloss_ma - speed2fuel*speedloss_act) + siliconeCoating_l*siliconeEffect*inservice);
    fuelCons_ma = consumptionPerDay*activity*(speed2fuel*speedloss_ma*(inservice - daysPerYear) + inservice);
    fuelCons_act = consumptionPerDay*activity*(speed2fuel*speedloss_act*(inservice - daysPerYear) + inservice); % + siliconeCoating_l*siliconeEffect*inservice);
%     annualConsRef = (1 + speed2fuel*marketAverage) * consumptionPerDay * daysPerYear * activity;
%     annualConsEval = (1 + speed2fuel*abs(muEval)) * consumptionPerDay * daysPerYear * activity;
%     fuelSavings = annualConsRef - annualConsEval;
    costSavings = fuelSavings * fuelCost;
    
    switch currVessel.FuelType
        
        case 'HFO'
            
            CO2convfact = 3.11440;
    end
    
    co2Savings = fuelSavings * CO2convfact;
    fuel_ma = consumptionPerDay*inservice*(speedloss_ma*speed2fuel)*activity;
    fuel_pc = fuelSavings/fuelCons_ma * 100; %((fuelCons_ma - fuelSavings) / fuelCons_ma) * 100;
    
    savings_st.Fuel = fuelSavings;
    savings_st.Fuelpc = fuel_pc;
    savings_st.Cost = costSavings;
    savings_st.CO2 = co2Savings;
    savings_st.FuelPenalty = fuelCons_act * fuelCost;
    savings_st.FuelPenaltyMarket = fuelCons_ma * fuelCost;
    
    % Assign struct to output
    savings(vi).DryDockInterval(ddi) = savings_st;
    currVessel.Report(ddi).EstimatedFuelConsumption = savings_st;
end