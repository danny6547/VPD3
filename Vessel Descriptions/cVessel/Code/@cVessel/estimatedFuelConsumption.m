function [ obj, savings ] = estimatedFuelConsumption( obj )
%fuelSavings Summary of this function goes here
%   Detailed explanation goes here

% Output
savings_st = struct('Fuel', [], 'Cost', []);
savings = struct('DryDockInterval', savings_st);

% Input
speed2fuel = 3;
consumptionPerDay = 70;
daysPerYear = 365.25;
activity = 0.70;
fuelCost = 350;

% [obj.EstimatedFuelConsumption] = deal(savings_st);
while obj.iterateDD
    
    [~, currVessel, ddi, vi] = obj.currentDD;
%     obj = obj.regressions(1);
    
    currPerf = currVessel.Report.InServicePerformance(ddi);
    if isempty(currPerf)
        continue
    end
    
    marketAverage = 0.059;
    speedDiff = marketAverage - currPerf.InservicePerformance;
    
%     % Second DDi is evaluation, first is reference
%     muRef = 0.059; % nanmean(obj(1).Speed_Index);
%     muEval = obj.Regression.Coefficients(1) * daysPerYear; % nanmean(obj(2).Speed_Index);
    
    fuelSavings = speedDiff * speed2fuel * consumptionPerDay * daysPerYear * activity;
%     annualConsRef = (1 + speed2fuel*marketAverage) * consumptionPerDay * daysPerYear * activity;
%     annualConsEval = (1 + speed2fuel*abs(muEval)) * consumptionPerDay * daysPerYear * activity;
%     fuelSavings = annualConsRef - annualConsEval;
    costSavings = fuelSavings * fuelCost;
    
    savings_st.Fuel = fuelSavings;
    savings_st.Cost = costSavings;
    
    % Assign struct to output
    savings.DryDockInterval(ddi) = savings_st;
    currVessel.Report.EstimatedFuelConsumption(ddi) = savings_st;
end